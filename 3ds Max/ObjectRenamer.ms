MacroScript ObjectRenamer category:"Custom Scripts" buttonText:"Object Renamer" tooltip:"Rename selected objects"
(
	Ntextpos = [10,136]
	Grppost = [4,118]
	nameCount = 0
	rollout ObjRenamer "Object Renamer" width:313 height:350
	(
		groupBox objBox "Objects" pos:[140,6] width:167 height:335
		groupBox prefBox "Prefix" pos:[4,6] width:133 height:49
		groupBox suffBox "Suffix" pos:[4,61] width:130 height:51
		groupBox grpBox "GroupBox" pos:[12,67] width:0 height:0
		groupBox nameBox "Name" pos:Grppost width:130 height:51
		editText prefEditTxt "" pos:[7,25] width:122 height:23 text:"P_"
		editText suffEditTxt "" pos:[7,81] width:122 height:23 text:"_S"
		editText nameEditTxt "" pos:Ntextpos width:122 height:23 text:"Name"
		checkbox onlySuffPrefChk "Only suffix/prefix" pos:[20,181] width:110 height:24
		listBox objList "" pos:[148,27] width:153 height:23 items:#("No items selected") readOnly:true
		button renameBtn "Rename selected" pos:[7,214] width:126 height:42
		button updateBtn "Update list" pos:[7,260] width:126 height:42
	
		on onlySuffPrefChk changed state do (
			if (onlySuffPrefChk.checked != true) then (
				Ntextpos = [10,136]
				Grppost = [4,118]
				nameEditTxt.pos = Ntextpos
				nameBox.pos = Grppost
			) else (
				Ntextpos = [1920,1000]
				Grppost = [1000,1000]
				nameEditTxt.pos = Ntextpos
				nameBox.pos = Grppost
			)
		)

		on renameBtn pressed do (
			nameCount = 0
			if (selection.count <= 0) then (
				messageBox "No objects selected" title:"Warning" beep:false
			) else (
				for x in $ do (
					if (onlySuffPrefChk.checked != true) then (
						x.name = prefEditTxt.text + nameEditTxt.text + "0" + nameCount as string + suffEditTxt.text
						nameCount = nameCount + 1
					) else (
						x.name = prefEditTxt.text + x.name + suffEditTxt.text
					)
					objList.items = for o in $ collect o.name
				)
			)
		)
		
		on updateBtn pressed do (
			if (selection.count > 0) then (
				objList.items = for o in $ collect o.name
			) else (
				objList.items = #("No objects selected")
			)
		)
	)
	
	createDialog ObjRenamer 313 350
)