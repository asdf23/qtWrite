.pragma library;

function dPathToNormalizedPath(dPath) {
	var pointBlocks = dPath.split(/[a-zA-z]/g).filter(f=> f.trim().length>0).map(m=>m.trim()).map(m=> m.split(/[\s,]/g));
	var lineTypes = dPath.replace(/[^a-zA-Z]/g,"").split("");
	//console.log("pointBlocks", pointBlocks);
	var results = [];
	var iOffset = 0;
	lineTypes.forEach((lineType,i) => {
		var points = [];
		switch(lineType) {
			case "m":
			case "M":
			case "l":
			case "L":
			case "t":
			case "T":
				points.push({
					 pointType: "xh"
					,value: parseFloat(pointBlocks[i+iOffset][0])
				});
				points.push({
					 pointType: "yh"
					,value: parseFloat(pointBlocks[i+iOffset][1])
				});
				results.push({
					 lineType
					,points
				});
				break;
			case "c":
			case "C":
				if( pointBlocks[i+iOffset].length == 6 ) {
					points.push({
						 pointType: "xr"
						,value: parseFloat(pointBlocks[i+iOffset][0])
					});
					points.push({
						 pointType: "yr"
						,value: parseFloat(pointBlocks[i+iOffset][1])
					});
					points.push({
						 pointType: "xr"
						,value: parseFloat(pointBlocks[i+iOffset][2])
					});
					points.push({
						 pointType: "yr"
						,value: parseFloat(pointBlocks[i+iOffset][3])
					});
					points.push({
						 pointType: "xh"
						,value: parseFloat(pointBlocks[i+iOffset][4])
					});
					points.push({
						 pointType: "yh"
						,value: parseFloat(pointBlocks[i+iOffset][5])
					});
					results.push({
						 lineType
						,points
					});
				} else if( pointBlocks[i+iOffset].length == 8 ) {
					points.push({
						 pointType: "xh"
						,value: parseFloat(pointBlocks[i+iOffset][0])
					});
					points.push({
						 pointType: "yh"
						,value: parseFloat(pointBlocks[i+iOffset][1])
					});
					points.push({
						 pointType: "xr"
						,value: parseFloat(pointBlocks[i+iOffset][2])
					});
					points.push({
						 pointType: "yr"
						,value: parseFloat(pointBlocks[i+iOffset][3])
					});
					points.push({
						 pointType: "xr"
						,value: parseFloat(pointBlocks[i+iOffset][4])
					});
					points.push({
						 pointType: "yr"
						,value: parseFloat(pointBlocks[i+iOffset][5])
					});
					points.push({
						 lineType
						,pointType: "xh"
						,value: parseFloat(pointBlocks[i+iOffset][6])
					});
					points.push({
						 pointType: "yh"
						,value: parseFloat(pointBlocks[i+iOffset][7])
					});
					results.push({
						 lineType
						,points
					});
				} else {
					console.log("C:", pointBlocks[i+iOffset]);
					throw "Unknown C segment";
				}
				break;
			case "h":
			case "H":
				points.push({
					 pointType: "xh"
					,value: parseFloat(pointBlocks[i+iOffset][0])
				});
				results.push({
					 lineType
					,points
				});
				break;
			case "v":
			case "V":
				points.push({
					 pointType: "yh"
					,value: parseFloat(pointBlocks[i+iOffset][0])
				});
				results.push({
					 lineType
					,points
				});
				break;
			case "z":
			case "Z":
				results.push({
					 lineType
					,points: []
				});
				iOffset--;
				break;
			case "s":
			case "S":
			case "q":
			case "Q":
				points.push({
					 pointType: "xh"
					,value: parseFloat(pointBlocks[i+iOffset][0])
				});
				points.push({
					 pointType: "yh"
					,value: parseFloat(pointBlocks[i+iOffset][1])
				});
				points.push({
					 pointType: "xh"
					,value: parseFloat(pointBlocks[i+iOffset][2])
				});
				points.push({
					 pointType: "yh"
					,value: parseFloat(pointBlocks[i+iOffset][3])
				});
				results.push({
					 lineType
					,points
				});
				break;
			case "a":
			case "A":
				points.push({
					 pointType: "xh"
					,value: parseFloat(pointBlocks[i+iOffset][0])
				});
				points.push({
					 pointType: "yh"
					,value: parseFloat(pointBlocks[i+iOffset][1])
				});
				points.push({
					 pointType: "o"
					,value: parseFloat(pointBlocks[i+iOffset][2])
				});
				points.push({
					 pointType: "o"
					,value: parseFloat(pointBlocks[i+iOffset][3])
				});
				points.push({
					 pointType: "o"
					,value: parseFloat(pointBlocks[i+iOffset][4])
				});
				points.push({
					 pointType: "xh"
					,value: parseFloat(pointBlocks[i+iOffset][5])
				});
				points.push({
					 pointType: "yh"
					,value: parseFloat(pointBlocks[i+iOffset][6])
				});
				results.push({
					 lineType
					,points
				});
				break;
		}
	});
	return results;
}
function npSegmentToString(nPathSegment) {
	switch(nPathSegment.lineType) {
			case "m":
			case "M":
			case "l":
			case "L":
			case "t":
			case "T":
				return `${nPathSegment.lineType} ${nPathSegment.points[0].value},${nPathSegment.points[1].value} `;
			case "c":
			case "C":
				if(nPathSegment.points.length == 6) {
					return `${nPathSegment.lineType} ${nPathSegment.points[0].value},${nPathSegment.points[1].value} ${nPathSegment.points[2].value},${nPathSegment.points[3].value} ${nPathSegment.points[4].value},${nPathSegment.points[5].value} `;
				} else if(nPathSegment.points.length == 8) {
					return `${nPathSegment.lineType} ${nPathSegment.points[0].value},${nPathSegment.points[1].value} ${nPathSegment.points[2].value},${nPathSegment.points[3].value} ${nPathSegment.points[4].value},${nPathSegment.points[5].value}  ${nPathSegment.points[6].value},${nPathSegment.points[7].value}`;
				} else {
					throw "Unknown C type";
				}
			case "h":
			case "H":
			case "v":
			case "V":
				return `${nPathSegment.lineType} ${nPathSegment.points[0].value} `;
			case "z":
			case "Z":
				return `${nPathSegment.lineType} `;
			case "s":
			case "S":
			case "q":
			case "Q":
				return `${nPathSegment.lineType} ${nPathSegment.points[0].value},${nPathSegment.points[1].value} ${nPathSegment.points[2].value},${nPathSegment.points[3].value} ${nPathSegment.points[4].value},${nPathSegment.points[5].value}  ${nPathSegment.points[6].value},${nPathSegment.points[7].value}`;
			case "a":
			case "A":
				return `${nPathSegment.lineType} ${nPathSegment.points[0].value},${nPathSegment.points[1].value} ${nPathSegment.points[2].value} ${nPathSegment.points[3].value} ${nPathSegment.points[4].value} ${nPathSegment.points[5].value},${nPathSegment.points[6].value} `;
	}
}
function normalizedPathToDPath(normalizedPath) {
	return normalizedPath.reduce( (acc,cur,i) => { 
		if(i==0) { 
			return npSegmentToString(cur);
		} else {
			return acc + npSegmentToString(cur) 
		} 
	}, null);
}
function flipYOnNormalizedPath(normalizedPath, baseLine) {
	return normalizedPath.map(m=> {
		m.points = m.points.map(m2=> {
			if(m2.pointType.startsWith("y")) { 
				m2.value = (m2.value * -1) + baseLine
			}
			return m2;
		})
		return m;
	});
}
function flipYOnDPath(dPath, baseLine) {
	return normalizedPathToDPath(flipYOnNormalizedPath(dPathToNormalizedPath(dPath), baseLine));
}
function offsetPath(dPath, offsetX, offsetY) {
	var normalizedPath = dPathToNormalizedPath(dPath);
	var offsetNP = normalizedPath.map(m=> { 
		m.points = m.points.map(p=> { 
			if(p.pointType.startsWith("x")) { 
				p.value += offsetX;
			} else if(p.pointType.startsWith("y")) { 
				p.value += offsetY;
			}
			return p;
		}); 
		return m; 
	});
	return normalizedPathToDPath(offsetNP);
}