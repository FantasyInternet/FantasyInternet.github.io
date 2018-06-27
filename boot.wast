(module
  ;; See API documentation at https://fantasyinternet.github.io/api
  (import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
  (import "env" "popToMemory" (func $popToMemory (param $offset i32)))
  (import "env" "logNumber" (func $log1Number (param i32)))
  (import "env" "logNumber" (func $log2Numbers (param i32) (param i32)))
  (import "env" "logNumber" (func $log3Numbers (param i32) (param i32) (param i32)))
  (import "env" "print" (func $print ))
  (import "env" "setDisplayMode" (func $setDisplayMode (param $mode i32) (param $width i32) (param $height i32) (param $visibleWidth i32) (param $visibleHeight i32) ))
  (import "env" "shutdown" (func $shutdown ))
  (import "env" "read" (func $read (param $tableIndex i32) (result i32)))
  (import "env" "list" (func $list (param $tableIndex i32) (result i32)))
  (import "env" "setStepInterval" (func $setStepInterval (param $milliseconds i32)))
  (import "env" "setInputType" (func $setInputType (param $type i32)))
  (import "env" "getInputText" (func $getInputText (result i32)))
  (import "env" "setInputText" (func $setInputText ))
  (import "env" "getInputKey" (func $getInputKey (result i32)))
  (import "env" "getBaseUrl" (func $getBaseUrl (result i32)))
  (import "env" "setBaseUrl" (func $setBaseUrl ))

  ;;@require $mem "fantasyinternet.wast/memory.wast"
  ;;@require $str "fantasyinternet.wast/strings.wast"
  ;;@require $cli "_wast/cli.wast"



  ;; Table for callback functions.
  (table $table 8 anyfunc)
    (elem (i32.const 1) $dump)
    (elem (i32.const 2) $loadLess)
    (export "table" (table $table))

  ;; Linear memory.
  (memory $memory 1)
    (export "memory" (memory $memory))
    (data (i32.const 0xf100) "\1b[K\n\1b[A")
    (data (i32.const 0xf200) "\n")
    (data (i32.const 0xf300) "The command you entered was: ")
    (data (i32.const 0xf400) "ls")
    (data (i32.const 0xf500) "./")
    (data (i32.const 0xf600) "\nerr!\n\n")
    (data (i32.const 0xf700) "cat")
    (data (i32.const 0xf800) "less")
    (data (i32.const 0xf900) "Commands available:\n\ncd <dir>/\tChange directory.\nls\t\tList directory contents.\ncat <filename>\tPrint file contents.\nless <filename>\tPrint file line by line.\n\n")
    (data (i32.const 0xfa00) "cd")
    (data (i32.const 0xfb00) "> ")

  ;; Global variables
  (global $mode     (mut i32) (i32.const 0))
  (global $prompt   (mut i32) (i32.const 0))
  (global $prompt2  (mut i32) (i32.const 0))
  (global $nl       (mut i32) (i32.const 0))
  (global $command  (mut i32) (i32.const 0))
  (global $confirm  (mut i32) (i32.const 0))
  (global $lsCmd    (mut i32) (i32.const 0))
  (global $cwd      (mut i32) (i32.const 0))
  (global $err      (mut i32) (i32.const 0))
  (global $catCmd   (mut i32) (i32.const 0))
  (global $lessCmd  (mut i32) (i32.const 0))
  (global $lessFile (mut i32) (i32.const 0))
  (global $lessLine (mut i32) (i32.const 0))
  (global $cdCmd    (mut i32) (i32.const 0))

  ;; Init function is called once on start.
  (func $init
    (call $setStepInterval (i32.const -1)) ;; step only on keypress
    (call $setDisplayMode (i32.const 0) (i32.const 80) (i32.const 20) (i32.const 80) (i32.const 20))
    (call $setInputType (i32.const 1))
    (set_global $prompt (call $str.createString (i32.const 0xf100)))
    (set_global $nl (call $str.createString (i32.const 0xf200)))
    (set_global $confirm (call $str.createString (i32.const 0xf300)))
    (set_global $lsCmd (call $str.createString (i32.const 0xf400)))
    (set_global $cwd (call $str.createString (i32.const 0xf500)))
    (set_global $err (call $str.createString (i32.const 0xf600)))
    (set_global $catCmd (call $str.createString (i32.const 0xf700)))
    (set_global $lessCmd (call $str.createString (i32.const 0xf800)))
    (set_global $cdCmd (call $str.createString (i32.const 0xfa00)))
    (set_global $prompt2 (call $str.createString (i32.const 0xfb00)))
    
    (set_global $command (call $mem.createPart (i32.const 0)))
    (set_global $lessFile (call $mem.createPart (i32.const 0)))
    (call $str.printStr (call $str.createString (i32.const 0xf900)))
    (call $gotoPrompt)
  )
  (export "init" (func $init))

  ;; Step function is called once every interval.
  (func $step (param $t f64)
    (local $s i32)
    (call $mem.enterPart (call $mem.createPart (i32.const 1)))
    (if (i32.eq (get_global $mode) (i32.const 0))(then
      (set_global $command (call $cli.step))
      (if (get_global $command)(then
        (if (call $str.equal (call $cli.getArg (i32.const 0)) (get_global $lsCmd))(then
          (set_global $mode (i32.const 1))
        ))
        (if (call $str.equal (call $cli.getArg (i32.const 0)) (get_global $cdCmd))(then
          (set_local $s (call $cli.getArg (i32.const 1)))
          (call $str.appendBytes (get_local $s) (i64.const 0x2f))
          (call $setBaseUrl (call $str.pushString (get_local $s)))
        ))
        (if (call $str.equal (call $cli.getArg (i32.const 0)) (get_global $catCmd))(then
          (set_global $mode (i32.const 2))
        ))
        (if (call $str.equal (call $cli.getArg (i32.const 0)) (get_global $lessCmd))(then
          (set_global $mode (i32.const 3))
        ))
        (if (i32.eqz (get_global $mode))(then
          (call $gotoPrompt)
        ))
      ))
    ))
    (if (i32.eq (get_global $mode) (i32.const 1))(then
      (drop (call $list (call $str.pushString (get_global $cwd)) (i32.const 1)))
      (set_global $mode (i32.const -1))
    ))
    (if (i32.eq (get_global $mode) (i32.const 2))(then
      (drop (call $read (call $str.pushString (call $cli.getArg (i32.const 1))) (i32.const 1)))
      (set_global $mode (i32.const -1))
    ))
    (if (i32.eq (get_global $mode) (i32.const 3))(then
      (drop (call $read (call $str.pushString (call $cli.getArg (i32.const 1))) (i32.const 2)))
      (set_global $mode (i32.const -1))
    ))
    (if (i32.eq (get_global $mode) (i32.const 4))(then
      (if (call $getInputKey) (then
        (call $str.printStr (call $str.getLine (get_global $lessFile) (get_global $lessLine)))
        (set_global $lessLine (i32.add (get_global $lessLine) (i32.const 1)))
        (if (i32.ge_u (get_global $lessLine) (call $str.countLines (get_global $lessFile)))(then
          (call $str.printStr (get_global $nl))
          (call $gotoPrompt)
        ))
      ))
    ))
    (call $mem.deleteParent)
  )
  (export "step" (func $step))

  (func $dump (param $success i32) (param $len i32) (param $req i32)
    (call $mem.enterPart (call $mem.createPart (i32.const 1)))
    (if (get_local $success) (then
      (call $str.printStr (call $str.popString ))
      (call $str.printStr (get_global $nl))
      (call $str.printStr (get_global $nl))
    )(else
      (call $str.printStr (get_global $err))
    ))
    (call $gotoPrompt)
    (call $mem.deleteParent)
  )

  (func $loadLess (param $success i32) (param $len i32) (param $req i32)
    (call $mem.enterPart (call $mem.createPart (i32.const 1)))
    (if (get_local $success) (then
      (call $mem.resizePart (get_global $lessFile) (get_local $len))
      (call $popToMemory (call $mem.getPartOffset (get_global $lessFile)))
      (set_global $lessLine (i32.const 0))
      (set_global $mode (i32.const 4))
    )(else
      (call $str.printStr (get_global $err))
      (call $gotoPrompt)
    ))
    (call $mem.deleteParent)
  )

  (func $gotoPrompt
    (call $setInputText (call $pushFromMemory (i32.const 0) (i32.const 0)))
    (call $print (drop (call $getBaseUrl)))
    (call $str.printStr (get_global $prompt2))
    (set_global $mode (i32.const 0))
  )


  ;; Display function is called whenever the display needs to be redrawn.
  (func $display (param $t f64)
  )
  (export "display" (func $display))

  ;; Break function is called whenever Esc is pressed.
  (func $break
    (if (get_global $mode)(then
      (call $gotoPrompt)
    )(else
      (call $shutdown)
    ))
  )
  (export "break" (func $break))
)
