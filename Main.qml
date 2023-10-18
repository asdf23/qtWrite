import QtQuick
import QtQuick.Window
import QtQuick.Controls
//import QtQuick.Controls.Styles 1.4
import FileOperations 1.0
import "scripts/script.js" as MyScript
import "scripts/simplifyScript.js" as SimplifyScript
import "scripts/glypabet.js" as Glypabet
import "scripts/sentenceToUseDefs.js" as SentenceBuilder
import "scripts/reversePath.js" as PathReverser

Window {
	id: window
	width: 800
	height: 1000
	visible: true
	title: qsTr("Writeboard")
	flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
	color: "#444444"

	property var svgDefs: ""

	FileOperations {
		id: cppCallBackTest
	}

	FontLoader {
		id: icons
		source: Qt.resolvedUrl("fonts/icons.woff2")
	}
	// Window Drag area
	MouseArea {
		id: mouseDragArea
		height: 50
		width: parent.width
		property point pos: Qt.point(0, 0)

		onPressed: (mouse) => { pos = Qt.point(mouse.x, mouse.y) }
		onPositionChanged: (mouse) => {
			window.x += mouse.x - pos.x
			window.y += mouse.y - pos.y
		}
	}
	Button {
		id: closeButton
		anchors.left: parent.right
		anchors.leftMargin: -50
		width: 50
		height: 50
		flat: true
		onClicked: { window.close() }

		Text {
			renderType: Text.NativeRendering
			font.family: icons.font.family
			font.pointSize: 24
			color: closeButton.down ? "red" : (closeButton.hovered ? "gray" : "white")
			text: String.fromCodePoint(0xe5cd)
			anchors.centerIn: parent
		}
	}
	Button {
		id: nextLetterButton
		anchors.top: closeButton.bottom
		anchors.left: parent.right
		anchors.leftMargin: -50
		width: 50
		height: 50
		flat: true

		Text {
			id: textCurrentLetter
			renderType: Text.NativeRendering
			font.family: icons.font.family
			font.pointSize: 24
			color: nextLetterButton.down ? "red" : (nextLetterButton.hovered ? "gray" : "white")
			text: "a"
			anchors.centerIn: parent
		}
		onClicked: {
			console.log("letter click detected");
			var glyphID = Glypabet.glyphs.find(f=> f.char == (MyScript.currentLetterIndex == -1 ? " " : (MyScript.letterArray[MyScript.currentLetterIndex])) ).id;
			console.log("-------- SAVED -----------");
			qml_saveLetter(glyphID);
			console.log("-------- /SAVED -----------");
			console.log("-------- NEXT LETTER -----------");
			var letterFound = qml_setNextLetter(false);
			console.log("-------- /NEXT LETTER -----------");
			if(letterFound) {
				console.log("loading old letter");
				qml_reDrawTextDisplay();
			} else {
				image1.source = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><path fill="orange" stroke="royalblue" d="L 150 50 L 100 150 z" /></svg>`
			}
			mycanvas.qml_clear();
		}
		function qml_saveLetter(glyphID) {
			console.log("saving letter");
			var metaData = MyScript.getBottomLineMetaData(rectCanvas.strokes, sliderLeftPadding.value, sliderRightPadding.value, sliderYOffset.value);
			console.log("saving:");
			console.log("metaData", JSON.stringify(metaData));
			console.log("sliderLeftPadding.value", sliderLeftPadding.value);
			console.log("sliderRightPadding.value", sliderRightPadding.value);
			console.log("sliderYOffset.value", sliderYOffset.value);
			var saveObj = JSON.stringify({
												 id: glyphID
												,dPath: MyScript.strokeToDPath(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value)
												,leftMargin: sliderLeftPadding.value
												,rightMargin: sliderRightPadding.value
												,anchorPoint: {
													 y: sliderYOffset.value
													,x: Math.min(0,sliderLeftPadding.value)
													,width: metaData.width
												}
												,sketch: rectCanvas.strokes
												,curve: sliderCurvature.value 
												,tolerance: sliderDistance.value
											});
			cppCallBackTest.saveDataToFile(glyphID,saveObj);
			
			console.log("saved letter");
		}
		function qml_setNextLetter(doInit) {
			var retVal = false;

			if(doInit) {
				//MyScript.currentLetterIndex = -1;
				MyScript.setCurrentLetterIndex(-1);
				console.log("currently ","default character and space");
			} else {
				console.log("currently " + MyScript.letterArray[MyScript.currentLetterIndex]);
			}				
			//return letterArray[MyScript.currentLetterIndex];
			if(!doInit) {
				MyScript.setCurrentLetterIndex(MyScript.currentLetterIndex+1);
				if( MyScript.currentLetterIndex >= MyScript.letterArray.length ) {
					//MyScript.currentLetterIndex = 0;
					MyScript.setCurrentLetterIndex(0);
				}
				console.log("to " + MyScript.letterArray[MyScript.currentLetterIndex]);
				textCurrentLetter.text = MyScript.letterArray[MyScript.currentLetterIndex];
			} else {
				textCurrentLetter.text = "_!";
			}
			

			var defMeta = qml_loadLetter(MyScript.currentLetterIndex);
			if(defMeta != null) {
				rectCanvas.strokes = defMeta.sketch;
				//console.log("set rectCanvas.strokes to" , JSON.stringify(rectCanvas.strokes));
				//console.log("rectCanvas.strokes.length" , rectCanvas.strokes.length);
				rectCanvas.currentStrokePoints = [];
				sliderLeftPadding.value = defMeta.leftMargin;
				sliderRightPadding.value = defMeta.rightMargin;
				sliderYOffset.value = defMeta.anchorPoint.y;
				sliderCurvature.value = defMeta.curve;
				sliderDistance.value = defMeta.tolerance;
				retVal = true;
			} else {
				rectCanvas.strokes = [];
				rectCanvas.currentStrokePoints = [];
				sliderLeftPadding.value = 0;
				sliderRightPadding.value = 0;
				sliderYOffset.value = 0;
				retVal = false;
			}
			return retVal;
		}
	}
	Button {
		id: backspaceButton
		anchors.top: nextLetterButton.bottom
		anchors.left: parent.right
		anchors.leftMargin: -50
		width: 50
		height: 50
		flat: true
		onClicked: { 
			console.log("clear");
			rectCanvas.strokes = [];
			rectCanvas.currentStrokePoints = [];
			//sliderDistance.to = 1;
			image1.source = `data:image/svg+xml;utf8,
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200">
<path fill="orange" stroke="royalblue" d="L 150 50 L 100 150 z" />
</svg>`
			mycanvas.qml_clear();
		}

		Text {
			renderType: Text.NativeRendering
			font.family: icons.font.family
			font.pointSize: 24
			color: backspaceButton.down ? "red" : (backspaceButton.hovered ? "gray" : "white")
			text: String.fromCodePoint(0xe14a)
			anchors.centerIn: parent
		}
	}
	Button {
		id: refreshButton
		anchors.top: backspaceButton.bottom
		anchors.left: parent.right
		anchors.leftMargin: -50
		width: 50
		height: 50
		flat: true
		onClicked: {
			console.log("refresh");
			var defMetas = qml_loadLetters(MyScript.currentLetterIndex);
			//console.log("defMetas", JSON.stringify(defMetas))
			var svgDefsString = MyScript.defMetaArrayToSVG(defMetas);
			// console.log("-----");
			// console.log("svgDefsString", JSON.stringify(svgDefsString));
			// console.log("-----");
			window.svgDefs = svgDefsString;
			//console.log("defs set", window.svgDefs);
			var sampleTextLine1 = SentenceBuilder.buildSentence("The quick brown fox jumped over the lazy dog.", false, defMetas, 100);
			var sampleTextLine2 = SentenceBuilder.buildSentence("0123456789!@#$%^&*()-=_+", false, defMetas, 200);
			var sampleTextLine3 = SentenceBuilder.buildSentence("Frog Zebra Tattoo", false, defMetas, 300);
			var sampleTextLine4 = SentenceBuilder.buildSentence("ABCDEF", false, defMetas, 400);
			var svgStrokes = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 200"><defs>${window.svgDefs}</defs><g transform="scale(0.2)">${sampleTextLine1}${sampleTextLine2}${sampleTextLine3}${sampleTextLine4}</g></svg>`;
			image1.source = `data:image/svg+xml;utf8,${svgStrokes}`;
			cppCallBackTest.saveSVG(svgStrokes);
		}

		Text {
			renderType: Text.NativeRendering
			font.family: icons.font.family
			font.pointSize: 28
			color: refreshButton.down ? "red" : (refreshButton.hovered ? "gray" : "white")
			text: String.fromCodePoint(0x27f3)
			anchors.centerIn: parent
		}
	}
	Button {
		property var isEnabled: false

		id: saveAsFontButton
		anchors.top: refreshButton.bottom
		anchors.left: parent.right
		anchors.leftMargin: -50
		width: 50
		height: 50
		flat: true
		onClicked: {
			if(saveAsFontButton.isEnabled) {
				popup.open()
			}
		}

		Text {
			renderType: Text.NativeRendering
			font.family: icons.font.family
			font.pointSize: 28
			color: saveAsFontButton.isEnabled ?(saveAsFontButton.down ? "red" : (saveAsFontButton.hovered ? "gray" : "white")) : "darkgreen"
			text: String.fromCodePoint(0x1F4BE)
			anchors.centerIn: parent
		}
	}
	Rectangle {
		id: rectFont
		width: parent.left - 58
		height: parent.height - 400
		anchors.left: parent.left
		anchors.leftMargin: 8
		anchors.top: mouseDragArea.bottom //parent.top //can't set this to 50 or + 50 ??
		anchors.topMargin: 8
		anchors.right: closeButton.left
		anchors.rightMargin: 8
		color: "green" //"#535353"
		
		Image {
			id: image1
			width: parent.width
			height: parent.height
			anchors.fill: parent
			source:
`data:image/svg+xml;utf8,
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200">
<path fill="orange" stroke="royalblue" d="L 150 50 L 100 150 z" />
</svg>`
		}
	}
	Rectangle {
		id: rectSliders
		height: 200
		width: parent.width
		anchors.top: rectFont.bottom
		color: "blue" //#535353"

        Rectangle {
            id: textForSliderDistance
            height: parent.height / 4
            width: parent.width/10
            anchors.top: parent.top
            color: "pink"
            Text {
                renderType: Text.NativeRendering
                font.family: icons.font.family
                font.pointSize: 24
                color: "black"
                text: "D"
                anchors.centerIn: parent
            }
        }
        Rectangle {
            id: textForSliderCurvature
            height: parent.height / 4
            width: parent.width/10
            anchors.top: sliderDistance.bottom
            color: "gray"
            Text {
                renderType: Text.NativeRendering
                font.family: icons.font.family
                font.pointSize: 24
                color: "black"
                text: "C"
                anchors.centerIn: parent
            }
        }
        Rectangle {
            id: textForSliderLeftPadding
            height: parent.height / 4
            width: parent.width/10
            anchors.top: sliderCurvature.bottom
            color: "darkblue"
            Text {
                renderType: Text.NativeRendering
                font.family: icons.font.family
                font.pointSize: 24
                color: "black"
                text: "L"
                anchors.centerIn: parent
            }
        }
        Rectangle {
            id: textForSliderRightPadding
            height: parent.height / 4
            width: parent.width/10
            anchors.top: sliderLeftPadding.bottom
            color: "darkgreen"
            Text {
                renderType: Text.NativeRendering
                font.family: icons.font.family
                font.pointSize: 24
                color: "black"
                text: "R"
                anchors.centerIn: parent
            }
        }
        Rectangle {
            id: textForSliderYOffset
            height: parent.height / 4
            width: parent.width/10
            anchors.top: parent.top
            x: (parent.width / 10) * 9
            color: "black"
            Text {
                renderType: Text.NativeRendering
                font.family: icons.font.family
                font.pointSize: 24
                color: "white"
                text: "H"
                anchors.centerIn: parent
            }
        }
        Slider {
            id: sliderDistance
            from: 0.0
            value: 0.0
            to: 20.0
            stepSize: 0.01
            height: parent.height / 4
            width: parent.width - (parent.width/5)
            anchors.top: parent.top
            x: (parent.width/10)
            onMoved: () => {
            	console.log("sliderDistance", sliderDistance.value);
            	qml_reDrawTextDisplay();
            }
        }
        Slider {
            id: sliderCurvature
            from: 0.001
            value: 0.001
            to: 3.0
            stepSize: 0.0001
            height: parent.height / 4
            width: parent.width - (parent.width/5)
            anchors.top: sliderDistance.bottom
            x: (parent.width/10)
            onMoved: () => {
            	console.log("sliderCurvature", sliderCurvature.value);
            	qml_reDrawTextDisplay();
            }
        }
        Slider {
            id: sliderLeftPadding
            from: -50
            value: 0
            to: 200
            stepSize: 1
            height: parent.height / 4
            width: parent.width - (parent.width/5)
            anchors.top: sliderCurvature.bottom
            x: (parent.width/10)
            onMoved: () => {
            	console.log("sliderLeftPadding", sliderLeftPadding.value);
            	rectCanvas.strokes = MyScript.resetStrokesLeftMinXTo(rectCanvas.strokes, sliderLeftPadding.value);
				mycanvas.requestPaint();
				mycanvas.qml_clear();
				mycanvas.qml_resetDrawing();
				qml_reDrawTextDisplay();
            }
        }
        Slider {
            id: sliderRightPadding
            from: -100
            value: 0
            to: 100
            stepSize: 1
            height: parent.height / 4
            width: parent.width - (parent.width/5)
            anchors.top: sliderLeftPadding.bottom
            x: (parent.width/10)
            onMoved: () => {
            	console.log("sliderRightPadding", sliderRightPadding.value);
            	//cppCallBackTest.printMessage("FROM QML to CPP");
            	//cppCallBackTest.saveDataToFile(JSON.stringify({"test":"successful"}));
            	//console.log(cppCallBackTest.loadDataFromFile() + "---");
            	//console.log("sliderRightPadding.value", sliderRightPadding.value);
				mycanvas.requestPaint();
				mycanvas.qml_clear();
				mycanvas.qml_resetDrawing();
            	qml_reDrawTextDisplay();
            }
        }
        Slider {
            id: sliderYOffset
            from: mycanvas.height
            value: 0
            to: 0
            stepSize: 1
            height: parent.height / 4 * 3
            width: parent.width/10
            //anchors.top: parent.top
            orientation: Qt.Vertical
            y: parent.height / 4
            x: (parent.width/10)*9
            onMoved: () => {
            	console.log("sliderYOffset.value", sliderYOffset.value);
            	mycanvas.qml_clear();
            	mycanvas.qml_resetDrawing();
            	qml_reDrawTextDisplay();
            }
        }
	}
	// Canvas
	Rectangle {
		property var currentStrokePoints: []
		property var strokes: []

		id: rectCanvas
		width: parent.width
		height: 200
		anchors.top: rectSliders.bottom
		anchors.bottom: parent.bottom
		
		color: "green" //"#535353"

		Canvas {
			id: mycanvas
			anchors.fill: parent

			property point lastPos: Qt.point(0, 0)
			property point pos: Qt.point(0, 0)
			property bool draw: true

			MouseArea {
				anchors.fill: parent
				onPressed: (mouse) => {
					mycanvas.draw = true
					mycanvas.lastPos = Qt.point(mouse.x, mouse.y)
					mycanvas.pos = Qt.point(mouse.x, mouse.y)
					rectCanvas.currentStrokePoints.push({x: mouse.x, y: mouse.y})
					mycanvas.requestPaint()
				}
				onReleased: {
					mycanvas.draw = false
					rectCanvas.currentStrokePoints = MyScript.removeDuplicatesFromPointArray(rectCanvas.currentStrokePoints);
					rectCanvas.strokes.push(rectCanvas.currentStrokePoints);
					rectCanvas.currentStrokePoints = [];
					var pointDistances = MyScript.getPointDistancesFromStrokes(rectCanvas.strokes);
					console.log("pointDistances= " + JSON.stringify(pointDistances) );
					//sliderDistance.to = pointDistances.length;
					//console.log("sliderDistance.to = pointDistances.length (" + pointDistances.length + ");");
					sliderLeftPadding.value = MyScript.getMinXOfStrokes(rectCanvas.strokes);
					sliderRightPadding.value = Math.abs(sliderLeftPadding.value/2);
					if(sliderYOffset.value == 0) {
						sliderYOffset.value = MyScript.getMaxYOfStrokes(rectCanvas.strokes);
						console.log("Reset sliderYOffset.value", sliderYOffset.value)
					} else {
						console.log("Did not reset sliderYOffset.value", sliderYOffset.value)
					}
					mycanvas.qml_resetDrawing();
					mycanvas.requestPaint();
					qml_reDrawTextDisplay();
				}
				onPositionChanged: (mouse) => {
					mycanvas.pos = Qt.point(mouse.x, mouse.y)
					rectCanvas.currentStrokePoints.push({x: mouse.x, y: mouse.y})
					mycanvas.requestPaint()
				}
			}
			onPaint: {
				if (mycanvas.draw && mycanvas.pos != mycanvas.lastPos) {
					var ctx = getContext("2d")
					ctx.lineWidth = 5
					ctx.strokeStyle = "#b3b3b3"
					ctx.lineCap = "round"
					ctx.lineJoin = "round"
					ctx.beginPath()
					ctx.moveTo(mycanvas.lastPos.x, mycanvas.lastPos.y)
					ctx.lineTo(mycanvas.pos.x, mycanvas.pos.y)
					mycanvas.lastPos = mycanvas.pos
					ctx.stroke()

                    ctx.lineWidth = 2;
                    ctx.strokeStyle = "red";
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    ctx.beginPath();
                    ctx.moveTo(0, sliderYOffset.value);
                    ctx.lineTo(mycanvas.parent.width, sliderYOffset.value);
                    ctx.stroke();
				}
			}
			function qml_resetDrawing() {
				var ctx = getContext("2d");
                ctx.lineWidth = 2;
                ctx.strokeStyle = "pink";
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

				for(var i=0; i<rectCanvas.strokes.length; i++) {
					for(var j=0; j<rectCanvas.strokes[i].length - 1; j++) {
						
	                    ctx.beginPath();
	                    ctx.moveTo(rectCanvas.strokes[i][j].x, rectCanvas.strokes[i][j].y);
	                    ctx.lineTo(rectCanvas.strokes[i][j+1].x, rectCanvas.strokes[i][j+1].y);
	                    ctx.stroke();
					}
				}

                ctx.lineWidth = 2;
                ctx.strokeStyle = "red";
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.beginPath();
                ctx.moveTo(0, sliderYOffset.value);
                ctx.lineTo(mycanvas.parent.width, sliderYOffset.value);
                ctx.stroke();

                var offsetLines = MyScript.getOffsetForStrokeToCanvasLines(rectCanvas.strokes, sliderRightPadding.value);
                //console.log("offsetLines=" + JSON.stringify(offsetLines));
                ctx.lineWidth = 2;
                ctx.strokeStyle = "blue";
                for(var i=0; i<offsetLines.length; i++) {
                	//console.log("line:", offsetLines[i].x1, offsetLines[i].y1, " => ", offsetLines[i].x2, offsetLines[i].y2);
	                ctx.beginPath();
	                ctx.moveTo(offsetLines[i].x1, offsetLines[i].y1);
	                ctx.lineTo(offsetLines[i].x2, offsetLines[i].y2);
	                ctx.stroke();
                }
			}
			function qml_clear() {
				var ctx = getContext("2d");
				ctx.reset();
				rectCanvas.currentStrokePoints = [];
				mycanvas.requestPaint();
			}
		}
	}
    Popup {
        id: popup

        parent: Overlay.overlay

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: (parent.width * 0.9)
        height: (parent.height * 0.9)

        Rectangle {
        	id: rectPopupLine1
			anchors.left: popup.left
			anchors.right: popup.right
			anchors.top: popup.top
			anchors.rightMargin: 2
			anchors.leftMargin: 2

			width: (popup.width * 0.95)
			height: 40
			color: "pink"

	        TextField {
	        	id: textFontFileName
				anchors.left: rectPopupLine1.left
				anchors.right: rectPopupLine1.right
				anchors.top: rectPopupLine1.top
				anchors.bottom: rectPopupLine1.bottom
				anchors.leftMargin: 2
				anchors.rightMargin: 2
				anchors.topMargin: 2
				anchors.bottomMargin: 2

		        placeholderText: qsTr("File name")
			}
        }

        Rectangle {
        	id: rectPopupLine2
			anchors.left: popup.left
			anchors.right: popup.right
			anchors.top: rectPopupLine1.bottom
			height: 40
			width: (popup.width * 0.95)
			color: "purple"
			
	        TextField {
	        	id: textFontFamily
				anchors.left: rectPopupLine2.left
				anchors.right: rectPopupLine2.right
				anchors.top: rectPopupLine2.top
				anchors.bottom: rectPopupLine2.bottom
				anchors.leftMargin: 2
				anchors.rightMargin: 2
				anchors.topMargin: 2
				anchors.bottomMargin: 2

		        placeholderText: qsTr("Font Family")
			}
		}

        Rectangle {
        	id: rectPopupLine3
			anchors.left: popup.left
			anchors.right: popup.right
			anchors.top: rectPopupLine2.bottom
			height: (popup.height / 4) - 80
			width: (popup.width * 0.95)
			
			
			TextArea {
				id: textFontDesc
				anchors.left: rectPopupLine3.left
				anchors.right: rectPopupLine3.right
				anchors.top: rectPopupLine3.top
				anchors.bottom: rectPopupLine3.bottom
				anchors.leftMargin: 2
				anchors.rightMargin: 2
				anchors.topMargin: 8
				anchors.bottomMargin: 2
			    placeholderText: qsTr("Enter description")
			    text: "Enter a descripiton here"
			}
		}
        Rectangle {
        	id: rectPopupLine4
			anchors.left: popup.left
			anchors.right: popup.right
			anchors.top: rectPopupLine3.bottom
			anchors.topMargin: 20
			height: (popup.height / 5) - 80
			width: (popup.width * 0.95)
			color: "#eee"

			Button {
				id: saveTTF
				anchors.left: rectPopupLine4.left
				anchors.top: rectPopupLine4.top
				anchors.leftMargin: 4
				anchors.rightMargin: 4
				width: (popup.width * 0.95)
				height: 40
				flat: true
				onClicked: { 
					var fontMetaData = textFontDesc.text;
					var fontNameIdentifier = textFontFamily.text.replace(/ /g,"_");
					var fontFamily = textFontFamily.text;
					var fontFileName = textFontFileName.text;
					if(!fontFileName.endsWith(".svg")) {
						fontFileName = fontFileName + ".svg";
					}
					var defMetas = qml_loadLetters(MyScript.currentLetterIndex);
					var svgGlyphsString = MyScript.defMetaArrayToSVGGlyphFormat(defMetas, PathReverser.closePath);
					var glyphMissing = defMetas.find(f=> f.id == "glyph_space");
					var svgGlyphs = `<?xml version="1.0" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" ><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">` + 
									`<metadata>${fontMetaData}</metadata><defs>` +
									`<font id="${fontNameIdentifier}" horiz-adv-x="${glyphMissing.leftMargin+glyphMissing.rightMargin+glyphMissing.anchorPoint.width}">` +
									`<font-face font-family="${fontFamily}" font-weight="500" font-stretch="normal" units-per-em="1000" panose-1="2 0 6 3 0 0 0 0 0 0" ascent="685" descent="-315" x-height="360.997" cap-height="529" bbox="-116.001 -320 471 740" underline-thickness="50" underline-position="-100" stemh="35" stemv="41" unicode-range="U+0020-E02B" />`
									+ svgGlyphsString + "</font></defs></svg>";

					cppCallBackTest.saveGlyphs(fontFileName, svgGlyphs);
				}

				Text {
					renderType: Text.NativeRendering
					font.family: icons.font.family
					font.pointSize: 24
					color: saveTTF.down ? "red" : (saveTTF.hovered ? "gray" : "white")
					text: "Generate TTF"
					anchors.centerIn: parent
				}
			}
		}

    }
	function qml_reDrawTextDisplay() {
		//console.log("qml_reDrawTextDisplay()");
		//console.log("sliderDistance.value=", sliderDistance.value);
		//console.log("sliderCurvature.value=", sliderCurvature.value);
		//console.log("sliderLeftPadding.value=", sliderLeftPadding.value);
		//console.log("sliderRightPadding.value=", sliderRightPadding.value);
		//console.log("sliderYOffset.value=", sliderYOffset.value);
		
		//var pointDistances = MyScript.getPointDistancesFromStrokes(rectCanvas.strokes);
		//var precision = pointDistances[sliderDistance.value];
		//var lowerResolutionStrokes = MyScript.reduceStrokesLessThanDistance(rectCanvas.strokes, precision);
		//var svgLetterPathD = MyScript.convertPointsToCurve3(rectCanvas.strokes, sliderCurvature.value, sliderRightPadding.value);

		//console.log("rectCanvas.strokes=", rectCanvas.strokes);
		//var lowerResolutionStrokes = MyScript.reduceStrokesLessThanDistance2(rectCanvas.strokes, sliderDistance.value, sliderCurvature.value);
		//console.log("lowerResolutionStrokes=", lowerResolutionStrokes);
		//var svgLetterPathDObj = MyScript.convertStrokesToDPathArray(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value, sliderLeftPadding.value, sliderRightPadding.value);
		//var svgLetterPathDObj2 = MyScript.convertStrokesToDPathArray(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value, sliderLeftPadding.value, svgLetterPathDObj.NextWriteOffsetLeft);
		
		var svgOffsetPathD = MyScript.getOffsetsForStroke(rectCanvas.strokes, sliderRightPadding.value);
		var svgBottomLinePathD = MyScript.getBottomLineForStroke(rectCanvas.strokes, sliderLeftPadding.value, sliderRightPadding.value, sliderYOffset.value);
		var svgOffsetPath = `<path fill="transparent" stroke-width="1" opacity="0.5" stroke="blue" d="${svgOffsetPathD}" />`;
		var svgBottomPath = `<path fill="transparent" stroke-width="1" opacity="0.5" stroke="red" d="${svgBottomLinePathD}" />`;

		//var svgLetterPath = `<path fill="transparent" stroke-width="1" stroke="black" d="` + svgLetterPathD.join(`" /><path fill="transparent" stroke-width="1" stroke="black" d="`) + `" />`;
		//var svgLetterPath = `<path fill="transparent" stroke-width="1" stroke="black" d="` + svgLetterPathDObj.StrokesToWrite.join(`" /><path fill="transparent" stroke-width="1" stroke="black" d="`) + `" />`;
		//var svgLetterPath2 = `<path fill="transparent" stroke-width="1" stroke="yellow" d="` + svgLetterPathDObj2.StrokesToWrite.join(`" /><path fill="transparent" stroke-width="1" stroke="yellow" d="`) + `" />`;
		var svgLetterPath = `<path fill="transparent" stroke-width="1" stroke="black" d="` + MyScript.strokeToDPath(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value) + `" />`;
		//console.log("svgLetterPath", svgLetterPath);
		//attempt to use a different simplify engine, seems to get same results
		//var svgLetterPath = `<path fill="transparent" stroke-width="1" stroke="black" d="` + MyScript.strokeToDPath(SimplifyScript.simplify(rectCanvas.strokes,sliderCurvature.value,false), sliderCurvature.value, sliderDistance.value) + `" />`;

		//var svgStrokes = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200">${svgOffsetPath}${svgLetterPath}${svgLetterPath2}</svg>`;
		//var svgDefsString = `<defs>${window.svgDefs}</defs>`;
		//console.log("svgDefsString", svgDefsString);
		//var sampleText = SentenceBuilder.buildSentence("The quick brown fox jumped over the lazy dog.", false, defMetas);
		var svgStrokes = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><defs>${window.svgDefs}</defs>${svgOffsetPath}${svgBottomPath}${svgLetterPath}</svg>`;
		//console.log(svgLetterPath.replace(/ /g," \n"));
		//console.log(svgStrokes);
		image1.source =  svgStrokes;
	}
	function qml_loadLetter(currentLetterIndex) {
		var glyphObj = Glypabet.glyphs.find(f=> f.char == ((currentLetterIndex == -1) ? " " : MyScript.letterArray[currentLetterIndex]));
		var glyphID = glyphObj.id;
		//console.log("loading", glyphID);
		var defMeta = cppCallBackTest.loadLetter(glyphID);
		//console.log("loaded", defMeta);
		defMeta = JSON.parse(defMeta);
		if(defMeta != null) {
			console.log("found letter on disk loading..");
			return defMeta;
		} else {
			console.log("no letter found");
			return null;
		}
		//return defMeta;
	}
	function qml_loadLetters(currentLetterIndex) {
		var results = [];
		var anyMissed = false;
		for(var i= -1; i<Glypabet.glyphs.length; i++) {
			var glyphObj = Glypabet.glyphs.find(f=> f.char == (i==-1 ? " " : MyScript.letterArray[i]) );
			if(glyphObj == null) {
				console.log("failed to find", MyScript.letterArray[i]);
				anyMissed = true;
			}
			var glyphID = glyphObj.id;
			//console.log("loading", glyphID);
			var defMeta = cppCallBackTest.loadLetter(glyphID);
			if(defMeta != "null") {
				//let letterData = cppCallBackTest.loadLetter(glyphID);
				//letterData["id"] = glyphObj.id
				defMeta = JSON.parse(defMeta);
				defMeta["glyphName"] = glyphObj.glyphName;
				defMeta["unicode"] = glyphObj.unicode;
				defMeta["char"] = glyphObj.char;
				results.push( defMeta );
				//console.log("loaded", defMeta);
			}
		}
		if(!anyMissed) {
			saveAsFontButton.isEnabled = true;
			console.log("Enabling ttf");
		}
		return results;
	}
	Component.onCompleted: {
    	nextLetterButton.qml_setNextLetter(true);
    	qml_reDrawTextDisplay();
    	popup.open()
    }
}