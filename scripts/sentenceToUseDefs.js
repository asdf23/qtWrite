.pragma library;

function getLetterInfo2(cVal, glyphData) {
	if(glyphData == null || cVal == " ") {
		console.log("missed", cVal);
		return ({
			 id: null
			,width: 0.0
			,height: null
		});
	} else {
		console.log("found", cVal);
		let thisLetterValues = ({
			 id: glyphData.id
			,width: glyphData.anchorPoint.width
			,height: glyphData.anchorPoint.y
		});
		return thisLetterValues;
	}
}
function getLetterInfo(cVal) {
	let node = document.querySelector(`[data-unicode="${cVal}"]`);
	if(node == null || cVal == " ") {
		console.log("missed", cVal);
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
	if(letterInfo != null && letterInfo.id != null) {
		console.log("xOffset", xOffset);
		return `<use href="#${letterInfo.id.replace(/^glyph_/,'group_')}" x="${xOffset}" y="${y-letterInfo.height}" />`;
	} else {
		return "";
	}
}
function buildSentence(text, insertDOM, glyphDataArray) {
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
		sentenceInfo = text.reduce((acc, cur, ci) => {
			if(ci==1) {
				return [getLetterInfo2(acc, glyphDataArray.find(f=>f.char == acc)),getLetterInfo2(cur, glyphDataArray.find(f=>f.char == cur))]
			} else {
				acc.push(getLetterInfo2(cur, glyphDataArray.find(f=>f.char == cur)))
				return acc
			}
		});
	}
	var htmlSnipBlob = sentenceInfo.reduce((acc,cur,ci,[])=> {
		if(ci==1) {
			var a = "";
			if(acc != null) {
				a = letterInfoToUseHTMLSnippet(acc,0,100);
			}
			var b = "";
			if(acc != null) {
				b = letterInfoToUseHTMLSnippet(cur,acc.width,100);
			}
			//console.log("acc.width + cur.width", acc.width + cur.width);
			return ({
				 r: a + b
				,t: (acc != null ? acc.width : 0) + (cur != null ? cur.width : 0)
			});
		} else {
			//console.log("else acc=",acc);
			var b = letterInfoToUseHTMLSnippet(cur,acc.t,100)
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