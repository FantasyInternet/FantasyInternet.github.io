(import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
(import "env" "popToMemory" (func $popToMemory (param $offset i32)))
(import "env" "getInputText" (func $getInputText (result i32)))
(import "env" "getInputPosition" (func $getInputPosition (result i32)))
(import "env" "getInputKey" (func $getInputKey (result i32)))
(import "env" "setInputText" (func $setInputText ))
(import "env" "print" (func $print ))

;;@require $mem "fantasyinternet.wast/memory.wast"
;;@require $str "fantasyinternet.wast/strings.wast"

(global $restore (mut i32) (i32.const 0))
(global $save (mut i32) (i32.const 0))
(global $clear (mut i32) (i32.const 0))
(global $nl (mut i32) (i32.const 0))
(global $input (mut i32) (i32.const 0))

(func $step (result i32)
  (local $key i32)
  (local $result i32)
  (call $mem.enterPart (call $mem.createPart (i32.const 0)))
  (if (i32.eqz (get_global $restore))(then
    (set_global $restore (call $mem.createPart (i32.const 0)))
    (call $str.appendBytes (get_global $restore) (i64.const 0x755b1b))
  ))
  (if (i32.eqz (get_global $save))(then
    (set_global $save (call $mem.createPart (i32.const 0)))
    (call $str.appendBytes (get_global $save) (i64.const 0x735b1b))
  ))
  (if (i32.eqz (get_global $clear))(then
    (set_global $clear (call $mem.createPart (i32.const 0)))
    (call $str.appendBytes (get_global $clear) (i64.const 0x4b5b1b))
  ))
  (if (i32.eqz (get_global $nl))(then
    (set_global $nl (call $mem.createPart (i32.const 0)))
    (call $str.appendBytes (get_global $nl) (i64.const 0x0a))
  ))
  (if (i32.eqz (get_global $input))(then
    (set_global $input (call $mem.createPart (i32.const 0)))
  ))
  (call $mem.resizePart (get_global $input) (call $getInputText))
  (call $popToMemory (call $mem.getPartOffset (get_global $input)))
  (set_local $key (call $getInputKey))
  (if (get_local $key)(then
    (if (i32.eq (get_local $key) (i32.const 13))(then
      (call $setInputText (call $pushFromMemory (i32.const 0) (i32.const 0)))
      (call $str.trim (get_global $input))
      (call $str.printStr (get_global $restore))
      (call $str.printStr (get_global $input))
      (call $str.printStr (get_global $clear))
      (call $str.printStr (get_global $nl))
      (set_local $result (get_global $input))
    )(else
      (call $str.printStr (get_global $save))
      (call $str.printStr (call $str.substr (get_global $input) (call $getInputPosition) (i32.sub (call $mem.getPartLength (get_global $input)) (call $getInputPosition))))
      (call $str.printStr (get_global $clear))
      (call $str.printStr (get_global $restore))
      (set_local $result (i32.const 0))
    ))
  ))
  (get_local $result)
  (call $mem.deleteParent)
)

