.pragma library

let letterArray = [
				 "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
				,"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
				,"`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "~", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+" 
				,"[", "]", "\\", "{", "}", "|", ";", "\'", ":", "\"", ",", ".", "/", "<", ">", "?", "'"
			];
let currentLetterIndex = 0;
let alphabetStrokes = [];
function setCurrentLetterIndex(newValue) {
	currentLetterIndex = newValue;
	return currentLetterIndex;
}
function removeDuplicatesFromPointArray(pointArray) {
	return pointArray.reduce((acc, cur, ci) => {
		if(ci == 1) {
			if(acc.x == cur.x && acc.y == cur.y) {
				return [cur];
			} else {
				return [acc,cur];
			}
		} else {
			if( samePoint(acc[acc.length-1], cur) ) {
				return acc;
			} else {
				acc.push(cur);
				return acc;
			}
		}
	});
}
function offsetStrokeArrayXAxis(strokeArray, leftOffset) {
	//console.log("offsetStrokeArrayXAxis", strokeArray[0][0].x);
	strokeArray = strokeArray.map(pointArray=> {
		return pointArray.map(points=> {
			console.log("points.x 1:", points.x);
			points.x = parseFloat(points.x) + parseFloat(leftOffset);
			console.log("points.x 2:", points.x);
			return points;
		})
	});
	//console.log("offsetStrokeArrayXAxis", strokeArray[0][0].x);
	return strokeArray;
}
function resetStrokesLeftMinXTo(strokeArray, newMinX) {
	//MTL V-H
	//MML HOF
	//MYR V-H
	//*   *
	var flatStrokes = _flat(strokeArray);
	var minX = Math.min.apply(null, flatStrokes.map(m=>m.x));
	var offsetX = (newMinX - minX);
	return strokeArray.map(line=> {
		return line.map(points=> {
			return ({
				 y: points.y
				,x: points.x + offsetX
			})
		})
	});
}
function getMinXOfStrokes(strokeArray) {
	var flatStrokes = _flat(strokeArray);
	var minX = Math.min.apply(null, flatStrokes.map(m=>m.x));
	return minX;
}
function getMaxYOfStrokes(strokeArray) {
	var flatStrokes = _flat(strokeArray);
	var maxY = Math.max.apply(null, flatStrokes.map(m=>m.y));
	return maxY;
}
function getBottomLineMetaData(strokeArray, leftMargin, rightMargin, yOffset) {
	var flatStrokes = _flat(strokeArray);
	var maxX = Math.max.apply(null, flatStrokes.map(m=>m.x));
	var maxY = Math.max.apply(null, flatStrokes.map(m=>m.y));
	var minX = Math.min.apply(null, flatStrokes.map(m=>m.x));
	var minY = Math.min.apply(null, flatStrokes.map(m=>m.y));
	var width = (maxX - minX) + leftMargin + rightMargin;
	return {
		 maxX
		,maxY
		,minX
		,minY
		,width
	};
}
function getBottomLineForStroke(strokeArray, leftMargin, rightMargin, yOffset) {
	var metaData =getBottomLineMetaData(strokeArray, leftMargin, rightMargin, yOffset)
	return `M${Math.min(leftMargin,0)},${yOffset} H${metaData.width}`;
}
function getOffsetsForStroke(strokeArray, rightOffset) {
	//MTL V-H
	//MML HOF
	//MYR V-H
	//*   *
	var flatStrokes = _flat(strokeArray);
	var maxX = Math.max.apply(null, flatStrokes.map(m=>m.x));
	var maxY = Math.max.apply(null, flatStrokes.map(m=>m.y));
	var minX = Math.min.apply(null, flatStrokes.map(m=>m.x));
	var minY = Math.min.apply(null, flatStrokes.map(m=>m.y));
	var midY = ((maxY - minY)/2) + minY;
	var rightStroke = "";
	if(rightOffset == 0) {
		rightStroke = `M${maxX},${minY} V${maxY}`
	} else {
		rightStroke = `M${maxX},${minY} V${maxY} M${maxX},${midY} h${rightOffset} M${maxX+rightOffset},${minY} V${maxY}`;
	}
	if(maxX == 0) {
		var d = `M0,${minY} V${maxY} ${rightStroke}`;
	} else {
		var d = `M0,${minY} V${maxY} M0,${midY} H${minX} M${minX},${minY} V${maxY} ${rightStroke}`;
		return d;
	}
}
function defMetaArrayToSVG(defMetaArray) {
	/*
		{
			 id: glyphID
			,dPath: MyScript.strokeToDPath(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value)
			,leftMargin: sliderLeftPadding.value
			,rightMargin: sliderRightPadding.value
			,anchorPoint: {
				 y: sliderYOffset.value
				,x: sliderLeftPadding.value
				,width: Math.min(0,sliderLeftPadding.value)
			}
			//d,sketch: rectCanvas.strokes
		}
		//letterData["id"] = glyphObj.id
		letterData["glyphName"] glyphObj.glyphName;
		letterData["unicode"] glyphObj.unicode;
		letterData["char"] glyphObj.char;
	*/
	//console.log("defMetaArray:", JSON.stringify(defMetaArray));
	return defMetaArray.reduce((acc,cur,i) => {
		if(cur.char == "&") {
			cur.char = "&amp;"
		} else if(cur.char == "<") {
			cur.char = "&lt;"
		} else if(cur.char == ">") {
			cur.char = "&gt;"
		}
		var escapedDataGlyphName = ((cur.char == "\"") ? `'${cur.char}'` : `"${cur.char}"`);
		if(acc == null) {
			return `<g id="${cur.id.replace(/^glyph_/,'group_')}" stroke="#000" data-unicode="${cur.unicode}" data-glyph-name=${escapedDataGlyphName}><rect id="${cur.id.replace(/^glyph_/,'padding_')}" x="${Math.min(0,cur.leftMargin)}" y="0" width="${cur.leftMargin+cur.rightMargin+cur.anchorPoint.width}" height="${cur.anchorPoint.y}" fill="transparent" stroke-width=".06"/><path id="${cur.id.replace(/^glyph_/,'plot_')}" stroke-width="4" fill="transparent" d="${cur.dPath}"/></g>`;
		} else {
			return acc + `<g id="${cur.id.replace(/^glyph_/,'group_')}" stroke="#000" data-unicode="${cur.unicode}" data-glyph-name=${escapedDataGlyphName}><rect id="${cur.id.replace(/^glyph_/,'padding_')}" x="${Math.min(0,cur.leftMargin)}" y="0" width="${cur.leftMargin+cur.rightMargin+cur.anchorPoint.width}" height="${cur.anchorPoint.y}" fill="transparent" stroke-width=".06"/><path id="${cur.id.replace(/^glyph_/,'plot_')}" stroke-width="4" fill="transparent" d="${cur.dPath}"/></g>`;
		}
	}, null);
}
function defMetaArrayToSVGGlyphFormat(defMetaArray, pathCloserCallBack, pathFlipperCallback) {
	/*
		{
			 id: glyphID
			,dPath: MyScript.strokeToDPath(rectCanvas.strokes, sliderCurvature.value, sliderDistance.value)
			,leftMargin: sliderLeftPadding.value
			,rightMargin: sliderRightPadding.value
			,anchorPoint: {
				 y: sliderYOffset.value
				,x: sliderLeftPadding.value
				,width: Math.min(0,sliderLeftPadding.value)
			}
			//d,sketch: rectCanvas.strokes
		}
		//letterData["id"] = glyphObj.id
		letterData["glyphName"] glyphObj.glyphName;
		letterData["unicode"] glyphObj.unicode;
		letterData["char"] glyphObj.char;
	*/
	//console.log("defMetaArray:", JSON.stringify(defMetaArray));
	var glyphMissing = defMetaArray.find(f=> f.id == "glyph_space");
	var results = `<missing-glyph horiz-adv-x="${glyphMissing.leftMargin+glyphMissing.rightMargin+glyphMissing.anchorPoint.width}"  d="${pathFlipperCallback(pathCloserCallBack(glyphMissing.dPath),glyphMissing.anchorPoint.y)}" />` +
				`<glyph glyph-name="space" unicode=" " horiz-adv-x="${glyphMissing.leftMargin+glyphMissing.rightMargin+glyphMissing.anchorPoint.width}" d="M158 20" />` + //this hard-coded point removes an error expecting a value here downstream
				`<glyph glyph-name=".notdef" horiz-adv-x="${glyphMissing.leftMargin+glyphMissing.rightMargin+glyphMissing.anchorPoint.width}"  d="${pathFlipperCallback(pathCloserCallBack(glyphMissing.dPath),glyphMissing.anchorPoint.y)}" />`;
	return results + defMetaArray.reduce((acc,cur,i) => {
		if(cur.char == "&") {
			cur.char = "&amp;"
		} else if(cur.char == "<") {
			cur.char = "&lt;"
		} else if(cur.char == ">") {
			cur.char = "&gt;"
		}
		var escapedDataGlyphName = ((cur.char == "\"") ? `'${cur.char}'` : `"${cur.char}"`);
		if(acc == null) {
			return `<glyph glyph-name="${cur.glyphName}" unicode="${cur.unicode}" horiz-adv-x="${cur.leftMargin+cur.rightMargin+cur.anchorPoint.width}" d="${pathFlipperCallback(pathCloserCallBack(cur.dPath),cur.anchorPoint.y)}" />`;
		} else {
			return acc + `<glyph glyph-name="${cur.glyphName}" unicode="${cur.unicode}" horiz-adv-x="${cur.leftMargin+cur.rightMargin+cur.anchorPoint.width}" d="${pathFlipperCallback(pathCloserCallBack(cur.dPath),cur.anchorPoint.y)}" />`;
		}
	}, null);
}
function getOffsetForStrokeToCanvasLines(strokeArray, rightOffset) {
	//MTL V-H
	//MML HOF
	//MYR V-H
	//*   *
	var flatStrokes = _flat(strokeArray);
	var maxX = Math.max.apply(null, flatStrokes.map(m=>m.x));
	var maxY = Math.max.apply(null, flatStrokes.map(m=>m.y));
	var minX = Math.min.apply(null, flatStrokes.map(m=>m.x));
	var minY = Math.min.apply(null, flatStrokes.map(m=>m.y));
	var midY = ((maxY - minY)/2) + minY;
	let points = [];
	if(rightOffset == 0) {
		//rightStroke = `M${maxX},${minY} V${maxY}`
		points.push({x1:maxX,y1:minY, x2:maxX, y2:maxY});
	} else {
		//rightStroke = `M${maxX},${minY} V${maxY} M${maxX},${midY} h${rightOffset} M${maxX+rightOffset},${minY} V${maxY}`;
		points.push({x1:maxX, y1:minY, x2:maxX, y2:maxY});
		points.push({x1:maxX, y1:midY, x2:maxX+rightOffset, y2:midY});
		points.push({x1:maxX+rightOffset, y1:minY, x2:maxX+rightOffset, y2:maxY});
	}
	if(maxX == 0) {
		//var d = `M0,${minY} V${maxY} ${rightStroke}`;
		points.push({x1:0, y1:minY, x2:0, y2:rightStroke});
	} else {
		//var d = `M0,${minY} V${maxY} M0,${midY} H${minX} M${minX},${minY} V${maxY} ${rightStroke}`;
		points.push({x1:0, y1:minY, x2:0, y2:maxY});
		points.push({x1:0, y1:midY, x2:minX, y2:midY});
		points.push({x1: minX, y1:minY, x2:minX, y2:maxY});
		//return d;
	}
	return points;
}
function getPointDistancesFromStrokes(strokeArray) {
	//console.log("getPointDistancesFromStrokes(strokeArray)");
	//console.log("strokeArray=", JSON.stringify(strokeArray));
	var results = strokeArray.map(m=> {
		return getPointDistances(m);
	});
	//console.log("results=", JSON.stringify(results));
	results = _flat(results);
	results.sort((a,b)=> a-b);
	return Array.from(new Set(results));	
}
function getPointDistances(pointArray) {
	var di = null;
	var results = [];
	for(var i=1; i<pointArray.length; i++) { 
		di = getDistanceBetweenPoints(pointArray[i-1], pointArray[i]);
		results.push(di);
	}
	results.sort((a,b)=> a-b);
	return Array.from(new Set(results));
}
function getDistanceBetweenPoints(p1,p2) {
	return Math.pow(Math.pow(p1.x-p2.x,2) + Math.pow(p1.y-p2.y,2), 0.5);
}
function getGreatestYDistance(pointArray) {
	var max = Math.max.apply(null, d.map(m=>m.y));
	var min = Math.min.apply(null, d.map(m=>m.y));
	return {
		 min: min
		,max: max
		,distance: max-min
	};
}
function getGreatestXDistance(pointArray) {

	if((pointArray!= null) && "length" in pointArray) {
		var max = Math.max.apply(null, pointArray.map(m=>m.x));
		var min = Math.min.apply(null, pointArray.map(m=>m.x));
		return {
			 min: min
			,max: max
			,distance: max-min
		};
	} else {
		return null;
	}
}
function samePoint(p1,p2) {
	return (p1.x == p2.x && p1.y == p2.y);
}
function reduceStrokesLessThanDistance(strokeArray, minimumDistance) {
	//console.log(  "original sizes: " + strokeArray.map(m=> m.length).join(", ") )
	var results = strokeArray.map(m=> {
		return reduceSegmentsLessThanDistance(m, minimumDistance);
	});
	//console.log( "reduced sizes: " + results.map(m=> m.length).join(", ") )
	return results;
}
function reduceSegmentsLessThanDistance(pointArray, minimumDistance) {
	var da = [ pointArray[0] ];
	var currentPoint = JSON.parse(JSON.stringify(pointArray[0]));
	var nextPointIndex = 1;
	var d = null;
	for(var nextPointIndex = 1; nextPointIndex < pointArray.length; nextPointIndex++) {
		d = getDistanceBetweenPoints(currentPoint, pointArray[nextPointIndex]);
		if( d > minimumDistance ) {
			da.push(pointArray[nextPointIndex]);
			currentPoint = JSON.parse(JSON.stringify(pointArray[nextPointIndex]));
		}
	}
	if( !samePoint(da[da.length-1], pointArray[pointArray.length-1]) ) {
		da.push(pointArray[pointArray.length-1]);
	}
	return da;
}
function getControlPoints(pointArray, t) {
	var pointControl = [];
	for (var i = 1; i < pointArray.length - 1; i++) {
		var dx = pointArray[i - 1].x - pointArray[i + 1].x; // difference x
		var dy = pointArray[i - 1].y - pointArray[i + 1].y; // difference y
		// the first control point
		var x1 = pointArray[i].x - dx * t;
		var y1 = pointArray[i].y - dy * t;
		var o1 = {
			x: x1,
			y: y1
		};
		// the second control point
		var x2 = pointArray[i].x + dx * t;
		var y2 = pointArray[i].y + dy * t;
		var o2 = {
			x: x2,
			y: y2
		};
		// building the control points array
		pointControl[i] = [];
		pointControl[i].push(o1);
		pointControl[i].push(o2);
	}
	return pointControl;
}
function convertPointsToCurve(pointArray, t) {
	var pointControl = getControlPoints(pointArray, t);  
	let d =`M${pointArray[0].x},${pointArray[0].y} Q${pointControl[1][1].x},${pointControl[1][1].y}, ${pointArray[1].x},${pointArray[1].y} `;
	if (pointArray.length > 2) {
		for (var i = 1; i < pointArray.length - 2; i++) {
    		d += `C${pointControl[i][0].x}, ${pointControl[i][0].y}, ${pointControl[i + 1][1].x}, ${pointControl[i + 1][1].y}, ${pointArray[i + 1].x},${pointArray[i + 1].y} `;
    	}
		var n = pointArray.length - 1;
		d += `Q${pointControl[n - 1][0].x}, ${pointControl[n - 1][0].y}, ${pointArray[n].x}, ${pointArray[n].y} `;
	}
	return d;
}
function resetXOfPointArray(pointArray, xInfo, newX) {
	//var xInfo = getGreatestXDistance(pointArray);
	return pointArray.map(m=> {
		m.x = m.x - xInfo.min + newX
		return m;
	});
}
function pointArrayToPointArrayAsArray(pointArray) {
		return pointArray.map(point=> {
			//console.log("point=", JSON.stringify(point));
			return [point.x, point.y]
		});
}
function pointArrayAsArrayToPointArray(pointArrayAsArray){
		return pointArrayAsArray.map(points=> {
			return ({
				 x: points[0]
				,y: points[1]
			})
		})
}
function convertStrokesToDPathArray2(strokeArray, tolerance, distance, leftOffset, rightOffset) {
	//strokeArray = [  
	//	 [{x:0,y:0},{x:10,y:5},{x:50,y:50},{x:100,y:100}]
	//	,[{x:100,y:0},{x:50,y:50},{x:70,y:90},{x:0,y:100}]
	//];
	//leftOffset = -5;
	//leftOffset should be 0, the points passed would have the correct left/right points given that the stroke is to be written
	var nextX = null;
	var dPath = strokeArray.map(pathArray=> {
		return "M " + pathArray.map(points=> {
			var resetX = points.x + leftOffset;
			nextX = (nextX == null) ? (resetX + rightOffset) : Math.max(nextX, resetX + rightOffset)
			return `${resetX},${points.y}`
		}).join(" ");
	}).join(" ");
	return ({
		 dPath
		,nextX
	})
}
function convertStrokesToDPathArray(strokeArray, tolerance, distance, leftOffset, rightOffset) {
	var xInfo = getGreatestXDistance(_flat(strokeArray));
	console.log(JSON.stringify(strokeArray));
	strokeArray = offsetStrokeArrayXAxis(strokeArray, -1 * leftOffset);
	var dPath = strokeArray.map(pointArray => {
		pointArray = resetXOfPointArray(JSON.parse(JSON.stringify(pointArray)), xInfo, rightOffset );
		var pointArrayAsArray = pointArrayToPointArrayAsArray(pointArray);
		var curvePoints = curveToBezier(pointArrayAsArray);
		var bCurve = pointsOnBezierCurves(curvePoints, tolerance, distance);
		return `M ${bCurve[0][0]},${bCurve[0][1]} C ` + bCurve.filter((f,i)=> {
			return (i != 0)
		}).map(m=> {
			return m[0] + "," + m[1] 
		}).join(" ")
	}).join(" ");

	return ({
		 StrokesToWrite: [dPath]
		,NextWriteOffsetLeft: (1)* (xInfo.distance+(xInfo.min*1)) + rightOffset
	});
}

function convertPointsToCurve3(strokeArray, curvature, rightOffset) {
	var xInfo = getGreatestXDistance(_flat(strokeArray));
	var strokesToWrite = strokeArray.map(m=> {
		return convertPointsToCurve(m, curvature);
	});
	let leftOffset = xInfo.min;
	var xInfoNew = xInfo;
	var shiftedStrokArray = strokeArray.map((m,i) => {
		var clone = JSON.parse(JSON.stringify(m));
		return resetXOfPointArray(clone, xInfo, (1)* (xInfo.distance+(xInfo.min*2)) + rightOffset );
	});
	xInfoNew = getGreatestXDistance(_flat(shiftedStrokArray));
	var nextLetter = shiftedStrokArray.map((m,i) => {
		return convertPointsToCurve(m, curvature);
	});
	for(var i=0; i<nextLetter.length; i++) {
		strokesToWrite.push(nextLetter[i]);
	}
	shiftedStrokArray = strokeArray.map((m,i)=> { 
		var clone = JSON.parse(JSON.stringify(m));
		return resetXOfPointArray(clone, xInfo, (2*(xInfo.distance+xInfo.min)) + xInfo.min + rightOffset*2);
	});
	xInfoNew = getGreatestXDistance(_flat(shiftedStrokArray));
	var nextLetter = shiftedStrokArray.map((m,i)=> { 
		return convertPointsToCurve(m, curvature); 
	});
	for(var i=0; i<nextLetter.length; i++) {
		strokesToWrite.push(nextLetter[i]);
	}
	return strokesToWrite;
}
function convertPointsToCurve2(strokeArray, t, minDistances, xInfo) {
	//console.log("convertPointsToCurve2, strokeArray:", JSON.stringify(strokeArray));
	//working: return strokeArray.map(m=> { return convertPointsToCurve(m, 0.5); });
	var xInfo = getGreatestXDistance(_flat(strokeArray));
	var strokesToWrite = strokeArray.map(m=> { return convertPointsToCurve(m, 0.5); });
	//console.log("strokesToWrite(" + strokesToWrite.length + ")");
	//..
var leftOffset = xInfo.min;
	var xInfoNew = xInfo;
	var shiftedStrokArray = strokeArray.map((m,i)=> { 
		var p = JSON.parse(JSON.stringify(m));
		return resetXOfPointArray(p, xInfo, (1)*(xInfo.distance+(xInfo.min*2)) );
	});
	xInfoNew = getGreatestXDistance(_flat(shiftedStrokArray));
	var nextLetter = shiftedStrokArray.map((m,i)=> { 
		return convertPointsToCurve(m, 0.5); 
	});
	for(var i=0; i<nextLetter.length; i++) {
		strokesToWrite.push(nextLetter[i]);
	}
	shiftedStrokArray = strokeArray.map((m,i)=> { 
		var p = JSON.parse(JSON.stringify(m));
		return resetXOfPointArray(p, xInfo, (2*(xInfo.distance+xInfo.min)) + xInfo.min);
	});
	xInfoNew = getGreatestXDistance(_flat(shiftedStrokArray));
	var nextLetter = shiftedStrokArray.map((m,i)=> { 
		return convertPointsToCurve(m, 0.6); 
	});
	for(var i=0; i<nextLetter.length; i++) {
		strokesToWrite.push(nextLetter[i]);
	}
	return strokesToWrite;
}
function setArrayToLengthRepeatingLastEntryIfNeccessary(someArray,len) {
	someArray = someArray.filter((f,i)=> i<len);
	for(;someArray.length<len;someArray.push(someArray[someArray.length-1]));
	return someArray;
}
function _flat(array) {
	//return Array.from(array).flat();
	var results = [];
	for(var i=0; i<array.length; i++) {
		if( "length" in array[i] ) {
			for(var j=0; j<array[i].length; j++) {
				results.push(array[i][j]);
			}
		} else {
			results.push(array[i]);
		}
	}
	return results;
}
//
function reduceStrokesLessThanDistance2(strokeArray, distance, tolerance) {
	//console.log("reduceStrokesLessThanDistance2(strokArray=", JSON.stringify(strokeArray));
	var strokeArrayInArrayFormat = strokeArray.map(pointArray=> {
		//console.log("pointArray=", JSON.stringify(pointArray));
		return pointArray.map(point=> {
			//console.log("point=", JSON.stringify(point));
			return [point.x, point.y]
		});
	});
	//console.log("strokeArrayInArrayFormat=", JSON.stringify(strokeArrayInArrayFormat));
	var simplifiedStrokeArray = strokeArrayInArrayFormat.map(pointArrayAsArray => {
		console.log("pointArrayAsArray=", JSON.stringify(pointArrayAsArray));
		var pointsOnBezierCurvesRet = pointsOnBezierCurves(pointArrayAsArray, tolerance, distance);
		console.log("pointsOnBezierCurvesRet=", JSON.stringify(pointsOnBezierCurvesRet));
		return pointsOnBezierCurvesRet;
	});
	console.log("simplifiedStrokeArray=", JSON.stringify(simplifiedStrokeArray));
	return simplifiedStrokeArray.map(pointArrayAsArray=> {
		return pointArrayAsArray.map(points=> {
			return ({
				 x: points[0]
				,y: points[1]
			})
		})
	});
}
//------------------- https://github.com/pshihn/bezier-points/tree/master
function clone(p) {
  return [...p]
}

function curveToBezier(pointsIn, curveTightness = 0) {
  const len = pointsIn.length
  if (len < 3) {
    throw new Error("A curve must have at least three points.")
  }
  const out = []
  if (len === 3) {
    out.push(
      clone(pointsIn[0]),
      clone(pointsIn[1]),
      clone(pointsIn[2]),
      clone(pointsIn[2])
    )
  } else {
    const points = []
    points.push(pointsIn[0], pointsIn[0])
    for (let i = 1; i < pointsIn.length; i++) {
      points.push(pointsIn[i])
      if (i === pointsIn.length - 1) {
        points.push(pointsIn[i])
      }
    }
    const b = []
    const s = 1 - curveTightness
    out.push(clone(points[0]))
    for (let i = 1; i + 2 < points.length; i++) {
      const cachedVertArray = points[i]
      b[0] = [cachedVertArray[0], cachedVertArray[1]]
      b[1] = [
        cachedVertArray[0] + (s * points[i + 1][0] - s * points[i - 1][0]) / 6,
        cachedVertArray[1] + (s * points[i + 1][1] - s * points[i - 1][1]) / 6
      ]
      b[2] = [
        points[i + 1][0] + (s * points[i][0] - s * points[i + 2][0]) / 6,
        points[i + 1][1] + (s * points[i][1] - s * points[i + 2][1]) / 6
      ]
      b[3] = [points[i + 1][0], points[i + 1][1]]
      out.push(b[1], b[2], b[3])
    }
  }
  return out
}

// distance between 2 points
function distance(p1, p2) {
  return Math.sqrt(distanceSq(p1, p2))
}

// distance between 2 points squared
function distanceSq(p1, p2) {
  return Math.pow(p1[0] - p2[0], 2) + Math.pow(p1[1] - p2[1], 2)
}

// Sistance squared from a point p to the line segment vw
function distanceToSegmentSq(p, v, w) {
  const l2 = distanceSq(v, w)
  if (l2 === 0) {
    return distanceSq(p, v)
  }
  let t = ((p[0] - v[0]) * (w[0] - v[0]) + (p[1] - v[1]) * (w[1] - v[1])) / l2
  t = Math.max(0, Math.min(1, t))
  return distanceSq(p, lerp(v, w, t))
}

function lerp(a, b, t) {
  return [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t]
}

// Adapted from https://seant23.wordpress.com/2010/11/12/offset-bezier-curves/
function flatness(points, offset) {
  const p1 = points[offset + 0]
  const p2 = points[offset + 1]
  const p3 = points[offset + 2]
  const p4 = points[offset + 3]

  let ux = 3 * p2[0] - 2 * p1[0] - p4[0]
  ux *= ux
  let uy = 3 * p2[1] - 2 * p1[1] - p4[1]
  uy *= uy
  let vx = 3 * p3[0] - 2 * p4[0] - p1[0]
  vx *= vx
  let vy = 3 * p3[1] - 2 * p4[1] - p1[1]
  vy *= vy

  if (ux < vx) {
    ux = vx
  }

  if (uy < vy) {
    uy = vy
  }

  return ux + uy
}

function getPointsOnBezierCurveWithSplitting(
  points,
  offset,
  tolerance,
  newPoints
) {
  const outPoints = newPoints || []
  if (flatness(points, offset) < tolerance) {
    const p0 = points[offset + 0]
    if (outPoints.length) {
      const d = distance(outPoints[outPoints.length - 1], p0)
      if (d > 1) {
        outPoints.push(p0)
      }
    } else {
      outPoints.push(p0)
    }
    outPoints.push(points[offset + 3])
  } else {
    // subdivide
    const t = 0.5
    const p1 = points[offset + 0]
    const p2 = points[offset + 1]
    const p3 = points[offset + 2]
    const p4 = points[offset + 3]

    const q1 = lerp(p1, p2, t)
    const q2 = lerp(p2, p3, t)
    const q3 = lerp(p3, p4, t)

    const r1 = lerp(q1, q2, t)
    const r2 = lerp(q2, q3, t)

    const red = lerp(r1, r2, t)

    getPointsOnBezierCurveWithSplitting(
      [p1, q1, r1, red],
      0,
      tolerance,
      outPoints
    )
    getPointsOnBezierCurveWithSplitting(
      [red, r2, q3, p4],
      0,
      tolerance,
      outPoints
    )
  }
  return outPoints
}

function simplify(points, distance) {
  return simplifyPoints(points, 0, points.length, distance)
}

// Ramer–Douglas–Peucker algorithm
// https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
function simplifyPoints(points, start, end, epsilon, newPoints) {
  const outPoints = newPoints || []

  // find the most distance point from the endpoints
  const s = points[start]
  const e = points[end - 1]
  let maxDistSq = 0
  let maxNdx = 1
  for (let i = start + 1; i < end - 1; ++i) {
    const distSq = distanceToSegmentSq(points[i], s, e)
    if (distSq > maxDistSq) {
      maxDistSq = distSq
      maxNdx = i
    }
  }

  // if that point is too far, split
  if (Math.sqrt(maxDistSq) > epsilon) {
    simplifyPoints(points, start, maxNdx + 1, epsilon, outPoints)
    simplifyPoints(points, maxNdx, end, epsilon, outPoints)
  } else {
    if (!outPoints.length) {
      outPoints.push(s)
    }
    outPoints.push(e)
  }

  return outPoints
}

function pointsOnBezierCurves(points, tolerance = 0.15, distance) {
  const newPoints = []
  const numSegments = (points.length - 1) / 3
  for (let i = 0; i < numSegments; i++) {
    const offset = i * 3
    getPointsOnBezierCurveWithSplitting(points, offset, tolerance, newPoints)
  }
  if (distance && distance > 0) {
    return simplifyPoints(newPoints, 0, newPoints.length, distance)
  }
  return newPoints
}


// ---- https://francoisromain.medium.com/smooth-a-svg-path-with-cubic-bezier-curves-e37b49d46c74
var line = (pointA, pointB) => {
  const lengthX = pointB[0] - pointA[0]
  const lengthY = pointB[1] - pointA[1];
	return {
    length: Math.sqrt(Math.pow(lengthX, 2) + Math.pow(lengthY, 2)),
    angle: Math.atan2(lengthY, lengthX)
  }
}

var controlPoint2 = (current, previous, next, reverse) => {  // When 'current' is the first or last point of the array
  // 'previous' or 'next' don't exist.
  // Replace with 'current'
  const p = previous || current
  const n = next || current  // The smoothing ratio
  const smoothing = 0.2  // Properties of the opposed-line
  const o = line(p, n)  // If is end-control-point, add PI to the angle to go backward
  const angle = o.angle + (reverse ? Math.PI : 0)
  const length = o.length * smoothing  // The control point position is relative to the current point
  const x = current[0] + Math.cos(angle) * length
  const y = current[1] + Math.sin(angle) * length  ;
	return [x, y]
}

function svgPath(points, command) {  // build the d attributes by looping over the points
  var d = points.reduce((acc, point, i, a) => i === 0    // if first point
    ? `M ${point[0]},${point[1]}`    // else
    : `${acc} ${command(point, i, a)}`
  , '');
	return d
}

function bezierCommand(point, i, a) {  // start control point
  const [cpsX, cpsY] = controlPoint2(a[i - 1], a[i - 2], point)  // end control point
  const [cpeX, cpeY] = controlPoint2(point, a[i - 1], a[i + 1], true);
	return `C ${cpsX},${cpsY} ${cpeX},${cpeY} ${point[0]},${point[1]}`
}


function strokeToDPath(strokeArray, tolerance, distance) {
	//console.log("strokeToDPath(strokeArray, tolerance, distance) strokeArray=", JSON.stringify(strokeArray));
	return strokeArray.map(pointArrayAsArray=> {
		pointArrayAsArray = pointArrayToPointArrayAsArray(pointArrayAsArray)
		//console.log(pointArrayAsArray.length)
		var curve = curveToBezier(pointArrayAsArray);
		var bCurve = pointsOnBezierCurves(curve, tolerance, distance);
		//console.log("curveToBezier()",curve);
		//console.log("pointsOnBezierCurves(curve",bCurve);
		//console.log("d",  svgPath(bCurve, bezierCommand));
		return svgPath(bCurve, bezierCommand);
	}).join(" ");
}