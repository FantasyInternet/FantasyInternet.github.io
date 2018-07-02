(module
  ;; See API documentation at https://fantasyinternet.github.io/api
  (import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
  (export "env.pushFromMemory" (func $pushFromMemory ))
  (import "env" "popToMemory" (func $popToMemory (param $offset i32)))
  (export "env.popToMemory" (func $popToMemory ))
  (import "env" "logNumber" (func $log1Number (param i32)))
  (import "env" "logNumber" (func $log2Numbers (param i32) (param i32)))
  (import "env" "logNumber" (func $log3Numbers (param i32) (param i32) (param i32)))
  (import "env" "print" (func $print ))
  (export "env.print" (func $print ))
  (import "env" "setDisplayMode" (func $setDisplayMode (param $mode i32) (param $width i32) (param $height i32)  ))
  (export "env.setDisplayMode" (func $setDisplayMode ))
  (import "env" "displayMemory" (func $displayMemory (param $offset i32) (param $length i32)))
  (export "env.displayMemory" (func $displayMemory ))
  (import "env" "shutdown" (func $shutdown ))
  (import "env" "read" (func $read (param $tableIndex i32) (result i32)))
  (export "env.read" (func $read ))
  (import "env" "readImage" (func $readImage (param $tableIndex i32) (result i32)))
  (export "env.readImage" (func $readImage ))
  (import "env" "list" (func $list (param $tableIndex i32) (result i32)))
  (export "env.list" (func $list ))
  (import "env" "setStepInterval" (func $setStepInterval (param $milliseconds i32)))
  (import "env" "setInputType" (func $setInputType (param $type i32)))
  (import "env" "getInputText" (func $getInputText (result i32)))
  (import "env" "setInputText" (func $setInputText ))
  (import "env" "getInputKey" (func $getInputKey (result i32)))
  (export "env.getInputKey" (func $getInputKey ))

  (import "env" "getOriginUrl" (func $getOriginUrl (result i32)))
  (import "env" "getBaseUrl" (func $getBaseUrl (result i32)))
  (import "env" "setBaseUrl" (func $setBaseUrl ))
  (export "env.setBaseUrl" (func $setBaseUrl ))

  (import "env" "loadProcess" (func $loadProcess (result i32) ))
  (import "env" "processStatus" (func $processStatus (param $pid i32) (result i32) ))
  (import "env" "stepProcess" (func $stepProcess (param $pid i32) ))
  (import "env" "killProcess" (func $killProcess (param $pid i32) ))
  (import "env" "transferMemory" (func $transferMemory (param $fromPid i32) (param $fromOffset i32) (param $length i32) (param $toPid i32) (param $toOffset i32) ))

  ;;@require $mem "fantasyinternet.wast/memory.wast"
  ;;@require $str "fantasyinternet.wast/strings.wast"
  ;;@require $cli "fantasyinternet.wast/cli.wast"
  ;;@require $utf8 "fantasyinternet.wast/utf8.wast"
  ;;@require $gfx "fantasyinternet.wast/graphics.wast"



  ;; Table for callback functions.
  (table $table 8 anyfunc)
    (elem (i32.const 1) $loadCmd)
    (export "table" (table $table))

  ;; Linear memory.
  (memory $memory 1)
    (data (i32.const 0xf100) "\n")
    (data (i32.const 0xf200) "> ")
    (data (i32.const 0xf300) "\n\nErr!\n\n")
    (data (i32.const 0xf400) ".wasm")
    (data (i32.const 0xf500) "Unknown command!\n")
    (data (i32.const 0xf600) "cmd/")
    (export "memory" (memory $memory))

  ;; Global variables
  (global $pid        (mut i32) (i32.const 0))
  (global $nl         (mut i32) (i32.const 0))
  (global $prompt     (mut i32) (i32.const 0))
  (global $errStr     (mut i32) (i32.const 0))
  (global $wasmExt    (mut i32) (i32.const 0))
  (global $unknownCmd (mut i32) (i32.const 0))
  (global $cmdPath    (mut i32) (i32.const 0))
  (global $prcVars    (mut i32) (i32.const -1))

  ;; Init function is called once on start.
  (func $init
    (call $setStepInterval (i32.const -1)) ;; step only on keypress
    (call $setDisplayMode (i32.const 0) (i32.const 80) (i32.const 20) )
    (call $setInputType (i32.const 1))
    (set_global $nl (call $str.createString (i32.const 0xf100)))
    (set_global $prompt (call $str.createString (i32.const 0xf200)))
    (set_global $errStr (call $str.createString (i32.const 0xf300)))
    (set_global $wasmExt (call $str.createString (i32.const 0xf400)))
    (set_global $unknownCmd (call $str.createString (i32.const 0xf500)))
    
    (set_global $cmdPath (call $str.concat (call $str.popString (drop (call $getOriginUrl))) (call $str.createString (i32.const 0xf600))))
    (call $gotoPrompt)
  )
  (export "init" (func $init))

  ;; Step function is called once every interval.
  (func $step (param $t f64)
    (call $mem.enterPart (call $mem.createPart (i32.const 1)))
    (if (get_global $pid)(then
      (if (i32.eq (call $processStatus (get_global $pid)) (i32.const 2))(then
        (call $stepProcess (get_global $pid))
      ))
      (if (i32.le_s (call $processStatus (get_global $pid)) (i32.const 0))(then
        (call $str.printStr (get_global $errStr))
        (call $gotoPrompt)
      ))
    )(else
      (if (call $cli.step)(then
        (call $runCmd)
      ))
    ))
    (call $mem.deleteParent)
  )
  (export "step" (func $step))

  (func $runCmd
    (call $mem.enterPart (call $mem.createPart (i32.const 1)))
    (if (call $mem.getPartLength (call $cli.getArg (i32.const 0)))(then
      (drop (call $read (call $str.pushString (call $str.concat (get_global $cmdPath) (call $str.concat (call $cli.getArg (i32.const 0)) (get_global $wasmExt)))) (i32.const 1)))
    )(else
      (call $gotoPrompt)
    ))
    (call $mem.deleteParent)
  )
  (func $loadCmd (param $success i32) (param $len i32)
    (local $wasm i32)
    (set_global $prcVars (call $mem.createPart (i32.const 1)))
    (call $mem.enterPart (call $mem.createPart (i32.const 1)))
    (if (get_local $success)(then
      (set_global $pid (call $loadProcess (call $str.pushString (call $str.popString))))
    )(else
      (call $str.printStr (get_global $unknownCmd))
      (call $gotoPrompt)
    ))
    (call $mem.deleteParent)
  )

  (func $gotoPrompt
    (if (get_global $pid)(then
      (call $killProcess (get_global $pid))
      (call $mem.deletePart (get_global $prcVars))
    ))
    (call $setDisplayMode (i32.const 0) (i32.const 80) (i32.const 20))
    (call $setInputText (call $pushFromMemory (i32.const 0) (i32.const 0)))
    (call $print (drop (call $getBaseUrl)))
    (call $str.printStr (get_global $prompt))
    (set_global $pid (i32.const 0))
  )


  ;; Display function is called whenever the display needs to be redrawn.
  (func $display (param $t f64)
  )
  (export "display" (func $display))

  ;; Break function is called whenever Esc is pressed.
  (func $break
    (if (get_global $pid)(then
      (call $killProcess (get_global $pid))
      (call $gotoPrompt)
    )(else
      (call $shutdown)
    ))
  )
  (export "break" (func $break))
  (export "env.break" (func $break))

  (export "env.getArg" (func $cli.getArg))

  (func $getStringLength (param $id i32) (result i32)
    (call $mem.getPartLength (get_local $id))
  )
  (export "env.getStringLength" (func $getStringLength))
  (func $getString (param $id i32) (param $offset i32)
    (call $transferMemory
      (i32.const 0)
      (call $mem.getPartOffset (get_local $id))
      (call $mem.getPartLength (get_local $id))
      (get_global $pid)
      (get_local $offset)
    )
  )
  (export "env.getString" (func $getString))
  (func $putString (param $offset i32) (param $length i32) (result i32)
    (local $parentPart i32)
    (local $str i32)
    (set_local $parentPart (get_global $mem.parentPart))
    (call $mem.enterPart (get_global $prcVars))
    (set_local $str (call $mem.createPart (get_local $length)))
    (call $transferMemory
      (get_global $pid)
      (get_local $offset)
      (get_local $length)
      (i32.const 0)
      (call $mem.getPartOffset (get_local $str))
    )
    (call $mem.enterPart (get_local $parentPart))
    (get_local $str)
  )
  (export "env.putString" (func $putString))
)
