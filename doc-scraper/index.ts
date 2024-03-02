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
)

// TODO: Could find the doc comments locations and add or update them?

console.log(functions.slice(0, 3))
