(module
  (import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
  (import "env" "break" (func $break ))
  (import "env" "setBaseUrl" (func $setBaseUrl ))
  (import "env" "getArg" (func $getArg (param $num i32) (result i32) ))
  (import "env" "getString" (func $getString (param $id i32) (param $offset i32) ))
  (import "env" "getStringLength" (func $getStringLength (param $id i32) (result i32) ))

  ;; Linear memory.
  (memory $memory 1)
    (export "memory" (memory $memory))

  (func $init
    (local $strId i32)
    (local $strLen i32)
    (set_local $strId (call $getArg (i32.const 1)))
    (set_local $strLen (call $getStringLength (get_local $strId)))
    (i32.store8 (get_local $strLen) (i32.const 0x2f))
    (set_local $strLen (i32.add (get_local $strLen) (i32.const 1)))
    (call $getString (get_local $strId) (i32.const 0))
    (call $pushFromMemory (i32.const 0) (get_local $strLen))
    (call $setBaseUrl)
    (call $break)
  )
  (export "init" (func $init))
  ;; (start $init)
)