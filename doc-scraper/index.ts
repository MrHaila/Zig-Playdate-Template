import fs from "node:fs/promises"
import path from "node:path"
import { JSDOM } from "jsdom"

/**
 * @fileoverview Scrape the HTML documentation of the Playdate C API and update the Zig doc comments in the bindings file.
 */

// Error out if the Playdate SDK env var is not set.
if (!process.env.PLAYDATE_SDK_PATH) {
	console.error("The PLAYDATE_SDK_PATH environment variable is not set.")
	process.exit(1)
}

// Resolve path to the Playdate SDK folder.
const playdateSDK = path.resolve(process.env.PLAYDATE_SDK_PATH)

// Load the HTML file from the Playdate SDK folder installed locally.
const html = await fs.readFile(
	path.join(playdateSDK, "Inside Playdate with C.html"),
	"utf-8",
)

// Also load the SDK version.
const sdkVersion = (
	await fs.readFile(path.join(playdateSDK, "VERSION.txt"), "utf-8")
).trim()

// Check the latest SDK version by visiting the https://sdk.play.date/ page and reding the version from the redirected URL.
// The URL is like https://sdk.play.date/2.4.0/ and the version is the last part of the URL.
const latestSdkVersion = await fetch("https://sdk.play.date/").then((res) => {
	const url = new URL(res.url)
	return url.pathname.slice(1, -1)
})

// Warn if the SDK version is not the latest.
if (sdkVersion !== latestSdkVersion) {
	console.warn(
		`The latest SDK version is ${latestSdkVersion} and you are using ${sdkVersion}. The generated types will be based on the ${sdkVersion} SDK.`,
	)
}

/** 
 * Example HTML structure.
 * 
	<div id="f-sound.setMicCallback" class="openblock item function">
	<div class="title">void playdate->sound->setMicCallback(AudioInputFunction* callback, void* context, int forceInternal)</div>
	<div class="content">
	<div class="paragraph">
	<p>The <em>callback</em> you pass in will be called every audio cycle.</p>
	</div>
	<div class="literalblock">
	<div class="title">AudioInputFunction</div>
	<div class="content">
	<pre>int AudioInputFunction(void* context, int16_t* data, int len)</pre>
	</div>
	</div>
	<div class="paragraph">
	<p>Your input callback will be called with the recorded audio data, a monophonic stream of samples. The function should return 1 to continue recording, 0 to stop recording. If <em>forceInternal</em> is set, the device microphone is used regardless of whether the headset has a microphone.</p>
	</div>
	</div>
	</div>
 * */

// Use JSDOM to parse the HTML.
const dom = new JSDOM(html)
const functions: { name: string; description: string }[] = []

// Find all the divs with an id starting with "f-"
const functionElements = dom.window.document.querySelectorAll("div[id^='f-']")

// Loop through all the function elements and extract the name and description.
for (const element of functionElements) {
	// Infer the function name from the id.
	const name = element.id.slice(2)

	// Parse the function description from the content. This could use some more love.
	let description =
		element
			.querySelector(".content")
			?.textContent?.trim()
			.replaceAll("\t", "")
			.replaceAll("\n", " ") ?? // This does not work great as there are formatted boxes in the HTML leave junk behind.
		`No official documentation as of SDK version ${sdkVersion}` // Fallback for if the description is not found.

	// Add docs link to the description.
	const docsLink = `https://sdk.play.date/${sdkVersion}/Inside%20Playdate%20with%20C.html#${element.id}`
	description += `\n\n${docsLink}`

	// Push the function name and description to the array.
	functions.push({ name, description })
}

// Load the Zig bindings file.
const bindings = await fs.readFile(
	path.join("../src/", "playdate_api_definitions.zig"),
	{ encoding: "utf-8" },
)

// Split to lines.
const lines = bindings.split("\n")

// For each function, find the corresponding struct name and inject the description as a doc comment.
for (const { name, description } of functions) {
	// String like "Calls the log function, outputting an error in red to the console, then pauses execution.\n\nhttps://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.error"
	// will be converted to:
	// "/// Calls the log function, outputting an error in red to the console, then pauses execution.\n///\n/// [Playdate SDK Documentation](https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.error)"
	const linesToInject = description.split("\n").map((line) => `    /// ${line}`)

	// If the name start with "json_", it is an inline function and we can use a simplified injection logic.
	if (name.startsWith("json_")) {
		// Find the line number of the function definition.
		const functionLine = lines.findIndex((line) =>
			line.includes(`inline fn ${name}(`),
		)

		// Inject the description as a doc comment on the above line.
		lines.splice(functionLine, 0, ...linesToInject)
		continue
	}

	// Find the struct name from the namespace.
	const structName = nameToStructName(name)
	let propertyName = name.split(".").pop()

	// 'error' is a special name that should get mapped to '@"error"'
	if (propertyName === "error") {
		propertyName = '@"error"'
	}

	// Find the line number of the struct definition.
	const startLine = lines.findIndex((line) => line.includes(` ${structName} =`))

	// Warn if not found.
	if (startLine === -1) {
		console.warn(`Struct "${structName}" not found for function name "${name}"`)
	} else {
		// Find the next instace of '};' after the struct definition line.
		const endLine = lines.findIndex(
			(line, i) => i > startLine && line.includes("};"),
		)

		// Find the function definition line from between the struct definition and the next '};'.
		const functionLine = lines.findIndex(
			(line, i) =>
				i > startLine && i < endLine && line.includes(`${propertyName}: `),
		)

		// Warn if not found.
		if (functionLine === -1) {
			console.warn(
				`"Property ${propertyName}" not found for struct "${structName}"`,
			)
		} else {
			// Inject the description as a doc comment on the above line.
			lines.splice(functionLine, 0, ...linesToInject)
		}
	}
}

// Create a new bindings file with the updated doc comments.
await fs.writeFile(
	path.join(".", "playdate_api_definitions_with_comments.zig"),
	lines.join("\n"),
)

/**
 * Lookup table to convert namespaces like "system" to struct names like "PlaydateSys" in the Zig bindings file.
 */
function nameToStructName(name: string) {
	// If the name does not have a dot, just return it as-is.
	if (!name.includes(".")) {
		return name
	}

	let namespace: string

	// If the name has more than one dot, ignore all but the last two parts.
	if (name.split(".").length > 2) {
		namespace = name.split(".").slice(-2)[0]
	} else {
		namespace = name.split(".")[0]
	}

	const dictionary: Record<string, string> = {
		system: "PlaydateSys",
		sound: "PlaydateSound",
		display: "PlaydateDisplay",
		file: "PlaydateFile",
		graphics: "PlaydateGraphics",
		json: "PlaydateJSON",
		lua: "PlaydateLua",
		sprite: "PlaydateSprite",
		video: "PlaydateVideo",
		channel: "PlaydateSoundChannel",
		lfo: "PlaydateSoundLFO",
		source: "PlaydateSoundSource",
		sample: "PlaydateSoundSample",
		fileplayer: "PlaydateSoundFileplayer",
		sampleplayer: "PlaydateSoundSampleplayer",
		synth: "PlaydateSoundSynth",
		instrument: "PlaydateSoundInstrument",
		signal: "PlaydateSoundSignal",
		envelope: "PlaydateSoundEnvelope",
		effect: "PlaydateSoundEffect",
		sequence: "PlaydateSoundSequence",
		controlsignal: "PlaydateControlSignal",
		track: "PlaydateSoundTrack",
		twopolefilter: "PlaydateSoundEffectTwopolefilter",
		onepolefilter: "PlaydateSoundEffectOnepolefilter",
		bitcrusher: "PlaydateSoundEffectBitcrusher",
		ringmodulator: "PlaydateSoundEffectRingmodulator",
		overdrive: "PlaydateSoundEffectOverdrive",
		delayline: "PlaydateSoundEffectDelayline",
	}

	const returnValue = dictionary[namespace]
	if (!returnValue) {
		throw new Error(`Unknown namespace in "${name}"`)
	}

	return returnValue
}
