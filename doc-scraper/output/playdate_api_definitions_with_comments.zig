const std = @import("std");
const builtin = @import("builtin");

pub const PlaydateAPI = extern struct {
    system: *const PlaydateSys,
    file: *const PlaydateFile,
    graphics: *const PlaydateGraphics,
    sprite: *const PlaydateSprite,
    display: *const PlaydateDisplay,
    sound: *const PlaydateSound,
    lua: *const PlaydateLua,
    json: *const PlaydateJSON,
    scoreboards: *const PlaydateScoreboards,
};

////////Buttons//////////////
pub const PDButtons = c_int;
pub const BUTTON_LEFT = (1 << 0);
pub const BUTTON_RIGHT = (1 << 1);
pub const BUTTON_UP = (1 << 2);
pub const BUTTON_DOWN = (1 << 3);
pub const BUTTON_B = (1 << 4);
pub const BUTTON_A = (1 << 5);

///////////////System/////////////////////////
pub const PDMenuItem = opaque {};
pub const PDCallbackFunction = *const fn (userdata: ?*anyopaque) callconv(.C) c_int;
pub const PDMenuItemCallbackFunction = *const fn (userdata: ?*anyopaque) callconv(.C) void;
pub const PDSystemEvent = enum(c_int) {
    EventInit,
    EventInitLua,
    EventLock,
    EventUnlock,
    EventPause,
    EventResume,
    EventTerminate,
    EventKeyPressed, // arg is keycode
    EventKeyReleased,
    EventLowPower,
};
pub const PDLanguage = enum(c_int) {
    PDLanguageEnglish,
    PDLanguageJapanese,
    PDLanguageUnknown,
};

pub const PDPeripherals = c_int;
const PERIPHERAL_NONE = 0;
const PERIPHERAL_ACCELEROMETER = (1 << 0);
// ...
const PERIPHERAL_ALL = 0xFFFF;

pub const PDStringEncoding = enum(c_int) {
    ASCIIEncoding,
    UTF8Encoding,
    @"16BitLEEncoding",
};

pub const PDDateTime = extern struct {
    year: u16,
    month: u8, // 1-12
    day: u8, // 1-31
    weekday: u8, // 1=monday-7=sunday
    hour: u8, // 0-23
    minute: u8,
    second: u8,
};

pub const PlaydateSys = extern struct {
    /// Allocates heap space if ptr is NULL, else reallocates the given pointer. If size is zero, frees the given pointer.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.realloc
    realloc: *const fn (ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque,
    /// Creates a formatted string and returns it via the outstring argument. The arguments and return value match libc’s asprintf(): the format string is standard printf() style, the string returned in outstring should be freed by the caller when it’s no longer in use, and the return value is the length of the formatted string.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.formatString
    formatString: *const fn (ret: ?*[*c]u8, fmt: [*c]const u8, ...) callconv(.C) c_int,
    /// Calls the log function.   Equivalent to print() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.logToConsole
    logToConsole: *const fn (fmt: [*c]const u8, ...) callconv(.C) void,
    /// Calls the log function, outputting an error in red to the console, then pauses execution.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.error
    @"error": *const fn (fmt: [*c]const u8, ...) callconv(.C) void,
    /// Returns the current language of the system.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getLanguage
    getLanguage: *const fn () callconv(.C) PDLanguage,
    /// Returns the number of milliseconds since…​some arbitrary point in time. This should present a consistent timebase while a game is running, but the counter will be disabled when the device is sleeping.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getCurrentTimeMilliseconds
    getCurrentTimeMilliseconds: *const fn () callconv(.C) c_uint,
    /// Returns the number of seconds (and sets milliseconds if not NULL) elapsed since midnight (hour 0), January 1, 2000.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getSecondsSinceEpoch
    getSecondsSinceEpoch: *const fn (milliseconds: ?*c_uint) callconv(.C) c_uint,
    /// Calculates the current frames per second and draws that value at x, y.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.drawFPS
    drawFPS: *const fn (x: c_int, y: c_int) callconv(.C) void,

    /// PDCallbackFunction  int PDCallbackFunction(void* userdata);    Replaces the default Lua run loop function with a custom update function. The update function should return a non-zero number to tell the system to update the display, or zero if update isn’t needed.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setUpdateCallback
    setUpdateCallback: *const fn (update: ?PDCallbackFunction, userdata: ?*anyopaque) callconv(.C) void,
    /// Sets the value pointed to by current to a bitmask indicating which buttons are currently down. pushed and released reflect which buttons were pushed or released over the previous update cycle—at the nominal frame rate of 50 ms, fast button presses can be missed if you just poll the instantaneous state.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getButtonState
    getButtonState: *const fn (current: ?*PDButtons, pushed: ?*PDButtons, released: ?*PDButtons) callconv(.C) void,
    /// By default, the accelerometer is disabled to save (a small amount of) power. To use a peripheral, it must first be enabled via this function. Accelerometer data is not available until the next update cycle after it’s enabled.   PDPeripherals  kNone kAccelerometer
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setPeripheralsEnabled
    setPeripheralsEnabled: *const fn (mask: PDPeripherals) callconv(.C) void,
    /// Returns the last-read accelerometer data.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getAccelerometer
    getAccelerometer: *const fn (outx: ?*f32, outy: ?*f32, outz: ?*f32) callconv(.C) void,
    /// Returns the angle change of the crank since the last time this function was called. Negative values are anti-clockwise.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getCrankChange
    getCrankChange: *const fn () callconv(.C) f32,
    /// Returns the current position of the crank, in the range 0-360. Zero is pointing up, and the value increases as the crank moves clockwise, as viewed from the right side of the device.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getCrankAngle
    getCrankAngle: *const fn () callconv(.C) f32,
    /// Returns 1 or 0 indicating whether or not the crank is folded into the unit.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.isCrankDocked
    isCrankDocked: *const fn () callconv(.C) c_int,
    /// The function returns the previous value for this setting.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setCrankSoundsDisabled
    setCrankSoundsDisabled: *const fn (flag: c_int) callconv(.C) c_int, // returns previous setting

    /// Returns 1 if the global "flipped" system setting is set, otherwise 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getFlipped
    getFlipped: *const fn () callconv(.C) c_int,
    /// Disables or enables the 3 minute auto lock feature. When called, the timer is reset to 3 minutes.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setAutoLockDisabled
    setAutoLockDisabled: *const fn (disable: c_int) callconv(.C) void,

    /// A game can optionally provide an image to be displayed alongside the system menu. bitmap must be a 400x240 LCDBitmap. All important content should be in the left half of the image in an area 200 pixels wide, as the menu will obscure the rest. The right side of the image will be visible briefly as the menu animates in and out.   Optionally, a non-zero xoffset, can be provided. This must be a number between 0 and 200 and will cause the menu image to animate to a position offset left by xoffset pixels as the menu is animated in.   This function could be called in response to the kEventPause event in your implementation of eventHandler().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setMenuImage
    setMenuImage: *const fn (bitmap: ?*LCDBitmap, xOffset: c_int) callconv(.C) void,
    /// title will be the title displayed by the menu item.   Adds a new menu item to the System Menu. When invoked by the user, this menu item will:     Invoke your callback function.   Hide the System Menu.   Unpause your game and call eventHandler() with the kEventResume event.     Your game can then present an options interface to the player, or take other action, in whatever manner you choose.   The returned menu item is freed when removed from the menu; it does not need to be freed manually.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.addMenuItem
    addMenuItem: *const fn (title: [*c]const u8, callback: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.C) ?*PDMenuItem,
    /// Adds a new menu item that can be checked or unchecked by the player.   title will be the title displayed by the menu item.   value should be 0 for unchecked, 1 for checked.   If this menu item is interacted with while the system menu is open, callback will be called when the menu is closed.   The returned menu item is freed when removed from the menu; it does not need to be freed manually.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.addCheckmarkMenuItem
    addCheckmarkMenuItem: *const fn (title: [*c]const u8, value: c_int, callback: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.C) ?*PDMenuItem,
    /// Adds a new menu item that allows the player to cycle through a set of options.   title will be the title displayed by the menu item.   options should be an array of strings representing the states this menu item can cycle through. Due to limited horizontal space, the option strings and title should be kept short for this type of menu item.   optionsCount should be the number of items contained in options.   If this menu item is interacted with while the system menu is open, callback will be called when the menu is closed.   The returned menu item is freed when removed from the menu; it does not need to be freed manually.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.addOptionsMenuItem
    addOptionsMenuItem: *const fn (title: [*c]const u8, optionTitles: [*c][*c]const u8, optionsCount: c_int, f: ?PDMenuItemCallbackFunction, userdata: ?*anyopaque) callconv(.C) ?*PDMenuItem,
    /// Removes all custom menu items from the system menu.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.removeAllMenuItems
    removeAllMenuItems: *const fn () callconv(.C) void,
    /// Removes the menu item from the system menu.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.removeMenuItem
    removeMenuItem: *const fn (menuItem: ?*PDMenuItem) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getMenuItemValue
    getMenuItemValue: *const fn (menuItem: ?*PDMenuItem) callconv(.C) c_int,
    /// Gets or sets the integer value of the menu item.   For checkmark menu items, 1 means checked, 0 unchecked. For option menu items, the value indicates the array index of the currently selected option.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setMenuItemValue
    setMenuItemValue: *const fn (menuItem: ?*PDMenuItem, value: c_int) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getMenuItemTitle
    getMenuItemTitle: *const fn (menuItem: ?*PDMenuItem) callconv(.C) [*c]const u8,
    /// Gets or sets the display title of the menu item.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setMenuItemTitle
    setMenuItemTitle: *const fn (menuItem: ?*PDMenuItem, title: [*c]const u8) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getMenuItemUserdata
    getMenuItemUserdata: *const fn (menuItem: ?*PDMenuItem) callconv(.C) ?*anyopaque,
    /// Gets or sets the userdata value associated with this menu item.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.setMenuItemUserdata
    setMenuItemUserdata: *const fn (menuItem: ?*PDMenuItem, ud: ?*anyopaque) callconv(.C) void,

    /// Returns 1 if the global "reduce flashing" system setting is set, otherwise 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getReduceFlashing
    getReduceFlashing: *const fn () callconv(.C) c_int,

    // 1.1
    /// Returns the number of seconds since playdate.resetElapsedTime() was called. The value is a floating-point number with microsecond accuracy.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getElapsedTime
    getElapsedTime: *const fn () callconv(.C) f32,
    /// Resets the high-resolution timer.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.resetElapsedTime
    resetElapsedTime: *const fn () callconv(.C) void,

    // 1.4
    /// Returns a value from 0-100 denoting the current level of battery charge. 0 = empty; 100 = full.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getBatteryPercentage
    getBatteryPercentage: *const fn () callconv(.C) f32,
    /// Returns the battery’s current voltage level.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getBatteryVoltage
    getBatteryVoltage: *const fn () callconv(.C) f32,

    // 1.13
    /// Returns the system timezone offset from GMT, in seconds.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.getTimezoneOffset
    getTimezoneOffset: *const fn () callconv(.C) i32,
    /// Returns 1 if the user has set the 24-Hour Time preference in the Settings program.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.shouldDisplay24HourTime
    shouldDisplay24HourTime: *const fn () callconv(.C) c_int,
    /// Converts the given epoch time to a PDDateTime.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.convertEpochToDateTime
    convertEpochToDateTime: *const fn (epoch: u32, datetime: ?*PDDateTime) callconv(.C) void,
    /// Converts the given PDDateTime to an epoch time.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.convertDateTimeToEpoch
    convertDateTimeToEpoch: *const fn (datetime: ?*PDDateTime) callconv(.C) u32,

    //2.0
    /// Flush the CPU instruction cache, on the very unlikely chance you’re modifying instruction code on the fly. (If you don’t know what I’m talking about, you don’t need this. :smile:)
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-system.clearICache
    clearICache: *const fn () callconv(.C) void,
};

////////LCD and Graphics///////////////////////
pub const LCD_COLUMNS = 400;
pub const LCD_ROWS = 240;
pub const LCD_ROWSIZE = 52;
pub const LCDBitmap = opaque {};
pub const LCDVideoPlayer = opaque {};
pub const PlaydateVideo = extern struct {
    /// Opens the pdv file at path and returns a new video player object for rendering its frames.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.loadVideo
    loadVideo: *const fn ([*c]const u8) callconv(.C) ?*LCDVideoPlayer,
    /// Frees the given video player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.freePlayer
    freePlayer: *const fn (?*LCDVideoPlayer) callconv(.C) void,
    /// Sets the rendering destination for the video player to the given bitmap. If the function fails, it returns 0 and sets an error message that can be read via getError().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.setContext
    setContext: *const fn (?*LCDVideoPlayer, ?*LCDBitmap) callconv(.C) c_int,
    /// Sets the rendering destination for the video player to the screen.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.useScreenContext
    useScreenContext: *const fn (?*LCDVideoPlayer) callconv(.C) void,
    /// Renders frame number n into the current context. In case of error, the function returns 0 and sets an error message that can be read via getError().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.renderFrame
    renderFrame: *const fn (?*LCDVideoPlayer, c_int) callconv(.C) c_int,
    /// Returns text describing the most recent error.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.getError
    getError: *const fn (?*LCDVideoPlayer) callconv(.C) [*c]const u8,
    /// Retrieves information about the video, by passing in (possibly NULL) value pointers.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.getInfo
    getInfo: *const fn (?*LCDVideoPlayer, [*c]c_int, [*c]c_int, [*c]f32, [*c]c_int, [*c]c_int) callconv(.C) void,
    /// Gets the rendering destination for the video player. If no rendering context has been setallocates a context bitmap with the same dimensions as the vieo will be allocated.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.video.getContext
    getContext: *const fn (?*LCDVideoPlayer) callconv(.C) ?*LCDBitmap,
};

pub const LCDPattern = [16]u8;
pub const LCDColor = usize; //Pointer to LCDPattern or a LCDSolidColor value
pub const LCDSolidColor = enum(c_int) {
    ColorBlack,
    ColorWhite,
    ColorClear,
    ColorXOR,
};
pub const LCDBitmapDrawMode = enum(c_int) {
    DrawModeCopy,
    DrawModeWhiteTransparent,
    DrawModeBlackTransparent,
    DrawModeFillWhite,
    DrawModeFillBlack,
    DrawModeXOR,
    DrawModeNXOR,
    DrawModeInverted,
};
pub const LCDLineCapStyle = enum(c_int) {
    LineCapStyleButt,
    LineCapStyleSquare,
    LineCapStyleRound,
};

pub const LCDFontLanguage = enum(c_int) {
    LCDFontLanguageEnglish,
    LCDFontLanguageJapanese,
    LCDFontLanguageUnknown,
};

pub const LCDBitmapFlip = enum(c_int) {
    BitmapUnflipped,
    BitmapFlippedX,
    BitmapFlippedY,
    BitmapFlippedXY,
};
pub const LCDPolygonFillRule = enum(c_int) {
    PolygonFillNonZero,
    PolygonFillEvenOdd,
};

pub const LCDBitmapTable = opaque {};
pub const LCDFont = opaque {};
pub const LCDFontPage = opaque {};
pub const LCDFontGlyph = opaque {};
pub const LCDFontData = opaque {};
pub const LCDRect = extern struct {
    left: c_int,
    right: c_int,
    top: c_int,
    bottom: c_int,
};

pub const PlaydateGraphics = extern struct {
    video: *const PlaydateVideo,
    // Drawing Functions
    /// Clears the entire display, filling it with color.   Equivalent to playdate.graphics.clear() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.clear
    clear: *const fn (color: LCDColor) callconv(.C) void,
    /// Sets the background color shown when the display is offset or for clearing dirty areas in the sprite system.   Equivalent to playdate.graphics.setBackgroundColor() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setBackgroundColor
    setBackgroundColor: *const fn (color: LCDSolidColor) callconv(.C) void,
    /// Sets the stencil used for drawing. For a tiled stencil, use setStencilImage() instead. To clear the stencil, set it to NULL.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setStencil
    setStencil: *const fn (stencil: ?*LCDBitmap) callconv(.C) void, // deprecated in favor of setStencilImage, which adds a "tile" flag
    /// Sets the mode used for drawing bitmaps. Note that text drawing uses bitmaps, so this affects how fonts are displayed as well.   LCDBitmapDrawMode  typedef enum { kDrawModeCopy, kDrawModeWhiteTransparent, kDrawModeBlackTransparent, kDrawModeFillWhite, kDrawModeFillBlack, kDrawModeXOR, kDrawModeNXOR, kDrawModeInverted } LCDBitmapDrawMode;    Equivalent to playdate.graphics.setImageDrawMode() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setDrawMode
    setDrawMode: *const fn (mode: LCDBitmapDrawMode) callconv(.C) void,
    /// Offsets the origin point for all drawing calls to x, y (can be negative).   This is useful, for example, for centering a "camera" on a sprite that is moving around a world larger than the screen.   Equivalent to playdate.graphics.setDrawOffset() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setDrawOffset
    setDrawOffset: *const fn (dx: c_int, dy: c_int) callconv(.C) void,
    /// Sets the current clip rect, using world coordinates—​that is, the given rectangle will be translated by the current drawing offset. The clip rect is cleared at the beginning of each update.   Equivalent to playdate.graphics.setClipRect() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setClipRect
    setClipRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) callconv(.C) void,
    /// Clears the current clip rect.   Equivalent to playdate.graphics.clearClipRect() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.clearClipRect
    clearClipRect: *const fn () callconv(.C) void,
    /// Sets the end cap style used in the line drawing functions.   LCDLineCapStyle  typedef enum { kLineCapStyleButt, kLineCapStyleSquare, kLineCapStyleRound } LCDLineCapStyle;    Equivalent to playdate.graphics.setLineCapStyle() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setLineCapStyle
    setLineCapStyle: *const fn (endCapStyle: LCDLineCapStyle) callconv(.C) void,
    /// Sets the font to use in subsequent drawText calls.   Equivalent to playdate.graphics.setFont() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setFont
    setFont: *const fn (font: ?*LCDFont) callconv(.C) void,
    /// Sets the tracking to use when drawing text.   Equivalent to playdate.graphics.font:setTracking() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setTextTracking
    setTextTracking: *const fn (tracking: c_int) callconv(.C) void,
    /// Push a new drawing context for drawing into the given bitmap. If target is NULL, the drawing functions will use the display framebuffer.   Equivalent to playdate.graphics.pushContext() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.pushContext
    pushContext: *const fn (target: ?*LCDBitmap) callconv(.C) void,
    /// Pops a context off the stack (if any are left), restoring the drawing settings from before the context was pushed.   Equivalent to playdate.graphics.popContext() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.popContext
    popContext: *const fn () callconv(.C) void,

    /// Draws the bitmap with its upper-left corner at location x, y, using the given flip orientation.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawBitmap
    drawBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, flip: LCDBitmapFlip) callconv(.C) void,
    /// Draws the bitmap with its upper-left corner at location x, y tiled inside a width by height rectangle.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.tileBitmap
    tileBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, width: c_int, height: c_int, flip: LCDBitmapFlip) callconv(.C) void,
    /// Draws a line from x1, y1 to x2, y2 with a stroke width of width.   Equivalent to playdate.graphics.drawLine() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawLine
    drawLine: *const fn (x1: c_int, y1: c_int, x2: c_int, y2: c_int, width: c_int, color: LCDColor) callconv(.C) void,
    /// Draws a filled triangle with points at x1, y1, x2, y2, and x3, y3.   LCDWindingRule  typedef enum { kPolygonFillNonZero, kPolygonFillEvenOdd } LCDPolygonFillRule;    Equivalent to playdate.graphics.fillTriangle() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.fillTriangle
    fillTriangle: *const fn (x1: c_int, y1: c_int, x2: c_int, y2: c_int, x3: c_int, y3: c_int, color: LCDColor) callconv(.C) void,
    /// Draws a width by height rect at x, y.   Equivalent to playdate.graphics.drawRect() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawRect
    drawRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, color: LCDColor) callconv(.C) void,
    /// Draws a filled width by height rect at x, y.   Equivalent to playdate.graphics.fillRect() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.fillRect
    fillRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, color: LCDColor) callconv(.C) void,
    /// Draws an ellipse inside the rectangle {x, y, width, height} of width lineWidth (inset from the rectangle bounds). If startAngle != _endAngle, this draws an arc between the given angles. Angles are given in degrees, clockwise from due north.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawEllipse
    drawEllipse: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, lineWidth: c_int, startAngle: f32, endAngle: f32, color: LCDColor) callconv(.C) void,
    /// Fills an ellipse inside the rectangle {x, y, width, height}. If startAngle != _endAngle, this draws a wedge/Pacman between the given angles. Angles are given in degrees, clockwise from due north.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.fillEllipse
    fillEllipse: *const fn (x: c_int, y: c_int, width: c_int, height: c_int, startAngle: f32, endAngle: f32, color: LCDColor) callconv(.C) void,
    /// Draws the bitmap scaled to xscale and yscale with its upper-left corner at location x, y. Note that flip is not available when drawing scaled bitmaps but negative scale values will achieve the same effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawScaledBitmap
    drawScaledBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, xscale: f32, yscale: f32) callconv(.C) void,
    /// Draws the given text using the provided options. If no font has been set with setFont, the default system font Asheville Sans 14 Light is used.   Equivalent to playdate.graphics.drawText() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawText
    drawText: *const fn (text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, x: c_int, y: c_int) callconv(.C) c_int,

    // LCDBitmap
    /// Allocates and returns a new width by height LCDBitmap filled with bgcolor.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.newBitmap
    newBitmap: *const fn (width: c_int, height: c_int, color: LCDColor) callconv(.C) ?*LCDBitmap,
    /// Frees the given bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.freeBitmap
    freeBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.C) void,
    /// Allocates and returns a new LCDBitmap from the file at path. If there is no file at path, the function returns null.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.loadBitmap
    loadBitmap: *const fn (path: [*c]const u8, outerr: ?*[*c]const u8) callconv(.C) ?*LCDBitmap,
    /// Returns a new LCDBitmap that is an exact copy of bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.copyBitmap
    copyBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.C) ?*LCDBitmap,
    /// Loads the image at path into the previously allocated bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.loadIntoBitmap
    loadIntoBitmap: *const fn (path: [*c]const u8, bitmap: ?*LCDBitmap, outerr: ?*[*c]const u8) callconv(.C) void,
    /// Gets various info about bitmap including its width and height and raw pixel data. The data is 1 bit per pixel packed format, in MSB order; in other words, the high bit of the first byte in data is the top left pixel of the image. If the bitmap has a mask, a pointer to its data is returned in mask, else NULL is returned.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getBitmapData
    getBitmapData: *const fn (bitmap: ?*LCDBitmap, width: ?*c_int, height: ?*c_int, rowbytes: ?*c_int, mask: ?*[*c]u8, data: ?*[*c]u8) callconv(.C) void,
    /// Clears bitmap, filling with the given bgcolor.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.clearBitmap
    clearBitmap: *const fn (bitmap: ?*LCDBitmap, bgcolor: LCDColor) callconv(.C) void,
    /// Returns a new, rotated and scaled LCDBitmap based on the given bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.rotatedBitmap
    rotatedBitmap: *const fn (bitmap: ?*LCDBitmap, rotation: f32, xscale: f32, yscale: f32, allocedSize: ?*c_int) callconv(.C) ?*LCDBitmap,

    // LCDBitmapTable
    /// Allocates and returns a new LCDBitmapTable that can hold count width by height LCDBitmaps.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.newBitmapTable
    newBitmapTable: *const fn (count: c_int, width: c_int, height: c_int) callconv(.C) ?*LCDBitmapTable,
    /// Frees the given bitmap table. Note that this will invalidate any bitmaps returned by getTableBitmap().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.freeBitmapTable
    freeBitmapTable: *const fn (table: ?*LCDBitmapTable) callconv(.C) void,
    /// Allocates and returns a new LCDBitmap from the file at path. If there is no file at path, the function returns null.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.loadBitmapTable
    loadBitmapTable: *const fn (path: [*c]const u8, outerr: ?*[*c]const u8) callconv(.C) ?*LCDBitmapTable,
    /// Loads the imagetable at path into the previously allocated table.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.loadIntoBitmapTable
    loadIntoBitmapTable: *const fn (path: [*c]const u8, table: ?*LCDBitmapTable, outerr: ?*[*c]const u8) callconv(.C) void,
    /// Returns the idx bitmap in table, If idx is out of bounds, the function returns NULL.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getTableBitmap
    getTableBitmap: *const fn (table: ?*LCDBitmapTable, idx: c_int) callconv(.C) ?*LCDBitmap,

    // LCDFont
    /// Returns the LCDFont object for the font file at path. In case of error, outErr points to a string describing the error. The returned font can be freed with playdate→system→realloc(font, 0) when it is no longer in use.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.loadFont
    loadFont: *const fn (path: [*c]const u8, outErr: ?*[*c]const u8) callconv(.C) ?*LCDFont,
    /// Returns an LCDFontPage object for the given character code. Each LCDFontPage contains information for 256 characters; specifically, if (c1 & ~0xff) == (c2 & ~0xff), then c1 and c2 belong to the same page and the same LCDFontPage can be used to fetch the character data for both instead of searching for the page twice.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getFontPage
    getFontPage: *const fn (font: ?*LCDFont, c: u32) callconv(.C) ?*LCDFontPage,
    /// Returns an LCDFontGlyph object for character c in LCDFontPage page, and optionally returns the glyph’s bitmap and advance value.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getPageGlyph
    getPageGlyph: *const fn (page: ?*LCDFontPage, c: u32, bitmap: ?**LCDBitmap, advance: ?*c_int) callconv(.C) ?*LCDFontGlyph,
    /// Returns the kerning adjustment between characters c1 and c2 as specified by the font.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getGlyphKerning
    getGlyphKerning: *const fn (glyph: ?*LCDFontGlyph, glyphcode: u32, nextcode: u32) callconv(.C) c_int,
    /// Returns the width of the given text in the given font.   PDStringEncoding  typedef enum { kASCIIEncoding, kUTF8Encoding, k16BitLEEncoding } PDStringEncoding;
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getTextWidth
    getTextWidth: *const fn (font: ?*LCDFont, text: ?*const anyopaque, len: usize, encoding: PDStringEncoding, tracking: c_int) callconv(.C) c_int,

    // raw framebuffer access
    /// Returns the current display frame buffer. Rows are 32-bit aligned, so the row stride is 52 bytes, with the extra 2 bytes per row ignored. Bytes are MSB-ordered; i.e., the pixel in column 0 is the 0x80 bit of the first byte of the row.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getFrame
    getFrame: *const fn () callconv(.C) [*c]u8, // row stride = LCD_ROWSIZE
    /// Returns the raw bits in the display buffer, the last completed frame.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getDisplayFrame
    getDisplayFrame: *const fn () callconv(.C) [*c]u8, // row stride = LCD_ROWSIZE
    /// Only valid in the Simulator; function is NULL on device. Returns the debug framebuffer as a bitmap. White pixels drawn in the image are overlaid on the display in 50% transparent red.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getDebugBitmap
    getDebugBitmap: *const fn () callconv(.C) ?*LCDBitmap, // valid in simulator only, function is null on device
    /// Returns a copy the contents of the working frame buffer as a bitmap. The caller is responsible for freeing the returned bitmap with playdate->graphics->freeBitmap().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.copyFrameBufferBitmap
    copyFrameBufferBitmap: *const fn () callconv(.C) ?*LCDBitmap,
    /// After updating pixels in the buffer returned by getFrame(), you must tell the graphics system which rows were updated. This function marks a contiguous range of rows as updated (e.g., markUpdatedRows(0,LCD_ROWS-1) tells the system to update the entire display). Both “start” and “end” are included in the range.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.markUpdatedRows
    markUpdatedRows: *const fn (start: c_int, end: c_int) callconv(.C) void,
    /// Manually flushes the current frame buffer out to the display. This function is automatically called after each pass through the run loop, so there shouldn’t be any need to call it yourself.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.display
    display: *const fn () callconv(.C) void,

    // misc util.
    /// Sets color to an 8 x 8 pattern using the given bitmap. x, y indicates the top left corner of the 8 x 8 pattern.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setColorToPattern
    setColorToPattern: *const fn (color: ?*LCDColor, bitmap: ?*LCDBitmap, x: c_int, y: c_int) callconv(.C) void,
    /// Returns 1 if any of the opaque pixels in bitmap1 when positioned at x1, y1 with flip1 overlap any of the opaque pixels in bitmap2 at x2, y2 with flip2 within the non-empty rect, or 0 if no pixels overlap or if one or both fall completely outside of rect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.checkMaskCollision
    checkMaskCollision: *const fn (bitmap1: ?*LCDBitmap, x1: c_int, y1: c_int, flip1: LCDBitmapFlip, bitmap2: ?*LCDBitmap, x2: c_int, y2: c_int, flip2: LCDBitmapFlip, rect: LCDRect) callconv(.C) c_int,

    // 1.1
    /// Sets the current clip rect in screen coordinates.   Equivalent to playdate.graphics.setScreenClipRect() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setScreenClipRect
    setScreenClipRect: *const fn (x: c_int, y: c_int, width: c_int, height: c_int) callconv(.C) void,

    // 1.1.1
    /// Fills the polygon with vertices at the given coordinates (an array of 2*nPoints ints containing alternating x and y values) using the given color and fill, or winding, rule. See https://en.wikipedia.org/wiki/Nonzero-rule for an explanation of the winding rule. An edge between the last vertex and the first is assumed.   Equivalent to playdate.graphics.fillPolygon() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.fillPolygon
    fillPolygon: *const fn (nPoints: c_int, coords: [*c]c_int, color: LCDColor, fillRule: LCDPolygonFillRule) callconv(.C) void,
    /// Returns the height of the given font.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getFontHeight
    getFontHeight: *const fn (font: ?*LCDFont) callconv(.C) u8,

    // 1.7
    /// Returns a bitmap containing the contents of the display buffer. The system owns this bitmap—​do not free it!
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getDisplayBufferBitmap
    getDisplayBufferBitmap: *const fn () callconv(.C) ?*LCDBitmap,
    /// Draws the bitmap scaled to xscale and yscale then rotated by degrees with its center as given by proportions centerx and centery at x, y; that is: if centerx and centery are both 0.5 the center of the image is at (x,y), if centerx and centery are both 0 the top left corner of the image (before rotation) is at (x,y), etc.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.drawRotatedBitmap
    drawRotatedBitmap: *const fn (bitmap: ?*LCDBitmap, x: c_int, y: c_int, rotation: f32, centerx: f32, centery: f32, xscale: f32, yscale: f32) callconv(.C) void,
    /// Sets the leading adjustment (added to the leading specified in the font) to use when drawing text.   Equivalent to playdate.graphics.font:setLeading() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setTextLeading
    setTextLeading: *const fn (lineHeightAdustment: c_int) callconv(.C) void,

    // 1.8
    /// Sets a mask image for the given bitmap. The set mask must be the same size as the target bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setBitmapMask
    setBitmapMask: *const fn (bitmap: ?*LCDBitmap, mask: ?*LCDBitmap) callconv(.C) c_int,
    /// Gets a mask image for the given bitmap, or returns NULL if the bitmap doesn’t have a mask layer. The returned image points to bitmap's data, so drawing into the mask image affects the source bitmap directly. The caller takes ownership of the returned LCDBitmap and is responsible for freeing it when it’s no longer in use.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getBitmapMask
    getBitmapMask: *const fn (bitmap: ?*LCDBitmap) callconv(.C) ?*LCDBitmap,

    // 1.10
    /// Sets the stencil used for drawing. If the tile flag is set the stencil image will be tiled. Tiled stencils must have width equal to a multiple of 32 pixels. To clear the stencil, call playdate→graphics→setStencil(NULL);.   Equivalent to playdate.graphics.setStencilImage() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.setStencilImage
    setStencilImage: *const fn (stencil: ?*LCDBitmap, tile: c_int) callconv(.C) void,

    // 1.12
    /// Returns an LCDFont object wrapping the LCDFontData data comprising the contents (minus 16-byte header) of an uncompressed pft file. wide corresponds to the flag in the header indicating whether the font contains glyphs at codepoints above U+1FFFF.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.makeFontFromData
    makeFontFromData: *const fn (data: *LCDFontData, wide: c_int) callconv(.C) *LCDFont,

    // 2.1
    /// Gets the tracking used when drawing text.   Equivalent to playdate.graphics.font:getTracking() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-graphics.getTextTracking
    getTextTracking: *const fn () callconv(.C) c_int,
};
pub const PlaydateDisplay = struct {
    /// Returns the width of the display, taking the current scale into account; e.g., if the scale is 2, this function returns 200 instead of 400.   Equivalent to playdate.display.getWidth() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.getWidth
    getWidth: *const fn () callconv(.C) c_int,
    /// Returns the height of the display, taking the current scale into account; e.g., if the scale is 2, this function returns 120 instead of 240.   Equivalent to playdate.display.getHeight() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.getHeight
    getHeight: *const fn () callconv(.C) c_int,

    /// Sets the nominal refresh rate in frames per second. The default is 30 fps, which is a recommended figure that balances animation smoothness with performance and power considerations. Maximum is 50 fps.   If rate is 0, the game’s update callback (either Lua’s playdate.update() or the function specified by playdate→system→setUpdateCallback()) is called as soon as possible. Since the display refreshes line-by-line, and unchanged lines aren’t sent to the display, the update cycle will be faster than 30 times a second but at an indeterminate rate.   Equivalent to playdate.display.setRefreshRate() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.setRefreshRate
    setRefreshRate: *const fn (rate: f32) callconv(.C) void,

    /// If flag evaluates to true, the frame buffer is drawn inverted—black instead of white, and vice versa.   Equivalent to playdate.display.setInverted() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.setInverted
    setInverted: *const fn (flag: c_int) callconv(.C) void,
    /// Sets the display scale factor. Valid values for scale are 1, 2, 4, and 8.   The top-left corner of the frame buffer is scaled up to fill the display; e.g., if the scale is set to 4, the pixels in rectangle [0,100] x [0,60] are drawn on the screen as 4 x 4 squares.   Equivalent to playdate.display.setScale() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.setScale
    setScale: *const fn (s: c_uint) callconv(.C) void,
    /// Adds a mosaic effect to the display. Valid x and y values are between 0 and 3, inclusive.   Equivalent to playdate.display.setMosaic in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.setMosaic
    setMosaic: *const fn (x: c_uint, y: c_uint) callconv(.C) void,
    /// Flips the display on the x or y axis, or both.   Equivalent to playdate.display.setFlipped() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.setFlipped
    setFlipped: *const fn (x: c_uint, y: c_uint) callconv(.C) void,
    /// Offsets the display by the given amount. Areas outside of the displayed area are filled with the current background color.   Equivalent to playdate.display.setOffset() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-display.setOffset
    setOffset: *const fn (x: c_uint, y: c_uint) callconv(.C) void,
};

//////File System/////
pub const SDFile = opaque {};

pub const FileOptions = c_int;
pub const FILE_READ = (1 << 0);
pub const FILE_READ_DATA = (1 << 1);
pub const FILE_WRITE = (1 << 2);
pub const FILE_APPEND = (2 << 2);

pub const SEEK_SET = 0;
pub const SEEK_CUR = 1;
pub const SEEK_END = 2;

const FileStat = extern struct {
    isdir: c_int,
    size: c_uint,
    m_year: c_int,
    m_month: c_int,
    m_day: c_int,
    m_hour: c_int,
    m_minute: c_int,
    m_second: c_int,
};

const PlaydateFile = extern struct {
    /// Returns human-readable text describing the most recent error (usually indicated by a -1 return from a filesystem function).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.geterr
    geterr: *const fn () callconv(.C) [*c]const u8,

    /// Calls the given callback function for every file at path. Subfolders are indicated by a trailing slash '/' in filename. listfiles() does not recurse into subfolders. If showhidden is set, files beginning with a period will be included; otherwise, they are skipped. Returns 0 on success, -1 if no folder exists at path or it can’t be opened.   Equivalent to playdate.file.listFiles() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.listfiles
    listfiles: *const fn (
        path: [*c]const u8,
        callback: *const fn (path: [*c]const u8, userdata: ?*anyopaque) callconv(.C) void,
        userdata: ?*anyopaque,
        showhidden: c_int,
    ) callconv(.C) c_int,
    /// Populates the FileStat stat with information about the file at path. Returns 0 on success, or -1 in case of error.   FileStat  typedef struct { int isdir; unsigned int size; int m_year; int m_month; int m_day; int m_hour; int m_minute; int m_second; } FileStat;
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.stat
    stat: *const fn (path: [*c]const u8, stat: ?*FileStat) callconv(.C) c_int,
    /// Creates the given path in the Data/<gameid> folder. It does not create intermediate folders. Returns 0 on success, or -1 in case of error.   Equivalent to playdate.file.mkdir() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.mkdir
    mkdir: *const fn (path: [*c]const u8) callconv(.C) c_int,
    /// Deletes the file at path. Returns 0 on success, or -1 in case of error. If recursive is 1 and the target path is a folder, this deletes everything inside the folder (including folders, folders inside those, and so on) as well as the folder itself.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.unlink
    unlink: *const fn (name: [*c]const u8, recursive: c_int) callconv(.C) c_int,
    /// Renames the file at from to to. It will overwrite the file at to without confirmation. It does not create intermediate folders. Returns 0 on success, or -1 in case of error.   Equivalent to playdate.file.rename() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.rename
    rename: *const fn (from: [*c]const u8, to: [*c]const u8) callconv(.C) c_int,

    /// Opens a handle for the file at path. The kFileRead mode opens a file in the game pdx, while kFileReadData searches the game’s data folder; to search the data folder first then fall back on the game pdx, use the bitwise combination kFileRead|kFileReadData.kFileWrite and kFileAppend always write to the data folder. The function returns NULL if a file at path cannot be opened, and playdate->file->geterr() will describe the error. The filesystem has a limit of 64 simultaneous open files. The returned file handle should be closed, not freed, when it is no longer in use.   FileOptions  typedef enum { kFileRead, kFileReadData, kFileWrite, kFileAppend } FileOptions;    Equivalent to playdate.file.open() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.open
    open: *const fn (name: [*c]const u8, mode: FileOptions) callconv(.C) ?*SDFile,
    /// Closes the given file handle. Returns 0 on success, or -1 in case of error.   Equivalent to playdate.file.close() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.close
    close: *const fn (file: ?*SDFile) callconv(.C) c_int,
    /// Reads up to len bytes from the file into the buffer buf. Returns the number of bytes read (0 indicating end of file), or -1 in case of error.   Equivalent to playdate.file.file:read() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.read
    read: *const fn (file: ?*SDFile, buf: ?*anyopaque, len: c_uint) callconv(.C) c_int,
    /// Writes the buffer of bytes buf to the file. Returns the number of bytes written, or -1 in case of error.   Equivalent to playdate.file.file:write() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.write
    write: *const fn (file: ?*SDFile, buf: ?*const anyopaque, len: c_uint) callconv(.C) c_int,
    /// Flushes the output buffer of file immediately. Returns the number of bytes written, or -1 in case of error.   Equivalent to playdate.file.flush() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.flush
    flush: *const fn (file: ?*SDFile) callconv(.C) c_int,
    /// Returns the current read/write offset in the given file handle, or -1 on error.   Equivalent to playdate.file.file:tell() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.tell
    tell: *const fn (file: ?*SDFile) callconv(.C) c_int,
    /// Sets the read/write offset in the given file handle to pos, relative to the whence macro. SEEK_SET is relative to the beginning of the file, SEEK_CUR is relative to the current position of the file pointer, and SEEK_END is relative to the end of the file. Returns 0 on success, -1 on error.   Equivalent to playdate.file.file:seek() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-file.seek
    seek: *const fn (file: ?*SDFile, pos: c_int, whence: c_int) callconv(.C) c_int,
};

/////////Audio//////////////
pub const PlaydateSound = extern struct {
    channel: *const PlaydateSoundChannel,
    fileplayer: *const PlaydateSoundFileplayer,
    sample: *const PlaydateSoundSample,
    sampleplayer: *const PlaydateSoundSampleplayer,
    synth: *const PlaydateSoundSynth,
    sequence: *const PlaydateSoundSequence,
    effect: *const PlaydateSoundEffect,
    lfo: *const PlaydateSoundLFO,
    envelope: *const PlaydateSoundEnvelope,
    source: *const PlaydateSoundSource,
    controlsignal: *const PlaydateControlSignal,
    track: *const PlaydateSoundTrack,
    instrument: *const PlaydateSoundInstrument,

    /// Returns the sound engine’s current time value, in units of sample frames, 44,100 per second.   Equivalent to playdate.sound.getCurrentTime() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.getCurrentTime
    getCurrentTime: *const fn () callconv(.C) u32,
    /// The callback function you pass in will be called every audio render cycle.   AudioSourceFunction  int AudioSourceFunction(void* context, int16_t* left, int16_t* right, int len)    This function should fill the passed-in left buffer (and right if it’s a stereo source) with len samples each and return 1, or return 0 if the source is silent through the cycle.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.addSource
    addSource: *const fn (callback: AudioSourceFunction, context: ?*anyopaque, stereo: c_int) callconv(.C) ?*SoundSource,

    /// Returns the default channel, where sound sources play if they haven’t been explicity assigned to a different channel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.getDefaultChannel
    getDefaultChannel: *const fn () callconv(.C) ?*SoundChannel,

    /// Adds the given channel to the sound engine. Returns 1 if the channel was added, 0 if it was already in the engine.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.addChannel
    addChannel: *const fn (channel: ?*SoundChannel) callconv(.C) void,
    /// Removes the given channel from the sound engine. Returns 1 if the channel was successfully removed, 0 if the channel is the default channel or hadn’t been previously added.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.removeChannel
    removeChannel: *const fn (channel: ?*SoundChannel) callconv(.C) void,

    /// The callback you pass in will be called every audio cycle.   AudioInputFunction  int AudioInputFunction(void* context, int16_t* data, int len)    enum MicSource  enum MicSource { kMicInputAutodetect = 0, kMicInputInternal = 1, kMicInputHeadset = 2 };    Your input callback will be called with the recorded audio data, a monophonic stream of samples. The function should return 1 to continue recording, 0 to stop recording.   The Playdate hardware has a circuit that attempts to autodetect the presence of a headset mic, but there are cases where you may want to override this. For instance, if you’re using a headphone splitter to wire an external source to the mic input, the detector may not always see the input. Setting the source to kMicInputHeadset forces recording from the headset. Using kMicInputInternal records from the device mic even when a headset with a mic is plugged in. And kMicInputAutodetect uses a headset mic if one is detected, otherwise the device microphone. setMicCallback() returns which source the function used, internal or headset, or 0 on error.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.setMicCallback
    setMicCallback: *const fn (callback: RecordCallback, context: ?*anyopaque, forceInternal: c_int) callconv(.C) void,
    getHeadphoneState: *const fn (headphone: ?*c_int, headsetmic: ?*c_int, changeCallback: *const fn (headphone: c_int, mic: c_int) callconv(.C) void) callconv(.C) void,
    setOutputsActive: *const fn (headphone: c_int, mic: c_int) callconv(.C) void,

    // 1.5
    /// Removes the given SoundSource object from its channel, whether it’s in the default channel or a channel created with playdate→sound→addChannel(). Returns 1 if a source was removed, 0 if the source wasn’t in a channel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.removeSource
    removeSource: *const fn (?*SoundSource) callconv(.C) void,

    // 1.12
    signal: *const PlaydateSoundSignal,

    // 2.2
    getError: *const fn () callconv(.C) [*c]const u8,
};

//data is mono
pub const RecordCallback = *const fn (context: ?*anyopaque, buffer: [*c]i16, length: c_int) callconv(.C) c_int;
// len is # of samples in each buffer, function should return 1 if it produced output
pub const AudioSourceFunction = *const fn (context: ?*anyopaque, left: [*c]i16, right: [*c]i16, len: c_int) callconv(.C) c_int;
pub const SndCallbackProc = *const fn (c: ?*SoundSource) callconv(.C) void;

pub const SoundChannel = opaque {};
pub const SoundSource = opaque {};
pub const SoundEffect = opaque {};
pub const PDSynthSignalValue = opaque {};

pub const PlaydateSoundChannel = extern struct {
    /// Returns a new SoundChannel object.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.newChannel
    newChannel: *const fn () callconv(.C) ?*SoundChannel,
    /// Frees the given SoundChannel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.freeChannel
    freeChannel: *const fn (channel: ?*SoundChannel) callconv(.C) void,
    /// Adds a SoundSource to the channel. If a source is not assigned to a channel, it plays on the default global channel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.addSource
    addSource: *const fn (channel: ?*SoundChannel, source: ?*SoundSource) callconv(.C) c_int,
    /// Removes a SoundSource to the channel. Returns 1 if the source was found in (and removed from) the channel, otherwise 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.removeSource
    removeSource: *const fn (channel: ?*SoundChannel, source: ?*SoundSource) callconv(.C) c_int,
    /// Creates a new SoundSource using the given data provider callback and adds it to the channel.   AudioSourceFunction  int AudioSourceFunction(void* context, int16_t* left, int16_t* right, int len)    This function should fill the passed-in left buffer (and right if it’s a stereo source) with len samples each and return 1, or return 0 if the source is silent through the cycle. The caller takes ownership of the allocated SoundSource, and should free it with    playdate->system->realloc(source, 0);    when it is not longer in use.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.addCallbackSource
    addCallbackSource: *const fn (?*SoundChannel, AudioSourceFunction, ?*anyopaque, c_int) callconv(.C) ?*SoundSource,
    /// Adds a SoundEffect to the channel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.addEffect
    addEffect: *const fn (channel: ?*SoundChannel, effect: ?*SoundEffect) callconv(.C) void,
    /// Removes a SoundEffect from the channel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.removeEffect
    removeEffect: *const fn (channel: ?*SoundChannel, effect: ?*SoundEffect) callconv(.C) void,
    /// Sets the volume for the channel, in the range [0-1].
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.setVolume
    setVolume: *const fn (channel: ?*SoundChannel, f32) callconv(.C) void,
    /// Gets the volume for the channel, in the range [0-1].
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.getVolume
    getVolume: *const fn (channel: ?*SoundChannel) callconv(.C) f32,
    /// Sets a signal to modulate the channel volume. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.setVolumeModulator
    setVolumeModulator: *const fn (channel: ?*SoundChannel, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Gets a signal modulating the channel volume.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.getVolumeModulator
    getVolumeModulator: *const fn (channel: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
    /// Sets the pan parameter for the channel. Valid values are in the range [-1,1], where -1 is left, 0 is center, and 1 is right.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.setPan
    setPan: *const fn (channel: ?*SoundChannel, pan: f32) callconv(.C) void,
    /// Sets a signal to modulate the channel pan. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.setPanModulator
    setPanModulator: *const fn (channel: ?*SoundChannel, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Gets a signal modulating the channel pan.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.getPanModulator
    getPanModulator: *const fn (channel: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
    /// Returns a signal that follows the volume of the channel before effects are applied.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.getDryLevelSignal
    getDryLevelSignal: *const fn (channe: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
    /// Returns a signal that follows the volume of the channel after effects are applied.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.channel.getWetLevelSignal
    getWetLevelSignal: *const fn (channel: ?*SoundChannel) callconv(.C) ?*PDSynthSignalValue,
};

pub const FilePlayer = SoundSource;
pub const PlaydateSoundFileplayer = extern struct {
    /// Allocates a new FilePlayer.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.newPlayer
    newPlayer: *const fn () callconv(.C) ?*FilePlayer,
    /// Frees the given player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.freePlayer
    freePlayer: *const fn (player: ?*FilePlayer) callconv(.C) void,
    /// Prepares player to stream the file at path. Returns 1 if the file exists, otherwise 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.loadIntoPlayer
    loadIntoPlayer: *const fn (player: ?*FilePlayer, path: [*c]const u8) callconv(.C) c_int,
    /// Sets the buffer length of player to bufferLen seconds;
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setBufferLength
    setBufferLength: *const fn (player: ?*FilePlayer, bufferLen: f32) callconv(.C) void,
    /// Starts playing the file player. If repeat is greater than one, it loops the given number of times. If zero, it loops endlessly until it is stopped with playdate->sound->fileplayer->stop(). Returns 1 on success, 0 if buffer allocation failed.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.play
    play: *const fn (player: ?*FilePlayer, repeat: c_int) callconv(.C) c_int,
    /// Returns one if player is playing, zero if not.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.isPlaying
    isPlaying: *const fn (player: ?*FilePlayer) callconv(.C) c_int,
    /// Pauses the file player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.pause
    pause: *const fn (player: ?*FilePlayer) callconv(.C) void,
    /// Stops playing the file.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.stop
    stop: *const fn (player: ?*FilePlayer) callconv(.C) void,
    /// Sets the playback volume for left and right channels of player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setVolume
    setVolume: *const fn (player: ?*FilePlayer, left: f32, right: f32) callconv(.C) void,
    /// Gets the left and right channel playback volume for player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.getVolume
    getVolume: *const fn (player: ?*FilePlayer, left: ?*f32, right: ?*f32) callconv(.C) void,
    /// Returns the length, in seconds, of the file loaded into player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.getLength
    getLength: *const fn (player: ?*FilePlayer) callconv(.C) f32,
    /// Sets the current offset in seconds.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setOffset
    setOffset: *const fn (player: ?*FilePlayer, offset: f32) callconv(.C) void,
    /// Sets the playback rate for the player. 1.0 is normal speed, 0.5 is down an octave, 2.0 is up an octave, etc. Unlike sampleplayers, fileplayers can’t play in reverse (i.e., rate < 0).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setRate
    setRate: *const fn (player: ?*FilePlayer, rate: f32) callconv(.C) void,
    /// Sets the start and end of the loop region for playback, in seconds. If end is omitted, the end of the file is used.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setLoopRange
    setLoopRange: *const fn (player: ?*FilePlayer, start: f32, end: f32) callconv(.C) void,
    /// Returns one if player has underrun, zero if not.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.didUnderrun
    didUnderrun: *const fn (player: ?*FilePlayer) callconv(.C) c_int,
    /// Sets a function to be called when playback has completed. This is an alias for playdate→sound→source→setFinishCallback().   sndCallbackProc  typedef void sndCallbackProc(SoundSource* c, void* userdata);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setFinishCallback
    setFinishCallback: *const fn (player: ?*FilePlayer, callback: SndCallbackProc) callconv(.C) void,
    setLoopCallback: *const fn (player: ?*FilePlayer, callback: SndCallbackProc) callconv(.C) void,
    /// Returns the current offset in seconds for player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.getOffset
    getOffset: *const fn (player: ?*FilePlayer) callconv(.C) f32,
    /// Returns the playback rate for player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.getRate
    getRate: *const fn (player: ?*FilePlayer) callconv(.C) f32,
    /// If flag evaluates to true, the player will restart playback (after an audible stutter) as soon as data is available.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.setStopOnUnderrun
    setStopOnUnderrun: *const fn (player: ?*FilePlayer, flag: c_int) callconv(.C) void,
    /// Changes the volume of the fileplayer to left and right over a length of len sample frames, then calls the provided callback (if set).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.fileplayer.fadeVolume
    fadeVolume: *const fn (player: ?*FilePlayer, left: f32, right: f32, len: i32, finishCallback: SndCallbackProc) callconv(.C) void,
    setMP3StreamSource: *const fn (
        player: ?*FilePlayer,
        dataSource: *const fn (data: [*c]u8, bytes: c_int, userdata: ?*anyopaque) callconv(.C) c_int,
        userdata: ?*anyopaque,
        bufferLen: f32,
    ) callconv(.C) void,
};

pub const AudioSample = opaque {};
pub const SamplePlayer = SoundSource;

pub const SoundFormat = enum(c_uint) {
    kSound8bitMono = 0,
    kSound8bitStereo = 1,
    kSound16bitMono = 2,
    kSound16bitStereo = 3,
    kSoundADPCMMono = 4,
    kSoundADPCMStereo = 5,
};
pub inline fn SoundFormatIsStereo(f: SoundFormat) bool {
    return @intFromEnum(f) & 1;
}
pub inline fn SoundFormatIs16bit(f: SoundFormat) bool {
    return switch (f) {
        .kSound16bitMono,
        .kSound16bitStereo,
        .kSoundADPCMMono,
        .kSoundADPCMStereo,
        => true,
        else => false,
    };
}
pub inline fn SoundFormat_bytesPerFrame(fmt: SoundFormat) u32 {
    return (if (SoundFormatIsStereo(fmt)) 2 else 1) *
        (if (SoundFormatIs16bit(fmt)) 2 else 1);
}

pub const PlaydateSoundSample = extern struct {
    /// Allocates and returns a new AudioSample with a buffer large enough to load a file of length bytes.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sample.newSampleBuffer
    newSampleBuffer: *const fn (byteCount: c_int) callconv(.C) ?*AudioSample,
    /// Loads the sound data from the file at path into an existing AudioSample, sample.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sample.loadIntoSample
    loadIntoSample: *const fn (sample: ?*AudioSample, path: [*c]const u8) callconv(.C) c_int,
    /// Allocates and returns a new AudioSample, with the sound data loaded in memory. If there is no file at path, the function returns null.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sample.load
    load: *const fn (path: [*c]const u8) callconv(.C) ?*AudioSample,
    /// Returns a new AudioSample referencing the given audio data. The sample keeps a pointer to the data instead of copying it, so the data must remain valid while the sample is active. format is one of the following values:   SoundFormat  typedef enum { kSound8bitMono = 0, kSound8bitStereo = 1, kSound16bitMono = 2, kSound16bitStereo = 3, kSoundADPCMMono = 4, kSoundADPCMStereo = 5 } SoundFormat;    pd_api_sound.h also provides some helper macros and functions:    #define SoundFormatIsStereo(f) ((f)&1) #define SoundFormatIs16bit(f) ((f)>=kSound16bitMono) static inline uint32_t SoundFormat_bytesPerFrame(SoundFormat fmt);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sample.newSampleFromData
    newSampleFromData: *const fn (data: [*c]u8, format: SoundFormat, sampleRate: u32, byteCount: c_int) callconv(.C) ?*AudioSample,
    getData: *const fn (sample: ?*AudioSample, data: ?*[*c]u8, format: [*c]SoundFormat, sampleRate: ?*u32, byteLength: ?*u32) callconv(.C) void,
    /// Frees the given sample.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sample.freeSample
    freeSample: *const fn (sample: ?*AudioSample) callconv(.C) void,
    /// Returns the length, in seconds, of sample.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sample.getLength
    getLength: *const fn (sample: ?*AudioSample) callconv(.C) f32,
};

pub const PlaydateSoundSampleplayer = extern struct {
    /// Allocates and returns a new SamplePlayer.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.newPlayer
    newPlayer: *const fn () callconv(.C) ?*SamplePlayer,
    /// Frees the given player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.freePlayer
    freePlayer: *const fn (?*SamplePlayer) callconv(.C) void,
    /// Assigns sample to player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setSample
    setSample: *const fn (player: ?*SamplePlayer, sample: ?*AudioSample) callconv(.C) void,
    /// Starts playing the sample in player.   If repeat is greater than one, it loops the given number of times. If zero, it loops endlessly until it is stopped with playdate->sound->sampleplayer->stop(). If negative one, it does ping-pong looping.   rate is the playback rate for the sample; 1.0 is normal speed, 0.5 is down an octave, 2.0 is up an octave, etc.   Returns 1 on success (which is always, currently).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.play
    play: *const fn (player: ?*SamplePlayer, repeat: c_int, rate: f32) callconv(.C) c_int,
    /// Returns one if player is playing a sample, zero if not.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.isPlaying
    isPlaying: *const fn (player: ?*SamplePlayer) callconv(.C) c_int,
    /// Stops playing the sample.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.stop
    stop: *const fn (player: ?*SamplePlayer) callconv(.C) void,
    /// Sets the playback volume for left and right channels.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setVolume
    setVolume: *const fn (player: ?*SamplePlayer, left: f32, right: f32) callconv(.C) void,
    /// Gets the current left and right channel volume of the sampleplayer.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.getVolume
    getVolume: *const fn (player: ?*SamplePlayer, left: ?*f32, right: ?*f32) callconv(.C) void,
    /// Returns the length, in seconds, of the sample assigned to player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.getLength
    getLength: *const fn (player: ?*SamplePlayer) callconv(.C) f32,
    /// Sets the current offset of the SamplePlayer, in seconds.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setOffset
    setOffset: *const fn (player: ?*SamplePlayer, offset: f32) callconv(.C) void,
    /// Sets the playback rate for the player. 1.0 is normal speed, 0.5 is down an octave, 2.0 is up an octave, etc. A negative rate produces backwards playback for PCM files, but does not work for ADPCM-encoded files.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setRate
    setRate: *const fn (player: ?*SamplePlayer, rate: f32) callconv(.C) void,
    /// When used with a repeat of -1, does ping-pong looping, with a start and end position in frames.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setPlayRange
    setPlayRange: *const fn (player: ?*SamplePlayer, start: c_int, end: c_int) callconv(.C) void,
    /// Sets a function to be called when playback has completed. See sndCallbackProc.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setFinishCallback
    setFinishCallback: *const fn (player: ?*SamplePlayer, callback: ?SndCallbackProc) callconv(.C) void,
    setLoopCallback: *const fn (player: ?*SamplePlayer, callback: ?SndCallbackProc) callconv(.C) void,
    /// Returns the current offset in seconds for player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.getOffset
    getOffset: *const fn (player: ?*SamplePlayer) callconv(.C) f32,
    /// Returns the playback rate for player.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.getRate
    getRate: *const fn (player: ?*SamplePlayer) callconv(.C) f32,
    /// Pauses or resumes playback.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sampleplayer.setPaused
    setPaused: *const fn (player: ?*SamplePlayer, flag: c_int) callconv(.C) void,
};

pub const PDSynth = SoundSource;
pub const SoundWaveform = enum(c_uint) {
    kWaveformSquare = 0,
    kWaveformTriangle = 1,
    kWaveformSine = 2,
    kWaveformNoise = 3,
    kWaveformSawtooth = 4,
    kWaveformPOPhase = 5,
    kWaveformPODigital = 6,
    kWaveformPOVosim = 7,
};
pub const NOTE_C4 = 60.0;
pub const MIDINote = f32;
pub inline fn pd_noteToFrequency(n: MIDINote) f32 {
    return 440 * std.math.pow(f32, 2, (n - 69) / 12.0);
}
pub inline fn pd_frequencyToNote(f: f32) MIDINote {
    return 12 * std.math.log(f32, 2, f) - 36.376316562;
}

// generator render callback
// samples are in Q8.24 format. left is either the left channel or the single mono channel,
// right is non-NULL only if the stereo flag was set in the setGenerator() call.
// nsamples is at most 256 but may be shorter
// rate is Q0.32 per-frame phase step, drate is per-frame rate step (i.e., do rate += drate every frame)
// return value is the number of sample frames rendered
pub const SynthRenderFunc = *const fn (userdata: ?*anyopaque, left: [*c]i32, right: [*c]i32, nsamples: c_int, rate: u32, drate: i32) callconv(.C) c_int;

// generator event callbacks

// len == -1 if indefinite
pub const SynthNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, velocity: f32, len: f32) callconv(.C) void;

pub const SynthReleaseFunc = *const fn (?*anyopaque, c_int) callconv(.C) void;
pub const SynthSetParameterFunc = *const fn (?*anyopaque, c_int, f32) callconv(.C) c_int;
pub const SynthDeallocFunc = *const fn (?*anyopaque) callconv(.C) void;

pub const PlaydateSoundSynth = extern struct {
    /// Creates a new synth object.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.newSynth
    newSynth: *const fn () callconv(.C) ?*PDSynth,
    /// Frees a synth object, first removing it from the sound engine if needed.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.freeSynth
    freeSynth: *const fn (synth: ?*PDSynth) callconv(.C) void,

    /// Sets the waveform of the synth. The SoundWaveform enum contains the following values:   SoundWaveform  typedef enum { kWaveformSquare, kWaveformTriangle, kWaveformSine, kWaveformNoise, kWaveformSawtooth, kWaveformPOPhase, kWaveformPODigital, kWaveformPOVosim } SoundWaveform;
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setWaveform
    setWaveform: *const fn (synth: ?*PDSynth, wave: SoundWaveform) callconv(.C) void,
    /// GeneratorCallbacks  typedef int (*synthRenderFunc)(void* userdata, int32_t* left, int32_t* right, int nsamples, uint32_t rate, int32_t drate); typedef void (*synthNoteOnFunc)(void* userdata, MIDINote note, float velocity, float len); // len == -1 if indefinite typedef void (*synthReleaseFunc)(void* userdata, int endoffset); typedef int (*synthSetParameterFunc)(void* userdata, int parameter, float value); typedef void (*synthDeallocFunc)(void* userdata); typedef void* (*synthCopyUserdata)(void* userdata);    Provides custom waveform generator functions for the synth. These functions are called on the audio render thread, so they should return as quickly as possible. synthRenderFunc, the data provider callback, is the only required function.   synthRenderFunc: called every audio cycle to get the samples for playback. left (and right if setGenerator() was called with the stereo flag set) are sample buffers in Q8.24 format. rate is the amount to change a (Q32) phase accumulator each sample, and drate is the amount to change rate each sample. Custom synths can ignore this and use the note paramter in the noteOn function to handle pitch, but synth→setFrequencyModulator() won’t work as expected.   synthNoteOnFunc: called when the synth receives a note on event. len is the length of the note in seconds, or -1 if it’s not known yet when the note will end.   synthReleaseFunc: called when the synth receives a note off event. endoffset is how many samples into the current render cycle the note ends, allowing for sample-accurate timing.   synthSetParameterFunc: called when a parameter change is received from synth→setParameter() or a modulator.   synthDeallocFunc: called when the synth is being dealloced. This function should free anything that was allocated for the synth and also free the userdata itself.   synthCopyUserdata: called when synth→copy() needs a unique copy of the synth’s userdata. External objects should be retained or copied so that the object isn’t freed while the synth is still using it.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setGenerator
    setGenerator: *const fn (
        synth: ?*PDSynth,
        stereo: c_int,
        render: SynthRenderFunc,
        note_on: SynthNoteOnFunc,
        release: SynthReleaseFunc,
        set_param: SynthSetParameterFunc,
        dealloc: SynthDeallocFunc,
        userdata: ?*anyopaque,
    ) callconv(.C) void,
    /// Provides a sample for the synth to play. Sample data must be uncompressed PCM, not ADPCM.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setSample
    setSample: *const fn (
        synth: ?*PDSynth,
        sample: ?*AudioSample,
        sustain_start: u32,
        sustain_end: u32,
    ) callconv(.C) void,

    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setAttackTime
    setAttackTime: *const fn (synth: ?*PDSynth, attack: f32) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setDecayTime
    setDecayTime: *const fn (synth: ?*PDSynth, decay: f32) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setSustainLevel
    setSustainLevel: *const fn (synth: ?*PDSynth, sustain: f32) callconv(.C) void,
    /// Sets the parameters of the synth’s ADSR envelope.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setReleaseTime
    setReleaseTime: *const fn (synth: ?*PDSynth, release: f32) callconv(.C) void,

    /// Transposes the synth’s output by the given number of half steps. For example, if the transpose is set to 2 and a C note is played, the synth will output a D instead.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setTranspose
    setTranspose: *const fn (synth: ?*PDSynth, half_steps: f32) callconv(.C) void,

    /// Sets a signal to modulate the synth’s frequency. The signal is scaled so that a value of 1 doubles the synth pitch (i.e. an octave up) and -1 halves it (an octave down). Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setFrequencyModulator
    setFrequencyModulator: *const fn (synth: ?*PDSynth, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set frequency modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.getFrequencyModulator
    getFrequencyModulator: *const fn (synth: ?*PDSynth) callconv(.C) ?*PDSynthSignalValue,
    /// Sets a signal to modulate the synth’s output amplitude. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setAmplitudeModulator
    setAmplitudeModulator: *const fn (synth: ?*PDSynth, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set amplitude modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.getAmplitudeModulator
    getAmplitudeModulator: *const fn (synth: ?*PDSynth) callconv(.C) ?*PDSynthSignalValue,

    /// Returns the number of parameters advertised by the synth.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.getParameterCount
    getParameterCount: *const fn (synth: ?*PDSynth) callconv(.C) c_int,
    /// Sets the (1-based) parameter at position num to the given value. Returns 0 if num is not a valid parameter index.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setParameter
    setParameter: *const fn (synth: ?*PDSynth, parameter: c_int, value: f32) callconv(.C) c_int,
    /// Sets a signal to modulate the parameter at index num. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setParameterModulator
    setParameterModulator: *const fn (synth: ?*PDSynth, parameter: c_int, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set parameter modulator for the given index.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.getParameterModulator
    getParameterModulator: *const fn (synth: ?*PDSynth, parameter: c_int) callconv(.C) ?*PDSynthSignalValue,

    /// Plays a note on the synth, at the given frequency. Specify len = -1 to leave the note playing until a subsequent noteOff() call. If when is 0, the note is played immediately, otherwise the note is scheduled for the given time. Use playdate→sound→getCurrentTime() to get the current time.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.playNote
    playNote: *const fn (synth: ?*PDSynth, freq: f32, vel: f32, len: f32, when: u32) callconv(.C) void,
    /// The same as playNote but uses MIDI note (where 60 = C4) instead of frequency. Note that MIDINote is a typedef for `float', meaning fractional values are allowed (for all you microtuning enthusiasts).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.playMIDINote
    playMIDINote: *const fn (synth: ?*PDSynth, note: MIDINote, vel: f32, len: f32, when: u32) callconv(.C) void,
    /// Sends a note off event to the synth, either immediately (when = 0) or at the scheduled time.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.noteOff
    noteOff: *const fn (synth: ?*PDSynth, when: u32) callconv(.C) void,
    stop: *const fn (synth: ?*PDSynth) callconv(.C) void,

    /// Sets the playback volume (0.0 - 1.0) for the left and, if the synth is stereo, right channels of the synth. This is equivalent to    playdate->sound->source->setVolume((SoundSource*)synth, lvol, rvol);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setVolume
    setVolume: *const fn (synth: ?*PDSynth, left: f32, right: f32) callconv(.C) void,
    /// Gets the playback volume for the left and right (if stereo) channels of the synth. This is equivalent to    playdate->sound->source->getVolume((SoundSource*)synth, outlvol, outrvol);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.getVolume
    getVolume: *const fn (synth: ?*PDSynth, left: ?*f32, right: ?*f32) callconv(.C) void,

    /// Returns 1 if the synth is currently playing.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.isPlaying
    isPlaying: *const fn (synth: ?*PDSynth) callconv(.C) c_int,

    // 1.13
    /// Returns the synth’s envelope. The PDSynth object owns this envelope, so it must not be freed.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.getEnvelope
    getEnvelope: *const fn (synth: ?*PDSynth) callconv(.C) ?*PDSynthEnvelope, // synth keeps ownership--don't free this!

    // 2.2
    /// Sets a wavetable for the synth to play. Sample data must be 16-bit mono uncompressed. log2size is the base 2 logarithm of the number of samples in each waveform "cell" in the table, and columns and rows gives the number of cells in each direction; for example, if the wavetable is arranged in an 8x8 grid, columns and rows are both 8 and log2size is 6, since 2^6 = 8x8.   The function returns 1 on success. If it fails, use playdate→sound→getError() to get a human-readable error message.   The synth’s "position" in the wavetable is set manually with setParameter() or automated with setParameterModulator(). In some cases it’s easier to use a parameter that matches the waveform position in the table, in others (notably when using envelopes and lfos) it’s more convenient to use a 0-1 scale, so there’s some redundancy here. Parameters are     1: x position, values are from 0 to the table width   2: x position, values are from 0 to 1, parameter is scaled up to table width     For 2-D tables (height > 1):     3: y position, values are from 0 to the table height   4: y position, values are from 0 to 1, parameter is scaled up to table height
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.synth.setWavetable
    setWavetable: *const fn (synth: ?*PDSynth, sample: ?*AudioSample, log2size: c_int, columns: c_int, rows: c_int) callconv(.C) c_int,
};

pub const SequenceTrack = opaque {};
pub const SoundSequence = opaque {};
pub const SequenceFinishedCallback = *const fn (seq: ?*SoundSequence, userdata: ?*anyopaque) callconv(.C) void;

pub const PlaydateSoundSequence = extern struct {
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.newSequence
    newSequence: *const fn () callconv(.C) ?*SoundSequence,
    /// Creates or destroys a SoundSequence object.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.freeSequence
    freeSequence: *const fn (sequence: ?*SoundSequence) callconv(.C) void,

    loadMidiFile: *const fn (seq: ?*SoundSequence, path: [*c]const u8) callconv(.C) c_int,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.getTime
    getTime: *const fn (seq: ?*SoundSequence) callconv(.C) u32,
    /// Gets or sets the current time in the sequence, in samples since the start of the file. Note that which step this moves the sequence to depends on the current tempo.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.setTime
    setTime: *const fn (seq: ?*SoundSequence, time: u32) callconv(.C) void,
    /// Sets the looping range of the sequence. If loops is 0, the loop repeats endlessly.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.setLoops
    setLoops: *const fn (seq: ?*SoundSequence, loopstart: c_int, loopend: c_int, loops: c_int) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.getTempo
    getTempo: *const fn (seq: ?*SoundSequence) callconv(.C) c_int,
    /// Sets or gets the tempo of the sequence, in steps per second.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.setTempo
    setTempo: *const fn (seq: ?*SoundSequence, stepsPerSecond: c_int) callconv(.C) void,
    /// Returns the number of tracks in the sequence.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.getTrackCount
    getTrackCount: *const fn (seq: ?*SoundSequence) callconv(.C) c_int,
    /// Adds the given playdate.sound.track to the sequence.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.addTrack
    addTrack: *const fn (seq: ?*SoundSequence) callconv(.C) ?*SequenceTrack,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.getTrackAtIndex
    getTrackAtIndex: *const fn (seq: ?*SoundSequence, track: c_uint) callconv(.C) ?*SequenceTrack,
    /// Sets or gets the given SoundTrack object at position idx in the sequence.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.setTrackAtIndex
    setTrackAtIndex: *const fn (seq: ?*SoundSequence, ?*SequenceTrack, idx: c_uint) callconv(.C) void,
    /// Sends a stop signal to all playing notes on all tracks.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.allNotesOff
    allNotesOff: *const fn (seq: ?*SoundSequence) callconv(.C) void,

    // 1.1
    /// Returns 1 if the sequence is currently playing, otherwise 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.isPlaying
    isPlaying: *const fn (seq: ?*SoundSequence) callconv(.C) c_int,
    /// Returns the length of the longest track in the sequence, in steps. See also playdate.sound.track.getLength().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.getLength
    getLength: *const fn (seq: ?*SoundSequence) callconv(.C) u32,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.play
    play: *const fn (seq: ?*SoundSequence, finishCallback: SequenceFinishedCallback, userdata: ?*anyopaque) callconv(.C) void,
    /// Starts or stops playing the sequence. finishCallback is an optional function to be called when the sequence finishes playing or is stopped.   SequenceFinishedCallback  typedef void (*SequenceFinishedCallback)(SoundSequence* seq, void* userdata);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.stop
    stop: *const fn (seq: ?*SoundSequence) callconv(.C) void,
    /// Returns the step number the sequence is currently at. If timeOffset is not NULL, its contents are set to the current sample offset within the step.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.getCurrentStep
    getCurrentStep: *const fn (seq: ?*SoundSequence, timeOffset: ?*c_int) callconv(.C) c_int,
    /// Set the current step for the sequence. timeOffset is a sample offset within the step. If playNotes is set, notes at the given step (ignoring timeOffset) are played.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.sequence.setCurrentStep
    setCurrentStep: *const fn (seq: ?*SoundSequence, step: c_int, timeOffset: c_int, playNotes: c_int) callconv(.C) void,
};

pub const EffectProc = *const fn (e: ?*SoundEffect, left: [*c]i32, right: [*c]i32, nsamples: c_int, bufactive: c_int) callconv(.C) c_int;

pub const PlaydateSoundEffect = extern struct {
    /// effectProc  typedef int effectProc(SoundEffect* e, int32_t* left, int32_t* right, int nsamples, int bufactive);    Creates a new effect using the given processing function. bufactive is 1 if samples have been set in the left or right buffers. The function should return 1 if it changed the buffer samples, otherwise 0. left and right (if the effect is on a stereo channel) are sample buffers in Q8.24 format.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.newEffect
    newEffect: *const fn (proc: ?*const EffectProc, userdata: ?*anyopaque) callconv(.C) ?*SoundEffect,
    /// Frees the given effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.freeEffect
    freeEffect: *const fn (effect: ?*SoundEffect) callconv(.C) void,

    /// Sets the wet/dry mix for the effect. A level of 1 (full wet) replaces the input with the effect output; 0 leaves the effect out of the mix (which is useful if you’re using a delay line with taps and don’t want to hear the delay line itself).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.setMix
    setMix: *const fn (effect: ?*SoundEffect, level: f32) callconv(.C) void,
    /// Sets a signal to modulate the effect’s mix level. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.setMixModulator
    setMixModulator: *const fn (effect: ?*SoundEffect, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the current mix modulator for the effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.getMixModulator
    getMixModulator: *const fn (effect: ?*SoundEffect) callconv(.C) ?*PDSynthSignalValue,

    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.setUserdata
    setUserdata: *const fn (effect: ?*SoundEffect, userdata: ?*anyopaque) callconv(.C) void,
    /// Sets or gets a userdata value for the effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.getUserdata
    getUserdata: *const fn (effect: ?*SoundEffect) callconv(.C) ?*anyopaque,

    twopolefilter: *const PlaydateSoundEffectTwopolefilter,
    onepolefilter: *const PlaydateSoundEffectOnepolefilter,
    bitcrusher: *const PlaydateSoundEffectBitcrusher,
    ringmodulator: *const PlaydateSoundEffectRingmodulator,
    delayline: *const PlaydateSoundEffectDelayline,
    overdrive: *const PlaydateSoundEffectOverdrive,
};
pub const LFOType = enum(c_uint) {
    kLFOTypeSquare = 0,
    kLFOTypeTriangle = 1,
    kLFOTypeSine = 2,
    kLFOTypeSampleAndHold = 3,
    kLFOTypeSawtoothUp = 4,
    kLFOTypeSawtoothDown = 5,
    kLFOTypeArpeggiator = 6,
    kLFOTypeFunction = 7,
};
pub const PDSynthLFO = opaque {};
pub const PlaydateSoundLFO = extern struct {
    /// Returns a new LFO object, which can be used to modulate sounds. The type argument is one of the following values:   LFOType  typedef enum { kLFOTypeSquare, kLFOTypeTriangle, kLFOTypeSine, kLFOTypeSampleAndHold, kLFOTypeSawtoothUp, kLFOTypeSawtoothDown, kLFOTypeArpeggiator, kLFOTypeFunction } LFOType;
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.newLFO
    newLFO: *const fn (LFOType) callconv(.C) ?*PDSynthLFO,
    /// Frees the LFO.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.freeLFO
    freeLFO: *const fn (lfo: ?*PDSynthLFO) callconv(.C) void,

    /// Sets the LFO shape to one of the values given above.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setType
    setType: *const fn (lfo: ?*PDSynthLFO, type: LFOType) callconv(.C) void,
    /// Sets the LFO’s rate, in cycles per second.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setRate
    setRate: *const fn (lfo: ?*PDSynthLFO, rate: f32) callconv(.C) void,
    /// Sets the LFO’s phase, from 0 to 1.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setPhase
    setPhase: *const fn (lfo: ?*PDSynthLFO, phase: f32) callconv(.C) void,
    /// Sets the center value for the LFO.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setCenter
    setCenter: *const fn (lfo: ?*PDSynthLFO, center: f32) callconv(.C) void,
    /// Sets the depth of the LFO.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setDepth
    setDepth: *const fn (lfo: ?*PDSynthLFO, depth: f32) callconv(.C) void,
    /// Sets the LFO type to arpeggio, where the given values are in half-steps from the center note. For example, the sequence (0, 4, 7, 12) plays the notes of a major chord.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setArpeggiation
    setArpeggiation: *const fn (lfo: ?*PDSynthLFO, nSteps: c_int, steps: [*c]f32) callconv(.C) void,
    /// Provides a custom function for LFO values.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setFunction
    setFunction: *const fn (lfo: ?*PDSynthLFO, lfoFunc: *const fn (lfo: ?*PDSynthLFO, userdata: ?*anyopaque) callconv(.C) f32, userdata: ?*anyopaque, interpolate: c_int) callconv(.C) void,
    /// Sets an initial holdoff time for the LFO where the LFO remains at its center value, and a ramp time where the value increases linearly to its maximum depth. Values are in seconds.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setDelay
    setDelay: *const fn (lfo: ?*PDSynthLFO, holdoff: f32, ramptime: f32) callconv(.C) void,
    /// If retrigger is on, the LFO’s phase is reset to its initial phase (default 0) when a synth using the LFO starts playing a note.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setRetrigger
    setRetrigger: *const fn (lfo: ?*PDSynthLFO, flag: c_int) callconv(.C) void,

    /// Return the current output value of the LFO.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.getValue
    getValue: *const fn (lfo: ?*PDSynthLFO) callconv(.C) f32,

    // 1.10
    /// If global is set, the LFO is continuously updated whether or not it’s currently in use.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.lfo.setGlobal
    setGlobal: *const fn (lfo: ?*PDSynthLFO, global: c_int) callconv(.C) void,
};

pub const PDSynthEnvelope = opaque {};
pub const PlaydateSoundEnvelope = extern struct {
    /// Creates a new envelope with the given parameters.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.newEnvelope
    newEnvelope: *const fn (attack: f32, decay: f32, sustain: f32, release: f32) callconv(.C) ?*PDSynthEnvelope,
    /// Frees the envelope.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.freeEnvelope
    freeEnvelope: *const fn (env: ?*PDSynthEnvelope) callconv(.C) void,

    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setAttack
    setAttack: *const fn (env: ?*PDSynthEnvelope, attack: f32) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setDecay
    setDecay: *const fn (env: ?*PDSynthEnvelope, decay: f32) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setSustain
    setSustain: *const fn (env: ?*PDSynthEnvelope, sustain: f32) callconv(.C) void,
    /// Sets the ADSR parameters of the envelope.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setRelease
    setRelease: *const fn (env: ?*PDSynthEnvelope, release: f32) callconv(.C) void,

    /// Sets whether to use legato phrasing for the envelope. If the legato flag is set, when the envelope is re-triggered before it’s released, it remains in the sustain phase instead of jumping back to the attack phase.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setLegato
    setLegato: *const fn (env: ?*PDSynthEnvelope, flag: c_int) callconv(.C) void,
    /// If retrigger is on, the envelope always starts from 0 when a note starts playing, instead of the current value if it’s active.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setRetrigger
    setRetrigger: *const fn (env: ?*PDSynthEnvelope, flag: c_int) callconv(.C) void,

    /// Return the current output value of the envelope.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.getValue
    getValue: *const fn (env: ?*PDSynthEnvelope) callconv(.C) f32,

    // 1.13
    /// Smoothly changes the envelope’s shape from linear (amount=0) to exponential (amount=1).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setCurvature
    setCurvature: *const fn (env: ?*PDSynthEnvelope, amount: f32) callconv(.C) void,
    /// Changes the amount by which note velocity scales output level. At the default value of 1, output is proportional to velocity; at 0 velocity has no effect on output level.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setVelocitySensitivity
    setVelocitySensitivity: *const fn (env: ?*PDSynthEnvelope, velsens: f32) callconv(.C) void,
    /// Scales the envelope rate according to the played note. For notes below start, the envelope’s set rate is used; for notes above end envelope rates are scaled by the scaling parameter. Between the two notes the scaling factor is interpolated from 1.0 to scaling.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.envelope.setRateScaling
    setRateScaling: *const fn (env: ?*PDSynthEnvelope, scaling: f32, start: MIDINote, end: MIDINote) callconv(.C) void,
};

pub const PlaydateSoundSource = extern struct {
    /// Sets the playback volume (0.0 - 1.0) for left and right channels of the source.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.source.setVolume
    setVolume: *const fn (c: ?*SoundSource, lvol: f32, rvol: f32) callconv(.C) void,
    /// Gets the playback volume (0.0 - 1.0) for left and right channels of the source.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.source.getVolume
    getVolume: *const fn (c: ?*SoundSource, outl: ?*f32, outr: ?*f32) callconv(.C) void,
    /// Returns 1 if the source is currently playing.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.source.isPlaying
    isPlaying: *const fn (c: ?*SoundSource) callconv(.C) c_int,
    setFinishCallback: *const fn (c: ?*SoundSource, SndCallbackProc) callconv(.C) void,
};

pub const ControlSignal = opaque {};
pub const PlaydateControlSignal = extern struct {
    /// Creates a new control signal object.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.controlsignal.newSignal
    newSignal: *const fn () callconv(.C) ?*ControlSignal,
    /// Frees the given signal.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.controlsignal.freeSignal
    freeSignal: *const fn (signal: ?*ControlSignal) callconv(.C) void,
    /// Clears all events from the given signal.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.controlsignal.clearEvents
    clearEvents: *const fn (control: ?*ControlSignal) callconv(.C) void,
    /// Adds a value to the signal’s timeline at the given step. If interpolate is set, the value is interpolated between the previous step+value and this one.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.controlsignal.addEvent
    addEvent: *const fn (control: ?*ControlSignal, step: c_int, value: f32, c_int) callconv(.C) void,
    /// Removes the control event at the given step.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.controlsignal.removeEvent
    removeEvent: *const fn (control: ?*ControlSignal, step: c_int) callconv(.C) void,
    /// Returns the MIDI controller number for this ControlSignal, if it was created from a MIDI file via playdate→sound→sequence→loadMIDIFile().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.controlsignal.getMIDIControllerNumber
    getMIDIControllerNumber: *const fn (control: ?*ControlSignal) callconv(.C) c_int,
};

pub const PlaydateSoundTrack = extern struct {
    /// Returns a new SequenceTrack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.newTrack
    newTrack: *const fn () callconv(.C) ?*SequenceTrack,
    /// Frees the SequenceTrack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.freeTrack
    freeTrack: *const fn (track: ?*SequenceTrack) callconv(.C) void,

    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.setInstrument
    setInstrument: *const fn (track: ?*SequenceTrack, inst: ?*PDSynthInstrument) callconv(.C) void,
    /// Sets or gets the PDSynthInstrument assigned to the track.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getInstrument
    getInstrument: *const fn (track: ?*SequenceTrack) callconv(.C) ?*PDSynthInstrument,

    /// Adds a single note event to the track.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.addNoteEvent
    addNoteEvent: *const fn (track: ?*SequenceTrack, step: u32, len: u32, note: MIDINote, velocity: f32) callconv(.C) void,
    /// Removes the event at step playing note.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.removeNoteEvent
    removeNoteEvent: *const fn (track: ?*SequenceTrack, step: u32, note: MIDINote) callconv(.C) void,
    /// Clears all notes from the track.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.clearNotes
    clearNotes: *const fn (track: ?*SequenceTrack) callconv(.C) void,

    /// Returns the number of ControlSignal objects in the track.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getControlSignalCount
    getControlSignalCount: *const fn (track: ?*SequenceTrack) callconv(.C) c_int,
    /// Returns the ControlSignal at index idx.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getControlSignal
    getControlSignal: *const fn (track: ?*SequenceTrack, idx: c_int) callconv(.C) ?*ControlSignal,
    /// Clears all ControlSignals from the track.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.clearControlEvents
    clearControlEvents: *const fn (track: ?*SequenceTrack) callconv(.C) void,

    /// Returns the maximum number of simultaneously playing notes in the track. (Currently, this value is only set when the track was loaded from a MIDI file. We don’t yet track polyphony for user-created events.)
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getPolyphony
    getPolyphony: *const fn (track: ?*SequenceTrack) callconv(.C) c_int,
    /// Returns the number of voices currently playing in the track’s instrument.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.activeVoiceCount
    activeVoiceCount: *const fn (track: ?*SequenceTrack) callconv(.C) c_int,

    /// Mutes or unmutes the track.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.setMuted
    setMuted: *const fn (track: ?*SequenceTrack, mute: c_int) callconv(.C) void,

    // 1.1
    /// Returns the length, in steps, of the track—​that is, the step where the last note in the track ends.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getLength
    getLength: *const fn (track: ?*SequenceTrack) callconv(.C) u32,
    /// Returns the internal array index for the first note at the given step.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getIndexForStep
    getIndexForStep: *const fn (track: ?*SequenceTrack, step: u32) callconv(.C) c_int,
    /// If the given index is in range, sets the data in the out pointers and returns 1; otherwise, returns 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getNoteAtIndex
    getNoteAtIndex: *const fn (track: ?*SequenceTrack, index: c_int, outSteo: ?*u32, outLen: ?*u32, outeNote: ?*MIDINote, outVelocity: ?*f32) callconv(.C) c_int,

    //1.10
    /// Returns the ControlSignal for MIDI controller number controller, creating it if the create flag is set and it doesn’t yet exist.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.track.getSignalForController
    getSignalForController: *const fn (track: ?*SequenceTrack, controller: c_int, create: c_int) callconv(.C) ?*ControlSignal,
};

pub const PDSynthInstrument = SoundSource;
pub const PlaydateSoundInstrument = extern struct {
    /// Creates a new PDSynthInstrument object.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.newInstrument
    newInstrument: *const fn () callconv(.C) ?*PDSynthInstrument,
    /// Frees the given instrument, first removing it from the sound engine if needed.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.freeInstrument
    freeInstrument: *const fn (inst: ?*PDSynthInstrument) callconv(.C) void,
    /// Adds the given PDSynth to the instrument. The synth will respond to playNote events between rangeState and rangeEnd, inclusive. The transpose argument is in half-step units, and is added to the instrument’s transpose parameter. The function returns 1 if successful, or 0 if the synth is already in another instrument or channel.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.addVoice
    addVoice: *const fn (inst: ?*PDSynthInstrument, synth: ?*PDSynth, rangeStart: MIDINote, rangeEnd: MIDINote, transpose: f32) callconv(.C) c_int,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.playNote
    playNote: *const fn (inst: ?*PDSynthInstrument, frequency: f32, vel: f32, len: f32, when: u32) callconv(.C) ?*PDSynth,
    /// The instrument passes the playNote/playMIDINote() event to the synth in its collection that has been off for the longest, or has been playing longest if all synths are currently playing. See also playdate→sound→synth→playNote(). The PDSynth that received the playNote event is returned.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.playMIDINote
    playMIDINote: *const fn (inst: ?*PDSynthInstrument, note: MIDINote, vel: f32, len: f32, when: u32) callconv(.C) ?*PDSynth,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.setPitchBend
    setPitchBend: *const fn (inst: ?*PDSynthInstrument, bend: f32) callconv(.C) void,
    /// Sets the pitch bend and pitch bend range to be applied to the voices in the instrument.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.setPitchBendRange
    setPitchBendRange: *const fn (inst: ?*PDSynthInstrument, halfSteps: f32) callconv(.C) void,
    /// Sets the transpose parameter for all voices in the instrument.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.setTranspose
    setTranspose: *const fn (inst: ?*PDSynthInstrument, halfSteps: f32) callconv(.C) void,
    /// Forwards the noteOff() event to the synth currently playing the given note. See also playdate→sound→synth→noteOff().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.noteOff
    noteOff: *const fn (inst: ?*PDSynthInstrument, note: MIDINote, when: u32) callconv(.C) void,
    /// Sends a noteOff event to all voices in the instrument.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.allNotesOff
    allNotesOff: *const fn (inst: ?*PDSynthInstrument, when: u32) callconv(.C) void,
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.setVolume
    setVolume: *const fn (inst: ?*PDSynthInstrument, left: f32, right: f32) callconv(.C) void,
    /// Sets and gets the playback volume (0.0 - 1.0) for left and right channels of the synth. This is equivalent to    playdate->sound->source->setVolume((SoundSource*)instrument, lvol, rvol); playdate->sound->source->getVolume((SoundSource*)instrument, &lvol, &rvol);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.getVolume
    getVolume: *const fn (inst: ?*PDSynthInstrument, left: ?*f32, right: ?*f32) callconv(.C) void,
    /// Returns the number of voices in the instrument currently playing.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.instrument.activeVoiceCount
    activeVoiceCount: *const fn (inst: ?*PDSynthInstrument) callconv(.C) c_int,
};

pub const PDSynthSignal = opaque {};
pub const SignalStepFunc = *const fn (userdata: ?*anyopaque, ioframes: [*c]c_int, ifval: ?*f32) callconv(.C) f32;
// len = -1 for indefinite
pub const SignalNoteOnFunc = *const fn (userdata: ?*anyopaque, note: MIDINote, vel: f32, len: f32) callconv(.C) void;
// ended = 0 for note release, = 1 when note stops playing
pub const SignalNoteOffFunc = *const fn (userdata: ?*anyopaque, stopped: c_int, offset: c_int) callconv(.C) void;
pub const SignalDeallocFunc = *const fn (userdata: ?*anyopaque) callconv(.C) void;
pub const PlaydateSoundSignal = struct {
    /// SignalCallbacks  typedef float (*signalStepFunc)(void* userdata, int* iosamples, float* ifval); typedef void (*signalNoteOnFunc)(void* userdata, MIDINote note, float vel, float len); // len = -1 for indefinite typedef void (*signalNoteOffFunc)(void* userdata, int stopped, int offset); // ended = 0 for note release, = 1 when note stops playing typedef void (*signalDeallocFunc)(void* userdata);    Provides a custom implementation for the signal. signalStepFunc step is the only required function, returning the value at the end of the current frame. When called, the ioframes pointer contains the number of samples until the end of the frame. If the signal needs to provide a value in the middle of the frame (e.g. an LFO that needs to be sample-accurate) it should return the "interframe" value in ifval and set iosamples to the sample offset of the value. The functions are called on the audio render thread, so they should return as quickly as possible.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.signal.newSignal
    newSignal: *const fn (step: SignalStepFunc, noteOn: SignalNoteOnFunc, noteOff: SignalNoteOffFunc, dealloc: SignalDeallocFunc, userdata: ?*anyopaque) callconv(.C) ?*PDSynthSignal,
    /// Frees a signal created with playdate→sound→signal→newSignal().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.signal.freeSignal
    freeSignal: *const fn (signal: ?*PDSynthSignal) callconv(.C) void,
    /// Returns the current output value of signal. The signal can be a custom signal created with newSignal(), or any of the PDSynthSignal subclasses.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.signal.getValue
    getValue: *const fn (signal: ?*PDSynthSignal) callconv(.C) f32,
    /// Scales the signal’s output by the given factor. The scale is applied before the offset.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.signal.setValueScale
    setValueScale: *const fn (signal: ?*PDSynthSignal, scale: f32) callconv(.C) void,
    /// Offsets the signal’s output by the given amount.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.signal.setValueOffset
    setValueOffset: *const fn (signal: ?*PDSynthSignal, offset: f32) callconv(.C) void,
};

// EFFECTS

// A SoundEffect processes the output of a channel's SoundSources

const TwoPoleFilter = SoundEffect;
const TwoPoleFilterType = enum(c_int) {
    FilterTypeLowPass,
    FilterTypeHighPass,
    FilterTypeBandPass,
    FilterTypeNotch,
    FilterTypePEQ,
    FilterTypeLowShelf,
    FilterTypeHighShelf,
};
const PlaydateSoundEffectTwopolefilter = extern struct {
    /// Creates a new two pole filter effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.newFilter
    newFilter: *const fn () callconv(.C) ?*TwoPoleFilter,
    /// Frees the given filter.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.freeFilter
    freeFilter: *const fn (filter: ?*TwoPoleFilter) callconv(.C) void,
    /// TwoPoleFilterType  typedef enum { kFilterTypeLowPass, kFilterTypeHighPass, kFilterTypeBandPass, kFilterTypeNotch, kFilterTypePEQ, kFilterTypeLowShelf, kFilterTypeHighShelf } TwoPoleFilterType;    Sets the type of the filter.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.setType
    setType: *const fn (filter: ?*TwoPoleFilter, type: TwoPoleFilterType) callconv(.C) void,
    /// Sets the center/corner frequency of the filter. Value is in Hz.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.setFrequency
    setFrequency: *const fn (filter: ?*TwoPoleFilter, frequency: f32) callconv(.C) void,
    /// Sets a signal to modulate the effect’s frequency. The signal is scaled so that a value of 1.0 corresponds to half the sample rate. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.setFrequencyModulator
    setFrequencyModulator: *const fn (filter: ?*TwoPoleFilter, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the filter’s current frequency modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.getFrequencyModulator
    getFrequencyModulator: *const fn (filter: ?*TwoPoleFilter) callconv(.C) ?*PDSynthSignalValue,
    /// Sets the filter gain.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.setGain
    setGain: *const fn (filter: ?*TwoPoleFilter, f32) callconv(.C) void,
    /// Sets the filter resonance.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.setResonance
    setResonance: *const fn (filter: ?*TwoPoleFilter, f32) callconv(.C) void,
    /// Sets a signal to modulate the filter resonance. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.setResonanceModulator
    setResonanceModulator: *const fn (filter: ?*TwoPoleFilter, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the filter’s current resonance modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.twopolefilter.getResonanceModulator
    getResonanceModulator: *const fn (filter: ?*TwoPoleFilter) callconv(.C) ?*PDSynthSignalValue,
};

pub const OnePoleFilter = SoundEffect;
pub const PlaydateSoundEffectOnepolefilter = extern struct {
    /// Creates a new one pole filter.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.onepolefilter.newFilter
    newFilter: *const fn () callconv(.C) ?*OnePoleFilter,
    /// Frees the filter.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.onepolefilter.freeFilter
    freeFilter: *const fn (filter: ?*OnePoleFilter) callconv(.C) void,
    /// Sets the filter’s single parameter (cutoff frequency) to p. Values above 0 (up to 1) are high-pass, values below 0 (down to -1) are low-pass.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.onepolefilter.setParameter
    setParameter: *const fn (filter: ?*OnePoleFilter, parameter: f32) callconv(.C) void,
    /// Sets a signal to modulate the filter parameter. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.onepolefilter.setParameterModulator
    setParameterModulator: *const fn (filter: ?*OnePoleFilter, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the filter’s current parameter modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.onepolefilter.getParameterModulator
    getParameterModulator: *const fn (filter: ?*OnePoleFilter) callconv(.C) ?*PDSynthSignalValue,
};

pub const BitCrusher = SoundEffect;
pub const PlaydateSoundEffectBitcrusher = extern struct {
    /// Returns a new BitCrusher effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.newBitCrusher
    newBitCrusher: *const fn () callconv(.C) ?*BitCrusher,
    /// Frees the given effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.freeBitCrusher
    freeBitCrusher: *const fn (filter: ?*BitCrusher) callconv(.C) void,
    /// Sets the amount of crushing to amount. Valid values are 0 (no effect) to 1 (quantizing output to 1-bit).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.setAmount
    setAmount: *const fn (filter: ?*BitCrusher, amount: f32) callconv(.C) void,
    /// Sets a signal to modulate the crushing amount. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.setAmountModulator
    setAmountModulator: *const fn (filter: ?*BitCrusher, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.getAmountModulator
    getAmountModulator: *const fn (filter: ?*BitCrusher) callconv(.C) ?*PDSynthSignalValue,
    /// Sets the number of samples to repeat, quantizing the input in time. A value of 0 produces no undersampling, 1 repeats every other sample, etc.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.setUndersampling
    setUndersampling: *const fn (filter: ?*BitCrusher, undersampling: f32) callconv(.C) void,
    /// Sets a signal to modulate the undersampling amount. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.setUndersampleModulator
    setUndersampleModulator: *const fn (filter: ?*BitCrusher, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.bitcrusher.getUndersampleModulator
    getUndersampleModulator: *const fn (filter: ?*BitCrusher) callconv(.C) ?*PDSynthSignalValue,
};

pub const RingModulator = SoundEffect;
pub const PlaydateSoundEffectRingmodulator = extern struct {
    /// Returns a new ring modulator effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.ringmodulator.newRingmod
    newRingmod: *const fn () callconv(.C) ?*RingModulator,
    freeRingmod: *const fn (filter: ?*RingModulator) callconv(.C) void,
    /// Sets the frequency of the modulation signal.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.ringmodulator.setFrequency
    setFrequency: *const fn (filter: ?*RingModulator, frequency: f32) callconv(.C) void,
    /// Sets a signal to modulate the frequency of the ring modulator. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.ringmodulator.setFrequencyModulator
    setFrequencyModulator: *const fn (filter: ?*RingModulator, signal: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set frequency modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.ringmodulator.getFrequencyModulator
    getFrequencyModulator: *const fn (filter: ?*RingModulator) callconv(.C) ?*PDSynthSignalValue,
};

pub const DelayLine = SoundEffect;
pub const DelayLineTap = SoundSource;
pub const PlaydateSoundEffectDelayline = extern struct {
    /// Creates a new delay line effect. The length parameter is given in samples.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.newDelayLine
    newDelayLine: *const fn (length: c_int, stereo: c_int) callconv(.C) ?*DelayLine,
    /// Frees the delay line.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.freeDelayLine
    freeDelayLine: *const fn (filter: ?*DelayLine) callconv(.C) void,
    /// Changes the length of the delay line, clearing its contents.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.setLength
    setLength: *const fn (filter: ?*DelayLine, frames: c_int) callconv(.C) void,
    /// Sets the feedback level of the delay line.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.setFeedback
    setFeedback: *const fn (filter: ?*DelayLine, fb: f32) callconv(.C) void,
    /// Returns a new tap on the delay line, at the given position. delay must be less than or equal to the length of the delay line.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.addTap
    addTap: *const fn (filter: ?*DelayLine, delay: c_int) callconv(.C) ?*DelayLineTap,

    // note that DelayLineTap is a SoundSource, not a SoundEffect
    /// Frees a tap previously created with playdate→sound→delayline→addTap(), first removing it from the sound engine if needed.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.freeTap
    freeTap: *const fn (tap: ?*DelayLineTap) callconv(.C) void,
    /// Sets the position of the tap on the delay line, up to the delay line’s length.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.setTapDelay
    setTapDelay: *const fn (t: ?*DelayLineTap, frames: c_int) callconv(.C) void,
    /// Sets a signal to modulate the tap delay. If the signal is continuous (e.g. an envelope or a triangle LFO, but not a square LFO) playback is sped up or slowed down to compress or expand time. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.setTapDelayModulator
    setTapDelayModulator: *const fn (t: ?*DelayLineTap, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the current delay modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.getTapDelayModulator
    getTapDelayModulator: *const fn (t: ?*DelayLineTap) callconv(.C) ?*PDSynthSignalValue,
    /// If the delay line is stereo and flip is set, the tap outputs the delay line’s left channel to its right output and vice versa.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.delayline.setTapChannelsFlipped
    setTapChannelsFlipped: *const fn (t: ?*DelayLineTap, flip: c_int) callconv(.C) void,
};

pub const Overdrive = SoundEffect;
pub const PlaydateSoundEffectOverdrive = extern struct {
    /// Returns a new overdrive effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.newOverdrive
    newOverdrive: *const fn () callconv(.C) ?*Overdrive,
    /// Frees the given effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.freeOverdrive
    freeOverdrive: *const fn (filter: ?*Overdrive) callconv(.C) void,
    /// Sets the gain of the overdrive effect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.setGain
    setGain: *const fn (o: ?*Overdrive, gain: f32) callconv(.C) void,
    /// Sets the level where the amplified input clips.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.setLimit
    setLimit: *const fn (o: ?*Overdrive, limit: f32) callconv(.C) void,
    /// Sets a signal to modulate the limit parameter. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.setLimitModulator
    setLimitModulator: *const fn (o: ?*Overdrive, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set limit modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.getLimitModulator
    getLimitModulator: *const fn (o: ?*Overdrive) callconv(.C) ?*PDSynthSignalValue,
    /// Adds an offset to the upper and lower limits to create an asymmetric clipping.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.setOffset
    setOffset: *const fn (o: ?*Overdrive, offset: f32) callconv(.C) void,
    /// Sets a signal to modulate the offset parameter. Set to NULL to clear the modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.setOffsetModulator
    setOffsetModulator: *const fn (o: ?*Overdrive, mod: ?*PDSynthSignalValue) callconv(.C) void,
    /// Returns the currently set offset modulator.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sound.effect.overdrive.getOffsetModulator
    getOffsetModulator: *const fn (o: ?*Overdrive) callconv(.C) ?*PDSynthSignalValue,
};

//////Sprite/////
pub const SpriteCollisionResponseType = enum(c_int) {
    CollisionTypeSlide,
    CollisionTypeFreeze,
    CollisionTypeOverlap,
    CollisionTypeBounce,
};
pub const PDRect = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub fn PDRectMake(x: f32, y: f32, width: f32, height: f32) callconv(.C) PDRect {
    return .{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
}

pub const CollisionPoint = extern struct {
    x: f32,
    y: f32,
};
pub const CollisionVector = extern struct {
    x: c_int,
    y: c_int,
};

pub const SpriteCollisionInfo = extern struct {
    sprite: ?*LCDSprite, // The sprite being moved
    other: ?*LCDSprite, // The sprite being moved
    responseType: SpriteCollisionResponseType, // The result of collisionResponse
    overlaps: u8, // True if the sprite was overlapping other when the collision started. False if it didn’t overlap but tunneled through other.
    ti: f32, // A number between 0 and 1 indicating how far along the movement to the goal the collision occurred
    move: CollisionPoint, // The difference between the original coordinates and the actual ones when the collision happened
    normal: CollisionVector, // The collision normal; usually -1, 0, or 1 in x and y. Use this value to determine things like if your character is touching the ground.
    touch: CollisionPoint, // The coordinates where the sprite started touching other
    spriteRect: PDRect, // The rectangle the sprite occupied when the touch happened
    otherRect: PDRect, // The rectangle the sprite being collided with occupied when the touch happened
};

pub const SpriteQueryInfo = extern struct {
    sprite: ?*LCDSprite, // The sprite being intersected by the segment
    // ti1 and ti2 are numbers between 0 and 1 which indicate how far from the starting point of the line segment the collision happened
    ti1: f32, // entry point
    ti2: f32, // exit point
    entryPoint: CollisionPoint, // The coordinates of the first intersection between sprite and the line segment
    exitPoint: CollisionPoint, // The coordinates of the second intersection between sprite and the line segment
};

pub const LCDSprite = opaque {};
pub const CWCollisionInfo = opaque {};
pub const CWItemInfo = opaque {};

pub const LCDSpriteDrawFunction = ?*const fn (sprite: ?*LCDSprite, bounds: PDRect, drawrect: PDRect) callconv(.C) void;
pub const LCDSpriteUpdateFunction = ?*const fn (sprite: ?*LCDSprite) callconv(.C) void;
pub const LCDSpriteCollisionFilterProc = ?*const fn (sprite: ?*LCDSprite, other: ?*LCDSprite) callconv(.C) SpriteCollisionResponseType;

pub const PlaydateSprite = extern struct {
    /// When flag is set to 1, this causes all sprites to draw each frame, whether or not they have been marked dirty. This may speed up the performance of your game if the system’s dirty rect tracking is taking up too much time - for example if there are many sprites moving around on screen at once.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setAlwaysRedraw
    setAlwaysRedraw: *const fn (flag: c_int) callconv(.C) void,
    /// Marks the given dirtyRect (in screen coordinates) as needing a redraw. Graphics drawing functions now call this automatically, adding their drawn areas to the sprite’s dirty list, so there’s usually no need to call this manually.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.addDirtyRect
    addDirtyRect: *const fn (dirtyRect: LCDRect) callconv(.C) void,
    /// Draws every sprite in the display list.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.drawSprites
    drawSprites: *const fn () callconv(.C) void,
    /// Updates and draws every sprite in the display list.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.updateAndDrawSprites
    updateAndDrawSprites: *const fn () callconv(.C) void,

    /// Allocates and returns a new LCDSprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.newSprite
    newSprite: *const fn () callconv(.C) ?*LCDSprite,
    freeSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    /// Allocates and returns a copy of the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.copy
    copy: *const fn (sprite: ?*LCDSprite) callconv(.C) ?*LCDSprite,

    /// Adds the given sprite to the display list, so that it is drawn in the current scene.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.addSprite
    addSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    /// Removes the given sprite from the display list.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.removeSprite
    removeSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    /// Removes the given count sized array of sprites from the display list.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.removeSprites
    removeSprites: *const fn (sprite: [*c]?*LCDSprite, count: c_int) callconv(.C) void,
    /// Removes all sprites from the display list.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.removeAllSprites
    removeAllSprites: *const fn () callconv(.C) void,
    /// Returns the total number of sprites in the display list.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getSpriteCount
    getSpriteCount: *const fn () callconv(.C) c_int,

    /// Sets the bounds of the given sprite with bounds.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setBounds
    setBounds: *const fn (sprite: ?*LCDSprite, bounds: PDRect) callconv(.C) void,
    /// Returns the bounds of the given sprite as an PDRect;
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getBounds
    getBounds: *const fn (sprite: ?*LCDSprite) callconv(.C) PDRect,
    /// Moves the given sprite to x, y and resets its bounds based on the bitmap dimensions and center.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.moveTo
    moveTo: *const fn (sprite: ?*LCDSprite, x: f32, y: f32) callconv(.C) void,
    /// Moves the given sprite to by offsetting its current position by dx, dy.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.moveBy
    moveBy: *const fn (sprite: ?*LCDSprite, dx: f32, dy: f32) callconv(.C) void,

    /// Sets the given sprite's image to the given bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setImage
    setImage: *const fn (sprite: ?*LCDSprite, image: ?*LCDBitmap, flip: LCDBitmapFlip) callconv(.C) void,
    /// Returns the LCDBitmap currently assigned to the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getImage
    getImage: *const fn (sprite: ?*LCDSprite) callconv(.C) ?*LCDBitmap,
    /// Sets the size. The size is used to set the sprite’s bounds when calling moveTo().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setSize
    setSize: *const fn (s: ?*LCDSprite, width: f32, height: f32) callconv(.C) void,
    /// Sets the Z order of the given sprite. Higher Z sprites are drawn on top of those with lower Z order.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setZIndex
    setZIndex: *const fn (s: ?*LCDSprite, zIndex: i16) callconv(.C) void,
    /// Returns the Z index of the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getZIndex
    getZIndex: *const fn (sprite: ?*LCDSprite) callconv(.C) i16,

    /// Sets the mode for drawing the sprite’s bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setDrawMode
    setDrawMode: *const fn (sprite: ?*LCDSprite, mode: LCDBitmapDrawMode) callconv(.C) void,
    /// Flips the bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setImageFlip
    setImageFlip: *const fn (sprite: ?*LCDSprite, flip: LCDBitmapFlip) callconv(.C) void,
    /// Returns the flip setting of the sprite’s bitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getImageFlip
    getImageFlip: *const fn (sprite: ?*LCDSprite) callconv(.C) LCDBitmapFlip,
    /// Specifies a stencil image to be set on the frame buffer before the sprite is drawn.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setStencil
    setStencil: *const fn (sprite: ?*LCDSprite, mode: ?*LCDBitmap) callconv(.C) void, // deprecated in favor of setStencilImage()

    /// Sets the clipping rectangle for sprite drawing.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setClipRect
    setClipRect: *const fn (sprite: ?*LCDSprite, clipRect: LCDRect) callconv(.C) void,
    /// Clears the sprite’s clipping rectangle.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.clearClipRect
    clearClipRect: *const fn (sprite: ?*LCDSprite) callconv(.C) void,
    /// Sets the clipping rectangle for all sprites with a Z index within startZ and endZ inclusive.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setClipRectsInRange
    setClipRectsInRange: *const fn (clipRect: LCDRect, startZ: c_int, endZ: c_int) callconv(.C) void,
    /// Clears the clipping rectangle for all sprites with a Z index within startZ and endZ inclusive.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.clearClipRectsInRange
    clearClipRectsInRange: *const fn (startZ: c_int, endZ: c_int) callconv(.C) void,

    /// Set the updatesEnabled flag of the given sprite (determines whether the sprite has its update function called). One is true, 0 is false.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setUpdatesEnabled
    setUpdatesEnabled: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    /// Get the updatesEnabled flag of the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.updatesEnabled
    updatesEnabled: *const fn (sprite: ?*LCDSprite) callconv(.C) c_int,
    /// Set the collisionsEnabled flag of the given sprite (along with the collideRect, this determines whether the sprite participates in collisions). One is true, 0 is false. Set to 1 by default.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setCollisionsEnabled
    setCollisionsEnabled: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    /// Get the collisionsEnabled flag of the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.collisionsEnabled
    collisionsEnabled: *const fn (sprite: ?*LCDSprite) callconv(.C) c_int,
    /// Set the visible flag of the given sprite (determines whether the sprite has its draw function called). One is true, 0 is false.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setVisible
    setVisible: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    /// Get the visible flag of the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.isVisible
    isVisible: *const fn (sprite: ?*LCDSprite) callconv(.C) c_int,
    /// Marking a sprite opaque tells the sprite system that it doesn’t need to draw anything underneath the sprite, since it will be overdrawn anyway. If you set an image without a mask/alpha channel on the sprite, it automatically sets the opaque flag.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setOpaque
    setOpaque: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,
    /// Forces the given sprite to redraw.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.markDirty
    markDirty: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    /// Sets the tag of the given sprite. This can be useful for identifying sprites or types of sprites when using the collision API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setTag
    setTag: *const fn (sprite: ?*LCDSprite, tag: u8) callconv(.C) void,
    /// Returns the tag of the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getTag
    getTag: *const fn (sprite: ?*LCDSprite) callconv(.C) u8,

    /// When flag is set to 1, the sprite will draw in screen coordinates, ignoring the currently-set drawOffset.   This only affects drawing, and should not be used on sprites being used for collisions, which will still happen in world-space.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setIgnoresDrawOffset
    setIgnoresDrawOffset: *const fn (sprite: ?*LCDSprite, flag: c_int) callconv(.C) void,

    /// Sets the update function for the given sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setUpdateFunction
    setUpdateFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteUpdateFunction) callconv(.C) void,
    /// Sets the draw function for the given sprite. Note that the callback is only called when the sprite is on screen and has a size specified via playdate→sprite→setSize() or playdate→sprite→setBounds().
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setDrawFunction
    setDrawFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteDrawFunction) callconv(.C) void,

    /// Sets x and y to the current position of sprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getPosition
    getPosition: *const fn (s: ?*LCDSprite, x: ?*f32, y: ?*f32) callconv(.C) void,

    // Collisions
    /// Frees and reallocates internal collision data, resetting everything to its default state.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.resetCollisionWorld
    resetCollisionWorld: *const fn () callconv(.C) void,

    /// Marks the area of the given sprite, relative to its bounds, to be checked for collisions with other sprites' collide rects.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setCollideRect
    setCollideRect: *const fn (sprite: ?*LCDSprite, collideRect: PDRect) callconv(.C) void,
    /// Returns the given sprite’s collide rect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getCollideRect
    getCollideRect: *const fn (sprite: ?*LCDSprite) callconv(.C) PDRect,
    /// Clears the given sprite’s collide rect.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.clearCollideRect
    clearCollideRect: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    // caller is responsible for freeing the returned array for all collision methods
    /// Set a callback that returns a SpriteCollisionResponseType for a collision between sprite and other.   LCDSpriteCollisionFilterProc  typedef SpriteCollisionResponseType LCDSpriteCollisionFilterProc(LCDSprite* sprite, LCDSprite* other);
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setCollisionResponseFunction
    setCollisionResponseFunction: *const fn (sprite: ?*LCDSprite, func: LCDSpriteCollisionFilterProc) callconv(.C) void,
    /// Returns the same values as playdate->sprite->moveWithCollisions() but does not actually move the sprite. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.checkCollisions
    checkCollisions: *const fn (sprite: ?*LCDSprite, goalX: f32, goalY: f32, actualX: ?*f32, actualY: ?*f32, len: ?*c_int) callconv(.C) [*c]SpriteCollisionInfo, // access results using const info = &results[i];
    /// Moves the given sprite towards goalX, goalY taking collisions into account and returns an array of SpriteCollisionInfo. len is set to the size of the array and actualX, actualY are set to the sprite’s position after collisions. If no collisions occurred, this will be the same as goalX, goalY. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.moveWithCollisions
    moveWithCollisions: *const fn (sprite: ?*LCDSprite, goalX: f32, goalY: f32, actualX: ?*f32, actualY: ?*f32, len: ?*c_int) callconv(.C) [*c]SpriteCollisionInfo,
    /// Returns an array of all sprites with collision rects containing the point at x, y. len is set to the size of the array. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.querySpritesAtPoint
    querySpritesAtPoint: *const fn (x: f32, y: f32, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    /// Returns an array of all sprites with collision rects that intersect the width by height rect at x, y. len is set to the size of the array. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.querySpritesInRect
    querySpritesInRect: *const fn (x: f32, y: f32, width: f32, height: f32, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    /// Returns an array of all sprites with collision rects that intersect the line connecting x1, y1 and  x2, y2. len is set to the size of the array. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.querySpritesAlongLine
    querySpritesAlongLine: *const fn (x1: f32, y1: f32, x2: f32, y2: f32, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    /// Returns an array of SpriteQueryInfo for all sprites with collision rects that intersect the line connecting x1, y1 and  x2, y2. len is set to the size of the array. If you don’t need this information, use querySpritesAlongLine() as it will be faster. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.querySpriteInfoAlongLine
    querySpriteInfoAlongLine: *const fn (x1: f32, y1: f32, x2: f32, y2: f32, len: ?*c_int) callconv(.C) [*c]SpriteQueryInfo, // access results using const info = &results[i];
    /// Returns an array of sprites that have collide rects that are currently overlapping the given sprite’s collide rect. len is set to the size of the array. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.overlappingSprites
    overlappingSprites: *const fn (sprite: ?*LCDSprite, len: ?*c_int) callconv(.C) [*c]?*LCDSprite,
    /// Returns an array of all sprites that have collide rects that are currently overlapping. Each consecutive pair of sprites is overlapping (eg. 0 & 1 overlap, 2 & 3 overlap, etc). len is set to the size of the array. The caller is responsible for freeing the returned array.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.allOverlappingSprites
    allOverlappingSprites: *const fn (len: ?*c_int) callconv(.C) [*c]?*LCDSprite,

    // added in 1.7
    /// Sets the sprite’s stencil to the given pattern.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setStencilPattern
    setStencilPattern: *const fn (sprite: ?*LCDSprite, pattern: [*c]u8) callconv(.C) void, //pattern is 8 bytes
    /// Clears the sprite’s stencil.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.clearStencil
    clearStencil: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setUserdata
    setUserdata: *const fn (sprite: ?*LCDSprite, userdata: ?*anyopaque) callconv(.C) void,
    /// Sets and gets the sprite’s userdata, an arbitrary pointer used for associating the sprite with other data.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getUserdata
    getUserdata: *const fn (sprite: ?*LCDSprite) callconv(.C) ?*anyopaque,

    // added in 1.10
    /// Specifies a stencil image to be set on the frame buffer before the sprite is drawn. If tile is set, the stencil will be tiled. Tiled stencils must have width evenly divisible by 32.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setStencilImage
    setStencilImage: *const fn (sprite: ?*LCDSprite, stencil: ?*LCDBitmap, tile: c_int) callconv(.C) void,

    // 2.1
    /// Sets the sprite’s drawing center as a fraction (ranging from 0.0 to 1.0) of the height and width. Default is 0.5, 0.5 (the center of the sprite). This means that when you call sprite→moveTo(sprite, x, y), the center of your sprite will be positioned at x, y. If you want x and y to represent the upper left corner of your sprite, specify the center as 0, 0.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.setCenter
    setCenter: *const fn (s: ?*LCDSprite, x: f32, y: f32) callconv(.C) void,
    /// Sets the values in outx and outy to the sprite’s drawing center as a fraction (ranging from 0.0 to 1.0) of the height and width.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-sprite.getCenter
    getCenter: *const fn (s: ?*LCDSprite, x: ?*f32, y: ?*f32) callconv(.C) void,
};

////////Lua///////
pub const LuaState = ?*anyopaque;
pub const LuaCFunction = ?*const fn (state: ?*LuaState) callconv(.C) c_int;
pub const LuaUDObject = opaque {};

//literal value
pub const LValType = enum(c_int) {
    Int = 0,
    Float = 1,
    Str = 2,
};
pub const LuaReg = extern struct {
    name: [*c]const u8,
    func: LuaCFunction,
};
pub const LuaType = enum(c_int) {
    TypeNil = 0,
    TypeBool = 1,
    TypeInt = 2,
    TypeFloat = 3,
    TypeString = 4,
    TypeTable = 5,
    TypeFunction = 6,
    TypeThread = 7,
    TypeObject = 8,
};
pub const LuaVal = extern struct {
    name: [*c]const u8,
    type: LValType,
    v: extern union {
        intval: c_uint,
        floatval: f32,
        strval: [*c]const u8,
    },
};
pub const PlaydateLua = extern struct {
    // these two return 1 on success, else 0 with an error message in outErr
    /// Adds the Lua function f to the Lua runtime, with name name. (name can be a table path using dots, e.g. if name = “mycode.myDrawingFunction” adds the function “myDrawingFunction” to the global table “myCode”.) Returns 1 on success or 0 with an error message in outErr.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.addFunction
    addFunction: *const fn (f: LuaCFunction, name: [*c]const u8, outErr: ?*[*c]const u8) callconv(.C) c_int,
    /// Creates a new "class" (i.e., a Lua metatable containing functions) with the given name and adds the given functions and constants to it. If the table is simply a list of functions that won’t be used as a metatable, isstatic should be set to 1 to create a plain table instead of a metatable. Please see C_API/Examples/Array for an example of how to use registerClass to create a Lua table-like object from C.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.registerClass
    registerClass: *const fn (name: [*c]const u8, reg: ?*const LuaReg, vals: [*c]const LuaVal, isstatic: c_int, outErr: ?*[*c]const u8) callconv(.C) c_int,

    /// Pushes a lua_CFunction onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushFunction
    pushFunction: *const fn (f: LuaCFunction) callconv(.C) void,
    /// If a class includes an __index function, it should call this first to check if the indexed variable exists in the metatable. If the indexMetatable() call returns 1, it has located the variable and put it on the stack, and the __index function should return 1 to indicate a value was found. If indexMetatable() doesn’t find a value, the __index function can then do its custom getter magic.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.indexMetatable
    indexMetatable: *const fn () callconv(.C) c_int,

    /// Stops the run loop.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.stop
    stop: *const fn () callconv(.C) void,
    /// Starts the run loop back up.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.start
    start: *const fn () callconv(.C) void,

    // stack operations
    /// Returns the number of arguments passed to the function.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgCount
    getArgCount: *const fn () callconv(.C) c_int,
    /// Returns the type of the variable at stack position pos. If the type is kTypeObject and outClass is non-NULL, it returns the name of the object’s metatable.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgType
    getArgType: *const fn (pos: c_int, outClass: ?*[*c]const u8) callconv(.C) LuaType,

    /// Returns 1 if the argument at the given position pos is nil.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.argIsNil
    argIsNil: *const fn (pos: c_int) callconv(.C) c_int,
    /// Returns one if the argument at position pos is true, zero if not.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgBool
    getArgBool: *const fn (pos: c_int) callconv(.C) c_int,
    /// Returns the argument at position pos as an int.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgInt
    getArgInt: *const fn (pos: c_int) callconv(.C) c_int,
    /// Returns the argument at position pos as a float.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgFloat
    getArgFloat: *const fn (pos: c_int) callconv(.C) f32,
    /// Returns the argument at position pos as a string.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgString
    getArgString: *const fn (pos: c_int) callconv(.C) [*c]const u8,
    /// Returns the argument at position pos as a string and sets outlen to its length.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgBytes
    getArgBytes: *const fn (pos: c_int, outlen: ?*usize) callconv(.C) [*c]const u8,
    /// Checks the object type of the argument at position pos and returns a pointer to it if it’s the correct type. Optionally sets outud to a pointer to the opaque LuaUDObject for the given stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getArgObject
    getArgObject: *const fn (pos: c_int, type: ?*i8, ?*?*LuaUDObject) callconv(.C) ?*anyopaque,

    /// Returns the argument at position pos as an LCDBitmap.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getBitmap
    getBitmap: *const fn (c_int) callconv(.C) ?*LCDBitmap,
    /// Returns the argument at position pos as an LCDSprite.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.getSprite
    getSprite: *const fn (c_int) callconv(.C) ?*LCDSprite,

    // for returning values back to Lua
    /// Pushes nil onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushNil
    pushNil: *const fn () callconv(.C) void,
    /// Pushes the int val onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushBool
    pushBool: *const fn (val: c_int) callconv(.C) void,
    /// Pushes the int val onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushInt
    pushInt: *const fn (val: c_int) callconv(.C) void,
    /// Pushes the float val onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushFloat
    pushFloat: *const fn (val: f32) callconv(.C) void,
    /// Pushes the string str onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushString
    pushString: *const fn (str: [*c]const u8) callconv(.C) void,
    /// Like pushString(), but pushes an arbitrary byte array to the stack, ignoring \0 characters.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushBytes
    pushBytes: *const fn (str: [*c]const u8, len: usize) callconv(.C) void,
    /// Pushes the LCDBitmap bitmap onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushBitmap
    pushBitmap: *const fn (bitmap: ?*LCDBitmap) callconv(.C) void,
    /// Pushes the LCDSprite sprite onto the stack.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushSprite
    pushSprite: *const fn (sprite: ?*LCDSprite) callconv(.C) void,

    /// Pushes the given custom object obj onto the stack and returns a pointer to the opaque LuaUDObject. type must match the class name used in playdate->lua->registerClass(). nValues is the number of slots to allocate for Lua values (see set/getObjectValue()).
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.pushObject
    pushObject: *const fn (obj: ?*anyopaque, type: ?*i8, nValues: c_int) callconv(.C) ?*LuaUDObject,
    /// Retains the opaque LuaUDObject obj and returns same.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.retainObject
    retainObject: *const fn (obj: ?*LuaUDObject) callconv(.C) ?*LuaUDObject,
    /// Releases the opaque LuaUDObject obj.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.releaseObject
    releaseObject: *const fn (obj: ?*LuaUDObject) callconv(.C) void,

    setObjectValue: *const fn (obj: ?*LuaUDObject, slot: c_int) callconv(.C) void,
    getObjectValue: *const fn (obj: ?*LuaUDObject, slot: c_int) callconv(.C) c_int,

    // calling lua from C has some overhead. use sparingly!
    callFunction_deprecated: *const fn (name: [*c]const u8, nargs: c_int) callconv(.C) void,
    /// Calls the Lua function name and and indicates that nargs number of arguments have already been pushed to the stack for the function to use. name can be a table path using dots, e.g. “playdate.apiVersion”. Returns 1 on success; on failure, returns 0 and puts an error message into the outerr pointer, if it’s set. Calling Lua from C is slow, so use sparingly.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-lua.callFunction
    callFunction: *const fn (name: [*c]const u8, nargs: c_int, outerr: ?*[*c]const u8) callconv(.C) c_int,
};

///////JSON///////
pub const JSONValueType = enum(c_int) {
    JSONNull = 0,
    JSONTrue = 1,
    JSONFalse = 2,
    JSONInteger = 3,
    JSONFloat = 4,
    JSONString = 5,
    JSONArray = 6,
    JSONTable = 7,
};
pub const JSONValue = extern struct {
    type: u8,
    data: extern union {
        intval: c_int,
        floatval: f32,
        stringval: [*c]u8,
        arrayval: ?*anyopaque,
        tableval: ?*anyopaque,
    },
};
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json_intValue
pub inline fn json_intValue(value: JSONValue) c_int {
    switch (@intFromEnum(value.type)) {
        .JSONInteger => return value.data.intval,
        .JSONFloat => return @intFromFloat(value.data.floatval),
        .JSONString => return std.fmt.parseInt(c_int, std.mem.span(value.data.stringval), 10) catch 0,
        .JSONTrue => return 1,
        else => return 0,
    }
}
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json_floatValue
pub inline fn json_floatValue(value: JSONValue) f32 {
    switch (@as(JSONValueType, @enumFromInt(value.type))) {
        .JSONInteger => return @floatFromInt(value.data.intval),
        .JSONFloat => return value.data.floatval,
        .JSONString => return 0,
        .JSONTrue => 1.0,
        else => return 0.0,
    }
}
    /// 
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json_boolValue
pub inline fn json_boolValue(value: JSONValue) c_int {
    return if (@as(JSONValueType, @enumFromInt(value.type)) == .JSONString)
        @intFromBool(value.data.stringval[0] != 0)
    else
        json_intValue(value);
}
    /// Note that a whole number encoded to JSON as a float might be decoded as an int. The above convenience functions can be used to convert a json_value to the required type.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json_stringValue
pub inline fn json_stringValue(value: JSONValue) [*c]u8 {
    return if (@as(JSONValueType, @enumFromInt(value.type)) == .JSONString)
        value.data.stringval
    else
        null;
}

// decoder

pub const JSONDecoder = extern struct {
    decodeError: *const fn (decoder: ?*JSONDecoder, @"error": [*c]const u8, linenum: c_int) callconv(.C) void,

    // the following functions are each optional
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) void,
    shouldDecodeTableValueForKey: ?*const fn (decoder: ?*JSONDecoder, key: [*c]const u8) callconv(.C) c_int,
    didDecodeTableValue: ?*const fn (decoder: ?*JSONDecoder, key: [*c]const u8, value: JSONValue) callconv(.C) void,
    shouldDecodeArrayValueAtIndex: ?*const fn (decoder: ?*JSONDecoder, pos: c_int) callconv(.C) c_int,
    didDecodeArrayValue: ?*const fn (decoder: ?*JSONDecoder, pos: c_int, value: JSONValue) callconv(.C) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) ?*anyopaque,

    userdata: ?*anyopaque,
    returnString: c_int, // when set, the decoder skips parsing and returns the current subtree as a string
    path: [*c]const u8, // updated during parsing, reflects current position in tree
};

// convenience functions for setting up a table-only or array-only decoder

pub inline fn json_setTableDecode(
    decoder: ?*JSONDecoder,
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) void,
    didDecodeTableValue: ?*const fn (decoder: ?*JSONDecoder, key: [*c]const u8, value: JSONValue) callconv(.C) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, name: JSONValueType) callconv(.C) ?*anyopaque,
) void {
    decoder.?.didDecodeTableValue = didDecodeTableValue;
    decoder.?.didDecodeArrayValue = null;
    decoder.?.willDecodeSublist = willDecodeSublist;
    decoder.?.didDecodeSublist = didDecodeSublist;
}

pub inline fn json_setArrayDecode(
    decoder: ?*JSONDecoder,
    willDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) void,
    didDecodeArrayValue: ?*const fn (decoder: ?*JSONDecoder, pos: c_int, value: JSONValue) callconv(.C) void,
    didDecodeSublist: ?*const fn (decoder: ?*JSONDecoder, name: [*c]const u8, type: JSONValueType) callconv(.C) ?*anyopaque,
) void {
    decoder.?.didDecodeTableValue = null;
    decoder.?.didDecodeArrayValue = didDecodeArrayValue;
    decoder.?.willDecodeSublist = willDecodeSublist;
    decoder.?.didDecodeSublist = didDecodeSublist;
}

pub const JSONReader = extern struct {
    read: *const fn (userdata: ?*anyopaque, buf: [*c]u8, bufsize: c_int) callconv(.C) c_int,
    userdata: ?*anyopaque,
};
pub const writeFunc = *const fn (userdata: ?*anyopaque, str: [*c]const u8, len: c_int) callconv(.C) void;

pub const JSONEncoder = extern struct {
    writeStringFunc: writeFunc,
    userdata: ?*anyopaque,

    state: u32, //this is pretty, startedTable, startedArray and depth bitfields combined

    startArray: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    addArrayMember: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    endArray: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    startTable: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    addTableMember: *const fn (encoder: ?*JSONEncoder, name: [*c]const u8, len: c_int) callconv(.C) void,
    endTable: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeNull: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeFalse: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeTrue: *const fn (encoder: ?*JSONEncoder) callconv(.C) void,
    writeInt: *const fn (encoder: ?*JSONEncoder, num: c_int) callconv(.C) void,
    writeDouble: *const fn (encoder: ?*JSONEncoder, num: f64) callconv(.C) void,
    writeString: *const fn (encoder: ?*JSONEncoder, str: [*c]const u8, len: c_int) callconv(.C) void,
};

pub const PlaydateJSON = extern struct {
    /// Populates the given json_encoder encoder with the functions necessary to encode arbitrary data into a JSON string. userdata is passed as the first argument of the given writeFunc write. When pretty is 1 the string is written with human-readable formatting.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json.initEncoder
    initEncoder: *const fn (encoder: ?*JSONEncoder, write: writeFunc, userdata: ?*anyopaque, pretty: c_int) callconv(.C) void,

    /// Equivalent to playdate.json.decode() in the Lua API.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json.decode
    decode: *const fn (functions: ?*JSONDecoder, reader: JSONReader, outval: ?*JSONValue) callconv(.C) c_int,
    /// Decodes a JSON file or string with the given decoder. An instance of json_decoder must implement decodeError. The remaining functions are optional although you’ll probably want to implement at least didDecodeTableValue and didDecodeArrayValue. The outval pointer, if set, contains the value retured from the top-level didDecodeSublist callback.
    /// 
    /// https://sdk.play.date/2.4.0/Inside%20Playdate%20with%20C.html#f-json.decodeString
    decodeString: *const fn (functions: ?*JSONDecoder, jsonString: [*c]const u8, outval: ?*JSONValue) callconv(.C) c_int,
};

///////Scoreboards///////////
pub const PDScore = extern struct {
    rank: u32,
    value: u32,
    player: [*c]u8,
};
pub const PDScoresList = extern struct {
    boardID: [*c]u8,
    count: c_uint,
    lastUpdated: u32,
    playerIncluded: c_int,
    limit: c_uint,
    scores: [*c]PDScore,
};
pub const PDBoard = extern struct {
    boardID: [*c]u8,
    name: [*c]u8,
};
pub const PDBoardsList = extern struct {
    count: c_uint,
    lastUpdated: u32,
    boards: [*c]PDBoard,
};
pub const AddScoreCallback = ?*const fn (score: ?*PDScore, errorMessage: [*c]const u8) callconv(.C) void;
pub const PersonalBestCallback = ?*const fn (score: ?*PDScore, errorMessage: [*c]const u8) callconv(.C) void;
pub const BoardsListCallback = ?*const fn (boards: ?*PDBoardsList, errorMessage: [*c]const u8) callconv(.C) void;
pub const ScoresCallback = ?*const fn (scores: ?*PDScoresList, errorMessage: [*c]const u8) callconv(.C) void;

pub const PlaydateScoreboards = extern struct {
    addScore: *const fn (boardId: [*c]const u8, value: u32, callback: AddScoreCallback) callconv(.C) c_int,
    getPersonalBest: *const fn (boardId: [*c]const u8, callback: PersonalBestCallback) callconv(.C) c_int,
    freeScore: *const fn (score: ?*PDScore) callconv(.C) void,

    getScoreboards: *const fn (callback: BoardsListCallback) callconv(.C) c_int,
    freeBoardsList: *const fn (boards: ?*PDBoardsList) callconv(.C) void,

    getScores: *const fn (boardId: [*c]const u8, callback: ScoresCallback) callconv(.C) c_int,
    freeScoresList: *const fn (scores: ?*PDScoresList) callconv(.C) void,
};
