.pragma library;

function getLetterInfo2(cVal, glyphData) {
	if(glyphData == null) {
		//console.log("missed2", cVal);
		 return ({
		 	 id: null
		 	,width: 0.0
		 	,height: null
		});
		// glyphData = ({
		// 	        "id": "glyph_space",
		// 	        "glyphName": "space",
		// 	        "unicode": " ",
		// 	        "char": " ",
		// 	        "_notStandard": true
		// 	    });
		// return ({
		// 			 id: glyphData.id
		// 			,width: glyphData.anchorPoint.width
		// 			,height: glyphData.anchorPoint.y
		// });
	}else {
		//console.log("found", cVal);
		let thisLetterValues = ({
			 id: glyphData.id
			,width: glyphData.anchorPoint.width
			,height: glyphData.anchorPoint.y
			,useDefault: glyphData.useDefault 
			,originalRequestedChar: cVal
		});
		return thisLetterValues;
	}
}
function getLetterInfo(cVal) {
	let node = document.querySelector(`[data-unicode="${cVal}"]`);
	if(node == null || cVal == " ") {
		console.log("missed1", cVal);
		return ({
			 id: null
			,width: 0.0
			,height: null
		});
	} else {
		console.log("found", cVal);
		let rect = node.querySelector("rect");
		let thisLetterValues = ({
			 id: node.id
			,width: parseFloat(rect.getAttribute("width"))
			,height: parseFloat(rect.getAttribute("height"))
		});
		return thisLetterValues;
	}
}
function letterInfoToUseHTMLSnippet(letterInfo,xOffset,y) {
	console.log("letterInfo.useDefault", letterInfo.useDefault);
	if(letterInfo != null && letterInfo.id != null && letterInfo.originalRequestedChar != " " ) {
		//console.log("xOffset", xOffset);
		//console.log("letterInfo", letterInfo);
		return `<use href="#${letterInfo.id.replace(/^glyph_/,'group_')}" x="${xOffset}" y="${y-letterInfo.height}" />`;
	} else {
		return "";
	}
}
function buildSentence(text, insertDOM, glyphDataArray, yOffset) {
	text = text.split('');
	var sentenceInfo;
	if(insertDOM) {
		sentenceInfo = text.reduce((acc,cur,ci,[])=> {
			if(ci==1) {
				return [getLetterInfo(acc),getLetterInfo(cur)]
			} else {
				acc.push(getLetterInfo(cur))
				return acc
			}
		});
	} else {
		// sentenceInfo = text.reduce((acc, cur, ci) => {
		// 	if(ci==1) {
		// 		return [
		// 				 getLetterInfo2(acc, glyphDataArray.find(f=>f.char == acc))
		// 				,getLetterInfo2(cur, glyphDataArray.find(f=>f.char == cur))
		// 		]
		// 	} else {
		// 		acc.push(getLetterInfo2(cur, glyphDataArray.find(f=>f.char == cur)))
		// 		return acc
		// 	}
		// });
		var glyphDataObj_defaultChar = glyphDataArray.find(f=>f.char == " ");
		//console.log("default charcter", JSON.stringify(glyphDataObj_defaultChar));
		sentenceInfo = text.reduce((acc, cur, ci) => {
			var glyphDataObj_acc = glyphDataArray.find(f=>f.char == acc);
			var glyphDataObj_cur = glyphDataArray.find(f=>f.char == cur);
			if(glyphDataObj_acc == null) { 
				//console.log("bad character", acc);
				glyphDataObj_acc = JSON.parse(JSON.stringify(glyphDataObj_defaultChar));
				//console.log(`using default for '${acc}'`);
				glyphDataObj_acc["useDefault"] = true;
			} else {
				glyphDataObj_acc["useDefault"] = false;
			}
			if(glyphDataObj_cur == null) { 
				//console.log("bad character", cur); 
				glyphDataObj_cur = JSON.parse(JSON.stringify(glyphDataObj_defaultChar));
				glyphDataObj_cur["useDefault"] = true;
				//console.log(`using default for '${cur}'`);
			} else {
				glyphDataObj_cur["useDefault"] = false;
			}
			if(ci==1) {
				return [
						 getLetterInfo2(acc, glyphDataObj_acc)
						,getLetterInfo2(cur, glyphDataObj_cur)
				]
			} else {
				acc.push(getLetterInfo2(cur, glyphDataObj_cur))
				return acc;
			}
		});
	}
	var htmlSnipBlob = sentenceInfo.reduce((acc,cur,ci,[])=> {
		if(ci==1) {
			var a = "";
			if(acc != null) {
				a = letterInfoToUseHTMLSnippet(acc,0, yOffset);
			}
			var b = "";
			if(acc != null) {
				b = letterInfoToUseHTMLSnippet(cur,acc.width, yOffset);
			}
			//console.log("acc.width + cur.width", acc.width + cur.width);
			return ({
				 r: a + b
				,t: (acc != null ? acc.width : 0) + (cur != null ? cur.width : 0)
			});
		} else {
			//console.log("else acc=",acc);
			var b = letterInfoToUseHTMLSnippet(cur,acc.t, yOffset)
			acc.r += b;
			acc.t += (cur != null ? cur.width : 0);
			return acc;
		}
	})
	if(insertDOM) {
		var g = document.createElementNS("http://www.w3.org/2000/svg","g");
		g.innerHTML = htmlSnipBlob.r;
		document.querySelector("defs").after(g)
	} 
	return htmlSnipBlob.r;
}
//buildSentence("The quick brown fox jumped over the lazy dog.", false, glyphData);