#
# --- Convert simulation anim to blendshape anim ---
#


import maya.cmds as cmds
import pymel.core as pm
    
class ClothAnimExportTool:
    def __init__(self):
        self.numOfBlendshapes = 20
        self.moveDistance = 0
        self.UI = {}
        self.InitUI()
    
    def FromCachetoBlendshapeAnim(self):
        self.numOfBlendshapes = self.UI["fromSim_numOfBlendshapes].getValue()
        self.moveDistance = self.UI["blendShapeMoveDistance"].getValue()
        rangeSliderMax = cmds.playbackOptions(q = True, maxTime = True) #Use range slider as the max keyframes
        frameSkip = rangeSliderMax/self.numOfBlendshapes
        source = cmds.ls(sl = True)
        blendShapes = []
        
        if len(source) != 1:
            pm.warning("Please select the simulated cloth object")
            return
        
        finalShape = cmds.duplicate()
        cmds.select(finalShape, r = True)
        finalShape = cmds.rename("Blendshape1")
        
        cmds.select(source, r = True)
        targetShape = cmds.duplicate()
        cmds.select(finalShape, r = True)
        cmds.select(targetShape, add = True)
        blendShapeNode = cmds.blendShape()
        cmds.select(source, r = True)
        
        for i in range(self.numOfBlendshapes):
            cmds.select(source, r = True)
            currentFrame = 0 + frameSkip*i
            cmds.currentTime(currentFrame)
            blendShapes.append(cmds.duplicate())
            cmds.select(blendShapes[i], r = True)
            blendShapes[i][0] = cmds.rename("Blendshape1")
            
            inBetweenValue = 0 + i*(1.0/self.numOfBlendshapes)
            
            cmds.move(self.moveDistance + i*self.moveDistance, 0, 0)
            cmds.select(targetShape, add = True)
            cmds.blendShape(blendShapeNode, edit = True, ib = True, t=(str(targetShape[0]), 0, str(blendShapes[i][0]), float("{0:.2f}".format(inBetweenValue)))) #Affected object, index, target shape, in-between value
            
        cmds.select(targetShape, r = True)
        cmds.rename("BakedAnim")
        print("Blendshape created successfully!")
        
    def CreateBlendshapeFromGeos(self):
        self.numOfBlendshapes = self.UI["fromBlend_numOfBlendshapes"].getValue()
        firstInBetween = self.UI["fromBlend_index"].getValue()
        inBetweenName = self.UI["blendName"].getText()
        
        source = cmds.ls(sl = True)
        
        if len(source) != 1:
            pm.warning("Please select the target object")
            return
            
        if firstInBetween == 0:
            cmds.select(inBetweenName, r = True)
            if len(pm.ls(inBetweenName)) < 1:
                pm.warning("Could not find blendshapes with the specified name")
                return
        else:
            cmds.select(inBetweenName + str(firstInBetween), r = True)
            if len(pm.ls(inBetweenName + str(firstInBetween))) < 1:
                pm.warning("Could not find blendshapes with the specified name")
                return
            
        cmds.select(source, add = True)
        blendShapeNode = cmds.blendShape(n = "blendShape")
        cmds.select(source, r = True)
        
        for i in range(self.numOfBlendshapes):
            geoName = inBetweenName + str(i+firstInBetween)
            inBetweenValue = 0 + i*(1.0/self.numOfBlendshapes)
            
            cmds.blendShape("blendShape", edit = True, ib = True, t=(str(source[0]), 0, geoName, float("{0:.2f}".format(inBetweenValue))))
            
    def DisplayHelp(self):
        self.UI["helpWin"] = pm.window(title = "Help", width = 300, height = 50)
        pm.columnLayout()
        self.UI["helpSpc"] = pm.text(label = "")
        self.UI["helpTxt"] = pm.text(label = "Meshes that come from an object with nCloth nodes don't work as expected.")
        self.UI["helpTxt2"] = pm.text(label = "If you notice that the baked blendshape animation doesn't export properly,")
        self.UI["helpTxt3"] = pm.text(label = "try deleting all nCloth nodes and reimporting the cache (Delete All by Type)")
        self.UI["helpSpc2"] = pm.text(label = "")
        pm.showWindow(self.UI["helpWin"])
            
    def InitUI(self):
        self.UI["win"] = pm.window(title = "Cloth Anim Baking Tool", h = 220, w = 280, s = False)
        
        with self.UI["win"]:
            with pm.columnLayout():
                with pm.frameLayout(label = "From Simulation/Cache", collapsable = True, width = 280):
                    with pm.verticalLayout():
                        with pm.horizontalLayout(ratios = [1,0.5,1,1]):
                            self.UI["fromSim_txt"] = pm.text(label = "Blendshapes:")
                            self.UI["fromSim_numOfBlendshapes] = pm.intField(minValue=1, value=20)
                            self.UI["blendShapeOffset_txt"] = pm.text(label = "Move each mesh by:")
                            self.UI["blendShapeMoveDistance"] = pm.intField(minValue=0, value=0)
                        with pm.horizontalLayout():
                            self.UI["fromSimBake_btn"] = pm.button(label = "Bake")
                            self.UI["fromSimBake_btn"].setCommand(pm.Callback(self.FromCachetoBlendshapeAnim))
                pm.text(label = " ")                
                with pm.frameLayout(label = "From Blendshapes", collapsable = True, width = 280):
                    with pm.verticalLayout():
                        with pm.horizontalLayout(ratios = [0.4,.2], spacing = 0):
                            self.UI["fromBlend_txt"] = pm.text(label = "Blendshapes:")
                            self.UI["fromBlend_numOfBlendshapes"] = pm.intField(minValue = 1, value = 20)
                            self.UI["fromBlend_spc"] = pm.text(label = "")
                        with pm.horizontalLayout(ratios = [1.1,0.7,0.7,0.5], spacing = 0):
                            self.UI["blendShapesName_txt"] = pm.text(label = "Blendshapes name:")
                            self.UI["blendName"] = pm.textField(text = "Blendshape")
                            self.UI["fromBlend_index"] = pm.text(label = "Start index:")
                            self.UI["fromBlend_index"] = pm.intField(minValue = 0, value = 1)
                        with pm.horizontalLayout():
                            self.UI["fromBlend_btn"] = pm.button(label = "Bake")
                            self.UI["fromBlend_btn"].setCommand(pm.Callback(self.CreateBlendshapeFromGeos))
                pm.text(label = "")
                self.UI["help"] = pm.button(label = "Help")
                self.UI["help"].setCommand(pm.Callback(self.DisplayHelp))
        pm.showWindow(self.UI["win"])
        
ClothAnimExportTool()