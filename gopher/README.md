# Gopher for X16

** THIS IS VERY EARLY / EXPERIMENTAL BUT HAS SOME FUNCTIONALITY **

This gopher client requires a Calypso card install in your X16 for networking.
I hope to test it with other networking solutions as well when they come
available.

Some keys:

 - stop, escape - escape gopher (this will have a confirmation eventually)
 - h, b, left-arrow = back
 - l, space, enter, right-arrow = follow link
 - j, down-arrow = move selection down
 - k, up-arrow = move selection up
 - r = reload current location
 - debug options
   - d = dump downloaded buffer to screen
   - D = dumb buffer in hex
   - s = show current stack index for "back" functionality

Currently only menus (gopher type "directory") and text file links are opened.
Text files are downloaded into the buffer and displayed via a horribly simple pager.

# Requirements
You'll need:
 - Commander X16 hardware of course. (until the emulator supports networking)
 - The most excellent Calypso board installed.
 - The custom rom and driver for the Calypso installed and configured.
 - `NET.BIN` driver which the Calypso should serve up automatically if you run `LOAD"NET.BIN"`
 - Patience. :)  It works, but doesn't do a whole lot yet.

# Usage

When you run `gopher` it will prompt you for a site name.  A good example is
`gopher.quux.org` as it doesn't have overly large menus.  Currently there is no
support for scrolling through large menus and they will overflow.

NOTE: MOST SITES AREN'T WORKING YET. Most links don't work, etc.  This is just
a beginning / proof of concept and needs plenty of work to get it to normal
usability.  Nevertheless it does work a bit and it is just fun to have an "retro"
8-bit computer that is accessing things on the Internet.

Some known not to work sites:
 - gopher.floodgap.com (around 100 lines of menu)
 - sdf.org (some smaller menus, but some massive)
 - gopherpedia.com (larger menu and text files)

 ## Running your own gopher server

 You can easily run your own gopher server using [PyGopherd](https://github.com/michael-lazar/pygopherd)

# Building

Gopher is written in Prog8.  Currently it is EXTREMELY ROUGH, but does work for me.
You should be able to type `make` but on Windows you might need to manually compile.
Something like `java -jar prog8c-11.2-all.jar src/main.p8` should work.

I plan on improving the build process eventually but this is very early stage here.

## Future
Obviously many more types need to be supposed and allow downloading and saving.
Images, binary files, video, audio are all possibilities for downloading.
Viewing those inside gopher is less likely, but eventually there could be support
for some basic images. 

