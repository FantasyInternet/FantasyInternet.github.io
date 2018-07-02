(module
  (import "env" "pushFromMemory" (func $pushFromMemory (param $offset i32) (param $length i32)))
  (import "env" "print" (func $print ))
  (import "env" "break" (func $break ))

  ;; Linear memory.
  (memory $memory 1)
    (data (i32.const 0x00) "Commands available:\n\ncd <dir>\tChange directory.\nls\t\tList directory contents.\ncat <filename>\tPrint file contents.\nless <filename>\tPrint file line by line.\nshow <filename>\tShow image file.\n\n")
    (export "memory" (memory $memory))

  (func $init
    (local $len i32)
    (loop
      (set_local $len (i32.add (get_local $len) (i32.const 1)))
      (br_if 0 (i32.load8_u (get_local $len)))
    )
    (call $pushFromMemory (i32.const 0) (get_local $len))
    (call $print)
    (call $break)
  )
  (export "init" (func $init))
  ;; (start $init)
)