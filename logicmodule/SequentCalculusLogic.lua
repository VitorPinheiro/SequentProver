--[[

	Sequent Calculus Module

	Author: Vitor

]]--

require 'SequentGoalsLogic'

-- Junta as funções que este modulo oferece como públicas.
LogicModule = {}

-- Sequente alvo da operação
local GoalSequentNode = nil

-- Lista de goals do grafo
-- nodeSeq:getLabel() é o id do sequent node. O sequente deejado estara indexado pelo id dele nesta lista.
-- para pegar os goals do sequentNode por exemplo é só fazer: goalsList[sequentNode:getLabel()]
local goalsList = {}

-------------------------------------------- Private functions --------------------------------------------

local function verifySideOfSequent(originNode, targetNode)
	-- VE SE O ORIGINNODE TEM ARESTA PRO TARGETNODE.
	-- SE NAO TIVER EH PQ NAO TA EM EVIDENCIA EM NENHUM LADO DO SEQUENTE E NAO PODE SER EXPANDIDO
	
	edgesOut = originNode:getEdgesOut()
	
	if edgesOut == nil then
		return false
	end
	
	local retValues = {}
	
	for i=1, #edgesOut do
		if edgesOut[i]:getDestino():getLabel() == targetNode:getLabel() then
			return true
		else
			return false
		end
	end
	
	return false

end

--- Cria um sequente novo para poder fazer uma dedução
-- Cria um SeqX + um nó eX + um nó dX e aponta o eX e o dX para os mesmo lugares que o sequente anterior
-- apontava.
local function createNewSequent(graph, sequentNode)

	local copiedSequent = nil

	local listNewNodes = {} -- todos os vertices que vou adicionar no grafo
	local listNewEdges = {} -- todas as arestas que vou adicionar no grafo
	
	nodeSeqNew = SequentNode:new(sequentNode:getInformation("type"))
	listNewNodes[#listNewNodes+1] = nodeSeqNew
	

	local newNodeLeft = SequentNode:new(lblNodeEsq)
	local newNodeDir = SequentNode:new(lblNodeDir)
	listNewNodes[#listNewNodes+1] = newNodeLeft
	listNewNodes[#listNewNodes+1] = newNodeDir

	local newEdgeLeft = SequentEdge:new(lblEdgeEsq, nodeSeqNew, newNodeLeft)		
	local newEdgeRight = SequentEdge:new(lblEdgeDir, nodeSeqNew, newNodeDir)
	listNewEdges[#listNewEdges+1] = newEdgeLeft
	listNewEdges[#listNewEdges+1] = newEdgeRight
	
	local nodeEsq = sequentNode:getEdgeOut(lblEdgeEsq):getDestino()
	local nodeDir = sequentNode:getEdgeOut(lblEdgeDir):getDestino()
	
	esqEdgesOut = nodeEsq:getEdgesOut()
	for i=1, #esqEdgesOut do
		local newEdge = SequentEdge:new(esqEdgesOut[i]:getLabel(), newNodeLeft, esqEdgesOut[i]:getDestino())
		listNewEdges[#listNewEdges+1] = newEdge
	end
		
	dirEdgesOut = nodeDir:getEdgesOut()
	for i=1, #dirEdgesOut do
		local newEdge = SequentEdge:new(dirEdgesOut[i]:getLabel(), newNodeDir, dirEdgesOut[i]:getDestino())
		listNewEdges[#listNewEdges+1] = newEdge
	end	

	-- adiciono no grafo principal	
	local deductionEdge = SequentEdge:new(lblEdgeDeducao, sequentNode, nodeSeqNew)
	listNewEdges[#listNewEdges+1] = deductionEdge
	
	graph:addNodes(listNewNodes)
	graph:addEdges(listNewEdges)	
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
	
	
	--goalsList[sequentNode:getLabel()]
	-- Depois vc pega o lado direto pelos goals do sequentNode
	
	
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
				return leftSide
			end
		end
		
		if seqEdgesOutList[i]:getLabel() == lblEdgeDir then
			-- verifica se ta na direita, pq pode nao estar em nenhum dos lados. (Usuario clicou em um operador que nao faz parte do sequente que ele tinha clicado)
			createDebugMessage("Verificando direita sequente")
			if verifySideOfSequent(seqEdgesOutList[i]:getDestino(), operatorNode) then
				return rightSide
			end
		end		
	end
	
	return nil 
end

--- Expand the not operator
-- @param graph The graph that will be expanded
-- @param sequentNode The sequente that the nodeOpNot is part
-- @param nodeOpNot The operator that will be expanded
local function expandNodeNot (graph, sequentNode, nodeOpNot)
	createDebugMessage("expandNodeNot foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpNot:getLabel())
		
	--- Enviar todo o grafo apontado pelo not para o outro lado do sequente GoalSequentNode.	
	-- 1) Verificar o lado que o not esta.
	local sideOfOperator = verifySideOfOperator(sequentNode, nodeOpNot)
	
	local lblEdge1
	local lblEdge2
	
	if sideOfOperator == leftSide then
		createDebugMessage(nodeOpNot:getLabel().." is in the left side of the ".. sequentNode:getLabel())
		lblEdge1 = lblEdgeEsq
		lblEdge2 = lblEdgeDir
	elseif sideOfOperator == rightSide then
		createDebugMessage(nodeOpNot:getLabel().." is in the right side of the ".. sequentNode:getLabel())
		lblEdge1 = lblEdgeDir
		lblEdge2 = lblEdgeEsq	
	elseif sideOfOperator == nil then
		createDebugMessage("sideOfOperator is nil")
		return nil -- nao atualizarei nada
	end
	
	createNewSequent(graph, sequentNode)
	
	local newSequentNode = sequentNode:getEdgeOut(lblEdgeDeducao):getDestino()
	
	-- 1) Verificar se esse operador eh alcancavel pelo no dX. se nao for eh pq tem um operador mais acima dele,
	-- e o usuario nao pode expandir.
	local node1 = newSequentNode:getEdgeOut(lblEdge1):getDestino()
	
	local edgesOut = node1:getEdgesOut()
	local isNodeOpNotFound = false
	local edgeToRemove = nil
	for i=1, #edgesOut do
		
		if edgesOut[i]:getDestino():getLabel() == nodeOpNot:getLabel() then
			isNodeOpNotFound = true
			edgeToRemove = edgesOut[i] --graph:removeEdge(edgesOut[i]) -- ja tiro a aresta
			break
		end
	end
	
	if not isNodeOpNotFound then
		-- o operador escolhido esta dentro de um outro operador e por isso nao pode ser expandido
		local nodeEsq = newSequentNode:getEdgeOut(lblEdgeEsq):getDestino()
		local nodeDir = newSequentNode:getEdgeOut(lblEdgeDir):getDestino()
		
		createDebugMessage("WARNING: Caiu em uma area nao testada!!! O grafo tem vertices a mais ou a menos errados??")
		
		graph:removeNode(nodeEsq)
		graph:removeNode(nodeDir)
		graph:removeNode(newSequentNode)
		return nil -- nao atualizarei nada			
	end		
	
	-- 2) Ir na direita do sequente no vertice "dX" e adicionar uma aresta comecando dele para o operador nodeOpNot
	local node2 = newSequentNode:getEdgeOut(lblEdge2):getDestino()
	
	local edges = node2:getEdgesOut()
	local numEdges = 0
	if edges ~= nil then		
		numEdges = #edges
	end
	
	newEdge = SequentEdge:new(""..numEdges, node2, nodeOpNot:getEdgeOut(lblCarnality..lblUnary):getDestino()) -- liguei do lado novo
	graph:addEdge(newEdge)
	
	graph:removeEdge(edgeToRemove)
	--graph:removeNode(nodeOpNot) -- deleta o vertice e as arestas que chegam nele e que saem	
	
	goalsList[newSequentNode:getLabel()] = GoalsLogic.assembleGoalList(newSequentNode)
	return graph
end

local function expandNodeAndRight(graph, sequentNode, nodeOpAnd)

	createNewSequent(graph, sequentNode)
	createNewSequent(graph, sequentNode)
	
	local newSequents = {}
	
	local edgesOutSeq = sequentNode:getEdgesOut()		
	
	j=1
	for i=1, #edgesOutSeq do
		if edgesOutSeq[i]:getLabel() == lblEdgeDeducao then
			newSequents[j] = edgesOutSeq[i]:getDestino()			
			j = j + 1
			if #newSequents == 2 then
				break
			end
		end
	end
	
	assert( #newSequents == 2, "expandNodeAndRight: Must have two new sequents to perform and right expansion. There is only "..#newSequents.." new sequents." )
	
	local nodeRight1 = newSequents[1]:getEdgeOut(lblEdgeDir):getDestino()
	local nodeRight2 = newSequents[2]:getEdgeOut(lblEdgeDir):getDestino()
	
	-- Remover aresta que sai de um dos sequentes
	local edgesOutRightTam = #(nodeRight1:getEdgesOut()) 	
	local edgesOutRightList = nodeRight1:getEdgesOut()
	for i=1, edgesOutRightTam do
		if edgesOutRightList[i]:getDestino():getLabel() == nodeOpAnd:getLabel() then
			graph:removeEdge(edgesOutRightList[i])									
			break
		end				
	end

	-- Remover aresta que sai do outro sequente
	edgesOutRightTam = #(nodeRight2:getEdgesOut()) 	
	edgesOutRightList = nodeRight2:getEdgesOut()
	for i=1, edgesOutRightTam do
		if edgesOutRightList[i]:getDestino():getLabel() == nodeOpAnd:getLabel() then
			graph:removeEdge(edgesOutRightList[i])									
			break
		end				
	end	
	
	-- Inserir lados do and em cada um dos sequentes novos
	local nodeOpEdges = nodeOpAnd:getEdgesOut()
			
	assert( #nodeOpEdges == 2, "expandNodeAndRight: Operator and do not have two edges." )
				
	local numEdge = #(nodeRight1:getEdgesOut())
	local newEdge1 = SequentEdge:new(""..numEdge, nodeRight1, nodeOpEdges[1]:getDestino())
	numEdge = #(nodeRight2:getEdgesOut())
	local newEdge2 = SequentEdge:new(""..numEdge, nodeRight2, nodeOpEdges[2]:getDestino())
	graph:addEdge(newEdge1)
	graph:addEdge(newEdge2)
	
	goalsList[newSequents[1]:getLabel()] = GoalsLogic.assembleGoalList(newSequents[2])
	return graph

end

local function expandNodeAndLeft(graph, sequentNode, nodeOpAnd)
	-- vira virgula
	createNewSequent(graph, sequentNode)
	
	local newSequentNode = sequentNode:getEdgeOut(lblEdgeDeducao):getDestino()
	
	local nodeLeft = newSequentNode:getEdgeOut(lblEdgeEsq):getDestino()
	
	local edgesOutLeftTam = #(nodeLeft:getEdgesOut()) 
	
	local edgesOutLeftList = nodeLeft:getEdgesOut()
	for i=1, edgesOutLeftTam do
		if edgesOutLeftList[i]:getDestino():getLabel() == nodeOpAnd:getLabel() then
			graph:removeEdge(edgesOutLeftList[i])
			
			local nodeOpEdges = nodeOpAnd:getEdgesOut()
			for j=1, #nodeOpEdges do
				local numEdge = #(nodeLeft:getEdgesOut())
				local newEdge1 = SequentEdge:new(""..numEdge, nodeLeft, nodeOpEdges[j]:getDestino())
				graph:addEdge(newEdge1)
			end
			
			break
		end				
	end
	
	goalsList[newSequentNode:getLabel()] = GoalsLogic.assembleGoalList(newSequentNode)
	return graph
	
end

local function expandNodeAnd(graph, sequentNode, nodeOpAnd)
	createDebugMessage("expandNodeAnd foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpAnd:getLabel())

	local sideOfOperator = verifySideOfOperator(sequentNode, nodeOpAnd)	
	
	if sideOfOperator == leftSide then
		createDebugMessage(nodeOpAnd:getLabel().." is in the left side of the ".. sequentNode:getLabel())
		expandNodeAndLeft(graph, sequentNode, nodeOpAnd)
	elseif sideOfOperator == rightSide then
		createDebugMessage(nodeOpAnd:getLabel().." is in the right side of the ".. sequentNode:getLabel())
		expandNodeAndRight(graph, sequentNode, nodeOpAnd)
	elseif sideOfOperator == nil then
		createDebugMessage("sideOfOperator is nil")
		return nil -- nao atualizarei nada
	end	
	
	
	return graph
end

local function expandNodeOrRight(graph, sequentNode, nodeOpOr)
	-- vira virgula
	createNewSequent(graph, sequentNode)
	
	local newSequentNode = sequentNode:getEdgeOut(lblEdgeDeducao):getDestino()
	
	local nodeRight = newSequentNode:getEdgeOut(lblEdgeDir):getDestino()
	
	local edgesOutRightTam = #(nodeRight:getEdgesOut()) 
	
	local edgesOutRightList = nodeRight:getEdgesOut()
	for i=1, edgesOutRightTam do
		if edgesOutRightList[i]:getDestino():getLabel() == nodeOpOr:getLabel() then
			graph:removeEdge(edgesOutRightList[i])
			
			local nodeOpEdges = nodeOpOr:getEdgesOut()
			for j=1, #nodeOpEdges do
				local numEdge = #(nodeRight:getEdgesOut())
				local newEdge1 = SequentEdge:new(""..numEdge, nodeRight, nodeOpEdges[j]:getDestino())
				graph:addEdge(newEdge1)
			end
			
			break
		end				
	end

	goalsList[newSequentNode:getLabel()] = GoalsLogic.assembleGoalList(newSequentNode)
	return graph
end

local function expandNodeOrLeft(graph, sequentNode, nodeOpOr)

	createNewSequent(graph, sequentNode)
	createNewSequent(graph, sequentNode)
	
	local newSequents = {}
	
	local edgesOutSeq = sequentNode:getEdgesOut()		
	
	j=1
	for i=1, #edgesOutSeq do
		if edgesOutSeq[i]:getLabel() == lblEdgeDeducao then
			newSequents[j] = edgesOutSeq[i]:getDestino()			
			j = j + 1
			if #newSequents == 2 then
				break
			end
		end
	end
	
	assert( #newSequents == 2, "expandNodeOrLeft: Must have two new sequents to perform the expansion. There is only "..#newSequents.." new sequents." )
	
	local nodeLeft1 = newSequents[1]:getEdgeOut(lblEdgeEsq):getDestino()
	local nodeLeft2 = newSequents[2]:getEdgeOut(lblEdgeEsq):getDestino()
	
	-- Remover aresta que sai de um dos sequentes
	local edgesOutLeftTam = #(nodeLeft1:getEdgesOut()) 	
	local edgesOutLeftList = nodeLeft1:getEdgesOut()
	for i=1, edgesOutLeftTam do
		if edgesOutLeftList[i]:getDestino():getLabel() == nodeOpOr:getLabel() then
			graph:removeEdge(edgesOutLeftList[i])									
			break
		end				
	end

	-- Remover aresta que sai do outro sequente
	edgesOutLeftTam = #(nodeLeft2:getEdgesOut()) 	
	edgesOutLeftList = nodeLeft2:getEdgesOut()
	for i=1, edgesOutLeftTam do
		if edgesOutLeftList[i]:getDestino():getLabel() == nodeOpOr:getLabel() then
			graph:removeEdge(edgesOutLeftList[i])									
			break
		end				
	end	
	
	-- Inserir lados do or em cada um dos sequentes novos
	local nodeOpEdges = nodeOpOr:getEdgesOut()
			
	assert( #nodeOpEdges == 2, "expandNodeOrLeft: Operator or do not have two edges." )
				
	local numEdge = #(nodeLeft1:getEdgesOut())
	local newEdge1 = SequentEdge:new(""..numEdge, nodeLeft1, nodeOpEdges[1]:getDestino())
	numEdge = #(nodeLeft2:getEdgesOut())
	local newEdge2 = SequentEdge:new(""..numEdge, nodeLeft2, nodeOpEdges[2]:getDestino())
	graph:addEdge(newEdge1)
	graph:addEdge(newEdge2)
	
	goalsList[newSequents[1]:getLabel()] = GoalsLogic.assembleGoalList(newSequents[1])
	goalsList[newSequents[2]:getLabel()] = GoalsLogic.assembleGoalList(newSequents[2])
	return graph

end

local function expandNodeOr(graph, sequentNode, nodeOpOr)
	createDebugMessage("expandNodeOr foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpOr:getLabel())

	local sideOfOperator = verifySideOfOperator(sequentNode, nodeOpOr)	
	
	if sideOfOperator == leftSide then
		createDebugMessage(nodeOpOr:getLabel().." is in the left side of the ".. sequentNode:getLabel())
		expandNodeOrLeft(graph, sequentNode, nodeOpOr)
	elseif sideOfOperator == rightSide then
		createDebugMessage(nodeOpOr:getLabel().." is in the right side of the ".. sequentNode:getLabel())
		expandNodeOrRight(graph, sequentNode, nodeOpOr)
	elseif sideOfOperator == nil then
		createDebugMessage("sideOfOperator is nil")
		return nil -- nao atualizarei nada
	end		
	
	return graph
end

local function expandNodeImpLeft(graph, sequentNode, nodeOpImp)
	
	createNewSequent(graph, sequentNode)
	createNewSequent(graph, sequentNode)
	
	local newSequents = {}
	
	local edgesOutSeq = sequentNode:getEdgesOut()		
	
	j=1
	for i=1, #edgesOutSeq do
		if edgesOutSeq[i]:getLabel() == lblEdgeDeducao then
			newSequents[j] = edgesOutSeq[i]:getDestino()			
			j = j + 1
			if #newSequents == 2 then
				break
			end
		end
	end
	
	assert( #newSequents == 2, "expandNodeImpLeft: Must have two new sequents to perform the expansion. There is only "..#newSequents.." new sequents." )
	
	local nodeLeft1 = newSequents[1]:getEdgeOut(lblEdgeEsq):getDestino()
	local nodeRight2 = newSequents[2]:getEdgeOut(lblEdgeDir):getDestino()
	
	-- Remover aresta que sai de um dos sequentes
	local edgesOutLeftTam = #(nodeLeft1:getEdgesOut()) 	
	local edgesOutLeftList = nodeLeft1:getEdgesOut()
	for i=1, edgesOutLeftTam do
		if edgesOutLeftList[i]:getDestino():getLabel() == nodeOpImp:getLabel() then
			graph:removeEdge(edgesOutLeftList[i])									
			break
		end				
	end

	-- Remover aresta que sai do outro sequente (o 2)
	edgesOutLeftTam = #(nodeRight2:getEdgesOut()) 	
	edgesOutLeftList = nodeRight2:getEdgesOut()
	for i=1, edgesOutLeftTam do
		graph:removeEdge(edgesOutLeftList[i])									
	end	
	
	-- Retirar a implicacao da esquerda do sequente2
	local nodeLeft2 = newSequents[2]:getEdgeOut(lblEdgeEsq):getDestino()
	edgesOutLeftTam = #(nodeLeft2:getEdgesOut()) 	
	edgesOutLeftList = nodeLeft2:getEdgesOut()
	for i=1, edgesOutLeftTam do
		if edgesOutLeftList[i]:getDestino():getLabel() == nodeOpImp:getLabel() then
			graph:removeEdge(edgesOutLeftList[i])									
			break
		end				
	end	
	
	-- Inserir lados do or em cada um dos sequentes novos
	local nodeRightSideOfImply = nodeOpImp:getEdgeOut(lblEdgeDir):getDestino()
	local nodeLeftSideOfImply = nodeOpImp:getEdgeOut(lblEdgeEsq):getDestino()
				
	local numEdge = #(nodeLeft1:getEdgesOut())
	local newEdge1 = SequentEdge:new(""..numEdge, nodeLeft1, nodeRightSideOfImply)
	numEdge = #(nodeRight2:getEdgesOut())
	local newEdge2 = SequentEdge:new(""..numEdge, nodeRight2, nodeLeftSideOfImply)
	graph:addEdge(newEdge1)
	graph:addEdge(newEdge2)
	
	goalsList[newSequents[1]:getLabel()] = GoalsLogic.assembleGoalList(newSequents[1])
	goalsList[newSequents[2]:getLabel()] = GoalsLogic.assembleGoalList(newSequents[2])
	
	return graph
	
end

local function expandNodeImpRight(graph, sequentNode, nodeOpImp)
	-- Só passar a parte esquerda da implicacao pra esquerda do sequente.
	
	createNewSequent(graph, sequentNode)
	
	local newSequentNode = sequentNode:getEdgeOut(lblEdgeDeducao):getDestino()
	
	local nodeRight = newSequentNode:getEdgeOut(lblEdgeDir):getDestino()
	local nodeLeft = newSequentNode:getEdgeOut(lblEdgeEsq):getDestino()
	
	local listEdgesOut = nodeRight:getEdgesOut()
	for i=1, #listEdgesOut do
		if listEdgesOut[i]:getDestino():getLabel() == nodeOpImp:getLabel() then
			graph:removeEdge(listEdgesOut[i]) -- tiro a aresta que liga a direita com a implicacao
			break
		end
	end
	
	local edgesOutLeft = #(nodeLeft:getEdgesOut()) 
	local edgesOutRight = #(nodeRight:getEdgesOut()) 
	
	local newEdge1 = SequentEdge:new(""..edgesOutLeft, nodeLeft, nodeOpImp:getEdgeOut(lblEdgeEsq):getDestino()) -- jogo a parte da esquerda da implicacao pra esquerda do sequente	
	local newEdge2 = SequentEdge:new(""..edgesOutRight, nodeRight, nodeOpImp:getEdgeOut(lblEdgeDir):getDestino())
	
	graph:addEdge(newEdge1)
	graph:addEdge(newEdge2)		
	
	goalsList[newSequentNode:getLabel()] = GoalsLogic.assembleGoalList(newSequentNode)
	
	return graph
	
end

local function expandNodeImp(graph, sequentNode, nodeOpImp)
	createDebugMessage("expandNodeImp foi chamado para o sequente: "..sequentNode:getLabel().. " e para o operador: "..nodeOpImp:getLabel())
	
	local sideOfOperator = verifySideOfOperator(sequentNode, nodeOpImp)	
	
	if sideOfOperator == leftSide then
		createDebugMessage(nodeOpImp:getLabel().." is in the left side of the ".. sequentNode:getLabel())
		return expandNodeImpLeft(graph, sequentNode, nodeOpImp)
	elseif sideOfOperator == rightSide then
		createDebugMessage(nodeOpImp:getLabel().." is in the right side of the ".. sequentNode:getLabel())
		return expandNodeImpRight(graph, sequentNode, nodeOpImp)
	elseif sideOfOperator == nil then
		createDebugMessage("sideOfOperator is nil")
		return nil -- nao atualizarei nada
	end		
	
	return graph
end

local function createGraphImplyLeft()
	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)
		
	NodeNot0 = SequentNode:new(opNot.graph)
	NodeF = SequentNode:new('F')
	NodeImp0 = SequentNode:new(opImp.graph)
	NodeA = SequentNode:new('A')

	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeDir, NodeNot0)
	Edge5 = SequentEdge:new('', NodeEsq, NodeImp0)
	Edge7 = SequentEdge:new(lblCarnality..lblUnary, NodeNot0, NodeF)
	Edge8 = SequentEdge:new(lblEdgeEsq , NodeImp0, NodeF)
	Edge9 = SequentEdge:new(lblEdgeDir , NodeImp0, NodeA)
	
	-- ~F SEQ (F -> A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeNot0, NodeImp0, NodeF, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge7, Edge8, Edge9}	
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph
end

local function createGraphImplyRight()

	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)
	
	
	NodeNot0 = SequentNode:new(opNot.graph)
	--NodeNot1 = SequentNode:new(opNot.graph)
	NodeF = SequentNode:new('F')
	--NodeAnd0 = SequentNode:new(opAnd.graph) -- ~F SEQ ~(F ^ A)
	NodeImp0 = SequentNode:new(opImp.graph)
	NodeA = SequentNode:new('A') -- ~F SEQ ~(F ^ A)

	
	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeEsq, NodeNot0)
	Edge5 = SequentEdge:new('', NodeDir, NodeImp0)
	Edge7 = SequentEdge:new(lblCarnality..lblUnary, NodeNot0, NodeF)
	Edge8 = SequentEdge:new(lblEdgeEsq , NodeImp0, NodeF)
	Edge9 = SequentEdge:new(lblEdgeDir , NodeImp0, NodeA)
	
	-- ~F SEQ (F -> A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeNot0, NodeImp0, NodeF, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge7, Edge8, Edge9}	
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph
end

local function createNotGraph()

	local SequentGraph = Graph:new ()
		
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
	Edge4 = SequentEdge:new('', NodeEsq, NodeNot0)
	Edge5 = SequentEdge:new('', NodeDir, NodeNot1)
	Edge6 = SequentEdge:new(lblCarnality..lblUnary, NodeNot0, NodeF) -- ~F SEQ ~F 
	Edge7 = SequentEdge:new(lblCarnality..lblUnary, NodeNot1, NodeF)
	
	-- ~F SEQ ~F
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeNot0, NodeNot1, NodeF}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7}
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph	

end

local function createOrGraphRight()

	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)

	NodeF = SequentNode:new('F')
	NodeB = SequentNode:new('B')
	NodeOr0 = SequentNode:new(opOr.graph) 
	NodeA = SequentNode:new('A') 

	
	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeEsq, NodeF)
	Edge5 = SequentEdge:new('', NodeDir, NodeOr0)	
	Edge6 = SequentEdge:new(lblCarnality..lblBinary, NodeOr0, NodeB)
	Edge7 = SequentEdge:new(lblCarnality..lblBinary, NodeOr0, NodeA) 

	-- F SEQ (B ^ A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeB, NodeF, NodeOr0, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7}
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph
end

local function createOrGraphLeft()

	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)

	NodeF = SequentNode:new('F')
	NodeB = SequentNode:new('B')
	NodeOr0 = SequentNode:new(opOr.graph) 
	NodeA = SequentNode:new('A') 

	
	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeDir, NodeF)
	Edge5 = SequentEdge:new('', NodeEsq, NodeOr0)	
	Edge6 = SequentEdge:new(lblCarnality..lblBinary, NodeOr0, NodeB)
	Edge7 = SequentEdge:new(lblCarnality..lblBinary, NodeOr0, NodeA) 

	-- F SEQ (B ^ A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeB, NodeF, NodeOr0, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7}
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph
	
end

local function createAndGraphLeft()

	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)

	NodeF = SequentNode:new('F')
	NodeB = SequentNode:new('B')
	NodeAnd0 = SequentNode:new(opAnd.graph) 
	NodeA = SequentNode:new('A') 

	
	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeDir, NodeF)
	Edge5 = SequentEdge:new('', NodeEsq, NodeAnd0)	
	Edge6 = SequentEdge:new(lblCarnality..lblBinary, NodeAnd0, NodeB)
	Edge7 = SequentEdge:new(lblCarnality..lblBinary, NodeAnd0, NodeA) 

	-- F SEQ (B ^ A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeB, NodeF, NodeAnd0, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7}
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph

end

local function createAndGraphRight()

	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)

	NodeF = SequentNode:new('F')
	NodeB = SequentNode:new('B')
	NodeAnd0 = SequentNode:new(opAnd.graph) 
	NodeA = SequentNode:new('A') 

	
	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeEsq, NodeF)
	Edge5 = SequentEdge:new('', NodeDir, NodeAnd0)	
	Edge6 = SequentEdge:new(lblCarnality..lblBinary, NodeAnd0, NodeB)
	Edge7 = SequentEdge:new(lblCarnality..lblBinary, NodeAnd0, NodeA) 

	-- F SEQ (B ^ A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeB, NodeF, NodeAnd0, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7}
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	return SequentGraph

end

local function createNotPlusAndGraphRight()

	local SequentGraph = Graph:new ()
		
	NodeGG = SequentNode:new(lblNodeGG)
	NodeSeq = SequentNode:new(opSeq.graph)
	NodeEsq = SequentNode:new(lblNodeEsq)
	NodeDir = SequentNode:new(lblNodeDir)
	
	
	NodeNot0 = SequentNode:new(opNot.graph)
	NodeNot1 = SequentNode:new(opNot.graph)
	NodeF = SequentNode:new('F')
	NodeAnd0 = SequentNode:new(opAnd.graph) -- ~F SEQ ~(F ^ A)
	NodeA = SequentNode:new('A') -- ~F SEQ ~(F ^ A)

	
	Edge1 = SequentEdge:new(lblEdgeGoal, NodeGG, NodeSeq)
	Edge2 = SequentEdge:new(lblEdgeEsq, NodeSeq, NodeEsq)
	Edge3 = SequentEdge:new(lblEdgeDir, NodeSeq, NodeDir)
	Edge4 = SequentEdge:new('', NodeEsq, NodeNot0)
	Edge5 = SequentEdge:new('', NodeDir, NodeNot1)	
	Edge6 = SequentEdge:new(lblCarnality..lblUnary, NodeNot1, NodeAnd0) -- ~F SEQ ~(F ^ A)
	Edge7 = SequentEdge:new(lblCarnality..lblUnary, NodeNot0, NodeF)
	Edge8 = SequentEdge:new(lblCarnality..lblBinary, NodeAnd0, NodeF) -- ~F SEQ ~(F ^ A)
	Edge9 = SequentEdge:new(lblCarnality..lblBinary, NodeAnd0, NodeA) -- ~F SEQ ~(F ^ A)

	-- ~F SEQ ~(F ^ A)
	nodes = {NodeGG, NodeSeq, NodeEsq, NodeDir, NodeNot0, NodeNot1, NodeF, NodeAnd0, NodeA}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6, Edge7, Edge8, Edge9}
	
	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	
	goalsList[NodeSeq:getLabel()] = GoalsLogic.assembleGoalList(NodeSeq)
	
	return SequentGraph

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
	
	local graph = createNotPlusAndGraphRight() -- ~F => ~(A^F)
	--local graph = createAndGraphLeft()
	--local graph = createAndGraphRight()
	--local graph = createOrGraphLeft()
	--local graph = createOrGraphRight()
	--local graph = createGraphImplyRight()
    --local graph = createGraphImplyLeft()
	--local graph = createNotGraph()
	--local graph = createGraphAndRight()
	
	return graph
end


--- Expand a operator in a sequent.
-- For a especific graph and a node of that graph, this functions expands the node if that node is an operator.
-- The operator node is only expanded if a sequent node were previusly selected.
-- @param graph The graph that contains the target node.
-- @param targetNode The node that you want to expand.
function LogicModule.expandNode( graph, targetNode )
	assert( getmetatable(targetNode) == Node_Metatable , "expandNode expects a Node") -- Garantir que é um vertice
	createDebugMessage("expandNode foi chamada")
	
	local typeOfNode = targetNode:getInformation("type")
	
	if typeOfNode == opSeq.graph then
	--if verifyGraphNodeOperator(targetNode, opSeq.graph) ~= nil then
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
	
	if not GoalSequentNode:getInformation("isExpanded") then
		if typeOfNode == opAnd.graph then				
			newGraph = expandNodeAnd(graph, GoalSequentNode, targetNode)
		elseif typeOfNode == opOr.graph then
			newGraph = expandNodeOr(graph, GoalSequentNode, targetNode)
		elseif typeOfNode == opImp.graph then
			newGraph = expandNodeImp(graph, GoalSequentNode, targetNode)
		elseif typeOfNode == opNot.graph then	
			newGraph = expandNodeNot(graph, GoalSequentNode, targetNode)
		end
	else
		createDebugMessage("O sequente "..GoalSequentNode:getLabel().."ja foi expandido!")
	end
	
	if newGraph ~= nil then
		GoalSequentNode:setInformation("isExpanded", true)
		goalsList[GoalSequentNode:getLabel()]:deleteGoal() -- Ja usei esse sequente, nao guardo a lista de goals dele
		
		GoalSequentNode = nil -- Ja expandiu, agora escolhe um sequente de novo.
		createDebugMessage("Atualizou grafo!")
		
		printGoals() -- WARNING, ONLY FOR DEBUG, DELETE IT - VITOR
		
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

---
-- Vai nos sequentes que ainda nao estao expandidos e faz a expancao até o final
function LogicModule.expandAll(graph)

	local newGraph = graph		
	local isAllExpanded = true
	
	-- loop em todos os sequentes do grafo. se achar um que nao ta expandido, expande.
	for k,goal in pairs(goalsList) do
		local seq = goal:getSequent()
		
		assert( getmetatable(seq) == Node_Metatable , "LogicModule.expandAll expects a Node") -- Garantir que é um vertice
		
		if not seq:getInformation("isExpanded") then
			-- expando
			isAllExpanded = false
			
			local operator = nil
			
			local leftSide = goal:getLeftSide()
			local rightSide = goal:getRightSide()
			if #leftSide ~= 0 then
				assert( getmetatable(leftSide[1]) == Node_Metatable , "LogicModule.expandAll expects a Node. "..leftSide[1]:getLabel())
				operator = leftSide[1]
			elseif #rightSide ~= 0 then
				operator = rightSide[1]
			else
				createDebugMessage("O sequente "..seq:getLabel().." nao tem mais nenhum operador. Nao pode ser mais expandido.")
				isAllExpanded = true -- pq ele nunca vai ser expandido
				seq:setInformation("isExpanded", true)
				break
			end
			
			GoalSequentNode = seq
			newGraph = LogicModule.expandNode(newGraph, operator)
		end
	end
	
	if not isAllExpanded then
		newGraph = LogicModule.expandAll(newGraph)
	end
		
	return newGraph	
end

-- Caso o programador deseje usar esse módulo a partir do retorno da função require.
return LogicModule