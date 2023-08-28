@echo off

rem --------------------------------------------------------------------------------
rem Friday Night Funkin' Rewritten DDS Mass Conversion Script for Windows v1.1
rem 
rem Copyright (C) 2021  HTV04
rem 
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem 
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem 
rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <https://www.gnu.org/licenses/>.
rem --------------------------------------------------------------------------------

set texconv=%CD%\bin\texconv\texconv.exe

pushd love\images\png

if exist ..\dds rmdir ..\dds /q /s

echo Converting...
for /d %%d in (*) do (
	mkdir ..\dds\%%d
	
	for %%f in (%%d\*) do (
		rem is it a folder? if so, loop through it
		if exist %%f\* (
			for /d %%g in (%%f\*) do (
				%texconv% -f DXT5 -m 1 -nologo -o ..\dds\%%d\%%~ng -srgb -y %%g

				rename ..\dds\%%d\%%~ng\%%~ng.DDS %%~ng.dds
			)
		)
		%texconv% -f DXT5 -m 1 -nologo -o ..\dds\%%d -srgb -y %%f
		
		rename ..\dds\%%d\%%~nf.DDS %%~nf.dds
	)
)
for %%f in (*) do (
	%texconv% -f DXT5 -m 1 -nologo -o ..\dds -srgb -y %%f
	
	rename ..\dds\%%~nf.DDS %%~nf.dds
)

rem go throug the png folder and check if there are .xml files, if so, simply just copy them over
for %%f in (*) do (
	if exist %%~nf.xml (
		copy %%~nf.xml ..\dds\%%~nf.xml
	)
)

popd
