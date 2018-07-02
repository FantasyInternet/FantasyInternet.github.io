(module
  (import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
  (import "env" "popToMemory" (func $popToMemory (param $offset i32)))
  (import "env" "break" (func $break ))
  (import "env" "read" (func $read (param $tableIndex i32) (result i32)))
  (import "env" "print" (func $print ))
  (import "env" "getArg" (func $getArg (param $num i32) (result i32) ))
  (import "env" "getString" (func $getString (param $id i32) (param $offset i32) ))
  (import "env" "getStringLength" (func $getStringLength (param $id i32) (result i32) ))
  (import "env" "getInputKey" (func $getInputKey (result i32)))

  ;; Table for callback functions.
  (table $table 8 anyfunc)
    (elem (i32.const 1) $readCB)
    (export "table" (table $table))

  ;; Linear memory.
  (memory $memory 1)
    (data (i32.const 0) "./")
    (export "memory" (memory $memory))

  ;; Global variables
  (global $pos (mut i32) (i32.const 0))

  (func $init
    (local $strId i32)
    (local $strLen i32)
    (set_local $strId (call $getArg (i32.const 1)))
    (set_local $strLen (call $getStringLength (get_local $strId)))
    (set_local $strLen (i32.add (get_local $strLen) (i32.const 2)))
    (call $getString (get_local $strId) (i32.const 2))
    (call $pushFromMemory (i32.const 0) (get_local $strLen))
    (drop (call $read (i32.const 1)))
  )
  (export "init" (func $init))

  ;; Step function is called once every interval.
  (func $step (param $t f64)
    (local $len i32)
    (if (call $getInputKey)(then
      (set_local $len (i32.const 0))
      (block(loop
        (if (i32.eq (i32.const 0) (i32.load8_u (i32.add (get_global $pos) (get_local $len))))(then
          (call $break)
        ))
        (br_if 1 (i32.eq (i32.const 0) (i32.load8_u (i32.add (get_global $pos) (get_local $len)))))
        (br_if 1 (i32.eq (i32.const 10) (i32.load8_u (i32.add (get_global $pos) (get_local $len)))))
        (set_local $len (i32.add (get_local $len) (i32.const 1)))
        (br 0)
      ))
      (set_local $len (i32.add (get_local $len) (i32.const 1)))
      (call $pushFromMemory (get_global $pos) (get_local $len))
      (call $print)
      (set_global $pos (i32.add (get_global $pos) (get_local $len)))
    ))
  )
  (export "step" (func $step))

  (func $readCB (param $success i32) (param $len i32)
    (if (get_local $success)(then
      (drop (grow_memory (i32.div_u (get_local $len) (i32.const 0x10000) )))
      (call $popToMemory (i32.const 0))
      (set_global $pos (i32.const 256))
      (call $pushFromMemory (i32.const 0) (get_global $pos))
      (call $print)
   )(else
      (unreachable)
    ))
  )
)