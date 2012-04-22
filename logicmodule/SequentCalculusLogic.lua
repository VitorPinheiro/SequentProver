--[[

	Sequent Calculus Module

	Author: Vitor

]]--

dofile "..\\logicmodule\\SequentGraph.lua"

-- Junta as funções que este modulo oferece como publicas.
LogicModule = {}

-- Sequente alvo da operação
local GoalSequentNode = nil

--[[ 
	Defining the Metatable
]]--
--LogicModule_Metatable = { __index = LogicModule }

--setmetatable( {}, LogicModule_Metatable )


-------------------------------------------- Private functions --------------------------------------------

local function verifySideOfSequent(originNode, targetNode)
	-- recursivo até achar o targetNode
	-- se achar retorna true
	-- se nao achar retorna false
	-- chama recursivamente para cada no destino a partir de originNode
	
	if originNode:getLabel() == targetNode:getLabel() then
		createDebugMessage("Achei!!!!")
		return true
	end
	
	edgesOut = originNode:getEdgesOut()
	
	if edgesOut == nil then
		return false
	end
	
	local retValues = {}
	
	for i=1, #edgesOut do
		retValues[i] = verifySideOfSequent(edgesOut[i]:getDestino(), targetNode)
	end
	
	for i=1, #retValues do
		if retValues[i] then
			return true
		end
	end
	
	return false

end


--- Verifica o lado do operador em relaçao ao sequente que ele participa
-- Essa funcao força que o grafo seja orientado e que a orientacao seja correta, se nao ele nao 
-- funcionara corretamente.
-- @param sequentNode The sequent node that the operatorNode participates
-- @param operatorNode The operator node
-- @return Return "Left" if the operatorNode is in the left side of the sequentNode
--         Return "Right" if the operatorNode is in the right side of the sequentNode
--         Return nil if the operatorNode is not part of the sequentNode
local function verifySideOfOperator(sequentNode, operatorNode)
	assert( operatorNode ~= nil , "verifySideOfOperator must be called only if operatorNode is not null.")
	assert( getmetatable(operatorNode) == Node_Metatable , "verifySideOfOperator operatorNode must be a Node")
	assert( sequentNode ~= nil , "verifySideOfOperator must be called only if sequentNode is not null.")	
	assert( getmetatable(sequentNode) == Node_Metatable , "verifySideOfOperator sequentNode must be a Node")
	
	seqEdgesOutList = sequentNode:getEdgesOut()
	if seqEdgesOutList == nil then
		return nil
	end
	
	createDebugMessage("Arestas que saem do "..sequentNode:getLabel()..": ")
	for i=1, #seqEdgesOutList do
		createDebugMessage(seqEdgesOutList[i]:getLabel())
				
		if seqEdgesOutList[i]:getLabel() == lblEdgeEsq then
			-- verifica se ta na esquerda
			createDebugMessage("Verificando esquerda sequente")
			if verifySideOfSequent(seqEdgesOutList[i]:getDestino(), operatorNode) then
				return "Left"
			end
		end
		
		if seqEdgesOutList[i]:getLabel() == lblEdgeDir then
			-- verifica se ta na direita, pq pode nao estar em nenhum dos lados. (Usuario clicou em um operador que nao faz parte do sequente que ele tinha clicado)
			createDebugMessage("Verificando direita sequente")
			if verifySideOfSequent(seqEdgesOutList[i]:getDestino(), operatorNode) then
				return "Right"
			end
		end		
	end
	
	return nil 
end

local function expandNodeNot (graph, sequentNode, nodeOpNot)
	createDebugMessage("expandNodeNot foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpNot:getLabel())
		
	--- Enviar todo o grafo apontado pelo not para o outro lado do sequente GoalSequentNode.	
	-- 1) Verificar o lado que o not esta.
	local sideOfOperator = verifySideOfOperator(sequentNode, nodeOpNot)
	
	if sideOfOperator == "Left" then
		createDebugMessage(nodeOpNot:getLabel().." is in the left side of the ".. sequentNode:getLabel())
		
		-- 1) Verificar se esse operador eh alcancavel pelo no dX. se nao for eh pq tem um operador mais acima dele,
		-- e o usuario nao pode expandir.
		local nodeEsq = sequentNode:getEdgeOut(lblEdgeEsq):getDestino()
		
		local edgesOut = nodeEsq:getEdgesOut()
		local isNodeOpNotFound = false
		for i=1, #edgesOut do
			
			if edgesOut[i]:getDestino():getLabel() == nodeOpNot:getLabel() then
				isNodeOpNotFound = true
				--graph:removeEdge(edgesOut[i]) -- ja tiro a aresta
			end
		end
		
		if not isNodeOpNotFound then
			-- o operador escolhido esta dentro de um outro operador e por isso nao pode ser expandido
			return nil -- nao atualizarei nada			
		end
		
		-- 2) Ir na direita do sequente no vertice "dX" e adicionar uma aresta comecando dele para o operador nodeOpNot
		local nodeDir = sequentNode:getEdgeOut(lblEdgeDir):getDestino()
		
		newEdge = SequentEdge:new("", nodeDir, nodeOpNot:getEdgeOut(lblCarnality..lblUnary):getDestino()) -- liguei do lado novo
		graph:addEdge(newEdge)
		
		graph:removeNode(nodeOpNot) -- deleta o vertice e as arestas que chegam nele e que saem
		
	elseif sideOfOperator == "Right" then
		createDebugMessage(nodeOpNot:getLabel().." is in the right side of the ".. sequentNode:getLabel())
		
		
	elseif sideOfOperator == nil then
		createDebugMessage("sideOfOperator is nil")
		return nil -- nao atualizarei nada
	end
	
	return graph
end

local function expandNodeAnd(graph, sequentNode, nodeOpAnd)
	createDebugMessage("expandNodeAnd foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpAnd:getLabel())
	return graph
end

local function expandNodeOr(graph, sequentNode, nodeOpOr)
	createDebugMessage("expandNodeOr foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpOr:getLabel())
	return graph
end

local function expandNodeImp(graph, sequentNode, nodeOpImp)
	createDebugMessage("expandNodeImp foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpImp:getLabel())
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
		--createDebugMessage("RETORNOU TRUE!")
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
	createDebugMessage("targetNode = "..targetNode:getLabel())
	
	-- Verificar se o targetNode é um operador
	local newGraph = nil
	
	if verifyGraphNodeOperator(targetNode, opAnd.graph) ~= nil then		
		newGraph = expandNodeAnd(graph, GoalSequentNode, targetNode)
	elseif verifyGraphNodeOperator(targetNode, opOr.graph) ~= nil then
		newGraph = expandNodeOr(graph, GoalSequentNode, targetNode)
	elseif verifyGraphNodeOperator(targetNode, opImp.graph) ~= nil then
		newGraph = expandNodeImp(graph, GoalSequentNode, targetNode)
	elseif verifyGraphNodeOperator(targetNode, opNot.graph) ~= nil then	
		createDebugMessage("Eh o operador: "..targetNode:getLabel())
		newGraph = expandNodeNot(graph, GoalSequentNode, targetNode)
	end
	
	if newGraph ~= nil then
		GoalSequentNode = nil -- Ja expandiu, agora escolhe um sequente de novo.
		createDebugMessage("Atualizou grafo!")
		return newGraph
	else
		-- Nao foi um operador, ele clicou fora para cancelar o sequente escolhido
		createDebugMessage("Sequente escolhido cancelado. Por favor escolha um sequente.")
		-- É possivel que ele caia aqui tb se quando ele mandou expandir escolheu um operador que
		-- nao fazia parte do sequente escolhido. Dai entao ele cancela a escolha do sequente.
		GoalSequentNode = nil			
		return nil -- significa que nao alterei o grafo, só para a app grafica nao ter que redesenhar
	end
end

