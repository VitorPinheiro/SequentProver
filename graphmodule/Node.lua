--[[

	Node Module

	Author: Vitor

]]--


--[[
	Defining the Node
]]--
Node = {}

--[[
	Defining the Metatable
]]--
Node_Metatable = { __index = Node }

--[[
	Class Constructor
	The label must not be nil.
	(x,y) can be both nil or both numbers.
	
	Param:
		label: A string with the label of the node, must not be nil.
		x: A number which defines the position of the node in the x axis.
		y: A number which defines the position of the node in the y axis.
]]--
function Node:new (label, x, y)
	assert( type(label) == "string" , "Node:new expects a string." )
	
	local ini = {}
	local xNotNil = false
	local yNotNil = false
	
	if x ~= nil then 
		assert( type(x) == "number" , "Node:new expects a number, x is not a number.")
		xNotNil = true
	end
	
	if y ~= nil then		
		assert( type(y) == "number" , "Node:new expects a number, y is not a number.")
		yNotNil = true
	else
		assert( not xNotNil, "Node:new expects two positions, a number for de x axis and a number for the y axis.")
	end
	
	if xNotNil and yNotNil then
		ini = {label = label, x = x, y = y, info = {}}
	elseif xNotNil then
		ini = {label = label, x = x, info = {}}
	elseif yNotNil then
		ini = {label = label, y = y, info = {}}
	else
		ini = {label = label, info = {}}
	end
	
	return setmetatable( ini, Node_Metatable )
end

--[[
	Defines the label of the node
	Param:
		label: A string with the label of the node
]]--
function Node:setLabel( label )
	assert( type(label) == "string" , "Node:setLabel expects a string.")
	self.label = label
end

--[[ 
	Returns the label of the node
]]--
function Node:getLabel()
	return self.label
end

--[[
	Create a field named "infoName" with the value "infoValue". If the field already exists, the value of it is atualized
	Param:
		infoName: A string or a number containing the name of the field of the desired information.
		infoValue: A value which the field "infoName" will have.
]]--
function Node:setInformation(infoName, infoValue)	
	assert( (type(infoName) == "number")or(type(infoName) == "string") , "Node:setInformation: infoName must be a number or a string.")
	self.info[infoName] = infoValue
end

--[[
	Retorna o valor da informaçao do campo infoName
	Param:
		infoName: A string or a number containing the name of the field of the desired information.
]]--
function Node:getInformation(infoName)
	assert( (type(infoName) == "number")or(type(infoName) == "string") , "Node:getInformation expects a number or a string.")
	return self.info[infoName]
end

--[[ 
	Define the x position of the node.
	Param:
		x: A number which defines the position of the node in the x axis
]]--
function Node:setPositionX(x)
	assert( type(x) == "number" , "Node:setPosition expects a number.")
	self.x = x
end

--[[
	Define the y position of the node.
	Param:
		y: A number which defines the position of the node in the y axis
]]--
function Node:setPositionY(y)
	assert( type(y) == "number" , "Node:setPosition expects a number.")
	self.y = y
end

--[[ 
	Define the (x,y) position of the node.
	Param:
		x: A number which defines the position of the node in the x axis
		y: A number which defines the position of the node in the y axis
]]--
function Node:setPosition(x, y)
	assert( type(x) == "number" , "Node:setPosition expects a number, x is not a number.")
	assert( type(y) == "number" , "Node:setPosition expects a number, y is not a number.")
	self.x = x
	self.y = y
end

--[[
	Returns the position of the node
]]--
function Node:getPosition()
	return self.x, self.y
end

--[[
	Return the x position of the node
]]--
function Node:getPositionX()
	return self.x
end

--[[
	Return the y position of the node
]]--
function Node:getPositionY()
	return self.y
end

--- Insert a edge in the list of the edges that this node have arriving at him
function Node:setEdgeIn(edgeIn)
	assert( getmetatable(edgeIn) == Edge_Metatable , "Node:setEdgeIn expects a edge")
	
	if self.edgesIn == nil then
		self.edgesIn = {}
	end
	
	self.edgesIn[#self.edgesIn+1] = edgeIn
end

--- Insert a list of edges in the list of the edges that this node have arriving at him
function Node:setEdgesIn(edgesIn)
	if edgesIn == nil then
		self.edgesIn = nil -- apago a lista
		return
	end
	
	if #edgesIn == 0 then
		return
	end

	for i=1, #edgesIn do
		self:setEdgeIn(edgesIn[i])
	end
	
end

--- Insert a edge in the list of the edges that this node have comming out of him
function Node:setEdgeOut(edgeOut)
	assert( getmetatable(edgeOut) == Edge_Metatable , "Node:setEdgeIn expects a edge")
	
	if self.edgesOut == nil then
		self.edgesOut = {}
	end
	
	self.edgesOut[#self.edgesOut+1] = edgeOut
end

--- Insert a list of edges in the list of the edges that this node have comming out of him
function Node:setEdgesOut(edgesOut)
	if edgesOut == nil then	
		return
	end
	
	if #edgesOut == 0 then
		return
	end

	for i=1, #edgesOut do
		self:setEdgeOut(edgesOut[i])
	end
	
end

--- Returns all the edges that comes out of this node.
function Node:getEdgesOut()
	return self.edgesOut
end

--- Returns all the edges that arrives at this node.
function Node:getEdgesIn()
	return self.edgesIn
end

function Node:getEdgeIn(label)
	-- retorna a primeira aresta da lista de arestas que entram do vertice que tenha o label desejado
	if self.edgesIn == nil then
		return nil
	end
	
	for i=1, #self.edgesIn do
		if self.edgesIn[i]:getLabel() == label then
			return self.edgesIn[i]
		end
	end
	
	return nil
end

function Node:getEdgeOut(label)
	-- retorna a primeira aresta da lista de arestas que saem do vertice que tenha o label desejado
	if self.edgesOut == nil then
		return nil
	end
	
	for i=1, #self.edgesOut do
		if self.edgesOut[i]:getLabel() == label then
			return self.edgesOut[i]
		end
	end
	
	return nil
end

function Node:deleteEdgeOut(edge)
	local edgesOut = self:getEdgesOut()

	local isEdgeDeleted = false
	local positionOfTheEdge = nil
	local numEdges = #edges
	
	for i=1, #edgesOut do
		if edgesOut[i]:getOrigem():getLabel() == edge:getOrigem():getLabel() and edgesOut[i]:getDestino():getLabel() == edge:getDestino():getLabel()then
		-- achei a aresta
			edgesOut[i] = nil			
			isEdgeDeleted = true
			positionOfTheEdge = i
			
			if i == numEdges then
				-- deletei do final, posso retornar
				return true
			end
			
			break			
		end
	end
	
	if isEdgeDeleted then
		-- nao é do final
		for i = positionOfTheEdge, #edgesOut do
			edgesOut[i] = edgesOut[i+1]
			edgesOut[i+1] = nil
			
			if i+1 == #edgesOut then
				-- chegamos no final
				return true
			end
		end
	end
	
	return false
end


function Node:deleteEdgeIn(edge)
	local edgesIn = self:getEdgesIn()

	local isEdgeDeleted = false
	local positionOfTheEdge = nil
	local numEdges = #edges
	
	for i=1, #edgesIn do
		if edgesIn[i]:getOrigem():getLabel() == edge:getOrigem():getLabel() and edgesIn[i]:getDestino():getLabel() == edge:getDestino():getLabel()then
		-- achei a aresta
			edgesIn[i] = nil			
			isEdgeDeleted = true
			positionOfTheEdge = i
			
			if i == numEdges then
				-- deletei do final, posso retornar
				return true
			end
			
			break			
		end
	end
	
	if isEdgeDeleted then
		-- nao é do final
		for i = positionOfTheEdge, #edgesIn do
			edgesIn[i] = edgesIn[i+1]
			edgesIn[i+1] = nil
			
			if i+1 == #edgesIn then
				-- chegamos no final
				return true
			end
		end
	end
	
	return false
end
