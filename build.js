const
  Watcher = require("file-watch"),
  wabt = require("wabt"),
  waquire = require("waquire"),
  fs = require("fs")

const watcher = new Watcher()

watcher.watch("wast", ["./boot.wast"])

watcher.on("wast", () => {
  console.log("Compiling...")
  fs.writeFileSync("boot.wasm", new Uint8Array(wabt.parseWat("boot", waquire("./boot.wast")).toBinary({}).buffer))
  console.log("oK")
})