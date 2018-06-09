How does it work?
=================

To access the fantasy internet, you need a [fantasy terminal](./download.html).

You use the terminal to type in an internet or local address you wish to connect to. The terminal will then look for a boot program called `boot.wasm`, near the root of the server.

Once the boot program is loaded, it will basically act as your gateway to the server. It will setup your user interface and define how the server is accessed and how its programs are run. It is basically the servers operating system.

If you are interested in how these boot programs are coded, take a look at the [source code for this server](https://github.com/FantasyInternet/FantasyInternet.github.io/blob/master/src/boot.wast).
