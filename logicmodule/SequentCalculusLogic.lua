--[[

	Sequent Calculus Module

	Author: Vitor

]]--

dofile "..\\logicmodule\\SequentGraph.lua"

-- Sequente alvo da operação
local GoalSequentNode = nil

-- Junta as funções que este modulo oferece como publicas.
LogicModule = {}

--[[ 
	Defining the Metatable
]]--
--LogicModule_Metatable = { __index = LogicModule }

--setmetatable( {}, LogicModule_Metatable )


-- Private functions
local function expandNodeNot (graph, nodeOpNot)
	createDebugMessage("expandNodeNot foi chamado para o sequente: "..GoalSequentNode:getLabel().. " e para o operador: "..nodeOpNot:getLabel())
	return graph
end

local function expandNodeAnd(graph, nodeOpAnd)
	createDebugMessage("expandNodeAnd foi chamado para o sequente: "..GoalSequentNode:getLabel().. " e para o operador: "..nodeOpAnd:getLabel())
	return graph
end

local function expandNodeOr(graph, nodeOpOr)
	createDebugMessage("expandNodeOr foi chamado para o sequente: "..GoalSequentNode:getLabel().. " e para o operador: "..nodeOpOr:getLabel())
	return graph
end

local function expandNodeImp(graph, nodeOpImp)
	createDebugMessage("expandNodeImp foi chamado para o sequente: "..GoalSequentNode:getLabel().. " e para o operador: "..nodeOpImp:getLabel())
	return graph
end

-- Public functions
--[[
	Create a graph from a formula in text form.
	
	Params:
		formulaText - Formula in string form.
		
	Returns:
		A graph that represents the given formula.
]]--
function LogicModule.createGraphFromString( formulaText )
	
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
	
	assert( getmetatable(SequentGraph) == Graph_Metatable , "LogicModule.createGraphFromString expects a graph.")
	
	return SequentGraph
end

--- Verify if a especific node is of the type difinet by operatorIdentifier
-- @param node The node to verify
-- @param operatorIdentifier An string defined in ConstantsForSequent.lua in Operators table.
local function verifyGraphNodeOperator(node, operatorIdentifier)

	local validOperator = false
	local operatorOfNode = nil
	
	for i=1, #operators do
		for key,value in pairs(operators[i]) do
			if key == "graph" then
				--createDebugMessage("key = "..key.." Value = "..value)
				--createDebugMessage("operatorIdentifier = "..operatorIdentifier)
				if value == operatorIdentifier then
					-- Ok ele usou um nome de operador valido
					validOperator = true	
					operatorOfNode = value
					break
				end
			end			
		end
		
		if validOperator then
			break
		end
	end
	
	
	if not validOperator then
		--"verifyGraphNodeOperator must recive a operatorIdentifier defined in operators table of the ConstantsForSequent.lua. "	
		return nil
	end
	
	-- Verifica se é um sequent
	local idPart = string.sub(node:getLabel(), 1, string.len(operatorIdentifier))		
	local numberPart = string.sub(node:getLabel(), string.len(operatorIdentifier)+1)		
	
	--createDebugMessage("idPart = "..idPart)
	--createDebugMessage("numberPart = "..numberPart)
	--createDebugMessage("node:getLabel() = "..node:getLabel())
	
	
	if tonumber(numberPart) ~= nil and idPart == operatorIdentifier then 
		createDebugMessage("RETORNOU TRUE!")
		return operatorOfNode
	else
		return nil
	end
end

--- Expand a operator in a sequent.
-- For a especific graph and a node of that graph, this functions expands the node if that node is an operator.
-- The operator node is only expanded if a sequent node were previusly selected.
-- @param graph The graph that contains the target node.
-- @param targetNode The node that you want to expand.
function LogicModule.expandNode( graph, targetNode )
	assert( getmetatable(targetNode) == Node_Metatable , "expandNode expects a Node") -- Garantir que é um vertice
	createDebugMessage("expandNode foi chamada")
	
	if verifyGraphNodeOperator(targetNode, opSeq.graph) ~= nil then
		GoalSequentNode = targetNode
		createDebugMessage("Sequente escolhido! = "..targetNode:getLabel()..", clique em um operador ou em qualquer lugar para cancelar a escolha do sequente.")
		return nil -- significa que nao alterei o grafo, só para a app grafica nao ter que redesenhar
	end

	if GoalSequentNode == nil then
		createDebugMessage("GoalSequentNode = nil, clique no sequente primeiro.")
		return nil
	end

	createDebugMessage("GoalSequentNode esta setado! = "..GoalSequentNode:getLabel())
	createDebugMessage("Vamos ver se vc clicou em um operador.")
	
	-- Verificar se o targetNode é um operador
	local newGraph = nil
	
	if verifyGraphNodeOperator(targetNode, opAnd.graph) ~= nil then		
		newGraph = expandNodeAnd(graph, targetNode)
	elseif verifyGraphNodeOperator(targetNode, opOr.graph) ~= nil then
		newGraph = expandNodeOr(graph, targetNode)
	elseif verifyGraphNodeOperator(targetNode, opImp.graph) ~= nil then
		newGraph = expandNodeImp(graph, targetNode)
	elseif verifyGraphNodeOperator(targetNode, opNot.graph) ~= nil then	
		createDebugMessage("Eh o operador: "..targetNode:getLabel())
		newGraph = expandNodeNot(graph, targetNode)
	end
	
	if newGraph ~= nil then
		GoalSequentNode = nil -- Ja expandiu, agora escolhe um sequente de novo.
		createDebugMessage("Atualizou grafo!")
		return newGraph
	else
		-- Nao foi um operador, ele clicou fora para cancelar o sequente escolhido
		createDebugMessage("Sequente escolhido cancelado. Por favor escolha um sequente.")
		GoalSequentNode = nil			
		return nil -- significa que nao alterei o grafo, só para a app grafica nao ter que redesenhar
	end
end

