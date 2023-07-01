import pymel.core as pm

class VtxAOtoRGB:
    def __init__(self):
        self.UI = {}
        self.InitUI();
        
    def InitUI(self):
        self.UI["win"] = pm.window(title = "Vertex AO to RGB tool", h = 115, w = 190, s = False)
        self.UI["layout"] = pm.formLayout()
        
        with self.UI["layout"]:
            self.UI["txt"] = pm.text(label = "Swap AO to channels:")
            
            self.UI["chkboxR"] = pm.checkBox(label = "R")
            self.UI["chkboxG"] = pm.checkBox(label = "G")
            self.UI["chkboxB"] = pm.checkBox(label = "B")
            self.UI["chkboxA"] = pm.checkBox(label = "A", en = False)
            self.UI["chkboxIgnore"] = pm.checkBox(label = "Ignore Alpha", value = True)
            self.UI["chkboxIgnore"].setOnCommand(pm.Callback(self.UpdateUI, False))
            self.UI["chkboxIgnore"].setOffCommand(pm.Callback(self.UpdateUI, True))
            self.UI["btn"] = pm.button(label = "Swap")
            self.UI["btn"].setCommand(pm.Callback(self.SwapColors))
            
        pm.formLayout(self.UI["layout"], e = True, attachForm = [(self.UI["txt"], "top", 5), (self.UI["txt"], "left", 35),
                                                                (self.UI["chkboxR"], "top", 25), (self.UI["chkboxR"], "left", 20),
                                                                (self.UI["chkboxG"], "top", 25), (self.UI["chkboxG"], "left", 60),
                                                                (self.UI["chkboxB"], "top", 25), (self.UI["chkboxB"], "left", 100),
                                                                (self.UI["chkboxA"], "top", 25), (self.UI["chkboxA"], "left", 140),
                                                                (self.UI["chkboxIgnore"], "top", 50), (self.UI["chkboxIgnore"], "left", 55),
                                                                (self.UI["btn"], "top", 75), (self.UI["btn"], "left", 75)])
        pm.showWindow(self.UI["win"])
        
    def UpdateUI(self, status):
        if status == True:
            pm.checkBox(self.UI["chkboxA"], en = True, edit = True)
        else:
            pm.checkBox(self.UI["chkboxA"], en = False, edit = True)
        
    
    def SwapColors(self):
        obj = pm.ls(sl = True)
        
        swapR = pm.checkBox(self.UI["chkboxR"], value = True, q = True)
        swapG = pm.checkBox(self.UI["chkboxG"], value = True, q = True)
        swapB = pm.checkBox(self.UI["chkboxB"], value = True, q = True)
        swapA = pm.checkBox(self.UI["chkboxA"], value = True, q = True)
        
        ignoreAlpha = pm.checkBox(self.UI["chkboxIgnore"], value = True, q = True)
        
        for o in obj:
            for v in o.vtx:
                pm.select(v, r = True)
                
                r = pm.polyColorPerVertex(q = True, r = True)[0]
                g = pm.polyColorPerVertex(q = True, g = True)[0]
                b = pm.polyColorPerVertex(q = True, b = True)[0]
                a = pm.polyColorPerVertex(q = True, a = True)[0]
    
                if swapR == True:
                    r = 1 - r
                else:
                    r = 0
                    
                if swapG == True:
                    g = 1 - g
                else:
                    g = 0
                    
                if swapB == True:
                    b = 1 - b
                else:
                    b = 0
                    
                if swapA == True:
                    a = 1 - a
                else:
                    a = 0
                    
                if ignoreAlpha == True:
                    a = 1;
                
                pm.polyColorPerVertex(r = r)
                pm.polyColorPerVertex(g = g)
                pm.polyColorPerVertex(b = b)
                pm.polyColorPerVertex(a = a)
            
        
VtxAOtoRGB()