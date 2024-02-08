# OpenComputer Lib

## How To

### Setup update.template.lua

> this section need to be preserved and all other deleted when a repo is mirrored

This repo is a template from this [repo](https://github.com/Pixailz/OpenComputer),
and it's include an update.template.lua that need to be configured to easily
transfert file beetween host PC and OC PC

Please refer to it for more informations

### Setup (Real PC)

1. First git clone the repo on your real computer
	```bash
	git clone https://github.com/Pixailz/OpenComputer
	```

1. Then copy paste the `update.template.lua` file to a new `update.lua`
	```bash
	cp update{.template,}.lua
	```

1. There's 2 options to fill up, the IP and the PORT the real PC will listen
on any HTTP request

> [!NOTE]
> One way to quickly open a webserver is by go in the repo folder and then
> `python3 -u -m http.server PORT 2>&1 | tee -a log.txt`

### Setup (OC PC)

1. Now that the Web server is up and running, you can simply type this command to
install the `update` script onto the OC PC

```OC
wget -f http://IP:PORT/update.lua /bin/update.lua
```
> [!NOTE]
> replace the IP and PORT variable with the one you setup

> [!TIP]
> Every time you launch the update command, all your configured fill will
be downloaded into the OC PC from the real one

### CLI Help

```
Usage: update [--help|-h] [--update|-u] [-r|--reboot] [PART..PARTN]

    -h  --help      display this help message
    -u  --update    update this script
    -r  --reboot    reboot the computer at the end

    PART            (lib bin conf etc service)
                    You can specify the part you wan't to update, for example
                    you can just update the lib part or the bin part or the 2.
                    If not provided all part is updated

    Note
                    After an update of the lib part a reboot is required, the
                    reboot flag is usefull in this case

Version: 0.0.1-alpha, by Pixailz
```
