--[[

	Sequent Calculus Module

	Author: Vitor

]]--

dofile "..\\logicmodule\\SequentGraph.lua"

-- Sequente alvo da operação
GoalSequent = nil

--[[
	Create a graph from a formula in text form.
	
	Params:
		formulaText - Formula in string form.
		
	Returns:
		A graph that represents the given formula.
]]--
function createGraphFromString( formulaText )
	
	local SequentGraph = Graph:new ()
	
	-- ~F SEQ ~F
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)
	NodeNot0 = SequentNode:new(opNot.graph)
	NodeNot1 = SequentNode:new(opNot.graph)
	NodeF = SequentNode:new('F')

	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeEsq, NodeNot1)
	Edge5 = SequentEdge:new('', NodeDir, NodeNot0)
	Edge6 = SequentEdge:new(lblCarnality..lblUnary, NodeNot0, NodeF)
	Edge7 = SequentEdge:new(lblCarnality..lblUnary, NodeNot1, NodeF)
	
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeNot0, NodeNot1, NodeF}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7}

	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	return SequentGraph
end


