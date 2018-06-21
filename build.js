const
  Watcher = require("file-watcher"),
  wabt = require("wabt"),
  waquire = require("waquire"),
  fs = require("fs")

const watcher = new Watcher({
  root: __dirname,
  filter: (filename) => filename.substr(-4) === "wast"
})

const wastModules = []
let cooldown = false
watcher.on("any", (event, change) => {
  if (change.oldPath) {
    let i = wastModules.indexOf(change.oldPath)
    if (i >= 0) wastModules.splice(i, 1)
  }
  if (change.newPath) {
    let wast = fs.readFileSync(change.newPath)
    if (wast.indexOf("(module") >= 0) wastModules.push(change.newPath)
  }
  if (cooldown) return
  cooldown = true
  wastModules.forEach((file) => {
    console.log("Compiling ", file, "...")
    let bundle = waquire("./" + file)
    // fs.writeFileSync(file.replace(".wast", ".bundle"), bundle)
    fs.writeFileSync(file.replace(".wast", ".wasm"), new Uint8Array(wabt.parseWat(file, bundle).toBinary({}).buffer))
  })
  console.log("oK")
  setTimeout(() => {
    cooldown = false
  }, 1024);
})

watcher.watch()