The Fantasy Internet API standard
=================================
When connecting to a URL, the terminal will look for a `boot.wasm` file near the root of the domain. Once found, it will load and instantiate with the following functions available to import and use.

API functions
-------------
The following functions can be imported from the `"env"` field. In a `.wast`-file it would look something like this:

    (import "env" "callApiFunction"
      (func $callApiFunction
        (param $index i32)
        (param $value i32)
        (result i32)
      )
    )

### pushFromMemory(offset, length)
Push memory range to buffer stack.

### popToMemory(offset)
Pop one buffer off the buffer stack and store in memory.

### getApiFunctionIndex(): index
Pop API function name off the buffer stack and return index or 0 if not found.


    ;; Call API function by index. Use any number of parameters and return values.
    (import "env" "callApiFunction" (func $callApiFunction (param $index i32) (param $a i32) (result i32)))
    (import "env" "callApiFunction" (func $api_i32i32_i32 (param $index i32) (param $a i32) (param $b i32) (result i32)))

    ;; Pop string from buffer stack and log it to the console.
    (import "env" "log" (func $log ))
    ;; Log numbers to the console. Use any number of parameters.
    (import "env" "logNumber" (func $log1Number  (param $a i32) ))
    (import "env" "logNumber" (func $log2Numbers (param $a i32) (param $b i32) ))
    (import "env" "logNumber" (func $log3Numbers (param $a i32) (param $b i32) (param $c i32) ))
    ;; Pop string from buffer stack and print it to text display.
    (import "env" "print" (func $print ))

    ;; Set the display mode(0=text,1=pixel), resolution and (optionally) display size (for overscan).
    (import "env" "setDisplayMode" (func $setDisplayMode (param $mode i32) (param $width i32) (param $height i32) (param $visibleWidth i32) (param $visibleHeight i32) ))
    ;; Copy memory range to display buffer ($destOffset optional) and commit display buffer.
    (import "env" "displayMemory" (func $displayMemory (param $offset i32) (param $length i32) (param $destOffset i32)))

    ;; Pop URL from buffer stack and connect to it.
    (import "env" "connectTo" (func $connectTo ))
    ;; Shut down this connection
    (import "env" "shutdown" (func $shutdown ))
    ;; Push base URL to buffer stack and return its length in bytes.  
    (import "env" "getBaseUrl" (func $getBaseUrl (result i32)))
    ;; Pop URL from buffer stack and set it as base URL.
    (import "env" "setBaseUrl" (func $setBaseUrl ))

    ;; Pop path from buffer stack, read it and push the contents to buffer stack. Returns a request ID.
    ;; Callback can expect success boolean, length in bytes and same request ID as parameters.
    (import "env" "read" (func $read (param $tableIndex i32) (result i32)))
    ;; Pop path from buffer stack, read it and push the pixel data to buffer stack. Returns a request ID.
    ;; Callback can expect success boolean, width and height in pixels and same request ID as parameters.
    ;; (import "env" "readImage" (func $readImage (param $tableIndex i32) (result i32)))
    ;; Pop data and path from buffer stack and write it to file. Returns a request ID.
    ;; Callback can expect success boolean and same request ID as parameters.
    (import "env" "write" (func $write (param $tableIndex i32) (result i32)))
    ;; Pop path from buffer stack and delete the file. Returns a request ID.
    ;; Callback can expect success boolean and same request ID as parameters.
    (import "env" "delete" (func $delete (param $tableIndex i32) (result i32)))
    ;; Pop path from buffer stack and retrieve directory contents. Returns a request ID.
    ;; Callback can expect success boolean, length in bytes and same request ID as parameters.
    (import "env" "list" (func $list (param $tableIndex i32) (result i32)))

    ;; Prioritize  given type of input. 1=text, 2=mouse, 3=game.
    (import "env" "focusInput" (func $focusInput (param $input i32)))

    ;; Push text input text to buffer stack and return its length in bytes.
    (import "env" "getInputText" (func $getInputText (result i32)))
    ;; Get character position of carret in text input.
    (import "env" "getInputPosition" (func $getInputPosition (result i32)))
    ;; Get number of characters selected in text input.
    (import "env" "getInputSelected" (func $getInputSelected (result i32)))
    ;; Get key code of key that was just pressed this step.
    (import "env" "getInputKey" (func $getInputKey (result i32)))
    ;; Set the type of text input. 0=multiline, 1=singleline, 2=password, 3=number, 4=url, 5=email, 6=phone
    (import "env" "setInputType" (func $setInputType (param i32)))
    ;; Pop text from buffer stack and set text of text input.
    (import "env" "setInputText" (func $setInputText))
    ;; Set position and (optionally) selection of text input.
    (import "env" "setInputPosition" (func $setInputPosition (param $position i32) (param $selected i32)))
    ;; Pop replacement and search substrings from buffer stack and
    ;; replace first occurence in text input.
    (import "env" "replaceInputText" (func $replaceInputText (param $fromIndex i32)))

    ;; Get X coordinate of mouse input.
    (import "env" "getMouseX" (func $getMouseX (result i32)))
    ;; Get Y coordinate of mouse input.
    (import "env" "getMouseY" (func $getMouseY (result i32)))
    ;; Check if mouse button is pressed.
    (import "env" "getMousePressed" (func $getMousePressed (result i32)))

    ;; Get X coodinate of game input. (-1 to 1)
    (import "env" "getGameAxisX" (func $getGameAxisX (result f32)))
    ;; Get Y coodinate of game input. (-1 to 1)
    (import "env" "getGameAxisY" (func $getGameAxisY (result f32)))
    ;; Check if game button A is pressed.
    (import "env" "getGameButtonA" (func $getGameButtonA (result i32)))
    ;; Check if game button B is pressed.
    (import "env" "getGameButtonB" (func $getGameButtonB (result i32)))
    ;; Check if game button X is pressed.
    (import "env" "getGameButtonX" (func $getGameButtonX (result i32)))
    ;; Check if game button Y is pressed.
    (import "env" "getGameButtonY" (func $getGameButtonY (result i32)))

    ;; Start generating a tone.
    (import "env" "startTone" (func $startTone (param $channel i32) (param $frequency i32) (param $volume f32) (param $type i32)))
    ;; Stop generating a tone.
    (import "env" "stopTone" (func $stopTone (param $channel i32)))

    ;; Set step interval. Set to -1 to only step on input.
    (import "env" "setStepInterval" (func $setStepInterval (param $milliseconds f64)))
    ;; Pop wasm binary code from buffer stack and load it. Returns new process ID.
    ;; All exports from boot.wasm starting with "api." are forwarded to the process.
    (import "env" "loadProcess" (func $loadProcess (result i32)))
    ;; Step a process, keeping it alive.
    (import "env" "stepProcess" (func $stepProcess (param $pid i32)))
    ;; Call back a process. Any parameters beyond the first two will be forwarded to the callback function.
    (import "env" "callbackProcess" (func $callbackProcess (param $pid i32) (param $tableIndex i32) (param $param i32)))
    ;; Kill a process.
    (import "env" "killProcess" (func $killProcess (param $pid i32)))
    ;; Transfer a chunk of memory from one process to another
    (import "env" "transferMemory" (func $transferMemory (param $srcPid i32) (param $srcOffset i32) (param $length i32) (param $destPid i32) (param $destOffset i32)))

    ;; transpile wa(s)t into wasm on the buffer stack and return byte length.
    ;; (import "env" "wabt" (func $wabt (result i32)))

    ;; All JavaScript Math functions are available.
    (import "Math" "random" (func $random (result f32)))
