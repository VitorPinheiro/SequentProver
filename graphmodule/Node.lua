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