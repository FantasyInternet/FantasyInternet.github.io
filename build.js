const
  Watcher = require("file-watcher"),
  poetry = require("poetry-compiler"),
  fs = require("fs")

const watcher = new Watcher({
  root: __dirname,
  filter: (filename, stat) => stat.isDirectory() || filename.substr(-5) === ".poem"
})

const wastModules = []
let cooldown = false
watcher.on("any", (event, change) => {
  if (change.oldPath) {
    let i = wastModules.indexOf(change.oldPath)
    if (i >= 0) wastModules.splice(i, 1)
  }
  if (change.newPath && !change.newStats.isDirectory()) {
    let wast = fs.readFileSync(change.newPath)
    wastModules.push(change.newPath)
  }
  if (cooldown) return
  cooldown = true
  wastModules.forEach((file) => {
    console.log("Compiling ", file, "...")
    let binary = poetry("./" + file, { wasm: file.replace(".poem", ".wasm") })
  })
  console.log("oK")
  setTimeout(() => {
    cooldown = false
  }, 1024);
})

watcher.watch()