--[[

	Constants for sequent Module
	
	Contains all the constants used by the Sequent Calculus Logic Module.

	Author: Vitor

]]--

-- Operators definitions
opAnd = {}
opAnd["tex"] = '\\land'
opAnd["print"] = '&'  
opAnd["graph"] = "and"

opOr = {}
opOr["tex"] = '\\lor' 
opOr["print"] = '|'  
opOr["graph"] = "or"

opImp = {}
opImp["tex"] = '\\to'
opImp["print"] = '->'
opImp["graph"] = "imply"

opNot = {}
opNot["tex"] = '\\neg'
opNot["print"] = '~'
opNot["graph"] = "not"

opSeq = {}
opSeq["tex"] = '\\vdash'
opSeq["print"] = '=>'
opSeq["graph"] = "Seq"

-- Labels for graph definitions
lblEdgeEsq = "esq"
lblEdgeDir = "dir"
lblEdgeDeducao = "DED"
lblEdgeGoal = "Goal"

lblNodeGG = "GG"
lblNodeEsq = "e"
lblNodeDir = "d"

lblCarnality = "log_"
lblUnary = "u"
lblBinary = "b" 

