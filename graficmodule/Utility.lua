--[[

	Utility Module

	Contain functions that can be used by all the aplication. Normaly functions for string manipulation or for debuging.
	This is provided by the grafic module to all others that want to use this functions.

	Author: Vitor

]]--

--[[
	Print in the screen all the messages contained in the MedDebugTable.
]]--
function printDebugMessageTable()	


	for i = 1, #MsgDebugTable do
		local yRes = yDebug + i*15		
		
		if yRes > windowHeight - yLim then
			MsgDebugTable = {}
			MsgDebugTable[1] = "Mensagens para debug:"
			
			love.graphics.setColor(0, 0, 255) -- Blue Color
			love.graphics.print(MsgDebugTable[1], xDebug, yRes)
			break
		else		
			love.graphics.setColor(0, 0, 255) -- Blue Color
			love.graphics.print(MsgDebugTable[i], xDebug, yRes)			
		end
	end
	love.graphics.setColor(0, 0, 0) -- Black Color
	

end

--[[
	Insert a message in the MsgDebugTable.
	Only insert diferents debug messages. This precaution was taken because of this function can be called
	by love.draw, so a span could occur.
	Param:
		debugMessage: A string containing the debug message.
]]--
function createDebugMessage(debugMessage)
	--[[
	for i=0, #MsgDebugTable do
		if MsgDebugTable[i] == debugMessage then
			return
		end
	end]]--

	MsgDebugTable[#MsgDebugTable+1] = debugMessage
end