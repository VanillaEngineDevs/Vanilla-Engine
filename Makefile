# --------------------------------------------------------------------------------
# Friday Night Funkin' Rewritten Makefile v1.3
#
# Copyright (C) 2021  HTV04
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# --------------------------------------------------------------------------------

main: lovefile win64 switch macos

all: lovefile desktop console

desktop: lovefile win64 macos

console: lovefile switch

lovefile:
	@rm -rf build/lovefile
	@mkdir -p build/lovefile

	@cd src/love; zip -r -9 ../../build/lovefile/funkin-vanilla-engine.love .

	@mkdir -p build/release
	@rm -f build/release/funkin-vanilla-engine-lovefile.zip
	@cd build/lovefile; zip -9 -r ../release/funkin-vanilla-engine-lovefile.zip .

win64: lovefile
	@rm -rf build/win64
	@mkdir -p build/win64

	@cp resources/win64_libs/* build/win64

	@cp resources/win64/love/OpenAL32.dll build/win64
	@cp resources/win64/love/SDL2.dll build/win64
	@cp resources/win64/love/license.txt build/win64
	@cp resources/win64/love/lua51.dll build/win64
	@cp resources/win64/love/mpg123.dll build/win64
	@cp resources/win64/love/love.dll build/win64
	@cp resources/win64/love/msvcp120.dll build/win64
	@cp resources/win64/love/msvcr120.dll build/win64

	@cat resources/win64/love/love.exe build/lovefile/funkin-vanilla-engine.love > build/win64/funkin-vanilla-engine.exe

	@mkdir -p build/release
	@rm -f build/release/funkin-vanilla-engine-win64.zip
	@cd build/win64; zip -9 -r ../release/funkin-vanilla-engine-win64.zip .

macos: lovefile
	@rm -rf build/macos
	@mkdir -p "build/macos/Friday Night Funkin' Vanilla Engine.app"

	@cp -r resources/macos/love.app/. "build/macos/Friday Night Funkin' Vanilla Engine.app"

	@cp build/lovefile/funkin-vanilla-engine.love "build/macos/Friday Night Funkin' Vanilla Engine.app/Contents/Resources"

	@mkdir -p build/release
	@rm -f build/release/funkin-vanilla-engine-macos.zip
	@cd build/macos; zip -9 -r ../release/funkin-vanilla-engine-macos.zip .

switch: lovefile
	@rm -rf build/switch
	@mkdir -p build/switch/switch/funkin-vanilla-engine

	@nacptool --create "Friday Night Funkin' Vanilla Engine" "VE Devs" "$(shell cat version.txt)" build/switch/funkin-vanilla-engine.nacp

	@mkdir build/switch/romfs
	@cp build/lovefile/funkin-vanilla-engine.love build/switch/romfs/game.love

	@elf2nro resources/switch/love.elf build/switch/switch/funkin-vanilla-engine/funkin-vanilla-engine.nro --icon=resources/switch/icon.jpg --nacp=build/switch/funkin-vanilla-engine.nacp --romfsdir=build/switch/romfs

	@rm -r build/switch/romfs
	@rm build/switch/funkin-vanilla-engine.nacp

	@mkdir -p build/release
	@rm -f build/release/funkin-vanilla-engine-switch.zip
	@cd build/switch; zip -9 -r ../release/funkin-vanilla-engine-switch.zip .

clean:
	@rm -rf build
