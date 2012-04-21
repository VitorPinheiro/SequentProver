--[[

	Graph Module

	Here is defined the graph estructure.

	Author: Vitor

]]--

dofile '..\\graphmodule\\Node.lua'
dofile '..\\graphmodule\\Edge.lua'

--[[ 
	Defining the Graph
]]--
Graph = {}

--[[ 
	Defining the Metatable
]]--
Graph_Metatable = { __index = Graph }

--[[ 
	Class constructor
]]--
function Graph:new ()
	return setmetatable( {}, Graph_Metatable )
end

-- Private functions
--[[	
	This function is used only in the Graph module
	Return true if the label of the newElement do not exist in any of the objects within the listOfObj and false otherwise.
	Param:
		listOfObj: A list of objects that are nodes or edges.
		newElement: An object that is a edge or a node.
]]--
local function verifyLabel(listOfObj, newElement)
	assert( (getmetatable(newElement) == Edge_Metatable) or (getmetatable(newElement) == Node_Metatable), "verifyLabel expects a edge or a node.")
	for i=1, #listOfObj do
		if listOfObj[i]:getLabel() == newElement:getLabel() then
			return false
		end
	end
	return true
end

-- Public functions
--[[ 
	Adds a list of nodes in the graph
	Param:
		nodes: Uma lista contendo todos os vertices que serão adicionados
]]--
function Graph:addNodes( nodes )

	if self.nodes == nil then
		self.nodes = {}
	end

	-- Adiciono os vertices na minha lista de vertices
	posInicial = #self.nodes
	for i=1, #nodes do
		assert( getmetatable(nodes[i]) == Node_Metatable , "Graph:addNodes expects a Node")
		assert( verifyLabel(self.nodes, nodes[i]), "Graph:addNodes: All labels of the nodes must be unique. The label \""..nodes[i]:getLabel().."\" already exists")
		self.nodes[posInicial + i] = nodes[i]
	end

end

--[[ 
	Add a node in the graph
	Param:
		node: O vertice que será adicionado
]]--
function Graph:addNode( node )

	assert( getmetatable(node) == Node_Metatable , "Graph:addNode expects a Node") -- Garantir que é um vertice
	
	if self.nodes == nil then
		self.nodes = {}
	end
	
	assert( verifyLabel(self.nodes, node), "Graph:addNode: All labels of the nodes must be unique.")
	
	self.nodes[#self.nodes+1] = node
end

--[[ 
	Return the list of the nodes.
]]--
function Graph:getNodes()
	return self.nodes
end

--[[ 
	Return the node with the specific label.
	Param:
		label: O string contendo o label do vertice desejado
]]--
function Graph:getNode(label)	
	assert( type(label) == "string", "Graph:getNode expects a string" )
	
	if self.nodes == nil then
		return nil
	end
	
	for i=1, #self.nodes do	
		if self.nodes[i].getLabel() == label then
			return self.nodes[i]
		end
	end
end

--[[
	Return the list of the edges.
]]--
function Graph:getEdges()
	return self.edges
end

--[[
	Return the edge with a specific label
	Param:
		label: A string with the label of the desired edge
]]--
function Graph:getEdge(label)
	assert( type(label) == "string", "Graph:getEdge expects a string" )
	
	if self.edges == nil then
		return nil
	end
	
	for i=1, #self.edges do	
		if self.edges[i]:getLabel() == label then
			return self.edges[i]
		end
	end
end

--[[
	Adds a list of edges in the graph.
	Param:
		edges: A list of edges
]]--
function Graph:addEdges(edges)

	if self.edges == nil then
		self.edges = {}
	end
	
	posInicial = #self.edges
	for i=1, #edges do
		assert( getmetatable(edges[i]) == Edge_Metatable , "Graph:addEdges expects a edge")
		self.edges[posInicial + i] = edges[i]
	end
end

--[[
	Add an edge in the graph.
	Param:
		edge: An edge
]]--
function Graph:addEdge(edge)
	assert( getmetatable(edge) == Edge_Metatable , "Graph:addEdge expects a edge")
	
	if self.edges == nil then
		self.edges = {}
	end
	self.edges[#self.edges +1] = edge
end