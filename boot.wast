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

  ;;@require $str "./_wast/strings.wast"




;;--------;;--------;;--------;;--------;;--------;;--------;;--------;;






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
    (data (i32.const 0xf700) "cat ")
    (data (i32.const 0xf800) "less ")
    (data (i32.const 0xf900) "Commands available:\n\ncd <dir>/\tChange directory.\nls\t\tList directory contents.\ncat <filename>\tPrint file contents.\nless <filename>\tPrint file line by line.\n\n")
    (data (i32.const 0xfa00) "cd ")
    (data (i32.const 0xfb00) " > ")

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
    (set_global $prompt (call $createString (i32.const 0xf100)))
    (set_global $nl (call $createString (i32.const 0xf200)))
    (set_global $confirm (call $createString (i32.const 0xf300)))
    (set_global $lsCmd (call $createString (i32.const 0xf400)))
    (set_global $cwd (call $createString (i32.const 0xf500)))
    (set_global $err (call $createString (i32.const 0xf600)))
    (set_global $catCmd (call $createString (i32.const 0xf700)))
    (set_global $lessCmd (call $createString (i32.const 0xf800)))
    (set_global $cdCmd (call $createString (i32.const 0xfa00)))
    (set_global $prompt2 (call $createString (i32.const 0xfb00)))
    
    (set_global $command (call $createPart (i32.const 0)))
    (set_global $lessFile (call $createPart (i32.const 0)))
    (call $printStr (call $createString (i32.const 0xf900)))
  )
  (export "init" (func $init))

  ;; Step function is called once every interval.
  (func $step (param $t f64)
    (call $enterPart (call $createPart (i32.const 1)))
    (if (i32.eq (get_global $mode) (i32.const 0))(then
      (call $printStr (get_global $prompt))
      (call $print (drop (call $getBaseUrl)))
      (call $printStr (get_global $prompt2))
      (call $print (drop (call $getInputText)))
      (if (i32.eq (call $getInputKey) (i32.const 13))(then
        (call $printStr (get_global $nl))
        (call $resizePart (get_global $command) (call $getInputText))
        (call $popToMemory (call $getPartOffset (get_global $command)))
        (call $setInputText (call $pushFromMemory (i32.const 0) (i32.const 0)))
        (call $printStr (get_global $nl))
        (if (call $compare (get_global $command) (get_global $lsCmd))(then
          (set_global $mode (i32.const 1))
        ))
        (if (call $compare (call $substr (get_global $command) (i32.const 0) (call $getPartLength (get_global $cdCmd))) (get_global $cdCmd))(then
          (call $setBaseUrl (call $pushString (call $substr (get_global $command) (i32.const 3) (i32.sub (call $getPartLength (get_global $command)) (i32.const 3)))))
        ))
        (if (call $compare (call $substr (get_global $command) (i32.const 0) (call $getPartLength (get_global $catCmd))) (get_global $catCmd))(then
          (set_global $mode (i32.const 2))
        ))
        (if (call $compare (call $substr (get_global $command) (i32.const 0) (call $getPartLength (get_global $lessCmd))) (get_global $lessCmd))(then
          (set_global $mode (i32.const 3))
        ))
      ))
    ))
    (if (i32.eq (get_global $mode) (i32.const 1))(then
      (drop (call $list (call $pushString (get_global $cwd)) (i32.const 1)))
      (set_global $mode (i32.const -1))
    ))
    (if (i32.eq (get_global $mode) (i32.const 2))(then
      (drop (call $read (call $pushString (call $substr (get_global $command) (i32.const 4) (i32.sub (call $getPartLength (get_global $command)) (i32.const 4)))) (i32.const 1)))
      (set_global $mode (i32.const -1))
    ))
    (if (i32.eq (get_global $mode) (i32.const 3))(then
      (drop (call $read (call $pushString (call $substr (get_global $command) (i32.const 5) (i32.sub (call $getPartLength (get_global $command)) (i32.const 5)))) (i32.const 2)))
      (set_global $mode (i32.const -1))
    ))
    (if (i32.eq (get_global $mode) (i32.const 4))(then
      (if (i32.eq (call $getInputKey) (i32.const 13))(then
        (call $printStr (call $getLine (get_global $lessFile) (get_global $lessLine)))
        (set_global $lessLine (i32.add (get_global $lessLine) (i32.const 1)))
        (if (i32.ge_u (get_global $lessLine) (call $countLines (get_global $lessFile)))(then
          (call $printStr (get_global $nl))
          (set_global $mode (i32.const 0))
        ))
      ))
    ))
    (call $deleteParent)
  )
  (export "step" (func $step))

  (func $dump (param $success i32) (param $len i32) (param $req i32)
    (call $enterPart (call $createPart (i32.const 1)))
    (if (get_local $success) (then
      (call $printStr (call $popString (get_local $len)))
      (call $printStr (get_global $nl))
      (call $printStr (get_global $nl))
    )(else
      (call $printStr (get_global $err))
    ))
    (set_global $mode (i32.const 0))
    (call $deleteParent)
  )

  (func $loadLess (param $success i32) (param $len i32) (param $req i32)
    (call $enterPart (call $createPart (i32.const 1)))
    (if (get_local $success) (then
      (call $resizePart (get_global $lessFile) (get_local $len))
      (call $popToMemory (call $getPartOffset (get_global $lessFile)))
      (set_global $lessLine (i32.const 0))
      (set_global $mode (i32.const 4))
    )(else
      (call $printStr (get_global $err))
      (set_global $mode (i32.const 0))
    ))
    (call $deleteParent)
  )


  ;; Display function is called whenever the display needs to be redrawn.
  (func $display (param $t f64)
  )
  (export "display" (func $display))

  ;; Break function is called whenever Esc is pressed.
  (func $break
    (if (get_global $mode)(then
      (set_global $mode (i32.const 0))
    )(else
      (call $shutdown)
    ))
  )
  (export "break" (func $break))






;;--------;;--------;;--------;;--------;;--------;;--------;;--------;;





  ;; String manipulation
  
  (func $printStr (param $str i32)
    (call $print (call $pushFromMemory (call $getPartOffset (get_local $str)) (call $getPartLength (get_local $str))))
  )
  
  (func $createString (param $srcOffset i32) (result i32)
    (local $str i32)
    (local $len i32)
    (set_local $len (i32.const 0))
    (block(loop
      (br_if 1 (i32.eq (i32.load8_u (i32.add (get_local $srcOffset) (get_local $len))) (i32.const 0)))
      (set_local $len (i32.add (get_local $len) (i32.const 1)))
      (br 0)
    ))
    (set_local $str (call $createPart (get_local $len)))
    (call $copyMem (get_local $srcOffset) (call $getPartOffset (get_local $str)) (get_local $len))
    (get_local $str)
  )

  (func $byteAt (param $str i32) (param $pos i32) (result i32)
    (i32.load8_u (i32.add (call $getPartOffset (get_local $str)) (get_local $pos)))
  )
  
  (func $substr (param $str i32) (param $pos i32) (param $len i32) (result i32)
    (local $strc i32)
    (if (i32.gt_u (get_local $pos) (call $getPartLength (get_local $str))) (then
      (set_local $pos (call $getPartLength (get_local $str)))
    ))
    (if (i32.gt_u (get_local $len) (i32.sub (call $getPartLength (get_local $str)) (get_local $pos))) (then
      (set_local $len (i32.sub (call $getPartLength (get_local $str)) (get_local $pos)) )
    ))
    (set_local $strc (call $createPart (get_local $len)))
    (call $copyMem (i32.add (call $getPartOffset (get_local $str)) (get_local $pos)) (call $getPartOffset (get_local $strc)) (get_local $len))
    (get_local $strc)
  )
  
  (func $concat (param $stra i32) (param $strb i32) (result i32)
    (local $strc i32)
    (set_local $strc (call $createPart (i32.add (call $getPartLength (get_local $stra)) (call $getPartLength (get_local $strb)))))
    (call $copyMem (call $getPartOffset (get_local $stra)) (call $getPartOffset (get_local $strc)) (call $getPartLength (get_local $stra)))
    (call $copyMem (call $getPartOffset (get_local $strb)) (i32.add (call $getPartOffset (get_local $strc)) (call $getPartLength (get_local $stra))) (call $getPartLength (get_local $strb)))
    (get_local $strc)
  )
  
  (func $appendBytes (param $str i32) (param $bytes i64)
    (local $l i32)
    (set_local $l (call $getPartLength (get_local $str)))
    (call $resizePart (get_local $str) (i32.add (get_local $l) (i32.const 9)))
    (set_local $l (i32.add (get_local $l) (i32.const 1)))
    (i64.store (i32.add (call $getPartOffset (get_local $str)) (get_local $l)) (i64.const 0))
    (set_local $l (i32.sub (get_local $l) (i32.const 1)))
    (i64.store (i32.add (call $getPartOffset (get_local $str)) (get_local $l)) (get_local $bytes))
    (set_local $l (i32.add (get_local $l) (i32.const 1)))
    (block(loop
      (br_if 1 (i32.eq (call $byteAt (get_local $str) (get_local $l)) (i32.const 0)))
      (set_local $l (i32.add (get_local $l) (i32.const 1)))
      (br 0)
    ))
    (call $resizePart (get_local $str) (get_local $l))
  )
  
  (func $usascii (param $str i32)
    (local $i i32)
    (local $l i32)
    (set_local $i (call $getPartOffset (get_local $str)))
    (set_local $l (call $getPartLength (get_local $str)))
    (block (loop
      (br_if 1 (i32.eq (get_local $l) (i32.const 0)))
      (if (i32.gt_u (i32.load8_u (get_local $i)) (i32.const 127)) (then
        (i32.store8 (get_local $i) (i32.const 63))
      ))
      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (set_local $l (i32.sub (get_local $l) (i32.const 1)))
      (br 0)
    ))
  )
  
  (func $getLine (param $str i32) (param $linenum i32) (result i32)
    (local $line i32)
    (local $col i32)
    (local $p i32)
    (local $strc i32)
    (block(loop
      (br_if 1 (get_local $strc))
      (set_local $col (i32.add (get_local $col) (i32.const 1)))
      (if (i32.eq (call $byteAt (get_local $str) (get_local $p)) (i32.const 10)) (then
        (if (i32.eq (get_local $line) (get_local $linenum)) (then
          (set_local $p (i32.sub (get_local $p) (i32.sub (get_local $col) (i32.const 1))))
          (set_local $strc (call $substr (get_local $str) (get_local $p) (get_local $col)))
          (set_local $p (i32.add (get_local $p) (i32.sub (get_local $col) (i32.const 1))))
        ))
        (set_local $line (i32.add (get_local $line) (i32.const 1)))
        (set_local $col (i32.const 0))
      ))
      (set_local $p (i32.add (get_local $p) (i32.const 1)))
      (br 0)
    ))
    (get_local $strc)
  )

  (func $countLines (param $str i32) (result i32)
    (local $line i32)
    (local $p i32)
    (local $l i32)
    (set_local $line (i32.const 1))
    (set_local $l (call $getPartLength (get_local $str)))
    (block(loop
      (br_if 1 (i32.ge_u (get_local $p) (get_local $l)))
      (if (i32.eq (call $byteAt (get_local $str) (get_local $p)) (i32.const 10)) (then
        (set_local $line (i32.add (get_local $line) (i32.const 1)))
      ))
      (set_local $p (i32.add (get_local $p) (i32.const 1)))
      (br 0)
    ))
    (get_local $line)
  )

  (func $lineAt (param $str i32) (param $pos i32) (result i32)
    (local $line i32)
    (local $p i32)
    (block(loop
      (br_if 1 (i32.eq (get_local $p) (get_local $pos)))
      (if (i32.eq (call $byteAt (get_local $str) (get_local $p)) (i32.const 10)) (then
        (set_local $line (i32.add (get_local $line) (i32.const 1)))
      ))
      (set_local $p (i32.add (get_local $p) (i32.const 1)))
      (br 0)
    ))
    (get_local $line)
  )

  (func $columnAt (param $str i32) (param $pos i32) (result i32)
    (local $col i32)
    (local $p i32)
    (block(loop
      (br_if 1 (i32.eq (get_local $p) (get_local $pos)))
      (set_local $col (i32.add (get_local $col) (i32.const 1)))
      (if (i32.eq (call $byteAt (get_local $str) (get_local $p)) (i32.const 10)) (then
        (set_local $col (i32.const 0))
      ))
      (set_local $p   (i32.add (get_local $p)   (i32.const 1)))
      (br 0)
    ))
    (get_local $col)
  )
  
  (func $uintToStr (param $int i32) (result i32)
    (local $order i32)
    (local $digit i32)
    (local $str i32)
    (set_local $order (i32.const 1000000000))
    (set_local $str (call $createPart (i32.const 0)))
    (block(loop
      (br_if 1 (i32.eq (get_local $order) (i32.const 0)))
      (set_local $digit (i32.div_u (get_local $int) (get_local $order)))
      (if (i32.or (get_local $digit) (call $getPartLength (get_local $str))) (then
        (call $appendBytes (get_local $str) (i64.extend_u/i32 (i32.add (i32.const 0x30) (get_local $digit))))
      ))
      (set_local $int (i32.rem_u (get_local $int) (get_local $order)))
      (set_local $order (i32.div_u (get_local $order) (i32.const 10)))
      (br 0)
    ))
    (get_local $str)
  )
  
  (func $compare (param $stra i32) (param $strb i32) (result i32)
    (local $p i32)
    (local $l i32)
    (if (i32.ne (call $getPartLength (get_local $stra)) (call $getPartLength (get_local $strb))) (then
      (return (i32.const 0))
    ))
    (set_local $l (call $getPartLength (get_local $stra)))
    (block(loop
      (br_if 1 (i32.eq (get_local $p) (get_local $l)))
      (if (i32.ne (call $byteAt (get_local $stra) (get_local $p)) (call $byteAt (get_local $strb) (get_local $p))) (then
        (return (i32.const 0))
      ))
      (set_local $p (i32.add (get_local $p) (i32.const 1)))
      (br 0)
    ))
    (i32.const 1)
  )
  
  (func $indexOf (param $haystack i32) (param $needle i32) (param $pos i32) (result i32)
    (local $sub i32)
    (if (i32.lt_u (call $getPartLength (get_local $haystack)) (call $getPartLength (get_local $needle))) (then
      (return (i32.const -1))
    ))
    (set_local $sub (call $createPart (call $getPartLength (get_local $needle))))
    (block(loop
      (br_if 1 (i32.ge_u (get_local $pos) (i32.sub (call $getPartLength (get_local $haystack)) (call $getPartLength (get_local $needle)))))
      (call $copyMem (i32.add (call $getPartOffset (get_local $haystack)) (get_local $pos)) (call $getPartOffset (get_local $sub)) (call $getPartLength (get_local $sub)))
      (if (call $compare (get_local $sub) (get_local $needle)) (then
        (return (get_local $pos))
      ))
      (set_local $pos (i32.add (get_local $pos) (i32.const 1)))
      (br 0)
    ))
    (i32.const -1)
  )

  (func $lastIndexOf (param $haystack i32) (param $needle i32) (param $pos i32) (result i32)
    (local $sub i32)
    (if (i32.lt_u (call $getPartLength (get_local $haystack)) (call $getPartLength (get_local $needle))) (then
      (return (i32.const -1))
    ))
    (set_local $sub (call $createPart (call $getPartLength (get_local $needle))))
    (block(loop
      (br_if 1 (i32.eq (get_local $pos) (i32.const 0)))
      (call $copyMem (i32.add (call $getPartOffset (get_local $haystack)) (get_local $pos)) (call $getPartOffset (get_local $sub)) (call $getPartLength (get_local $sub)))
      (if (call $compare (get_local $sub) (get_local $needle)) (then
        (return (get_local $pos))
      ))
      (set_local $pos (i32.sub (get_local $pos) (i32.const 1)))
      (br 0)
    ))
    (i32.const -1)
  )
  
  (func $trim (param $str i32)
    (local $p i32)
    (local $l i32)
    (set_local $p (call $getPartOffset (get_local $str)))
    (set_local $l (call $getPartLength (get_local $str)))
    (block(loop
      (br_if 1 (i32.or (i32.eqz (get_local $l)) (i32.gt_u (i32.load8_u (get_local $p)) (i32.const 32))))
      (set_local $p (i32.add (get_local $p) (i32.const 1)))
      (set_local $l (i32.sub (get_local $l) (i32.const 1)))
      (br 0)
    ))
    (call $copyMem (get_local $p) (call $getPartOffset (get_local $str)) (get_local $l))
    (block(loop
      (br_if 1 (i32.or (i32.eqz (get_local $l)) (i32.gt_u (call $byteAt (get_local $str) (i32.sub (get_local $l) (i32.const 1))) (i32.const 32))))
      (set_local $l (i32.sub (get_local $l) (i32.const 1)))
      (br 0)
    ))
    (call $resizePart (get_local $str) (get_local $l))
  )

  (func $pushString (param $str i32)
    (call $pushFromMemory (call $getPartOffset (get_local $str)) (call $getPartLength (get_local $str)))
  )

  (func $popString (param $len i32) (result i32)
    (local $str i32)
    (set_local $str (call $createPart (get_local $len)))
    (call $popToMemory (call $getPartOffset (get_local $str)))
    (get_local $str)
  )

 

  

 

  ;; Graphic routines

  (global $display (mut i32) (i32.const -1))
  (global $font    (mut i32) (i32.const -1))

  (func $rgb (param $r i32) (param $g i32) (param $b i32) (result i32)
    (local $c i32)
    (set_local $c (i32.const 255))
    (set_local $c (i32.mul (get_local $c) (i32.const 256)))
    (set_local $c (i32.add (get_local $c) (get_local $b)))
    (set_local $c (i32.mul (get_local $c) (i32.const 256)))
    (set_local $c (i32.add (get_local $c) (get_local $g)))
    (set_local $c (i32.mul (get_local $c) (i32.const 256)))
    (set_local $c (i32.add (get_local $c) (get_local $r)))
    (get_local $c)
  )

  (func $createImg (param $w i32) (param $h i32) (result i32)
    (local $img i32)
    (local $imgOffset i32)
    (set_local $img (call $createPart (i32.add (i32.const 8) (i32.mul (i32.mul (get_local $w) (get_local $h)) (i32.const 4)))))
    (set_local $imgOffset (call $getPartOffset (get_local $img)))
    (i32.store (i32.add (get_local $imgOffset) (i32.const 0)) (get_local $w))
    (i32.store (i32.add (get_local $imgOffset) (i32.const 4)) (get_local $h))
    (get_local $img)
  )
  (func $getImgWidth (param $img i32) (result i32)
    (i32.load (call $getPartOffset (get_local $img)))
  )
  (func $getImgHeight (param $img i32) (result i32)
    (i32.load (i32.add (call $getPartOffset (get_local $img)) (i32.const 4)))
  )

  (func $pget (param $img i32) (param $x i32) (param $y i32) (result i32)
    (local $imgOffset i32)
    (local $imgWidth i32)
    (local $imgHeight i32)
    (local $i i32)
    (set_local $imgOffset (call $getPartOffset (get_local $img)))
    (set_local $imgWidth (i32.load (get_local $imgOffset)))
    (set_local $imgOffset (i32.add (get_local $imgOffset) (i32.const 4)))
    (set_local $imgHeight (i32.load (get_local $imgOffset)))
    (set_local $imgOffset (i32.add (get_local $imgOffset) (i32.const 4)))

    (set_local $i (i32.mul (i32.const 4) (i32.add (get_local $x) (i32.mul (get_local $y) (get_local $imgWidth)))))
    (i32.load (i32.add (get_local $imgOffset) (get_local $i)))
  )
  (func $pset (param $img i32) (param $x i32) (param $y i32) (param $c i32)
    (local $imgOffset i32)
    (local $imgWidth i32)
    (local $imgHeight i32)
    (local $i i32)
    (set_local $imgOffset (call $getPartOffset (get_local $img)))
    (set_local $imgWidth (i32.load (get_local $imgOffset)))
    (set_local $imgOffset (i32.add (get_local $imgOffset) (i32.const 4)))
    (set_local $imgHeight (i32.load (get_local $imgOffset)))
    (set_local $imgOffset (i32.add (get_local $imgOffset) (i32.const 4)))

    (br_if 0 (i32.ge_u (get_local $x) (get_local $imgWidth)))
    (br_if 0 (i32.ge_u (get_local $y) (get_local $imgHeight)))
    (set_local $i (i32.mul (i32.const 4) (i32.add (get_local $x) (i32.mul (get_local $y) (get_local $imgWidth)))))
    (i32.store (i32.add (get_local $imgOffset) (get_local $i)) (get_local $c))
  )

  (func $rect (param $img i32) (param $x i32) (param $y i32) (param $w i32) (param $h i32) (param $c i32)
    (local $i i32)
    (local $j i32)
    (local $imgOffset i32)
    (local $imgWidth i32)
    (local $imgHeight i32)
    (set_local $imgOffset (call $getPartOffset (get_local $img)))
    (set_local $imgWidth (i32.load (get_local $imgOffset)))
    (set_local $imgOffset (i32.add (get_local $imgOffset) (i32.const 4)))
    (set_local $imgHeight (i32.load (get_local $imgOffset)))
    (set_local $imgOffset (i32.add (get_local $imgOffset) (i32.const 4)))
    
    (br_if 0 (i32.ge_s (get_local $x) (get_local $imgWidth)))
    (br_if 0 (i32.ge_s (get_local $y) (get_local $imgHeight)))
    (br_if 0 (i32.lt_s (i32.add (get_local $x) (get_local $w)) (i32.const 0)))
    (br_if 0 (i32.lt_s (i32.add (get_local $y) (get_local $h)) (i32.const 0)))
    (if (i32.lt_s (get_local $x) (i32.const 0)) (then
      (set_local $w (i32.add (get_local $w) (get_local $x)))
      (set_local $x (i32.const 0))
    ))
    (if (i32.lt_s (get_local $y) (i32.const 0)) (then
      (set_local $h (i32.add (get_local $h) (get_local $y)))
      (set_local $y (i32.const 0))
    ))
    (if (i32.gt_s (i32.add (get_local $x) (get_local $w)) (get_local $imgWidth)) (then
      (set_local $w (i32.sub (get_local $imgWidth) (get_local $x)))))
    (if (i32.gt_s (i32.add (get_local $y) (get_local $h)) (get_local $imgHeight)) (then
      (set_local $h (i32.sub (get_local $imgHeight) (get_local $y)))))
    (set_local $i (i32.mul (i32.const 4) (i32.add (get_local $x) (i32.mul (get_local $y) (get_local $imgWidth)))))
    (block (loop
      (br_if 1 (i32.eq (get_local $h) (i32.const 0)))
      (set_local $j (get_local $w))
      (block (loop
        (br_if 1 (i32.eq (get_local $j) (i32.const 0)))
        (i32.store (i32.add (get_local $imgOffset) (get_local $i)) (get_local $c))
        (set_local $i (i32.add (get_local $i) (i32.const 4)))
        (set_local $j (i32.sub (get_local $j) (i32.const 1)))
        (br 0)
      ))
      (set_local $i (i32.sub (i32.add (get_local $i) (i32.mul (i32.const 4) (get_local $imgWidth))) (i32.mul (i32.const 4) (get_local $w))))
      (set_local $h (i32.sub (get_local $h) (i32.const 1)))
      (br 0)
    ))
  )

  (func $copyImg (param $simg i32) (param $sx i32) (param $sy i32) (param $dimg i32) (param $dx i32) (param $dy i32) (param $w i32) (param $h i32)
    (local $x i32)
    (local $y i32)
    (local $c i32)
    (block (set_local $y (i32.const 0)) (loop
      (br_if 1 (i32.ge_u (get_local $y) (get_local $h)))
      (block (set_local $x (i32.const 0)) (loop
        (br_if 1 (i32.ge_u (get_local $x) (get_local $w)))
        (set_local $c (call $pget (get_local $simg)
          (i32.add (get_local $sx) (get_local $x))
          (i32.add (get_local $sy) (get_local $y))
        ))
        (if (i32.gt_u (get_local $c) (i32.const 0x77777777)) (then
          (call $pset (get_local $dimg)
            (i32.add (get_local $dx) (get_local $x))
            (i32.add (get_local $dy) (get_local $y))
            (get_local $c)
          )
        ))
        (set_local $x (i32.add (get_local $x) (i32.const 1)))
        (br 0)
      ))
      (set_local $y (i32.add (get_local $y) (i32.const 1)))
      (br 0)
    ))
  )

  (global $txtX (mut i32) (i32.const 0))
  (global $txtY (mut i32) (i32.const 0))

  (func $printChar (param $img i32) (param $char i32)
    (call $copyImg (get_global $font) (i32.const 0) (i32.mul (get_local $char) (i32.const 8)) (get_local $img) (get_global $txtX) (get_global $txtY) (i32.const 8) (i32.const 8))
    (set_global $txtX (i32.add (get_global $txtX) (i32.const 8)))
    (if (i32.eq (get_local $char) (i32.const 9)) (then
      (set_global $txtX (i32.sub (get_global $txtX) (i32.const 8)))
      (set_global $txtX (i32.div_u (get_global $txtX) (i32.const 32)))
      (set_global $txtX (i32.mul (get_global $txtX) (i32.const 32)))
      (set_global $txtX (i32.add (get_global $txtX) (i32.const 32)))
    ))
    (if (i32.eq (get_local $char) (i32.const 10)) (then
      (set_global $txtX (i32.const 0))
      (set_global $txtY (i32.add (get_global $txtY) (i32.const 8)))
    ))
    (if (i32.ge_u (get_global $txtX) (call $getImgWidth (get_local $img))) (then
      (set_global $txtX (i32.const 0))
      (set_global $txtY (i32.add (get_global $txtY) (i32.const 8)))
    ))
    (if (i32.ge_u (get_global $txtY) (call $getImgHeight (get_local $img))) (then
      (call $copyImg (get_local $img) (i32.const 0) (i32.const 8) (get_local $img) (i32.const 0) (i32.const 0) (call $getImgWidth (get_local $img)) (i32.sub (call $getImgHeight (get_local $img)) (i32.const 8)))
      (call $rect (get_local $img) (i32.const 0) (i32.sub (call $getImgHeight (get_local $img)) (i32.const 8)) (call $getImgWidth (get_local $img)) (i32.const 8) (call $pget (get_local $img) (i32.sub (call $getImgWidth (get_local $img)) (i32.const 1)) (i32.sub (call $getImgHeight (get_local $img)) (i32.const 1))))
      (set_global $txtY (i32.sub (get_global $txtY) (i32.const 8)))
    ))
  )

  (func $printStr (param $img i32) (param $str i32)
    (local $i i32)
    (local $len i32)
    (set_local $i (call $getPartOffset (get_local $str)))
    (set_local $len (call $getPartLength (get_local $str)))
    (if (i32.gt_u (get_local $len) (i32.const 0)) (then
      (loop
        (call $printChar (get_local $img) (i32.load8_u (get_local $i)))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (set_local $len (i32.sub (get_local $len) (i32.const 1)))
        (br_if 0 (i32.gt_u (get_local $len) (i32.const 0)))
      )
    ))
  )

  (func $printInput (param $img i32) (param $str i32) (param $pos i32) (param $sel i32) (param $c i32)
    (local $i i32)
    (local $len i32)
    (set_local $i (call $getPartOffset (get_local $str)))
    (set_local $len (call $getPartLength (get_local $str)))
    (if (i32.gt_u (get_local $len) (i32.const 0)) (then
      (loop
        (if (i32.eq (get_local $pos) (i32.const 0)) (then
          (if (i32.gt_u (get_local $sel) (i32.const 0)) (then
            (call $rect (get_local $img) (get_global $txtX) (get_global $txtY) (i32.const 8) (i32.const 8) (get_local $c))
            (set_local $sel (i32.sub (get_local $sel) (i32.const 1)))
          )(else
            (call $rect (get_local $img) (get_global $txtX) (get_global $txtY) (i32.const 1) (i32.const 8) (get_local $c))
            (set_local $pos (i32.sub (get_local $pos) (i32.const 1)))
          ))
        )(else
          (set_local $pos (i32.sub (get_local $pos) (i32.const 1)))
        ))
        (call $printChar (get_local $img) (i32.load8_u (get_local $i)))
        (set_local $i (i32.add (get_local $i) (i32.const 1)))
        (set_local $len (i32.sub (get_local $len) (i32.const 1)))
        (br_if 0 (i32.gt_u (get_local $len) (i32.const 0)))
      )
      (if (i32.eq (get_local $pos) (i32.const 0)) (then
        (if (i32.gt_u (get_local $sel) (i32.const 0)) (then
          (call $rect (get_local $img) (get_global $txtX) (get_global $txtY) (i32.const 8) (i32.const 8) (get_local $c))
          (set_local $sel (i32.sub (get_local $sel) (i32.const 1)))
        )(else
          (call $rect (get_local $img) (get_global $txtX) (get_global $txtY) (i32.const 1) (i32.const 8) (get_local $c))
          (set_local $pos (i32.sub (get_local $pos) (i32.const 1)))
        ))
      )(else
        (set_local $pos (i32.sub (get_local $pos) (i32.const 1)))
      ))
    ))
  )







  ;; Memory management

  (data (i32.const 0) "\00\00\00\00\00\00\00\00\10\00\00\00\00\00\00\00")
  (global $nextPartId (mut i32) (i32.const 1))
  (global $parentPart (mut i32) (i32.const 0))

  (func $getPartIndex (param $id i32) (result i32)
    (local $indexOffset i32)
    (local $indexLength i32)
    (local $p i32)
    (set_local $indexOffset (i32.const 0x00))
    (set_local $indexLength (i32.const 0x10))
    (set_local $p (get_local $indexOffset))
    (block(loop
      (br_if 1 (i32.ge_u (get_local $p) (i32.add (get_local $indexOffset) (get_local $indexLength))))
      (if (i32.eq (i32.load (get_local $p)) (get_local $id)) (then
        (return (get_local $p))
      ))
      (if (i32.eq (i32.load (get_local $p)) (i32.const 0)) (then
        (set_local $indexOffset (i32.load (i32.add (get_local $p) (i32.const 0x8))))
        (set_local $indexLength (i32.load (i32.add (get_local $p) (i32.const 0xc))))
        (set_local $p (get_local $indexOffset))
      )(else
        (set_local $p (i32.add (get_local $p) (i32.const 0x10)))
      ))
      (br 0)
    ))
    (i32.const -1)
  )
  (func $getPartParent (param $id i32) (result i32)
    (local $i i32)
    (set_local $i (call $getPartIndex (get_local $id)))
    (if (i32.ne (get_local $i) (i32.const -1)) (then
      (set_local $i (i32.load (i32.add (get_local $i) (i32.const 0x4))))
    ))
    (get_local $i)
  )
  (func $getPartOffset (param $id i32) (result i32)
    (local $i i32)
    (set_local $i (call $getPartIndex (get_local $id)))
    (if (i32.ne (get_local $i) (i32.const -1)) (then
      (set_local $i (i32.load (i32.add (get_local $i) (i32.const 0x8))))
    ))
    (get_local $i)
  )
  (func $getPartLength (param $id i32) (result i32)
    (local $i i32)
    (set_local $i (call $getPartIndex (get_local $id)))
    (if (i32.ne (get_local $i) (i32.const -1)) (then
      (set_local $i (i32.load (i32.add (get_local $i) (i32.const 0xc))))
    ))
    (get_local $i)
  )

  (func $getNextPart (param $fromOffset i32) (result i32)
    (local $indexOffset i32)
    (local $indexLength i32)
    (local $id i32)
    (local $offset i32)
    (local $bestId i32)
    (local $bestIdOffset i32)
    (local $p i32)
    (set_local $indexOffset (i32.const 0x00))
    (set_local $indexLength (i32.const 0x10))
    (set_local $bestId (i32.const -1))
    (set_local $bestIdOffset (i32.const -1))
    (set_local $p (get_local $indexOffset))
    (block(loop
      (br_if 1 (i32.ge_u (get_local $p) (i32.add (get_local $indexOffset) (get_local $indexLength))))
      (set_local $id (i32.load (get_local $p)))
      (set_local $offset (i32.load (i32.add (get_local $p) (i32.const 0x8))))
      (if (i32.and (i32.ge_u (get_local $offset) (get_local $fromOffset)) (i32.lt_u (get_local $offset) (get_local $bestIdOffset))) (then
        (set_local $bestId (get_local $id))
        (set_local $bestIdOffset (get_local $offset))
      ))
      (if (i32.eq (i32.load (get_local $p)) (i32.const 0)) (then
        (set_local $indexOffset (i32.load (i32.add (get_local $p) (i32.const 0x8))))
        (set_local $indexLength (i32.load (i32.add (get_local $p) (i32.const 0xc))))
        (set_local $p (get_local $indexOffset))
      )(else
        (set_local $p (i32.add (get_local $p) (i32.const 0x10)))
      ))
      (br 0)
    ))
    (get_local $bestId)
  )

  (func $alloc (param $len i32) (result i32)
    (local $offset i32)
    (local $nextId i32)
    (local $nextOffset i32)
    (set_local $offset (i32.const 0x10))
    (block(loop
      (set_local $nextId (call $getNextPart (get_local $offset)))
      (if (i32.eq (get_local $nextId) (i32.const -1))(then
        (set_local $nextOffset (i32.mul (current_memory) (i32.const 65536)))
      )(else
        (set_local $nextOffset (call $getPartOffset (get_local $nextId)))
      ))
      (br_if 1 (i32.gt_u (i32.sub (get_local $nextOffset) (get_local $offset)) (get_local $len)))
      (br_if 1 (i32.eq (get_local $nextId) (i32.const -1)))
      (set_local $offset (i32.add (get_local $nextOffset) (i32.add (call $getPartLength (get_local $nextId)) (i32.const 1))))
      (br 0)
    ))
    (if (i32.le_u (i32.sub (get_local $nextOffset) (get_local $offset)) (get_local $len)) (then
      (if (i32.lt_s (grow_memory (i32.add (i32.div_u (get_local $len) (i32.const 65536)) (i32.const 1))) (i32.const 0)) (then
        (unreachable)
      ))
      (set_local $offset (call $alloc (get_local $len)))
    ))
    (get_local $offset)
  )
  (func $resizePart (param $id i32) (param $newlen i32)
    (local $offset i32)
    (local $len i32)
    (set_local $offset (call $getPartOffset (get_local $id)))
    (set_local $len (call $getPartLength (get_local $id)))
    (if (i32.le_u (get_local $newlen) (get_local $len)) (then
      (i32.store (i32.add (call $getPartIndex (get_local $id)) (i32.const 0xc)) (get_local $newlen))
    )(else
      (i32.store (i32.add (call $getPartIndex (get_local $id)) (i32.const 0x8)) (call $alloc (get_local $newlen)))
      (i32.store (i32.add (call $getPartIndex (get_local $id)) (i32.const 0xc)) (get_local $newlen))
      (call $copyMem (get_local $offset) (call $getPartOffset (get_local $id)) (get_local $len))
    ))
  )
  (func $copyMem (param $fromOffset i32) (param $toOffset i32) (param $len i32)
    (local $delta i32)
    (if (i32.eqz (get_local $len)) (return))
    (if (i32.gt_u (get_local $fromOffset) (get_local $toOffset)) (then
      (set_local $delta (i32.const 1))
    )(else
      (set_local $delta (i32.const -1))
      (set_local $len (i32.sub (get_local $len) (i32.const 1)))
      (set_local $fromOffset (i32.add (get_local $fromOffset) (get_local $len)))
      (set_local $toOffset   (i32.add (get_local $toOffset  ) (get_local $len)))
      (set_local $len (i32.add (get_local $len) (i32.const 1)))
    ))
    (block (loop
      (br_if 1 (i32.eqz (get_local $len)))
      (i32.store8 (get_local $toOffset) (i32.load8_u (get_local $fromOffset)))
      (set_local $fromOffset (i32.add (get_local $fromOffset) (get_local $delta)))
      (set_local $toOffset   (i32.add (get_local $toOffset  ) (get_local $delta)))
      (set_local $len        (i32.sub (get_local $len)        (i32.const 1)))
      (br 0)
    ))
  )
  (func $createPart (param $len i32) (result i32)
    (local $offset i32)
    (call $resizePart (i32.const 0) (i32.add (call $getPartLength (i32.const 0)) (i32.const 0x10)))
    (set_local $offset (i32.sub (i32.add (call $getPartOffset (i32.const 0)) (call $getPartLength (i32.const 0))) (i32.const 0x10)))
    (i32.store (i32.add (get_local $offset) (i32.const 0x0)) (get_global $nextPartId))
    (i32.store (i32.add (get_local $offset) (i32.const 0x4)) (get_global $parentPart))
    (i32.store (i32.add (get_local $offset) (i32.const 0x8)) (call $alloc (get_local $len)))
    (i32.store (i32.add (get_local $offset) (i32.const 0xc)) (get_local $len))
    (get_global $nextPartId)
    (set_global $nextPartId (i32.add (get_global $nextPartId) (i32.const 1)))
  )

  (func $deletePart (param $id i32)
    (local $indexOffset i32)
    (local $indexLength i32)
    (local $p i32)
    (set_local $indexOffset (call $getPartOffset (i32.const 0)))
    (set_local $indexLength (call $getPartLength (i32.const 0)))
    (set_local $p (get_local $indexOffset))
    (block(loop
      (br_if 1 (i32.ge_u (get_local $p) (i32.add (get_local $indexOffset) (get_local $indexLength))))
      (if (i32.eq (i32.load (get_local $p)) (get_local $id)) (then
        (call $copyMem (i32.sub (i32.add (get_local $indexOffset) (get_local $indexLength)) (i32.const 0x10)) (get_local $p) (i32.const 0x10))
        (set_local $indexLength (i32.sub (get_local $indexLength) (i32.const 0x10)))
        (call $resizePart (i32.const 0) (get_local $indexLength))
        (set_local $p (i32.sub (get_local $p) (i32.const 0x10)))
      ))
      (if (i32.eq (i32.load (i32.add (get_local $p) (i32.const 0x4))) (get_local $id)) (then
        (call $deletePart (i32.load (get_local $p)))
        (set_local $indexOffset (call $getPartOffset (i32.const 0)))
        (set_local $indexLength (call $getPartLength (i32.const 0)))
        (set_local $p (i32.sub (get_local $indexOffset) (i32.const 0x10)))
      ))
      (set_local $p (i32.add (get_local $p) (i32.const 0x10)))
      (br 0)
    ))
    (if (i32.eq (get_global $parentPart) (get_local $id))(then
      (call $exitPart)
    ))
  )
  (func $movePartUp (param $id i32)
    (local $p i32)
    (set_local $p (call $getPartIndex (get_local $id)))
    (i32.store (i32.add (get_local $p) (i32.const 0x4)) (call $getPartParent (call $getPartParent (get_local $id))))
  )
  (func $enterPart (param $id i32)
    (set_global $parentPart (get_local $id))
  )
  (func $exitPart
    (set_global $parentPart (call $getPartParent (get_global $parentPart)))
  )
  (func $deleteParent
    (call $deletePart (get_global $parentPart))
  )
)
