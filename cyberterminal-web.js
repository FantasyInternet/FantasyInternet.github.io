(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){module.exports={"name":"cyberterminal","version":"0.0.106","description":"A fantasy internet client.","author":{"name":"codeartisticninja","url":"http://codeartistic.ninja/"},"private":true,"build":{"appId":"ninja.codeartistic","nsis":{"oneClick":false,"allowToChangeInstallationDirectory":true},"win":{"target":["nsis","portable"],"icon":"images/icon.png"},"mac":{"category":"your.app.category.type"},"directories":{"app":"./build/electron-version/","output":"./build-desktop/"}},"scripts":{"prepublish":"jake","build":"jake","build-desktop":"electron-builder","deploy":"jake deploy","start":"statify -d ./build/","watch":"jake watch"},"devDependencies":{"@types/electron":"^1.6.10","browserify":"^16.2.2","cssmin":"^0.4.3","electron-builder":"^20.15.1","file-watch":"^0.1.0","ftp":"^0.3.10","htmlmin":"0.0.7","jake":"^8.0.16","jsmin":"^1.0.1","jstransformer-markdown-it":"^2.1.0","less":"^3.0.4","livereload":"^0.7.0","md5":"^2.2.1","pug":"^2.0.3","tsify":"^4.0.0","typedoc":"^0.11.1","typedoc-plugin-markdown":"^1.1.12","typescript":"^2.9.1","wabt":"^1.0.0","walt-compiler":"^0.6.2"},"dependencies":{"statify":"^2.0.1"}}},{}],2:[function(require,module,exports){"use strict";Object.defineProperty(exports,"__esModule",{value:true});class Breaker{constructor(sys){this.sys=sys;this.state={level:0};this._listeners=[];document.addEventListener("keydown",(e)=>{if(e.code==="Escape"&&this.state.level===0){this.state.level=1;this._sendState();setTimeout(()=>{if(this.state.level===1){this.state.level=2;this._sendState();}},1024);}});document.addEventListener("keyup",(e)=>{if(e.code==="Escape"){this.state.level=0;this._sendState();}});}
addEventListener(fn){let i=this._listeners.indexOf(fn);if(i<0){this._listeners.push(fn);}}
removeEventListener(fn){let i=this._listeners.indexOf(fn);if(i>=0){this._listeners.splice(i,1);}}
_sendState(){let newState=JSON.stringify(this.state);if(this._lastState!==newState){this._lastState=newState;this._listeners.forEach((fn)=>{fn(this.state);});}}}
exports.default=Breaker;},{}],3:[function(require,module,exports){"use strict";Object.defineProperty(exports,"__esModule",{value:true});class ChipSound{constructor(){this._channels=[];this._ctx=new AudioContext();if(this._ctx.state==="suspended"){let cb=()=>{this._ctx.resume();if(this._ctx.state==="running"){document.body.removeEventListener("pointerdown",cb);document.body.removeEventListener("keydown",cb);}};document.body.addEventListener("pointerdown",cb);document.body.addEventListener("keydown",cb);}}
startTone(channel,frequency,volume=1,type="square"){let chan=this._channels[channel];if(!chan){chan={oscillator:this._ctx.createOscillator(),gain:this._ctx.createGain(),autoStop:null};chan.oscillator.connect(chan.gain);chan.gain.connect(this._ctx.destination);}
clearTimeout(chan.autoStop);chan.oscillator.frequency.setValueAtTime(frequency,0);chan.gain.gain.setValueAtTime(volume*.5,0);chan.oscillator.type=type;if(!this._channels[channel]){this._channels[channel]=chan;chan.oscillator.start();}
chan.autoStop=setTimeout(()=>{this.stopTone(channel);},1000*10);}
stopTone(channel){let chan=this._channels[channel];if(chan){clearTimeout(chan.autoStop);chan.oscillator.stop();chan.oscillator.disconnect(chan.gain);chan.gain.disconnect(this._ctx.destination);delete this._channels[channel];}}
stopAll(){for(let i=0;i<this._channels.length;i++){this.stopTone(i);}}}
exports.default=ChipSound;},{}],4:[function(require,module,exports){"use strict";var __awaiter=(this&&this.__awaiter)||function(thisArg,_arguments,P,generator){return new(P||(P=Promise))(function(resolve,reject){function fulfilled(value){try{step(generator.next(value));}catch(e){reject(e);}}
function rejected(value){try{step(generator["throw"](value));}catch(e){reject(e);}}
function step(result){result.done?resolve(result.value):new P(function(resolve){resolve(result.value);}).then(fulfilled,rejected);}
step((generator=generator.apply(thisArg,_arguments||[])).next());});};Object.defineProperty(exports,"__esModule",{value:true});let pkg=require("../../../package.json");class CyberTerminal{constructor(sys){this.sys=sys;this.machineWorkers=[];this._disconnecting=false;this.sys.textInput.addEventListener(this._onTextInput.bind(this));this.sys.mouseInput.addEventListener(this._onMouseInput.bind(this));this.sys.gameInput.addEventListener(this._onGameInput.bind(this));this.sys.breaker.addEventListener(this._onBreak.bind(this));this.sys.setDisplayMode("text",80,20);this.sys.print("CyberTerminal v"+pkg.version);setTimeout(()=>{this.sys.startTone(0,512);setTimeout(()=>{this.connectTo(location.toString());},256);},1024);document.addEventListener("visibilitychange",()=>{if(this.machineWorkers.length){if(document.visibilityState==="visible"){this.machineWorkers[this.machineWorkers.length-1].send({cmd:"resume"});}
else{this.machineWorkers[this.machineWorkers.length-1].send({cmd:"suspend"});this.sys.chipSound.stopAll();}}});}
connectTo(url){return __awaiter(this,void 0,void 0,function*(){if(this._connecting)
return;this.sys.setDisplayMode("text",80,20);this.sys.print("\n\nConnecting to "+url);this._connecting=true;let machine=this.addMachine();let msg=yield this._findBoot(url);if(msg.wasm){this.sys.print(".");this.sys.setTitle(""+msg.url);this.sys.setDisplayMode("none",0,0);machine.send(msg);this._connecting=setTimeout(()=>{this._connecting=null;},1024);}
else if(typeof process!=="undefined"){this.sys.print(".");this._connecting=setTimeout(()=>{this.removeMachine();this._connecting=null;},1024);this.sys.openWeb(url);}
else if(location.toString()!==url){this.sys.print(".");this.sys.openWeb(url);}
else{this.sys.print("!\n");this.sys.print("could not load boot.wasm!");}});}
addMachine(){if(this.machineWorkers.length)
this.machineWorkers[this.machineWorkers.length-1].send({cmd:"suspend"});let machine=this.sys.createMachine();this.machineWorkers.push(machine);machine.onMessage(this._onMessage.bind(this));this.sys.textInput.setState({type:"multiline",text:"",pos:0,len:0,key:0});this.sys.chipSound.stopAll();return machine;}
removeMachine(){let machine=this.machineWorkers.pop();if(machine)
machine.terminate();this.sys.setDisplayMode("text",80,20);this.sys.print("\n\nDisconnecting...");setTimeout(()=>{if(this.machineWorkers.length){this.sys.setDisplayMode("none",0,0);this.machineWorkers[this.machineWorkers.length-1].send({cmd:"resume"});}
else{if(history.length>1){history.back();}
else{location.reload(true);}}},128);this.sys.textInput.setState({type:"multiline",text:"",pos:0,len:0});this.sys.chipSound.stopAll();}
_onMessage(message,machineWorker){switch(message.cmd){case"call":let value;try{message.success=true;if(this[message.method]){value=this[message.method].apply(this,message.arguments);}
else{value=this.sys[message.method].apply(this.sys,message.arguments);}}
catch(error){message.success=false;value=error;}
if(message.reqId!=null){message.cmd="response";if(value instanceof Promise){value.then((value)=>{message.value=value;machineWorker.send(message);},(value)=>{message.success=false;message.value=value;machineWorker.send(message);});}
else{message.value=value;machineWorker.send(message);}}
break;case"imagedata":let buffer=message.buffer;if(!buffer)
throw"No buffer received!";this.sys.drawBitmap(buffer);machineWorker.send({cmd:"imagedata",width:message.width,height:message.height,buffer:buffer},[buffer]);break;default:break;}}
_onTextInput(state){let msg={cmd:"textInput",state:state};if(!this.machineWorkers.length)
return;this.machineWorkers[this.machineWorkers.length-1].send(msg);}
_onMouseInput(state){let msg={cmd:"mouseInput",state:state};if(!this.machineWorkers.length)
return;this.machineWorkers[this.machineWorkers.length-1].send(msg);}
_onGameInput(state){let msg={cmd:"gameInput",state:state};if(!this.machineWorkers.length)
return;this.machineWorkers[this.machineWorkers.length-1].send(msg);}
_onBreak(state){if(state.level===0&&this._disconnecting){this.sys.stopTone(0);this.removeMachine();this._disconnecting=false;}
else if(state.level===1){let msg={cmd:"break",state:state};if(!this.machineWorkers.length)
return;this.machineWorkers[this.machineWorkers.length-1].send(msg);}
else if(state.level===2){if(!this.machineWorkers.length)
return;this.machineWorkers[this.machineWorkers.length-1].terminate();this.sys.startTone(0,256);setTimeout(()=>{this.sys.stopTone(0);},128);this._disconnecting=true;}}
_findBoot(url){return __awaiter(this,void 0,void 0,function*(){this.sys.print(".");if(url.substr(0,5)!=="file:"){try{url=(yield fetch(url)).url;}
catch(error){return{};}}
let parts=url.split("/");let candidate=parts.shift()+"/"+parts.shift()+"/";let wasm=null;while(parts.length&&!wasm){this.sys.print(".");candidate+=parts.shift()+"/";try{wasm=yield this.sys.read(candidate+"boot.wasm",{type:"binary"});}
catch(error){wasm=null;}}
this.sys.print(".");return{cmd:"boot",wasm:wasm,url:url,origin:candidate};});}}
exports.default=CyberTerminal;},{"../../../package.json":1}],5:[function(require,module,exports){"use strict";Object.defineProperty(exports,"__esModule",{value:true});class GameInput{constructor(sys){this.sys=sys;this.state={axis:{x:0,y:0},buttons:{a:false,b:false,x:false,y:false}};this._listeners=[];this._keyMap=this._getKeyMap();document.addEventListener("keydown",(e)=>{if(this.sys.inputPriority.indexOf("game")>this.sys.inputPriority.indexOf("text"))
return this.sys.focusInput("text");if(e.altKey&&e.code==="KeyT")
return this.sys.focusInput("text");let ctrl=this._keyMap[e.code];switch(ctrl){case"left":this.state.axis.x=-1;e.preventDefault();break;case"right":this.state.axis.x=1;e.preventDefault();break;case"up":this.state.axis.y=-1;e.preventDefault();break;case"down":this.state.axis.y=1;e.preventDefault();break;case"a":this.state.buttons.a=true;e.preventDefault();break;case"b":this.state.buttons.b=true;e.preventDefault();break;case"x":this.state.buttons.x=true;e.preventDefault();break;case"y":e.preventDefault();this.state.buttons.y=true;break;}
this._sendState();});document.addEventListener("keyup",(e)=>{let ctrl=this._keyMap[e.code];switch(ctrl){case"left":this.state.axis.x=Math.max(this.state.axis.x,0);break;case"right":this.state.axis.x=Math.min(this.state.axis.x,0);break;case"up":this.state.axis.y=Math.max(this.state.axis.y,0);break;case"down":this.state.axis.y=Math.min(this.state.axis.y,0);break;case"a":this.state.buttons.a=false;break;case"b":this.state.buttons.b=false;break;case"x":this.state.buttons.x=false;break;case"y":this.state.buttons.y=false;break;}
this._sendState();switch(e.code){case"KeyD":this._keyMap["KeyA"]="left";this._keyMap["KeyS"]="down";break;case"KeyL":this._keyMap["KeyA"]="left";this._keyMap["KeyS"]="right";break;case"ArrowLeft":case"ArrowRight":case"ArrowUp":case"ArrowDown":this._keyMap["KeyA"]="a";this._keyMap["KeyS"]="b";break;default:break;}});}
focus(){}
blur(){this.state.axis.x=this.state.axis.y=0;this.state.buttons.a=this.state.buttons.b=this.state.buttons.x=this.state.buttons.y=false;this._sendState();}
addEventListener(fn){let i=this._listeners.indexOf(fn);if(i<0){this._listeners.push(fn);}}
removeEventListener(fn){let i=this._listeners.indexOf(fn);if(i>=0){this._listeners.splice(i,1);}}
_sendState(){let newState=JSON.stringify(this.state);if(this._lastState!==newState){this._lastState=newState;this._listeners.forEach((fn)=>{fn(this.state);});}}
_getKeyMap(){let map={},ctrls={"left":["ArrowLeft","KeyA"],"right":["ArrowRight","KeyD"],"up":["ArrowUp","KeyW","KeyP"],"down":["ArrowDown","KeyS","KeyL"],"a":["KeyA","KeyK","KeyV","Enter"],"b":["KeyB","KeyS","KeyO","Space"],"x":["KeyX","KeyE","Backspace"],"y":["KeyY","KeyZ","KeyC"]};for(let ctrl in ctrls){let codes=ctrls[ctrl];for(let code of codes){map[code]=ctrl;}}
return map;}}
exports.default=GameInput;},{}],6:[function(require,module,exports){"use strict";Object.defineProperty(exports,"__esModule",{value:true});var wabt=require("./wabt");class Machine{constructor(){this._active=false;this._nextStep=performance.now();this._stepInterval=-1;this._stepCount=0;this._stepSecond=0;this._frameCount=0;this._frameSecond=0;this._toneTypes=["square","sawtooth","triangle","sine"];this._displayModes=["text","pixel"];this._displayMode=-1;this._displayWidth=-1;this._displayHeight=-1;this._visibleWidth=-1;this._visibleHeight=-1;this._transferBuffer=new ArrayBuffer(8);this._lastCommit=performance.now();this._pendingCommits=[];this._pendingRequests=[];this._baseUrl="";this._originUrl="";this._romApiNames=[];this._processes=[];this._activePID=-1;this._bufferStack=new Uint8Array(1024);this._bufferStackLengths=[];this._asyncCalls=0;this._inputFocus=-1;this._textInputState={type:0,text:"",pos:0,len:0,key:0};this._keyBuffer=[0];this._inputTypes=["multiline","text","password","number","url","email","tel"];this._mouseInputState={x:0,y:0,pressed:false};this._gameInputState={axis:{x:0,y:0},buttons:{a:false,b:false,x:false,y:false}};this._initCom();}
log(){console.log("📟",this._popString());}
logNumber(){console.log("💡",...arguments);}
setDisplayMode(mode,width,height,visibleWidth=width,visibleHeight=height){this._sysCall("setDisplayMode",this._displayModes[mode],width,height,visibleWidth,visibleHeight);this._displayMode=mode;this._displayWidth=width;this._displayHeight=height;this._visibleWidth=visibleWidth;this._visibleHeight=visibleHeight;switch(this._displayModes[this._displayMode]){case"text":break;case"pixel":break;default:this._displayMode=-1;this._visibleWidth=-1;this._visibleHeight=-1;throw"DisplayMode not supported!";}
return;}
print(){this._sysCall("print",this._popString());}
displayMemory(offset,length,destination=0){let process=this._processes[this._activePID];if(!process)
throw"No active process!";let buffer;if(this._transferBuffer&&this._transferBuffer.byteLength===(this._displayWidth*this._displayHeight*4)){buffer=this._transferBuffer;delete this._transferBuffer;}
else{console.warn("Creating new _transferBuffer");buffer=new ArrayBuffer(this._displayWidth*this._displayHeight*4);}
let data=new Uint8ClampedArray(buffer);data.set(new Uint8Array(process.instance.exports.memory.buffer.slice(offset,offset+length)),destination);postMessage({cmd:"imagedata",width:this._displayWidth,height:this._displayHeight,buffer:buffer},[buffer]);this._lastCommit=performance.now();}
pushFromMemory(offset,length){let process=this._processes[this._activePID];if(!process)
throw"No active process!";let ar=new Uint8Array(length);ar.set(new Uint8Array(process.instance.exports.memory.buffer.slice(offset,offset+length)));return this._pushArrayBuffer(ar.buffer);}
popToMemory(offset){let process=this._processes[this._activePID];if(!process)
throw"No active process!";if(!this._bufferStackLengths.length)
throw"Buffer stack is empty!";let ar=new Uint8Array(process.instance.exports.memory.buffer);ar.set(new Uint8Array(this._popArrayBuffer()),offset);}
getApiFunctionIndex(){let name=this._popString();return Math.max(0,this._romApiNames.indexOf(name));}
callApiFunction(index,...params){return this[this._romApiNames[index]].apply(this,params);}
connectTo(){let url=(new URL(this._popString(),this._baseUrl)).toString();this._sysCall("connectTo",url);this._active=false;}
shutdown(){this._sysCall("removeMachine");this._active=false;}
getBaseUrl(){return this._pushString(this._baseUrl);}
setBaseUrl(){let relurl=this._popString();if(this._originUrl){let url=new URL(relurl,this._baseUrl);if(url.toString().substr(0,this._originUrl.length)!==this._originUrl)
throw"cross origin not allowed!";this._baseUrl=url.toString();}
else{let url=new URL(relurl);this._baseUrl=url.toString();this._originUrl=this._baseUrl.substr(0,this._baseUrl.indexOf(url.pathname)+1);}}
read(callback){callback=this._getCallback(callback);let id=this._asyncCalls++;let filename=(new URL(this._popString(),this._baseUrl)).toString();if(filename.substr(0,this._originUrl.length)!==this._originUrl)
throw"cross origin not allowed!";this._sysRequest("read",filename,{type:"binary"}).then((data)=>{this._pushArrayBuffer(data);callback(true,data.byteLength,id);}).catch((err)=>{console.error(err);callback(false,0,id);});return id;}
readImage(callback){callback=this._getCallback(callback);let id=this._asyncCalls++;let filename=(new URL(this._popString(),this._baseUrl)).toString();if(filename.substr(0,this._originUrl.length)!==this._originUrl)
throw"cross origin not allowed!";this._sysRequest("read",filename,{type:"image"}).then((data)=>{this._pushArrayBuffer(data.data.buffer);callback(true,data.width,data.height,id);}).catch((err)=>{console.error(err);callback(false,0,0,id);});return id;}
write(callback){callback=this._getCallback(callback);let id=this._asyncCalls++;let data=this._popArrayBuffer();let filename=(new URL(this._popString(),this._baseUrl)).toString();if(filename.substr(0,this._originUrl.length)!==this._originUrl)
throw"cross origin not allowed!";this._sysRequest("write",filename,data).then((success)=>{callback(success,id);}).catch((err)=>{console.error(err);callback(false,id);});return id;}
delete(callback){callback=this._getCallback(callback);let id=this._asyncCalls++;let filename=(new URL(this._popString(),this._baseUrl)).toString();if(filename.substr(0,this._originUrl.length)!==this._originUrl)
throw"cross origin not allowed!";this._sysRequest("delete",filename).then((success)=>{callback(success,id);}).catch((err)=>{console.error(err);callback(false,id);});return id;}
list(callback){callback=this._getCallback(callback);let id=this._asyncCalls++;let filename=(new URL(this._popString(),this._baseUrl)).toString();if(filename.substr(0,this._originUrl.length)!==this._originUrl)
throw"cross origin not allowed!";this._sysRequest("list",filename).then((list)=>{callback(true,this._pushString(list),id);}).catch((err)=>{console.error(err);callback(false,0,id);});return id;}
setStepInterval(milliseconds){this._stepInterval=milliseconds;}
loadProcess(){let wasm=this._popArrayBuffer();let env=this._processes.length?this._generateProcessApi():this._generateRomApi();let pid=this._processes.length;this._processes.push(null);WebAssembly.instantiate(wasm,{env,Math}).then((process)=>{this._activePID=pid;this._processes[pid]=process;if(process.instance.exports.init){try{process.instance.exports.init();this._active=true;}
catch(error){this._die(error);}}
this._nextStep=performance.now();if(this._activePID===0)
this._tick();this._activePID=0;}).catch((err)=>{this._processes[pid]=false;if(!pid){this._die(err);}});return pid;}
stepProcess(pid){let oldpid=this._activePID;this._activePID=pid;let process=this._processes[this._activePID];if(process)
process.instance.export.step(performance.now());this._activePID=oldpid;}
callbackProcess(pid,tableIndex,...a){let oldpid=this._activePID;this._activePID=pid;let process=this._processes[this._activePID];if(process)
process.instance.export.table.get(tableIndex)(...a);this._activePID=oldpid;}
killProcess(pid){this._processes[pid]=false;this._activePID=0;}
transferMemory(srcPid,srcOffset,length,destPid,destOffset){let srcProcess=this._processes[srcPid];let destProcess=this._processes[destPid];if(!srcProcess)
throw"No active process!";let ar=new Uint8Array(destProcess.instance.exports.memory.buffer);ar.set(new Uint8Array(srcProcess.instance.exports.memory.buffer.slice(srcOffset,srcOffset+length)),destOffset);}
focusInput(input){this._inputFocus=input;switch(input){case 1:this._sysCall("focusInput","text");break;case 2:this._sysCall("focusInput","mouse");break;case 3:this._sysCall("focusInput","game");break;}}
getInputText(){return this._pushString(this._textInputState.text);}
getInputPosition(){return this._textInputState.pos;}
getInputSelected(){return this._textInputState.len;}
getInputKey(){return this._textInputState.key;}
setInputType(type){this._textInputState.type=type;this._textInputState.text="";this._textInputState.pos=0;this._textInputState.len=0;this._sysCall("setTextInput",this._textInputState.text,this._textInputState.pos||0,this._textInputState.len||0,this._inputTypes[this._textInputState.type]);}
setInputText(){this._textInputState.text=this._popString();this._textInputState.pos=Math.min(this._textInputState.text.length,this._textInputState.pos);this._textInputState.len=Math.min(this._textInputState.text.length-this._textInputState.pos,this._textInputState.len);this._sysCall("setTextInput",this._textInputState.text,this._textInputState.pos||0,this._textInputState.len||0);}
setInputPosition(position=0,selection=0){this._textInputState.pos=position||0;this._textInputState.len=selection||0;this._textInputState.pos=Math.min(this._textInputState.text.length,this._textInputState.pos);this._textInputState.len=Math.min(this._textInputState.text.length-this._textInputState.pos,this._textInputState.len);this._sysCall("setTextInput",this._textInputState.text,this._textInputState.pos||0,this._textInputState.len||0);}
replaceInputText(fromIndex=0){let replace=this._popString();let search=this._popString();this._sysCall("replaceTextInput",search,replace,fromIndex);let text=this._textInputState.text;let i=text.indexOf(search,fromIndex);if(i>=0){text=text.substr(0,i)+replace+text.substr(i+search.length);this._textInputState.text=text;if(this._textInputState.pos>i){this._textInputState.pos+=replace.length-search.length;}}}
getMouseX(){return this._mouseInputState.x;}
getMouseY(){return this._mouseInputState.y;}
getMousePressed(){return this._mouseInputState.pressed;}
getGameAxisX(){return this._gameInputState.axis.x;}
getGameAxisY(){return this._gameInputState.axis.y;}
getGameButtonA(){return this._gameInputState.buttons.a;}
getGameButtonB(){return this._gameInputState.buttons.b;}
getGameButtonX(){return this._gameInputState.buttons.x;}
getGameButtonY(){return this._gameInputState.buttons.y;}
startTone(channel,frequency,volume=1,type=0){this._sysCall("startTone",channel,frequency,volume,this._toneTypes[type]);}
stopTone(channel){this._sysCall("stopTone",channel);}
wabt(){let wast=this._popString();let module=wabt.parseWat("idunno.wast",wast);return this._pushArrayBuffer(module.toBinary({}).buffer);}
_tick(){if(!this._active)
return;let t=performance.now();let process=this._processes[0];if(!process){return this._active=false;}
if(this._stepInterval<0){this._nextStep=t;}
else{if(t>this._nextStep){setTimeout(this._tick.bind(this),this._nextStep+this._stepInterval-t);}
else{setTimeout(this._tick.bind(this),this._nextStep-t);}}
try{let stepped=!(process.instance.exports.step);let tard=Infinity;if(process.instance.exports.step){while(t>=this._nextStep){this._textInputState.key=this._keyBuffer.shift()||0;process.instance.exports.step(this._nextStep);this._stepCount++;stepped=true;this._nextStep+=this._stepInterval;if(performance.now()-t>16){t=performance.now();if(t-this._nextStep>tard)
this._nextStep=t+1;tard=t-this._nextStep;}
if(this._stepInterval<0)
this._nextStep=t+1;}
if(this._stepSecond!==Math.floor(performance.now()/1000)){if(this._baseUrl.includes("?debug"))
console.log("Steps Per Second",this._stepCount);this._stepCount=0;this._stepSecond=Math.floor(performance.now()/1000);}}
else{this._textInputState.key=this._keyBuffer.shift()||0;this._nextStep+=this._stepInterval;}
if(this._transferBuffer&&stepped&&process.instance.exports.display){process.instance.exports.display(t);this._frameCount++;if(this._frameSecond!==Math.floor(performance.now()/1000)){if(this._baseUrl.includes("?debug"))
console.log("Frames Per Second",this._frameCount);this._frameCount=0;this._frameSecond=Math.floor(performance.now()/1000);}}}
catch(error){this._die(error);}}
_initCom(){self.addEventListener("message",this._onMessage.bind(this));}
_onMessage(e){switch(e.data.cmd){case"boot":this._pushString(e.data.url);this.setBaseUrl();this._originUrl=e.data.origin;this._pushArrayBuffer(e.data.wasm);this.loadProcess();break;case"suspend":this._active=false;this._mouseInputState.pressed=false;this._gameInputState={axis:{x:0,y:0},buttons:{a:false,b:false,x:false,y:false}};this._keyBuffer=[];break;case"resume":this._active=true;if(this._displayMode>=0){this.setDisplayMode(this._displayMode,this._displayWidth,this._displayHeight,this._visibleWidth,this._visibleHeight);let txt=this._textInputState;this._textInputState={};this.setInputType(txt.type);this._pushString(txt.text);this.setInputText();this.setInputPosition(txt.pos,txt.len);this.focusInput(this._inputFocus);this._keyBuffer.push(16);}
this._nextStep=performance.now();this._tick();break;case"break":if(this._processes[0]&&this._processes[0].instance.exports.break){this._processes[0].instance.exports.break();}
else{this.shutdown();}
break;case"imagedata":this._transferBuffer=e.data.buffer;let cb;while(cb=this._pendingCommits.pop())
cb(this._lastCommit);break;case"response":if(this._pendingRequests[e.data.reqId]){if(e.data.success){this._pendingRequests[e.data.reqId].resolve(e.data.value);}
else{this._pendingRequests[e.data.reqId].reject(e.data.value);}
this._pendingRequests[e.data.reqId]=undefined;}
if(this._stepInterval<0)
this._tick();break;case"textInput":if(!this._active)
break;this._textInputState=e.data.state;this._keyBuffer.push(e.data.state.key);if(this._stepInterval<0)
this._tick();break;case"mouseInput":if(!this._active)
break;this._mouseInputState=e.data.state;if(this._stepInterval<0)
this._tick();break;case"gameInput":if(!this._active)
break;this._gameInputState=e.data.state;if(this._stepInterval<0)
this._tick();break;}}
_postMessage(msg){;postMessage(msg);}
_sysCall(method,...args){this._postMessage({cmd:"call",method:method,arguments:args});}
_sysRequest(method,...args){let reqId=this._pendingRequests.indexOf(undefined);if(reqId<0)
reqId=this._pendingRequests.length;this._pendingRequests[reqId]=true;this._postMessage({cmd:"call",method:method,arguments:args,reqId:reqId});return new Promise((resolve,reject)=>{this._pendingRequests[reqId]={resolve:resolve,reject:reject};});}
_generateRomApi(){let api={};this._romApiNames=[""];for(let name of Object.getOwnPropertyNames(Machine.prototype)){let val=this[name];if(name.substr(0,1)!=="_"&&name!=="constructor"&&typeof val==="function"){api[name]=this._copyFunction(val.bind(this));this._romApiNames.push(name);}}
return api;}
_generateProcessApi(){let api={};let exports=this._processes[0].instance.exports;for(let name of Object.getOwnPropertyNames(exports)){let val=exports[name];if(name.substr(0,4)==="api."&&typeof val==="function"){api[name]=val;}}
return api;}
_copyClass(_class){return class{constructor(...a){return new _class(...a);}};}
_copyObject(_obj){let obj={};for(let name of Object.getOwnPropertyNames(_obj)){obj[name]=_obj[name];}
return obj;}
_copyFunction(_fn){return(...a)=>_fn(...a);}
_growBufferStack(addition){let old=this._bufferStack;this._bufferStack=new Uint8Array(this._bufferStack.byteLength+addition);this._bufferStack.set(old);}
_pushArrayBuffer(arbuf){let offset=this._bufferStackLengths.reduce((a=0,b=0)=>a+b,0);if(this._bufferStack.byteLength-offset<arbuf.byteLength){this._growBufferStack(arbuf.byteLength);}
this._bufferStack.set(new Uint8Array(arbuf),offset);this._bufferStackLengths.push(arbuf.byteLength);return arbuf.byteLength;}
_popArrayBuffer(){let len=this._bufferStackLengths.pop()||0;let offset=this._bufferStackLengths.reduce((a=0,b=0)=>a+b,0);return this._bufferStack.slice(offset,offset+len);}
_pushString(str){let enc=new TextEncoder();let buf=enc.encode(str).buffer;return this._pushArrayBuffer(buf);}
_popString(){let dec=new TextDecoder("utf-8");return dec.decode(this._popArrayBuffer());}
_die(err){console.trace(err);this._processes[0]=false;this.setDisplayMode(0,80,20);this._pushString("\n\nError!\n"+err);this.print();}
_getCallback(callback){if(typeof callback==="number"){let process=this._processes[this._activePID];if(!process)
throw"No active process!";callback=process.instance.exports.table.get(callback);}
return callback;}}
exports.default=Machine;},{"./wabt":11}],7:[function(require,module,exports){"use strict";Object.defineProperty(exports,"__esModule",{value:true});class MouseInput{constructor(sys){this.sys=sys;this.state={x:0,y:0,pressed:false};this.scale=1;this._listeners=[];this._element=document.body;}
set element(val){this._element.removeEventListener("pointermove",this._mouseMove.bind(this));this._element.removeEventListener("pointerdown",this._mouseDown.bind(this));this._element.removeEventListener("pointerup",this._mouseUp.bind(this));this._element=val;this._element.addEventListener("pointermove",this._mouseMove.bind(this));this._element.addEventListener("pointerdown",this._mouseDown.bind(this));this._element.addEventListener("pointerup",this._mouseUp.bind(this));}
focus(){}
blur(){this.state.pressed=false;this._sendState();}
addEventListener(fn){let i=this._listeners.indexOf(fn);if(i<0){this._listeners.push(fn);}}
removeEventListener(fn){let i=this._listeners.indexOf(fn);if(i>=0){this._listeners.splice(i,1);}}
_sendState(){let newState=JSON.stringify(this.state);if(this._lastState!==newState){this._lastState=newState;this._listeners.forEach((fn)=>{fn(this.state);});}}
_mouseMove(e){this.state.x=e.offsetX/this.scale*devicePixelRatio;this.state.y=e.offsetY/this.scale*devicePixelRatio;this._sendState();}
_mouseDown(e){this.sys.focusInput("mouse");this.state.x=e.offsetX/this.scale*devicePixelRatio;this.state.y=e.offsetY/this.scale*devicePixelRatio;this.state.pressed=true;this._sendState();}
_mouseUp(e){this.state.pressed=false;this._sendState();}}
exports.default=MouseInput;},{}],8:[function(require,module,exports){"use strict";Object.defineProperty(exports,"__esModule",{value:true});class TextInput{constructor(sys,_element){this.sys=sys;this._element=_element;this.state={type:"multiline",text:"",pos:0,len:0,key:0};this._listeners=[];_element.innerHTML='<textarea cols="80"></textarea><input/>';this._multiline=_element.querySelector("textarea");this._multiline.addEventListener("keydown",this._keyDown.bind(this));this._multiline.addEventListener("keyup",this._keyDown.bind(this));this._multiline.addEventListener("keydown",function(e){if(e.code==="Tab"){let start=this.selectionStart,end=this.selectionEnd,value=this.value;this.value=value.substr(0,start)+"\t"+value.substr(end);this.selectionStart=this.selectionEnd=start+1;e.preventDefault();}});this._singleline=_element.querySelector("input");this._singleline.addEventListener("keydown",this._keyDown.bind(this));this._singleline.addEventListener("keyup",this._keyDown.bind(this));this._singleline.addEventListener("keydown",function(e){if(e.code==="Tab"){e.preventDefault();}});this._input=this._multiline;}
focus(){this._input.focus();}
blur(){this._input.blur();}
setState(state){if(state.type){if(state.type==="multiline"){this._input=this._multiline;}
else{this._input=this._singleline;this._input.setAttribute("type",state.type);}
this.state.type=state.type;};this._input.value=state.text;this._input.selectionStart=state.pos;this._input.selectionEnd=state.pos+state.len;}
addEventListener(fn){let i=this._listeners.indexOf(fn);if(i<0){this._listeners.push(fn);}}
removeEventListener(fn){let i=this._listeners.indexOf(fn);if(i>=0){this._listeners.splice(i,1);}}
_sendState(){let newState=JSON.stringify(this.state);if(this._lastState!==newState){this._lastState=newState;this._listeners.forEach((fn)=>{fn(this.state);});}}
_keyDown(e){if(e&&e.altKey&&e.code==="KeyG")
this.sys.focusInput("game");requestAnimationFrame(()=>{let input=this._input;this.state.text=input.value;this.state.pos=input.selectionStart==null?input.value.length:input.selectionStart;this.state.len=(input.selectionEnd||this.state.pos)-this.state.pos;this.state.key=0;if(e&&e.type==="keydown")
this.state.key=e.keyCode;if(!this.state.text&&e&&e.type==="keydown"){switch(e.code){case"Backspace":this.state.text="\b \b";break;case"ArrowUp":this.state.text="\x1b[A";break;case"ArrowDown":this.state.text="\x1b[B";break;case"ArrowRight":this.state.text="\x1b[C";break;case"ArrowLeft":this.state.text="\x1b[D";break;}}
this._sendState();});}}
exports.default=TextInput;},{}],9:[function(require,module,exports){"use strict";var __awaiter=(this&&this.__awaiter)||function(thisArg,_arguments,P,generator){return new(P||(P=Promise))(function(resolve,reject){function fulfilled(value){try{step(generator.next(value));}catch(e){reject(e);}}
function rejected(value){try{step(generator["throw"](value));}catch(e){reject(e);}}
function step(result){result.done?resolve(result.value):new P(function(resolve){resolve(result.value);}).then(fulfilled,rejected);}
step((generator=generator.apply(thisArg,_arguments||[])).next());});};Object.defineProperty(exports,"__esModule",{value:true});const css_1=require("./css");const GameInput_1=require("./GameInput");const ChipSound_1=require("./ChipSound");const MouseInput_1=require("./MouseInput");const TextInput_1=require("./TextInput");const Breaker_1=require("./Breaker");let scriptSrc;let dirCache={};class WebSys{constructor(){this.inputPriority=["text","mouse","game"];this._container=document.querySelector("fantasy-terminal");this._displayMode="";this._displayWidth=-1;this._displayHeight=-1;this._visibleWidth=-1;this._visibleHeight=-1;this._displayCursorCol=-1;this._displayCursorRow=-1;this._displayTextSize=10;this._displayTextSizeDelta=0;this._displayTextEscape="";this._displayScale=8;let scripts=document.querySelectorAll("script");scriptSrc=scripts[scripts.length-1].src;this._initContainer();this.chipSound=new ChipSound_1.default();this.textInput=new TextInput_1.default(this,this._container.querySelector(".input .text"));this.mouseInput=new MouseInput_1.default(this);this.gameInput=new GameInput_1.default(this);this.breaker=new Breaker_1.default(this);}
setTitle(title){}
setDisplayMode(mode,width,height,visibleWidth=width,visibleHeight=height){if(this._displayMode===mode&&this._displayWidth===width&&this._displayHeight===height&&this._visibleWidth===visibleWidth&&this._visibleHeight===visibleHeight)
return;this._displayMode=mode;this._displayWidth=width;this._displayHeight=height;this._visibleWidth=visibleWidth;this._visibleHeight=visibleHeight;delete this._displayTextGrid;delete this._displayBitmap;delete this._displayCanvas;delete this._displayContext;switch(this._displayMode){case"none":break;case"text":this._initTextGrid(width,height);break;case"pixel":this._displayBitmap=new ImageData(width,height);this._initCanvas();break;default:this._displayMode="";this._visibleWidth=-1;this._visibleHeight=-1;throw`DisplayMode ${mode}not supported!`;}
return;}
drawBitmap(buffer){if(this._displayContext&&this._displayBitmap){let data=new Uint8ClampedArray(buffer);this._displayBitmap.data.set(data,0);this._displayContext.putImageData(this._displayBitmap,0,0);}}
print(str){if(!this._displayTextGrid)
return;for(let char of str){if(this._displayTextEscape){this._displayTextEscape+=char;if(char==="\x1b")
this._displayTextEscape="e";if(this._displayTextEscape.length>16)
this._displayTextEscape="";let match;if(match=this._displayTextEscape.match(/e\[([0-9]*)A/)){let count=Number.parseInt(match[1])||1;this._displayCursorRow=Math.max(this._displayCursorRow-count,0);this._displayTextEscape="";}
else if(match=this._displayTextEscape.match(/e\[([0-9]*)B/)){let count=Number.parseInt(match[1])||1;this._displayCursorRow=Math.min(this._displayCursorRow+count,this._displayHeight-1);this._displayTextEscape="";}
else if(match=this._displayTextEscape.match(/e\[([0-9]*)C/)){let count=Number.parseInt(match[1])||1;this._displayCursorCol=Math.min(this._displayCursorCol+count,this._displayWidth-1);this._displayTextEscape="";}
else if(match=this._displayTextEscape.match(/e\[([0-9]*)D/)){let count=Number.parseInt(match[1])||1;this._displayCursorCol=Math.max(this._displayCursorCol-count,0);this._displayTextEscape="";}
else if(match=this._displayTextEscape.match(/e\[([0-9]*);*([0-9]*)[Hf]/)){let row=Number.parseInt(match[1])||1;let col=Number.parseInt(match[2])||1;this._displayCursorRow=Math.min(Math.max(0,row-1),this._displayHeight-1);this._displayCursorCol=Math.min(Math.max(0,col-1),this._displayWidth-1);this._displayTextEscape="";}
else if(match=this._displayTextEscape.match(/e\[([0-9]*)J/)){let n=Number.parseInt(match[1])||0;switch(n){case 0:this._clearTextRect(this._displayCursorCol,this._displayCursorRow,this._displayWidth,1);this._clearTextRect(0,this._displayCursorRow+1,this._displayWidth,this._displayHeight);break;case 1:this._clearTextRect(0,this._displayCursorRow,this._displayCursorCol,1);this._clearTextRect(0,0,this._displayWidth,this._displayCursorRow);break;default:this._clearTextRect(0,0,this._displayWidth,this._displayHeight);this._displayCursorRow=this._displayCursorCol=0;}
this._displayTextEscape="";}
else if(match=this._displayTextEscape.match(/e\[([0-9]*)K/)){let n=Number.parseInt(match[1])||0;switch(n){case 0:this._clearTextRect(this._displayCursorCol,this._displayCursorRow,this._displayWidth,1);break;case 1:this._clearTextRect(0,this._displayCursorRow,this._displayCursorCol,1);break;default:this._clearTextRect(0,this._displayCursorRow,this._displayWidth,1);}
this._displayTextEscape="";}}
else{let selector=`div:nth-child(${this._displayCursorRow+1})\nspan:nth-child(${this._displayCursorCol+1})`;let cell=this._displayTextGrid.querySelector(selector);cell.classList.remove("current");if((char.codePointAt(0)||0)>=32){cell.textContent=char;}
this._displayCursorCol++;if(char==="\b"){this._displayCursorCol-=2;}
if(char==="\t"){this._displayCursorCol=Math.ceil(this._displayCursorCol/8)*8;}
if(char==="\n"){this._displayCursorCol=0;this._displayCursorRow++;}
if(char==="\x1b"){this._displayCursorCol--;this._displayTextEscape="e";}}
while(this._displayCursorCol<0){this._displayCursorCol+=this._displayWidth;this._displayCursorRow--;}
while(this._displayCursorCol>=this._displayWidth){this._displayCursorCol-=this._displayWidth;this._displayCursorRow++;}
while(this._displayCursorRow<0){this._displayCursorRow=0;}
while(this._displayCursorRow>=this._displayHeight){this._scrollText();}}
let selector=`div:nth-child(${this._displayCursorRow+1})\nspan:nth-child(${this._displayCursorCol+1})`;let cell=this._displayTextGrid.querySelector(selector);cell.classList.add("current");}
waitForVsync(){return __awaiter(this,void 0,void 0,function*(){return new Promise((resolve,reject)=>{requestAnimationFrame(resolve);});});}
createMachine(){return new WebMachineWorker();}
read(filename,options={}){return __awaiter(this,void 0,void 0,function*(){let res=yield fetch(filename);if(res.ok){this._dirCache(filename,true);}
else{this._dirCache(filename,false);throw"read error!";}
let buf=yield res.arrayBuffer();let dec=new TextDecoder("utf-8");let txt=dec.decode(buf);try{let parser=new DOMParser();let url=new URL(filename);let doc=parser.parseFromString(txt,"text/html");let links=doc.querySelectorAll("[href],[src]");for(let link of links){this._dirCache(""+new URL(link.getAttribute("href")||link.getAttribute("src")||".",url));}}
catch(error){}
switch(options.type){case"binary":return buf;case"text":return txt;case"image":return new Promise((resolve)=>{let blob=new Blob([buf]);let img=new Image();img.src=URL.createObjectURL(blob);img.addEventListener("load",()=>{let canvas=document.createElement("canvas");let g=canvas.getContext("2d");canvas.width=img.width;canvas.height=img.height;g.drawImage(img,0,0);resolve(g.getImageData(0,0,img.width,img.height));URL.revokeObjectURL(img.src);});});default:throw"Unknown type!";}});}
write(filename,data){return __awaiter(this,void 0,void 0,function*(){let res=yield fetch(filename,{method:"PUT",body:new Blob([data])});if(!res.ok)
throw"write error!";this._dirCache(filename,true);return res.ok;});}
delete(filename){return __awaiter(this,void 0,void 0,function*(){let res=yield fetch(filename,{method:"DELETE"});if(!res.ok)
throw"delete error!";this._dirCache(filename,false);return res.ok;});}
list(path){return __awaiter(this,void 0,void 0,function*(){if(path.substr(-1)==="/")
path=path.substr(0,path.length-1);yield this.read(path+"/",{type:"text"});let dir=this._dirCache(path);let list="";for(let name in dir){if(name&&name!=="."&&name!==".."){if(dir[name]){if(typeof dir[name]==="object"){list+=name+"/\n";}
else{list+=name+"\n";}}
else if(dir[name]==null){list+=name+"\n";}}}
return list;});}
startTone(){this.chipSound.startTone.apply(this.chipSound,arguments);}
stopTone(){this.chipSound.stopTone.apply(this.chipSound,arguments);}
focusInput(input){let i=this.inputPriority.indexOf(input);if(i>=0){this.inputPriority.splice(i,1);this.inputPriority.unshift(input);}
for(let i=0;i<this.inputPriority.length;i++){if(i){this[this.inputPriority[i]+"Input"].blur();}
else{this[this.inputPriority[i]+"Input"].focus();}}
return this.inputPriority;}
setTextInput(text,pos,len,type){this.textInput.setState({type:type,text:text,pos:pos,len:len});}
replaceTextInput(search,replace="",fromIndex=0){let text=this.textInput.state.text;let pos=this.textInput.state.pos;let len=this.textInput.state.len;let i=text.indexOf(search,fromIndex);if(i>=0){text=text.substr(0,i)+replace+text.substr(i+search.length);if(pos>i){pos+=replace.length-search.length;}
this.textInput.setState({text:text,pos:pos,len:len});}}
openWeb(url){location.assign(url);}
_initContainer(){let style=document.createElement("style");style.textContent=css_1.default;document.querySelector("head").insertBefore(style,document.querySelector("head *"));this._container.innerHTML='<div class="display"></div><div class="input"><div class="text"></div><div class="mouse"></div><div class="game"></div></div>';this._displayContainer=this._container.querySelector(".display");addEventListener("resize",()=>{this._resize();});}
_initCanvas(){if(!this._displayContainer)
throw"No display container!";if(!this._displayBitmap)
throw"No display bitmap!";this._displayContainer.innerHTML='<canvas></canvas>';this._displayCanvas=this._displayContainer.querySelector("canvas");this._displayCanvas.width=this._displayBitmap.width;this._displayCanvas.height=this._displayBitmap.height;this._displayContext=this._displayCanvas.getContext("2d");this.mouseInput.element=this._displayCanvas;this._resize();}
_initTextGrid(width,height){if(!this._displayContainer)
throw"No display container!";let html='<pre>';for(let row=0;row<height;row++){html+='<div>';for(let col=0;col<width;col++){html+='<span>&nbsp;</span>';}
html+='</div>';}
html+='</pre>';this._displayContainer.innerHTML=html;this._displayTextGrid=this._displayContainer.querySelector("pre");this._displayCursorCol=this._displayCursorRow=0;this.mouseInput.element=this._displayTextGrid;this._resize();}
_scrollText(){if(this._displayTextGrid){let row=this._displayTextGrid.querySelector("div");let parent=row.parentElement;parent.removeChild(row);let cols=row.querySelectorAll("span");for(let col of cols){col.textContent=" ";}
parent.appendChild(row);this._displayCursorRow--;}}
_clearTextRect(col,row,w,h){if(!this._displayTextGrid)
return;for(let down=0;down<h;down++){for(let right=0;right<w;right++){let selector=`div:nth-child(${row+down+1})\nspan:nth-child(${col+right+1})`;let cell=this._displayTextGrid.querySelector(selector);if(cell)
cell.textContent=" ";}}}
_resize(){switch(this._displayMode){case"text":this._displayTextSizeDelta=1;this._displayTextSize+=8;this._resizeTextGrid();break;case"pixel":this._resizeCanvas(false);break;}}
_resizeTextGrid(){if(!this._displayTextGrid)
return;while(this._displayTextSizeDelta){let terminalWidth=this._container.offsetWidth;let terminalHeight=this._container.offsetHeight;if(this._displayTextGrid.offsetWidth>terminalWidth||this._displayTextGrid.offsetHeight>terminalHeight){if(this._displayTextSize<=0){this._displayTextSizeDelta=0;}
else{this._displayTextSizeDelta=-1;}}
else if(this._displayTextSizeDelta<0){this._displayTextSizeDelta=0;}
this._displayTextSize+=this._displayTextSizeDelta;this._displayTextGrid.style.fontSize=this._displayTextSize+"px";}}
_resizeCanvas(checkHeight=true){if(!this._displayCanvas)
return;if(!checkHeight){;this._displayCanvas.style["imageRendering"]="-moz-crisp-edges";this._displayCanvas.style["imageRendering"]="pixelated";this._displayCanvas.style.display="none";this._displayScale=1;}
let terminalWidth=this._container.offsetWidth*devicePixelRatio;let terminalHeight=this._container.offsetHeight*devicePixelRatio;while(this._visibleWidth*this._displayScale<terminalWidth)
this._displayScale++;while(this._visibleWidth*this._displayScale>terminalWidth)
this._displayScale--;if(checkHeight)
while(this._visibleHeight*this._displayScale>terminalHeight)
this._displayScale--;if(this._displayScale<1){;this._displayCanvas.style["imageRendering"]="";this._displayScale=1;let divide=1;while(this._visibleWidth*this._displayScale>terminalWidth)
this._displayScale=(1/++divide);if(checkHeight)
while(this._visibleHeight*this._displayScale>terminalHeight)
this._displayScale=(1/++divide);}
this._displayCanvas.style.width=(this._displayCanvas.width*this._displayScale)/devicePixelRatio+"px";this._displayCanvas.style.height=(this._displayCanvas.height*this._displayScale)/devicePixelRatio+"px";this._displayCanvas.style.marginLeft=this._displayCanvas.style.marginRight=(this._visibleWidth-this._displayCanvas.width)/2*this._displayScale/devicePixelRatio+"px";this._displayCanvas.style.marginTop=this._displayCanvas.style.marginBottom=(this._visibleHeight-this._displayCanvas.height)/2*this._displayScale/devicePixelRatio+"px";this._displayCanvas.style.display="inline-block";if(!checkHeight)
requestAnimationFrame(this._resizeCanvas.bind(this));else
this.mouseInput.scale=this._displayScale;}
_dirCache(path,exists,cache=dirCache){while(path.substr(0,1)==="/")
path=path.substr(1);let parts=path.split("/");let name=parts.shift()||".";if(parts.length){if(typeof cache!=="object")
cache={};if(typeof cache[name]!=="object")
cache[name]={};return this._dirCache(parts.join("/"),exists,cache[name]);}
else{if(cache[name]==null)
cache[name]=null;if(typeof exists==="boolean")
cache[name]=exists;return cache[name];}}}
exports.default=WebSys;class WebMachineWorker{constructor(){this.worker=new Worker(scriptSrc);}
send(msg,transferables){this.worker.postMessage(msg,transferables);}
onMessage(listener){this.worker.addEventListener("message",(e)=>{return listener(e.data,this);});}
else{self.machine=new Machine_1.default();}},{"./_lib/CyberTerminal":4,"./_lib/Machine":6,"./_lib/WebSys":9}]},{},[12])