:: Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
:: Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>
::
:: This file is part of Call of Duty 4 Promod.
::
:: Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
:: Terms of license can be found in LICENSE.md document bundled with the project.

@echo off

SET mod_name=pml220
SET work_directory=%~dp0
cd %work_directory%

del ..\%mod_name%\*.iwd

7za a -r -mx=9 -mpass=15 -mfb=258 -mmt=on -mtc=off -tzip ..\%mod_name%\%mod_name%.iwd weapons images sound
7za a -r -mx=9 -mpass=15 -mfb=258 -mmt=on -mtc=off -tzip ..\%mod_name%\z_c_r.iwd promod_ruleset

compile_fastfile.bat
