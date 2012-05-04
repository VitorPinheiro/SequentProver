--[[

	Goal Module

	Author: Vitor
]]--

--[[ 
	Defining the Goal
]]--
Goal = {}

--[[ 
	Defining the Metatable
]]--
Goal_Metatable = { __index = Goal }

--[[
	Class Constructor
	
	leftGoals - Será uma lista de operadores que ele pode expandir na parte esquerda do sequente.
]]--
function Goal:new (sequent, leftGoals, rightGoals)
	assert( getmetatable(sequent) == Node_Metatable , "Goal:new expects a Node. Sequent is not a node.")	
	
	local ini = {}
	
	if leftGoals ~= nil and rightGoals ~= nil then
		assert( type(leftGoals) == "table" , "Goal:new expects a table. leftGoals is not a table.")
		assert( type(rightGoals) == "table" , "Goal:new expects a table. rightGoals is not a table.")
		ini = {sequent = sequent, leftGoals = leftGoals, rightGoals = rightGoals}
	elseif leftGoals ~= nil then
		assert( type(leftGoals) == "table" , "Goal:new expects a table. leftGoals is not a table.")
		ini = {sequent = sequent, leftGoals = leftGoals}
	elseif rightGoals ~= nil then
		assert( type(rightGoals) == "table" , "Goal:new expects a table. rightGoals is not a table.")
		ini = {sequent = sequent, rightGoals = rightGoals}
	else
		ini = {sequent = sequent}
	end
	
	return setmetatable( ini, Goal_Metatable )
end

function Goal:deleteGoal()
	self.rightGoals = nil
	self.leftGoals = nil
	self = nil
end

--[[
	Return the sequent of the Goal
]]--
function Goal:getSequent()
	return self.sequent
end

--[[
	Return the left side of the Goal
]]--
function Goal:getLeftSide()
	return self.leftGoals
end

--[[
	Return the right side of the Goal
]]--
function Goal:getRightSide()
	return self.rightGoals
end