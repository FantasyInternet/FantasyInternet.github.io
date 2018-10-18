(global $current_pid (mut i32) (i32.const 0))

;; Buffer stack
(import "env" "pushFromMemory" (func $_pushFromMemory (param $offset f64) (param $length f64) (param $pid f64) (result f64)))
(func $pushFromMemory (param $offset f64) (param $length f64) (result f64)
  (call $_pushFromMemory (get_local $offset) (get_local $length) (call $-f64 (get_global $current_pid)))
)
(export "env.pushFromMemory" (func $pushFromMemory))
(import "env" "popToMemory" (func $_popToMemory (param $offset f64) (param $pid f64) (result f64)))
(func $popToMemory (param $offset f64) (result f64)
  (call $_popToMemory (get_local $offset) (call $-f64 (get_global $current_pid)))
)
(export "env.popToMemory" (func $popToMemory))
(import "env" "teeToMemory" (func $_teeToMemory (param $offset f64) (param $pid f64) (result f64)))
(func $teeToMemory (param $offset f64) (result f64)
  (call $_teeToMemory (get_local $offset) (call $-f64 (get_global $current_pid)))
)
(export "env.teeToMemory" (func $teeToMemory))
(import "env" "getBufferSize" (func $_getBufferSize (result f64)))
(export "env.getBufferSize" (func $_getBufferSize))

;; API function index
(import "env" "getApiFunctionIndex" (func $_getApiFunctionIndex (result f64)))
(export "env.getApiFunctionIndex" (func $_getApiFunctionIndex))
(import "env" "callApiFunction" (func $_callApiFunction (param f64) (param f64) (param f64) (param f64) (param f64) (param f64) (param f64) (param f64) (result f64)))
(export "env.callApiFunction" (func $_callApiFunction))

;; Logging
(import "env" "log" (func $_log (result f64)))
(export "env.log" (func $_log))
(import "env" "logNumber" (func $_logNumber (param f64) (param f64) (param f64) (param f64) (param f64) (param f64) (param f64) (param f64) (result f64)))
(export "env.logNumber" (func $_logNumber))

;; Display
(import "env" "setDisplayMode" (func $_setDisplayMode (param $mode f64) (param $width f64) (param $height f64) (param $visibleWidth f64) (param $visibleHeight f64) (result f64)))
(export "env.setDisplayMode" (func $_setDisplayMode ))
(import "env" "print" (func $_print (result f64)))
(export "env.print" (func $_print))
(import "env" "displayMemory" (func $_displayMemory (param $offset f64) (param $length f64) (param $screenOffset f64) (param $pid f64) (result f64)))
(func $displayMemory (param $offset f64) (param $length f64) (param $screenOffset f64) (result f64)
  (call $_displayMemory (get_local $offset) (get_local $length) (get_local $screenOffset) (call $-f64 (get_global $current_pid)))
)
(export "env.displayMemory" (func $displayMemory))
(import "env" "getNativeDisplayWidth" (func $_getNativeDisplayWidth (result f64)))
(export "env.getNativeDisplayWidth" (func $_getNativeDisplayWidth))
(import "env" "getNativeDisplayHeight" (func $_getNativeDisplayHeight (result f64)))
(export "env.getNativeDisplayHeight" (func $_getNativeDisplayHeight))

;; Audio
(import "env" "startTone" (func $_startTone (param $channel f64) (param $frequency f64) (param $volume f64) (param $type f64) (result f64)))
(export "env.startTone" (func $_startTone))
(import "env" "rampFrequency" (func $_rampFrequency (param $channel f64) (param $frequency f64) (param $duration f64) (result f64)))
(export "env.rampFrequency" (func $_rampFrequency))
(import "env" "rampVolume" (func $_rampVolume (param $channel f64) (param $volume f64) (param $duration f64) (result f64)))
(export "env.rampVolume" (func $_rampVolume))
(import "env" "stopTone" (func $_stopTone (param $channel f64) (result f64)))
(export "env.stopTone" (func $_stopTone))

;; User input
(import "env" "focusInput" (func $_focusInput (param $type f64) (result f64)))
(export "env.focusInput" (func $_focusInput))
(import "env" "getInputText" (func $_getInputText (result f64)))
(export "env.getInputText" (func $_getInputText))
(import "env" "getInputPosition" (func $_getInputPosition (result f64)))
(export "env.getInputPosition" (func $_getInputPosition))
(import "env" "getInputSelected" (func $_getInputSelected (result f64)))
(export "env.getInputSelected" (func $_getInputSelected))
(import "env" "getInputKey" (func $_getInputKey (result f64)))
(export "env.getInputKey" (func $_getInputKey))
(import "env" "setInputType" (func $_setInputType (param $type f64) (result f64)))
(export "env.setInputType" (func $_setInputType))
(import "env" "setInputText" (func $_setInputText (result f64)))
(export "env.setInputText" (func $_setInputText))
(import "env" "setInputPosition" (func $_setInputPosition (param $position f64) (param $length f64) (result f64)))
(export "env.setInputPosition" (func $_setInputPosition))
(import "env" "replaceInputText" (func $_replaceInputText (param $fromPosition f64) (result f64)))
(export "env.replaceInputText" (func $_replaceInputText))
(import "env" "getMouseX" (func $_getMouseX (result f64)))
(export "env.getMouseX" (func $_getMouseX))
(import "env" "getMouseY" (func $_getMouseY (result f64)))
(export "env.getMouseY" (func $_getMouseY))
(import "env" "getMousePressed" (func $_getMousePressed (result f64)))
(export "env.getMousePressed" (func $_getMousePressed))
(import "env" "setNativeMouse" (func $_setNativeMouse (param $visible f64) (result f64)))
(export "env.setNativeMouse" (func $_setNativeMouse))
(import "env" "getGameAxisX" (func $_getGameAxisX (result f64)))
(export "env.getGameAxisX" (func $_getGameAxisX))
(import "env" "getGameAxisY" (func $_getGameAxisY (result f64)))
(export "env.getGameAxisY" (func $_getGameAxisY))
(import "env" "getGameButtonA" (func $_getGameButtonA (result f64)))
(export "env.getGameButtonA" (func $_getGameButtonA))
(import "env" "getGameButtonB" (func $_getGameButtonB (result f64)))
(export "env.getGameButtonB" (func $_getGameButtonB))
(import "env" "getGameButtonX" (func $_getGameButtonX (result f64)))
(export "env.getGameButtonX" (func $_getGameButtonX))
(import "env" "getGameButtonY" (func $_getGameButtonY (result f64)))
(export "env.getGameButtonY" (func $_getGameButtonY))

;; Navigation
(import "env" "connectTo" (func $_connectTo (result f64)))
(export "env.connectTo" (func $_connectTo))
(func $shutdown (result f64)
  (call $_killProcess (call $-f64 (get_global $current_pid)))
  (drop (call $_setStepInterval (f64.const 128)))
)
(export "env.shutdown" (func $shutdown))
(import "env" "getOriginUrl" (func $_getOriginUrl (result f64)))
(export "env.getOriginUrl" (func $_getOriginUrl))
(import "env" "getBaseUrl" (func $_getBaseUrl (result f64)))
(export "env.getBaseUrl" (func $_getBaseUrl))
(import "env" "setBaseUrl" (func $_setBaseUrl (result f64)))
(export "env.setBaseUrl" (func $_setBaseUrl))

;; File system
(import "env" "read" (func $_read (param $callback f64) (param $pid f64) (result f64)))
(func $read (param $callback f64) (result f64)
  (call $_read (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.read" (func $read))
(import "env" "write" (func $_write (param $callback f64) (param $pid f64) (result f64)))
(func $write (param $callback f64) (result f64)
  (call $_write (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.write" (func $write))
(import "env" "delete" (func $_delete (param $callback f64) (param $pid f64) (result f64)))
(func $delete (param $callback f64) (result f64)
  (call $_delete (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.delete" (func $delete))
(import "env" "list" (func $_list (param $callback f64) (param $pid f64) (result f64)))
(func $list (param $callback f64) (result f64)
  (call $_list (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.list" (func $list))
(import "env" "head" (func $_head (param $callback f64) (param $pid f64) (result f64)))
(func $head (param $callback f64) (result f64)
  (call $_head (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.head" (func $head))
(import "env" "post" (func $_post (param $callback f64) (param $pid f64) (result f64)))
(func $post (param $callback f64) (result f64)
  (call $_post (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.post" (func $post))
(import "env" "readImage" (func $_readImage (param $callback f64) (param $pid f64) (result f64)))
(func $readImage (param $callback f64) (result f64)
  (call $_readImage (get_local $callback) (call $-f64 (get_global $current_pid)))
)
(export "env.readImage" (func $readImage))

;; Process handling
(import "env" "setStepInterval" (func $_setStepInterval (param $interval f64) (result f64)))
(export "env.setStepInterval" (func $_setStepInterval))
(import "env" "killProcess" (func $_killProcess (param $pid f64) (result f64)))
(export "env.killProcess" (func $_killProcess))