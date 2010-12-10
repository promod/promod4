:: Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
:: Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>
::
:: This file is part of Call of Duty 4 Promod.
::
:: Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
:: Terms of license can be found in LICENSE.md document bundled with the project.

@echo off

SET work_directory=%~dp0
cd %work_directory%

xcopy maps ..\..\raw\maps\ /SY
xcopy promod ..\..\raw\promod\ /SY
xcopy shock ..\..\raw\shock\ /SY
xcopy sound ..\..\raw\sound\ /SY
xcopy soundaliases ..\..\raw\soundaliases\ /SY
xcopy ui_mp ..\..\raw\ui_mp\ /SY

copy mod.csv ..\..\zone_source /Y
copy promod.str ..\..\raw\english\localizedstrings /Y

cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod -verbose

cd ..\mods\promodlive210
copy ..\..\zone\english\mod.ff

pause
