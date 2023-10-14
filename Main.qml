import QtQuick
import QtQuick.Window
import QtQuick.Controls
import FileOperations 1.0
import "scripts/script.js" as MyScript
import "scripts/simplifyScript.js" as SimplifyScript
import "scripts/glypabet.js" as Glypabet

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
			var glyphID = Glypabet.glyphs.find(f=> f.char == MyScript.letterArray[MyScript.currentLetterIndex] ).id;
			qml_saveLetter(glyphID);
			qml_setNextLetter();
/*			if( rectCanvas.strokes.length > 0 ) {
				console.log("some strokes detected");
				//console.log("rectCanvas.strokes", JSON.stringify(rectCanvas.strokes));
				//console.log("MyScript._flat(rectCanvas.strokes)", JSON.stringify(MyScript._flat(rectCanvas.strokes)));
				qml_reDrawTextDisplay();
				//var flatStrokes = MyScript._flat(rectCanvas.strokes);
				//var xInfo = MyScript.getGreatestXDistance(flatStrokes);
				//var dInfo = MyScript.getPointDistances(flatStrokes);
				//console.log("dInfo:(" + dInfo.length + ")", dInfo[0], " --> ", dInfo[dInfo.length - 1]);
				//dInfo = MyScript.setArrayToLengthRepeatingLastEntryIfNeccessary(dInfo, 1);
				//					//console.log("MyScript.convertPointsToCurve2(rectCanvas.strokes, [0.5, 0.6, 0.7, 0.8], dInfo, xInfo);");
				//					//console.log("rectCanvas.strokes:", rectCanvas.strokes);
				//					//console.log("dInfo", dInfo);
				//					//console.log("xInfo", JSON.stringify(xInfo));
				//var svgPath = MyScript.convertPointsToCurve2(rectCanvas.strokes, [0.5], dInfo, xInfo);
				////console.log("svgPath(" + svgPath.length + ")[0]=", JSON.stringify(svgPath[0]));
				//					//console.log("=svgPath",JSON.stringify(svgPath));
				//					//console.log("/MyScript.convertPointsToCurve2(rectCanvas.strokes, [0.5, 0.6, 0.7, 0.8], dInfo, xInfo);");
				////MyScript.convertPointsToCurve(rectCanvas.strokes[0], 0.8)
				//var svgStrokes = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><path fill="transparent" stroke-width="3" stroke="royalblue" d="` + svgPath.join(`" /><path fill="transparent" stroke-width="3" stroke="royalblue" d="`) + `" /></svg>`
				//console.log("svg:", svgStrokes);
				//image1.source =  svgStrokes;
			}*/
			rectCanvas.strokes = [];
			rectCanvas.currentStrokePoints = [];
			sliderYOffset.value = 0;
			//sliderDistance.to = 1;
			image1.source = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><path fill="orange" stroke="royalblue" d="L 150 50 L 100 150 z" /></svg>`
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
			cppCallBackTest.saveDataToFile(  glyphID
											,JSON.stringify({
												 id: glyphID
												,dPath: MyScript.strokeToDPath(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value)
												,leftMargin: sliderLeftPadding.value
												,rightMargin: sliderRightPadding.value
												,anchorPoint: {
													 y: sliderYOffset.value
													,x: Math.min(0,sliderLeftPadding.value)
													,width: metaData.width
												}
												//d,sketch: rectCanvas.strokes
											})
			);
			console.log("saved letter");
		}
		function qml_setNextLetter() {
			console.log("currently " + MyScript.letterArray[MyScript.currentLetterIndex]);
			//return letterArray[MyScript.currentLetterIndex];
			MyScript.setCurrentLetterIndex(MyScript.currentLetterIndex+1);
			if( MyScript.currentLetterIndex >= MyScript.letterArray.length ) {
				//MyScript.currentLetterIndex = 0;
				MyScript.setCurrentLetterIndex(0);
			}
			console.log("to " + MyScript.letterArray[MyScript.currentLetterIndex]);
			textCurrentLetter.text = MyScript.letterArray[MyScript.currentLetterIndex]
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
			console.log("defMetas", JSON.stringify(defMetas))
			var svgDefsString = MyScript.defMetaArrayToSVG(defMetas);
			// console.log("-----");
			// console.log("svgDefsString", JSON.stringify(svgDefsString));
			// console.log("-----");
			window.svgDefs = svgDefsString;
			//console.log("defs set", window.svgDefs);

			var svgStrokes = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><defs>${window.svgDefs}</defs></svg>`;

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
		//attempt to use a different simplify engine, seems to get same results
		//var svgLetterPath = `<path fill="transparent" stroke-width="1" stroke="black" d="` + MyScript.strokeToDPath(SimplifyScript.simplify(rectCanvas.strokes,sliderCurvature.value,false), sliderCurvature.value, sliderDistance.value) + `" />`;

		//var svgStrokes = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200">${svgOffsetPath}${svgLetterPath}${svgLetterPath2}</svg>`;
		//var svgDefsString = `<defs>${window.svgDefs}</defs>`;
		//console.log("svgDefsString", svgDefsString);
		var svgStrokes = `data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 200"><defs>${window.svgDefs}</defs>${svgOffsetPath}${svgBottomPath}${svgLetterPath}</svg>`;
		//console.log(svgLetterPath.replace(/ /g," \n"));
		//console.log(svgStrokes);
		image1.source =  svgStrokes;
	}
	function qml_loadLetters(currentLetterIndex) {
		var results = [];
		for(var i=0; i<currentLetterIndex; i++) {
			var glyphObj = Glypabet.glyphs.find(f=> f.char == MyScript.letterArray[i] );
			var glyphID = glyphObj.id;
			console.log("loading", glyphID);
			var defMeta = cppCallBackTest.loadLetter(glyphID);
			if(defMeta != "null") {
				//let letterData = cppCallBackTest.loadLetter(glyphID);
				//letterData["id"] = glyphObj.id
				defMeta = JSON.parse(defMeta);
				defMeta["glyphName"] = glyphObj.glyphName;
				defMeta["unicode"] = glyphObj.unicode;
				defMeta["char"] = glyphObj.char;
				results.push( defMeta );
				console.log("loaded", defMeta);
			}
		}
		return results;
	}
}