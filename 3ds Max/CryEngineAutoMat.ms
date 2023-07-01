macroScript CryEngine3Mat
	category:"Custom Scripts"
	toolTip:"CryEngine Fast Materials"
(
	global edtTxtCtrls = #()
	global chkCtrls = #()
	global dropDownCtrls = #()

	rci = rolloutCreator "CryEngine_Mat" "CryEngine Fast Material" width:300 height:650
	rci.begin()

	-- Static UI
	rci.addControl #groupBox "materialGrp" "Material List" paramStr:"pos:[6,6] width:165 height:640"
	rci.addControl #spinner "subIdSpinner" "SubIDs" paramStr:"pos:[205,13] width:75 height:16 enabled:true type:#integer range:[1,12,1]"
	rci.addControl #button "createMatBtn" "Create Materials" paramStr:"pos:[179,100] width:110 height:43"
	rci.addControl #label "multiMatLabel" "Multimaterial Name" paramStr:"pos:[186,40]"
	rci.addControl #editText "multiMatEdtTxt" "" paramStr:"pos:[183,60] width:100 height:19 enabled:false"

	-- Per-material settings UI
	for i=0 to 11 do (
		posIncrementY = 50 * i
		matEdtTxtName = ("matEdtTxt" + i as string)
		matChkName = ("matChk" + i as string)
		matDropDownName = ("matDropDown" + i as string)

		enableState = "false"
		if (i == 0) then (
			enableState = "true"
		)

		rci.addControl #editText matEdtTxtName "Name" paramStr:("pos:[16," + (26 + posIncrementY) as string + "] width:148 height:19 " + "enabled:" + enableState)
		rci.addControl #checkbox matChkName "Collision" paramStr:("pos:[15," + (50 + posIncrementY) as string + "] width:59 height:14 " + "enabled:" + enableState)
		rci.addControl #dropDownList matDropDownName "" paramStr:("pos:[80," + (50 + posIncrementY) as string + "] width:84 height:21 enabled:false selection:1 items:#(\"Default\",\"Proxy\") " + "enabled:" + enableState)

		-- Checkbox command: Enable/disable dropdown list on change
		chkBoxCommand = (matDropDownName + ".enabled = newState")
		rci.addHandler matChkName #changed filter:on paramStr:"newState" codeStr:chkBoxCommand
	)

	-- Spinner command: Enable/disable necessary material UI elements on change
	spinnerCommand = (
		"for i=1 to newValue do (" +
			"edtTxtCtrls[i].enabled = true\n" +
			"chkCtrls[i].enabled = true\n" +
			"dropDownCtrls[i].enabled = true\n" +
		")" +
		"for i=newValue to 11 do (" +
			"edtTxtCtrls[i + 1].enabled = false\n" +
			"chkCtrls[i + 1].enabled = false\n" +
			"dropDownCtrls[i + 1].enabled = false\n" +
		")" +	
		"if (newValue > 1) then (" +
			"multiMatEdtTxt.enabled = true" +
		") else (" +
			"multiMatEdtTxt.enabled = false" +
		")"
	)

	rci.addHandler "subIdSpinner" #changed filter:on paramStr:"newValue" codeStr:spinnerCommand
	
	-- Create button command: Create material(s) and adjust collision settings
	createMatBtnCommand = (
		"actionMan.executeAction 0 \"50048\"\n" +
		
		"if (subIdSpinner.value == 1) then (" +
			"meditMaterials[2] = Standardmaterial ()\n" +
			"meditMaterials[2].shaderType = 2\n" +
			"meditMaterials[2].adTextureLock = on\n" +
			"meditMaterials[2].name = edtTxtCtrls[1].text\n" +
			
			"if (chkCtrls[1].checked) then (" +
				"meditMaterials[2].physicalizeMaterial = on\n" +
				"if (dropDownCtrls[1].selection == 1) then (" +
					"meditMaterials[2].surfaceName = \"Default\"" +
				")" +
				"if (dropDownCtrls[1].selection == 2) then (" +
					"meditMaterials[2].surfaceName = \"Physical Proxy (NoDraw)\"" +
				")" +
			") else (" +
				"meditMaterials[2].physicalizeMaterial = off" +
			")" +
			
		") else (" +
			"meditMaterials[2] = Multimaterial ()\n" +
			"meditMaterials[2].name = multiMatEdtTxt.text\n" +
			"meditMaterials[2].numsubs = subIdSpinner.value\n" +

			"for i=1 to subIdSpinner.value do (" +
				"meditMaterials[2].materialList[i] = Standardmaterial ()\n" +
				"meditMaterials[2].materialList[i].shaderType = 2\n" +
				"meditMaterials[2].materialList[i].name = edtTxtCtrls[i].text\n" +
				"meditMaterials[2].materialList[i].adTextureLock = on\n" +
				
				"if (chkCtrls[i].checked) then (" +
					"meditMaterials[2].materialList[i].physicalizeMaterial = on\n" +
					"if (dropDownCtrls[i].selection == 1) then (" +
						"meditMaterials[2].materialList[i].surfaceName = \"Default\"" +
					")" +
					"if (dropDownCtrls[i].selection == 2) then (" +
						"meditMaterials[2].materialList[i].surfaceName = \"Physical Proxy (NoDraw)\"" +
					")" +
				") else (" +
					"meditMaterials[2].materialList[i].physicalizeMaterial = off" +
				")" +
			")" +
		")"
	)

	rci.addHandler "createMatBtn" #pressed filter:on codeStr:createMatBtnCommand
	
	rci.end()
		
	createDialog rci.def 300 650

	-- Get and store dynamic UI components for later use (need to use execute since rollout is dynamically created)
	execute (
		"for ctrl in CryEngine_Mat.controls do (" +
			"if (matchPattern ctrl.name pattern:\"matEdtTxt*\") then (" +
				"append edtTxtCtrls ctrl\n" +
				"print (\"Added \" + ctrl.name)" +
			")" +

			"if (matchPattern ctrl.name pattern:\"matChk*\") then (" +
				"append chkCtrls ctrl" +
			")" +

			"if (matchPattern ctrl.name pattern:\"matDropDown*\") then (" +
				"append dropDownCtrls ctrl" +
			")" +
		")"
	)
)