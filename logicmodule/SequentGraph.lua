--[[

	Sequent Graph Module
	Extends Node and Edge modules.

	Here is defined the node estructure of the Sequent Graph.

	Author: Vitor

]]--

dofile "..\\logicmodule\\ConstantsForSequent.lua"
dofile '..\\graphmodule\\Graph.lua'

-- Contadores dos operadores
edgeCount = 0
andNodeCount = 0
notNodeCount = 0
orNodeCount  = 0
implyNodeCount = 0
sequentNodeCount = 0 -- o label esquerda("esq") e direita("dir") do sequente vai ser o mesmo contador
esqNodeCount = 0
dirNodeCount = 0

--[[ 
	Defining the SequentNode, extends Node
]]--
SequentNode = {}

function SequentNode:new(labelNode) -- testar esse override

	if labelNode == opSeq.graph then
		labelNode = labelNode .. sequentNodeCount		
		sequentNodeCount = sequentNodeCount + 1
	elseif labelNode == opNot.graph then
		labelNode = labelNode .. notNodeCount
		notNodeCount = notNodeCount + 1
	elseif labelNode == opOr.graph then
		labelNode = labelNode .. orNodeCount
		orNodeCount = orNodeCount + 1
	elseif labelNode == opAnd.graph then
		labelNode = labelNode .. andNodeCount
		andNodeCount = andNodeCount + 1
	elseif labelNode == opImp.graph then
		labelNode = labelNode .. implyNodeCount
		implyNodeCount = implyNodeCount + 1
	elseif labelNode == lblNodeEsq then
		labelNode = labelNode .. esqNodeCount
		esqNodeCount = esqNodeCount + 1
	elseif labelNode == lblNodeDir then		
		labelNode = labelNode .. dirNodeCount
		dirNodeCount = dirNodeCount + 1
	end
		
	return Node:new(labelNode)

end



--[[ 
	Defining the SequentEdge, extends Edge
]]--

SequentEdge = {}-- = Edge:new("SequentEdgeClass", )

--[[
	If label is equals to "", then a number is created acording to the origin node edgeCount field.	
]]--
function SequentEdge:new(label, origem, destino)

	local edgeCount = nil
	
	if label ~= '' then
		return Edge:new(label, origem, destino)
	end
	
	-- é a string vazia
	local labelNodeOrigin = string.sub(origem:getLabel(), 2)		
	
	if tonumber(labelNodeOrigin) == nil then
		-- "SequentEdge:new só gera numeros para arestas que tenham origem em vertices com label: "..lblNodeEsq.."+numero ou "..lblNodeDir.."+numero "
		return Edge:new(label, origem, destino)
	end
	
	edgeCount = origem:getInformation("edgeCount")
	
	if edgeCount == nil then		
		origem:setInformation("edgeCount", 0)
		edgeCount = 0
	else
		-- incremento o edgeCount, ja tinha uma aresta sem label saindo desse vertice
		edgeCount = edgeCount + 1
		origem:setInformation("edgeCount", edgeCount)
	end
	
	label = label .. edgeCount

	createDebugMessage("AQUI!Edge "..label)
	return Edge:new(label, origem, destino)

end

