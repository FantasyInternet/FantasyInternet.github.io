(module
  (import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
  (import "env" "popToMemory" (func $popToMemory (param $offset i32)))
  (import "env" "break" (func $break ))
  (import "env" "readImage" (func $readImage (param $tableIndex i32) (result i32)))
  (import "env" "print" (func $print ))
  (import "env" "getArg" (func $getArg (param $num i32) (result i32) ))
  (import "env" "getString" (func $getString (param $id i32) (param $offset i32) ))
  (import "env" "getStringLength" (func $getStringLength (param $id i32) (result i32) ))
  (import "env" "getInputKey" (func $getInputKey (result i32)))
  (import "env" "setDisplayMode" (func $setDisplayMode (param $mode i32) (param $width i32) (param $height i32)  ))
  (import "env" "displayMemory" (func $displayMemory (param $offset i32) (param $length i32)))

  ;; Table for callback functions.
  (table $table 8 anyfunc)
    (elem (i32.const 1) $readCB)
    (export "table" (table $table))

  ;; Linear memory.
  (memory $memory 1)
    (data (i32.const 0) "./")
    (export "memory" (memory $memory))

  (func $init
    (local $strId i32)
    (local $strLen i32)
    (set_local $strId (call $getArg (i32.const 1)))
    (set_local $strLen (call $getStringLength (get_local $strId)))
    (set_local $strLen (i32.add (get_local $strLen) (i32.const 2)))
    (call $getString (get_local $strId) (i32.const 2))
    (call $pushFromMemory (i32.const 0) (get_local $strLen))
    (drop (call $readImage (i32.const 1)))
  )
  (export "init" (func $init))

  (func $readCB (param $success i32) (param $w i32) (param $h i32)
    (local $len i32)
    (if (get_local $success)(then
      (set_local $len (i32.mul (i32.const 4) (i32.mul (get_local $w) (get_local $h))))
      (drop (grow_memory (i32.div_u (get_local $len) (i32.const 0x10000) )))
      (call $popToMemory (i32.const 0))
      (call $setDisplayMode (i32.const 1) (get_local $w) (get_local $h))
      (call $displayMemory (i32.const 0) (get_local $len))
    )(else
      (unreachable)
    ))
  )
)