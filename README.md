# OpenComputer Lib

## LINKS

1. [ImmersiveRailroading](https://github.com/TeamOpenIndustry/ImmersiveRailroading/wiki/Augment-Detector)
	1. [Computer-APIs](https://github.com/TeamOpenIndustry/ImmersiveRailroading/wiki/Computer-APIs)
		1. [Augment-Detector](https://github.com/TeamOpenIndustry/ImmersiveRailroading/wiki/Augment-Detector)
		1. [Augment-Control](https://github.com/TeamOpenIndustry/ImmersiveRailroading/wiki/Augment-Control)

## HOW TO

> [!TIP]
> This is a template repo so i encourage you to change the **update.lua** file
> to something else, like in the [sc-train-automate](https://github.com/ApelSoftCorp/sc-train-automat)
> repo.

### Setup (Real PC)

1. First git clone the repo on your real computer
	```bash
	git clone https://github.com/Pixailz/OpenComputer
	```

1. Then copy paste the `<prefix>_update.template.lua` file to a new `<prefix>_update.lua`
	```bash
	cp <prefix>_update{.template,}.lua
	```

1. Now there's 2 options to fill up, the IP and the PORT the real PC will listen
on any HTTP request, on way to quickly open a webserver is by go in the repo
folder and then
	```bash
	python3 -m http.server PORT
	```

### Setup (OC PC)

1. Now that the Web server is up and running, you can simply type this command to
install the `<prefix>_update` script onto the OC PC

```OC
wget -f http://IP:PORT/<prefix>_update.lua /bin/<prefix>_update.lua
```
> [!NOTE]
> replace the IP and PORT variable with the one you setup

1. now every time you launch the update command, all your configured fill will
be downloaded into the OC PC from the real one

> here's the help of the script
```
Usage: <prefix>_update [--help|-h] [--update|-u] [-r|--reboot] [PART..PARTN]

    -h  --help      display this help message
    -u  --update    update this script
    -r  --reboot    reboot the computer at the end

    PART            (lib bin etc)
                    You can specify the part you wan't to update, for example
                    you can just update the lib part or the bin part or the 2.
                    If not provided all part is updated

    Note
                    After an update of the lib part a reboot is required, the
                    reboot flag is usefull in this case

Version: 0.0.1-alpha, by Pixailz
```
