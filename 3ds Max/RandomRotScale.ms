MacroScript RandomScaleRot category:"Custom Scripts" buttonText: "Random Rotate & Scale" tooltip:"Rotate & Scale randomly"
(
	sSize01 = 72
	hPos01 = 56
	hPos02 = 180
	rollout RandomRotScal "Random Rotate & Scale" width:268 height:236
	(
		button startBtn "Start" pos:[87,197] width:101 height:35
		checkbox globalScaleChk "Use global scale" pos:[90,178] width:97 height:16
		groupBox axisBox "Axis values" pos:[6,7] width:256 height:131
		groupBox globalScaleBox "Global scale" pos:[8,141] width:256 height:34
		spinner minRotXSpn "Min Rotation X" pos:[hPos01,28] width:sSize01 height:16 range:[0,360,0]
		spinner minRotYSpn "Min Rotation Y" pos:[hPos01,46] width:sSize01 height:16 range:[0,360,0]
		spinner minRotZSpn "Min Rotation Z" pos:[hPos01,63] width:sSize01 height:16 range:[0,360,0]
		spinner minScaleXSpn "Min Scale X" pos:[hPos01,81] width:sSize01 height:16 range:[0.01,100,1]
		spinner minScaleYSpn "Min Scale Y" pos:[hPos01,100] width:sSize01 height:16 range:[0.01,100,1]
		spinner minScaleZSpn "Min Scale Z" pos:[hPos01,119] width:sSize01 height:16 range:[0.01,100,1]
		spinner maxRotXSpn "Max Rotation X" pos:[hPos02,28] width:sSize01 height:16 range:[0,360,360]
		spinner maxRotYSpn "Max Rotation Y" pos:[hPos02,46] width:sSize01 height:16 range:[0,360,360]
		spinner maxRotZSpn "Max Rotation Z" pos:[hPos02,63] width:sSize01 height:16 range:[0,360,360]
		spinner maxScaleXSpn "Max Scale X" pos:[hPos02,81] width:sSize01 height:16 range:[0.01,100,1]
		spinner maxScaleYSpn "Max Scale Y" pos:[hPos02,100] width:sSize01 height:16 range:[0.01,100,1]
		spinner maxScaleZSpn "Max Scale Z" pos:[hPos02,119] width:sSize01 height:16 range:[0.01,100,1]
		spinner minScaleSpn "Min Scale" pos:[hPos01,154] width:sSize01 height:16 range:[0.01,100,1]
		spinner maxScaleSpn "Max Scale" pos:[hPos02,154] width:sSize01 height:16 range:[0.01,100,1]
		
		on startBtn pressed do (
			undo on (
				if (selection.count <= 0) then (
					messageBox "Select one or more objects" title:"Warning" beep:false
				) else (
					for x in $ do (
					if (selection.count > 0) then (
						rX = random minRotXSpn.value maxRotXSpn.value
						rY = random minRotYSpn.value maxRotYSpn.value
						rZ = random minRotZSpn.value maxRotZSpn.value
						sX = random minScaleXSpn.value maxScaleXSpn.value
						sY = random minScaleYSpn.value maxScaleYSpn.value
						sZ = random minScaleZSpn.value maxScaleZSpn.value
						sG = random minScaleSpn.value maxScaleSpn.value
						
						if (globalScaleChk.checked) then (
							scale x [sG,sG,sG]
						) else (
							scale x [sX,sY,sZ]
						)
						rot = eulerAngles rX rY rZ
						rotate x rot
						) 
					)
				)
			)
		)
	)
	createDialog RandomRotScal 268 236
)