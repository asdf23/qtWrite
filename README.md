# qtWrite
Single stroke font generator

Placeholder for single stroke font generator.
Write text in your own handwriting using a plotter, or generate a woff2 font that mimicks your handwriting.

This code is in a alpha state. What you can do currently is to generate an SVG document containing words using your own handwriting. To do that it takes a two step process.

![image](https://github.com/asdf23/qtWrite/assets/4165735/9c530076-cba7-4c77-a5c6-903a12780701)


To come:
Generate a woff font with a collasped border. 
Streamline process to generate SVG document.

Possibly to come:
GUI to capture text to convert.
Export gcode.
Interact with plotter in real-time.

To do:
Clean up code
Figure out license(s)
Requests? (need help)
Load existing font, skip ahead to missing letters

To use:
	Compile:
		This has only been tested on Fedora. I'm not sure how/if other OS's will work (need help)
		
		Install Required libraries:
		dnf install libxkbcommon-devel qxkb make gcc qt6-qtdeclarative cmake @development-tools gcc-c++ qt6-qtbase qt6-qtbase-devel qt6-qtquick3d-devel qt6-qtquick3d qt6-qtsvg-devel qt6-qtsvg
		
		Optionally turn on debugging messages:
		export QT_LOGGING_RULES="*.debug=true; qt.*.debug=false"
		
		Compile and run:
		clear && cmake -S . -B build && pushd build && make && ./writeboard && popd
		
		In the lower screen draw the first letter, adjust the spacing and curvature, when it's ready click on the letter "a", this will save the data in the ./data directory and reset the tool for letter "b"
		The next button (back) will clear the drawing. Use this to clear the current letter.
		The next button (refresh) will generate a svg file. This file will be used to genreate the font and/or to draw your text.
		To draw text open the svg file. A separate script is included (./data/sentenceToUseDefs.js.txt). Open the savedGlyph.svg file in a browser, set the text in line one of the file then execute the script from the console. 
  		  This will place the letters on the page adjusting for spacing between the letters.
		In a future version the next button (save - missing) will generate a woff file.
		To generate gcode you could use a tool like juicy. I would integrate this but currently there is no GUI to capture the text.
		
Need help:
Not sure how to resolve dependanies and run on other OS's
Not familiar with QML, I want to open a sepate window, for unrelated GUI inputs

The application is pretty ugly, The following screen shows a preview of the text to be generated

![image](https://github.com/asdf23/qtWrite/assets/4165735/0a34775a-3fff-42be-9c08-fc2b86920a83)

Each letter is captured then edited for spacing / boarders
![image](https://github.com/asdf23/qtWrite/assets/4165735/2014b5cd-911c-4e3d-9e69-3a52e8ccc352)
