The Fantasy Internet API standard
=================================
When connecting to a URL, the terminal will look for a `boot.wasm` file near the root of the domain. Once found, it will load and instantiate with the following functions available to import and use.

* Table of contents
{:toc}

API functions
-------------
The following functions can be imported from the `"env"` field. In a `.wa(s)t`-file it would look something like this:

    (import "env" "pushFromMemory"
      (func $pushFromMemory (param $offset i32) (param $length i32))
    )
    (import "env" "getApiFunctionIndex"
      (func $getApiFunctionIndex (result i32))
    )

### The buffer stack
    pushFromMemory(offset, length)
    popToMemory(offset)

WebAssembly (wasm) only supports numerical datatypes as function parameters and return types. To pass strings and binary data back and forth, you can use the buffer stack to copy any length of data in and out of linear memory.

The `offset` and `length` parameters specify, in bytes, where in memory the data should be copied. Make sure to allocate enough memory when popping data to memory. Functions that pushes data to the stack usually tell you how many bytes were just pushed.

Parameters and return values that needs to be passed through the buffer stack (and not as actual parameters) will be suffixed with a `$` in this documentation. Functions that return a buffer actually return its length in bytes instead, so you know how much data you can expect to pop off the stack.

### The API function index
    getApiFunctionIndex(name$): index
    callApiFunction(index [, parameters...]): [returnValue]

You can call any of the API functions by index without importing them first. This is useful for detecting experimental and future functions that not all terminal programs may have implemented yet.

The `name$` parameter is the name of the function you are testing for. If the function doesn't exist, the index will be `0` and you cannot call it.

You may have to import `callApiFunction` multiple times for different function signatures.

    (import "env" "callApiFunction"
      (func $funcWithOneParamAndReturn (param $index i32) (param $a i32) (result i32) )
    )
    (import "env" "callApiFunction"
      (func $funcWithTwoParams (param $index i32) (param $a i32) (param $b i32) )
    )

### Logging
    log(string$)
    logNumber(numbers...)

These log messages and numbers to the developer console. Useful for debugging.

### Display
    setDisplayMode(mode, width, height [, visibleWidth, visibleHeight])
    print(string$) // only works in text mode.
    displayMemory(offset, length [, screenOffset]) // only pixel mode.

The API currently supports two display modes: text (mode `0`) and pixels (mode `1`). Each can be any size/resolution you want.

Text mode supports the most commonly used ANSI escape codes.

Pixel mode relies on part of linear memory to hold a string of RGBA bytes. 4 bytes for each pixel.

`visibleWidth` and `visibleHeight` can be used to simulate overscan. This is useful for border graphics that is not part of the main display and therefore may be hidden to make best use of the physical pixels.

### Audio
    // types: 0=square, 1=sawtooth, 2=triangle, 3=sine
    startTone(channel, frequency [, volume [, type]])
    stopTone(channel)

It is recommended to only use `stopTone()` when done you are done playing audio for a while, as it may cause a slight pop in the speakers.

### User input
    focusInput(type) // 1=text, 2=mouse, 3=game.

    getInputText(): text$
    getInputPosition(): position
    getInputSelected(): length
    getInputKey(): keyCode
    setInputType(type) // 0=multiline, 1=single, 2=password, 3=number, 4=url, 5=email, 6=phone
    setInputText(text$)
    setInputPosition(position, length)
    replaceInputText(search$, replace$ [, fromPosition])

    getMouseX(): x
    getMouseY(): y
    getMousePressed(): pressed

    getGameAxisX(): x // -1 to 1
    getGameAxisY(): y // -1 to 1
    getGameButtonA(): pressed
    getGameButtonB(): pressed
    getGameButtonX(): pressed
    getGameButtonY(): pressed

Input from the user can be prioritized depending on context. This is useful on mobile devices with touchscreen as focusing on a specific type of input may produce an onscreen keyboard, touch controls etc..

### Navigation
    connectTo(url$)
    shutdown()
    getBaseUrl(): url$
    setBaseUrl(url$)

The navigation system is (primarily) stack based. Connecting to a URL suspends the current connection and adds a new one to the navigation stack. Shutdown terminates the current connection (deleting its state and memory), pops it off the stack and returns control to the previous connection.

The URL connected to will be the initial base URL, where any relative URLs are resolved from. This is useful for creating permalinks that boots straight into a specific resource. Only resources residing in the same folder as `boot.wasm` (or subfolders) can be accessed.

Currently `http(s):` and `file:` URL schemes are supported.

### File system
    read(path$, callback(success, length$, requestID) ): requestID
    write(path$, data$, callback(success, requestID)): requestID
    delete(path$, callback(success, requestID)): requestID
    list(path$, callback(success, length$, requestID)): requestID

    // readImage may be obsoleted in the future.
    // width$ and height$ refer to the same buffer.
    readImage(path$, callback(success, width$, height$, requestID)): requestID

File access is done through asyncrounous calls like these. The `callback` parameter is actually an index in the function table. Each of these functions return a `requestID` which is then passed again to the callback function once the operation completes. This makes it useful for the callback function to distinguish between multiple requests as they may not complete in the same order they were issued.

If the operation fails, `success` will be zero and nothing will be pushed to the buffer stack.

`list()` will return a line seperated list of filenames discovered in the specified folder through webcrawling. This works best if the server generates directory listings. If the `file:` scheme is used, it will simply return the directory contents.

### Process handling
    setStepInterval(milliseconds) // Set to -1 to only step on input.
    loadProcess(wasmBinary$): processID
    stepProcess(processID)
    callbackProcess(processID, tableIndex [, params...]): [returnValue]
    killProcess(processID)
    transferMemory(fromPID, fromOffset, length, toPID, toOffset)

The `boot.wasm` file can load and run other `.wasm`-files. Any functions exported by `boot.wasm` that starts with `"api."` will be importable by any process it loads.

### Math
    (import "Math" "random" (func $random (result f32)))

Any function from the JavaScript Math class is importable from the `"Math"` field.


Exports
-------
In order for your program to run, it needs to export any of the following functions. Any of these functions need to complete within a reasonable amount of time or the UI will lag or freeze.

    init() // once upon load
    step(timestamp) // every step interval
    display(timestamp) // on screen refresh
    break() // when user presses ESC or Back

