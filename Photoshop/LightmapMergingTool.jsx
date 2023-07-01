// ----- Lightmap Merging Tool ----
//
// -- Parameters
//	_numOfTextures = Starting number of textures to merge
//

#target photoshop

var _numOfTextures = 2;

function InitUI()
{
	var window = new Window("dialog", "Lightmap Merging Tool");
	
	var numOfLightmapsGroup = window.add("group");
	var numOfLightmapsTxt = numOfLightmapsGroup.add("statictext", undefined, "Number of Lightmaps to Merge:");
	var numOfLightmaps = numOfLightmapsGroup.add("edittext", undefined, _numOfTextures);
	numOfLightmaps.characters = 2;
	var numOfLightmapsBtn = numOfLightmapsGroup.add("button", undefined, "Set");
	numOfLightmapsBtn.onClick  = function ()
	{
		_numOfTextures = parseInt(numOfLightmaps.text);
		
		if (_numOfTextures < 2 || _numOfTextures > 10 || isNaN(_numOfTextures))
		{
			alert("Please input a number between 2 and 10");
			return;
		}
		
		window.close();
		InitUI();
	}
	
	var titleGroup = window.add("group");
	titleGroup.alignment = "center";
	var titleTex = titleGroup.add("statictext", undefined, "Select " + _numOfTextures + " lightmaps and input their Unity tiling values");
	
	// UI arrays
	var texPanel = [];
	var texPathGroup = [];
	var texPath = [];
	var texBrowseBtn = [];
	var texBrowseBtnArg = [];
	var tilingGroup = [];
	var tilingTxt1 = [];
	var tilingTxt2 = [];
	var tilingX = [];
	var tilingY = [];
	
	// Loop that creates all the UI input fields necessary for texture loading
	for (var i = 0; i < _numOfTextures; i++)
	{
		texPanel[i] = window.add("panel");
		texPathGroup[i] = texPanel[i].add("group");
		
		texPath[i] = texPathGroup[i].add("edittext", undefined, "~/Desktop");
		texPath[i].characters = 30;
		texBrowseBtn[i] = texPathGroup[i].add("button", undefined, "Browse");
		texBrowseBtn[i].name = i;
		texBrowseBtn[i].onClick = function () { texPath[this.name].text = BrowseFile(); } // Callback for browse buttons
			
		tilingGroup[i] = texPanel[i].add("group");
		tilingTxt1[i] = tilingGroup[i].add("statictext", undefined, "Tiling X");
		tilingX[i] = tilingGroup[i].add("edittext", undefined, "1.0000000");
		tilingX.characters = 13;
		tilingTxt2[i] = tilingGroup[i].add("statictext", undefined, "Tiling Y");
		tilingY[i] = tilingGroup[i].add("edittext", undefined, "1.0000000");
		tilingY.characters = 13;
	}
	
	var buttonGroup = window.add("group");
	var btn1 = buttonGroup.add("button", undefined, "Merge");
	var btn2 = buttonGroup.add("button", undefined, "Cancel");
	
	btn1.onClick = 
	function () 
	{ 
		RunTool(texPath, tilingX, tilingY);
		window.close();
	}

	window.show();
}

function BrowseFile()
{
	targetFile = File.openDialog("Selection prompt");
	return targetFile.fsName; // Return OS specific path instead of URI encoding
}

function RunTool(uiPathArray, uiTilingX, uiTilingY)
{
	var appUnits = app.preferences.rulerUnits;
	app.preferences.rulerUnits = Units.PIXELS;
	
	var files = [];
	var docs = [];
	var finalDoc = "temp";
	
	for (i = 0; i < _numOfTextures; i++)
	{
		if (i != 0)
		{
			finalDoc = app.activeDocument;
		}
		
		files[i] = File(uiPathArray[i].text);
		docs[i] = open(files[i]);
		res = [docs[i].width, docs[i].height];
		
		if (docs[i].channels.length < 4)
		{
			alert("Please open an EXR file as an non-transparent EXR first before running the tool.");
			return;
		}
		
		if (i == 0)
		{
			blackBG = new SolidColor();
			blackBG.rgb.red = 0;
			blackBG.rgb.green = 0;
			blackBG.rgb.blue = 0;
			
			app.backgroundColor = blackBG;
			
			finalDoc = documents.add(res[0], res[0], 72, "MergedLightmap", NewDocumentMode.RGB, DocumentFill.BACKGROUNDCOLOR, 1.0, BitsPerChannelType.THIRTYTWO);
			mainFolder = finalDoc.layerSets.add();
			mainFolder.name = "Main";
		}

		app.activeDocument = docs[i];
		mainLayer = docs[i].activeLayer;
		mainLayer.isBackgroundLayer = false;
		
		var sizeX = 100.0 + ((1.0000000 - uiTilingX[i].text) * 100.0); // Convert Unity tiling values to 100-based scaling
		var sizeY = 100.0 + ((1.0000000 - uiTilingY[i].text) * 100.0);
		mainLayer.resize(sizeX, sizeY, AnchorPosition.BOTTOMLEFT);
		docs[i].activeChannels = [docs[i].channels[3]];
		docs[i].selection.selectAll();
		docs[i].selection.resize(sizeX, sizeY, AnchorPosition.BOTTOMLEFT);  //Alpha resizing (uses selection-based resizing so it takes the entire document into account)
		docs[i].activeChannels = [docs[i].channels[0], docs[i].channels[1], docs[i].channels[2]];
		
		SelectNonTransparentPixels();
		docs[i].selection.expand(1);
		docs[i].selection.copy();
		
		app.activeDocument = finalDoc;
		PasteInPlace();
		finalDoc.selection.deselect();
		finalDoc.activeLayer.name = "Map " + i;
		finalDoc.activeLayer.move(finalDoc.layerSets.getByName("Main"), ElementPlacement.INSIDE);
		
		app.activeDocument = docs[i];
		docs[i].selection.deselect();
		docs[i].activeChannels = [docs[i].channels[3]];
		SelectNonTransparentPixels();
		docs[i].selection.copy();
		app.activeDocument = finalDoc;
		
		if (finalDoc.channels.length < 4)
		{
			finalDoc.channels.add();
		}
		
		finalDoc.activeChannels = [finalDoc.channels[3]];
		PasteInPlace();
		
		app.activeDocument = finalDoc;
		finalDoc.activeChannels = [finalDoc.channels[0], finalDoc.channels[1], finalDoc.channels[2]];
		
		if (i+1 == _numOfTextures)
		{
			finalDoc.layerSets.getByName("Main").merge();
			
			app.preferences.rulerUnits = appUnits;
			
			alert("Lightmaps merged successfully!");
		}
	}
}

// ScriptListener functions
function SelectNonTransparentPixels() 
{
	var idsetd = charIDToTypeID( "setd" );
    var desc2 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
	var ref1 = new ActionReference();
	var idChnl = charIDToTypeID( "Chnl" );
	var idfsel = charIDToTypeID( "fsel" );
	ref1.putProperty( idChnl, idfsel );
    desc2.putReference( idnull, ref1 );
    var idT = charIDToTypeID( "T   " );
	var ref2 = new ActionReference();
	var idChnl = charIDToTypeID( "Chnl" );
	ref2.putName( idChnl, "Alpha 1" );
    desc2.putReference( idT, ref2 );
	executeAction( idsetd, desc2, DialogModes.NO );
}

function MaskLayerFromSelection()
{
	var idMk = charIDToTypeID( "Mk  " );
    var desc7 = new ActionDescriptor();
    var idNw = charIDToTypeID( "Nw  " );
    var idChnl = charIDToTypeID( "Chnl" );
    desc7.putClass( idNw, idChnl );
    var idAt = charIDToTypeID( "At  " );
	var ref5 = new ActionReference();
	var idChnl = charIDToTypeID( "Chnl" );
	var idChnl = charIDToTypeID( "Chnl" );
	var idMsk = charIDToTypeID( "Msk " );
	ref5.putEnumerated( idChnl, idChnl, idMsk );
    desc7.putReference( idAt, ref5 );
    var idUsng = charIDToTypeID( "Usng" );
    var idUsrM = charIDToTypeID( "UsrM" );
    var idRvlS = charIDToTypeID( "RvlS" );
    desc7.putEnumerated( idUsng, idUsrM, idRvlS );
	executeAction( idMk, desc7, DialogModes.NO );
}

function ApplyLayerMask()
{
	var idDlt = charIDToTypeID( "Dlt " );
    var desc158 = new ActionDescriptor();
    var idnull = charIDToTypeID( "null" );
	var ref118 = new ActionReference();
	var idChnl = charIDToTypeID( "Chnl" );
	var idOrdn = charIDToTypeID( "Ordn" );
	var idTrgt = charIDToTypeID( "Trgt" );
	ref118.putEnumerated( idChnl, idOrdn, idTrgt );
    desc158.putReference( idnull, ref118 );
    var idAply = charIDToTypeID( "Aply" );
    desc158.putBoolean( idAply, true );
	executeAction( idDlt, desc158, DialogModes.NO );
}

function PasteInPlace()
{
	var idpast = charIDToTypeID( "past" );
    var desc133 = new ActionDescriptor();
    var idinPlace = stringIDToTypeID( "inPlace" );
    desc133.putBoolean( idinPlace, true );
    var idAntA = charIDToTypeID( "AntA" );
    var idAnnt = charIDToTypeID( "Annt" );
    var idAnno = charIDToTypeID( "Anno" );
    desc133.putEnumerated( idAntA, idAnnt, idAnno );
	executeAction( idpast, desc133, DialogModes.NO );
}

// Main
InitUI();