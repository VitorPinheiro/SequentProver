--[[

	Constants Module
	
	Contains all the constants used by the grafic module.

	Author: Vitor

]]--

-- Positioning definitions
windowWidth = 800
windowHeight = 600
xLim = 30
yLim = 30
xStep = 40
yStep = 40
xBegin = windowWidth / 2
yBegin = 60

-- Pan screen
xInitial = 0
yInitial = 0

-- Tamanho vertice e arestas
circleSeparation = 20
raioDoVertice = 5
escalaLetraVertice = .85 -- <1 para diminuir e >=1 para aumentar
escalaLetraAresta = .75

-- String para mensagem de erro
xDebug = 10
yDebug = 10
countDebugMsgs = 1
MsgDebugTable = {}
MsgDebugTable[1] = "Mensagens para debug:"

-- Button names
expandAllButtonName = "Expand All"

buttonTime = 150