--[[

	Main Module

	Author: Vitor

]]--

require 'Constants.lua'
require 'Utility.lua'
dofile '..\\logicmodule\\SequentCalculusLogic.lua'
--dofile '..\\graphmodule\\Graph.lua' -- Adicione este quando for usar direto o modulo grafo.


-- Love initial configuration
love.graphics.setBackgroundColor(255, 255, 255) -- White Color
love.graphics.setColor(0, 0, 0) -- Black Color
font = love.graphics.newFont(11)
isDragging = false

--[[
	Create a graph, used just for tests
]]--
--[[
function createGraph()	

	SequentGraph = Graph:new ()

	Node1 = Node:new('Vertice 1', xBegin, yBegin)
	Node2 = Node:new('Vertice 2', xBegin + 3*xStep, yBegin)
	Node3 = Node:new('Vertice 3', xBegin, yBegin + 3*yStep)
	Node4 = Node:new('Vertice 4', xBegin + 3*xStep, yBegin + 3*yStep)
	Node5 = Node:new('Vertice 5', xBegin - 3*xStep, yBegin)
	Node6 = Node:new('Vertice 6', xBegin - 50, yBegin + 3*yStep)
	
	-- Exemplo de novo atributo para um vertice
	Node1:setInformation("cor", "Verde")
	createDebugMessage("Node1:getInfo(cor) = "..Node1:getInformation("cor") )

	Edge1 = Edge:new('Edge1', Node1, Node2)
	Edge2 = Edge:new('Edge2', Node2, Node3)
	Edge3 = Edge:new('Edge3', Node3, Node4)
	Edge4 = Edge:new('Edge4', Node3, Node5)
	Edge5 = Edge:new('Edge5', Node2, Node4)
	Edge6 = Edge:new('Edge6', Node1, Node6)

	-- Exemplo de novo atributo para uma aresta
	Edge1:setInformation("tamanhoLetra", .65)
	createDebugMessage("Edge1:getInformation(tamanhoLetra) = "..Edge1:getInformation("tamanhoLetra") )
	
	nodes = {Node1, Node2, Node3, Node4, Node5, Node6}
	edges = {Edge1, Edge2, Edge3, Edge4, Edge5, Edge6}

	SequentGraph:addNodes(nodes)
	SequentGraph:addEdges(edges)
	

end
]]--
--createGraph()-- SÓ PARA TESTES:

-- Private function
--[[	
	Ela prepara as posições (x,y) de todos os vertices para que eles possam ser desenhados.
]]--
local function prepareGraphToDraw(graph)
	
	nodes = graph:getNodes()
	
	posX = xBegin
	posY = yBegin
	
	if nodes ~= nil then
		for  i = 1, #nodes do		
			if nodes[i]:getPosition() == nil then -- sõ atualiza os nós que nao tem posicao.			
				nodes[i]:setPosition(posX,posY)
				if i % 2 == 0 then
					posX = posX + 10
				else
					posY = posY + 10
				end
			end
		end
	end

	return graph
end

--[[
	Chama a função de criar grafo de um determinado sistema de prova.
]]--

-- Essa funcao tera que ser implementada pelo logicmodule
-- Queria criar uma forma de criar uma interface para ser implementada pelo logic module
-- Talvez criar uma tabela que seja LogicModule e que ela tenha funcoes a ser implementadas.
-- que ai quem quiser criar um novo sistema de prova é só completar os espaços.
-- Variavel privada
local SequentGraph = LogicModule.createGraphFromString("")

-- WARNING - tirar daqui
prepareGraphToDraw(SequentGraph)

-- Private functions
--[[
	Dada uma aresta, ele retorna o angulo em radianos que a aresta faz com o eixo horizontal.
	É usada para escrever textos em cima das arestas.
]]--
local function getInclinacaoAresta(edge)
	local inclinacao
	local x2Maiorx1 = false
	local y2Maiory1 = false
	local invertSignal = 1 -- para saber para onde o angulo esta virado
	local x1, y1 = edge:getOrigem():getPosition()
	local x2, y2 = edge:getDestino():getPosition()
	
	local a,b,c
	
	-- Calculando o tamanho dos lados do triangulo retangulo que a aresta forma
	-- a = hipotenusa
	-- b e c catetos
	if x1 > x2 then
		b = x1 - x2		
	elseif x2 > x1 then
		b = x2 - x1
		x2Maiorx1 = true
	else
		return math.rad(-90) -- A aresta esta na vertical
	end
	
	if y1 > y2 then
		c = y1 - y2
	elseif y2 > y1 then
		c = y2 - y1
		y2Maiory1 = true
	else
		return math.rad(0) -- A aresta esta na horizontal
	end
	
	-- Distancia entre 2 pontos
	a = math.pow(b,2) + math.pow(c,2)
	a = math.sqrt(a)
	
	--createDebugMessage( "x1 = "..x1.." y1 = "..y1.." x2 = "..x2 .."y2 = "..y2)
	
	-- Lei dos cossenos
	inclinacao = math.acos( (math.pow(a,2) + math.pow(b,2) - math.pow(c,2))/ (2*a*b) )
		
	--createDebugMessage( "Teta = ".. (inclinacao * invertSignal) )	
	
	-- Ajeitando a rotação para o lado correto
	if y2Maiory1 and x2Maiorx1 then
		invertSignal = 1
	elseif y2Maiory1 then
		invertSignal = -1
	elseif x2Maiorx1 then
		invertSignal = -1
	end
	
	return inclinacao * invertSignal
end

--[[
	Um algoritmo massa-mola + carca eletrica aplicado ao grafo.
]]--
local function ApplyForces(graph)

	local nodes = graph:getNodes()
	local edges = graph:getEdges()


	for i=1, #nodes do
		nodes[i]:setInformation("Vx",0.0)
		nodes[i]:setInformation("Vy",0.0)
		nodes[i]:setInformation("m",0.5)

	end


	repeat		
		total_kinetic_energy = 0
		for i=1, #nodes do
		
			nodes[i]:setInformation("Fx",0.0)
			nodes[i]:setInformation("Fy",0.0)
			for j=1, #nodes do
				if i ~= j then
					dx = nodes[i]:getPositionX() - nodes[j]:getPositionX()
					dy = nodes[i]:getPositionY() - nodes[j]:getPositionY()
					rsq = (dx*dx) + (dy*dy)
					nodes[i]:setInformation("Fx",(nodes[i]:getInformation("Fx")+(100*dx/rsq)))
					nodes[i]:setInformation("Fy",(nodes[i]:getInformation("Fy")+(100*dy/rsq)))
				end
			end

			for j=1, #edges do
				local edge = edges[j]
				local nodeO = edge:getOrigem()
				local nodeD = edge:getDestino()

				if nodeO:getLabel() == nodes[i]:getLabel() or nodeD:getLabel() == nodes[i]:getLabel() then
					local Xi=0
					local Xj=0
					local Yi=0
					local Yj=0
					if nodeO:getLabel() == nodes[i]:getLabel() then
						Xi,Yi = nodeO:getPosition()
						Xj,Yj = nodeD:getPosition()
					else
						Xi,Yi = nodeD:getPosition()
						Xj,Yj = nodeO:getPosition()
					end

					dx = Xj - Xi
					dy = Yj - Yi
					nodes[i]:setInformation("Fx", nodes[i]:getInformation("Fx")+(0.06*dx))
					nodes[i]:setInformation("Fy", nodes[i]:getInformation("Fy")+(0.06*dy))
				end

			end
			nodes[i]:setInformation("Vx", (nodes[i]:getInformation("Vx")+(nodes[i]:getInformation("Fx")*0.85)))
			nodes[i]:setInformation("Vy", (nodes[i]:getInformation("Vy")+(nodes[i]:getInformation("Fy")*0.85)))
			
			nodes[i]:setPositionX(nodes[i]:getPositionX()+nodes[i]:getInformation("Vx"))
			nodes[i]:setPositionY(nodes[i]:getPositionY()+nodes[i]:getInformation("Vy"))

			total_kinetic_energy = total_kinetic_energy + (nodes[i]:getInformation("m") * ((nodes[i]:getInformation("Vx")^2) + (nodes[i]:getInformation("Vy")^2)))
		end
	until total_kinetic_energy < 50000
	
end

--[[
	Recive a graph and draws it on the screen.
]]--
local function drawGraph(graph)
	local i = 1
	
	assert( getmetatable(graph) == Graph_Metatable , "drawGraph expects a graph.")
	
	local nodes = graph:getNodes()
	local edges = graph:getEdges()
	
	-- Desenha os vertices
	if nodes ~= nil then
		while i <= #nodes do
		
			local node = nodes[i]
			
			love.graphics.setColor(0, 255, 0) -- Green circle		
			love.graphics.circle("fill", node:getPositionX(), node:getPositionY(), raioDoVertice, 25)
			love.graphics.setColor(0, 0, 0, 99) -- Black 99%
			love.graphics.circle("line", node:getPositionX(), node:getPositionY(), 6)
			love.graphics.print(node:getLabel(), node:getPositionX() - 10, node:getPositionY() - circleSeparation , 0, escalaLetraVertice, escalaLetraVertice )
			i = i + 1
		end
	end
	
	i=1
	-- Desenha as arestas
	if edges ~= nil then
		while i <= #edges do
			
			local edge = edges[i]

			love.graphics.setColor(0, 0, 0, 99) -- Black 99%
			local x1, y1 = edge:getOrigem():getPosition()
			local x2, y2 = edge:getDestino():getPosition()
			love.graphics.line(x1, y1, x2, y2)
			
			inclinacao = getInclinacaoAresta(edge)
			--createDebugMessage(edge:getLabel() .." : ".. inclinacao)
			--createDebugMessage("y1 = "..y1 .. "y2 = "..y2)		
			love.graphics.print(edge:getLabel(), (x1 + x2)/2 , (y1 + y2)/2  , inclinacao, escalaLetraAresta, escalaLetraAresta )
			
			i = i + 1
		end
	end
	
	ApplyForces(SequentGraph)
end

--[[
	Esta função verifica se algum vertice foi clicado pelo usuário. E retorna este vertice.
]]--
local function getNodeClicked()	
	-- Varrer todo o grafo procurando o vertice que pode ter sido clicado.
	nodes = SequentGraph:getNodes()	
	for i=1, #nodes do			
		x,y = nodes[i]:getPosition()
		
		if (love.mouse.getX() <= x + raioDoVertice) and (love.mouse.getX() >= x - raioDoVertice) then
			if (love.mouse.getY() <= y + raioDoVertice) and (love.mouse.getY() >= y - raioDoVertice) then
				-- Este vertice foi clicado
				return nodes[i]
			end
		end
	end
	return nil	
end

--[[
	Esta função é chamada pela love.draw.
	A todo instante ela verifica se o botão esquerdo do mouse foi apertado. Em caso positivo 
	conforme o botão continuar sendo pressionado e caso o clicke tenha sido em um vertice esta função
	ira alterar a posição de desenho do vertice, criando o efeito do drag and drop.
]]--
local function dragNodeOrScreen()	
	-- Chama o modulo de prova associado.
	-- Verifica que o usuário quer expandir um vertice.
	if love.mouse.isDown("r") then
		nodeClicked = getNodeClicked()

		if nodeClicked ~= nil then

			-- INICIO) PARA TESTAR, TIRAR! WARNING! VITOR 
			--[[
			createDebugMessage("ANTES: Arestas do grafo:")
			local edgesAll = SequentGraph:getEdges()
			for i=1, #edgesAll do
				createDebugMessage(edgesAll[i]:getLabel())
			end
			
			local edgesOut = nodeClicked:getEdgesOut()
			createDebugMessage("ANTES Arestas saindo do vertice "..nodeClicked:getLabel().. " :")
			for i=1, #edgesOut do
				createDebugMessage(edgesOut[i]:getLabel())
			end
			
			if edgesOut[1] ~= nil then
				SequentGraph:removeEdge(edgesOut[1]) 
			end
			
			local edgesOut = nodeClicked:getEdgesOut()
			createDebugMessage("DEPOIS Arestas saindo do vertice "..nodeClicked:getLabel().. " :")
			for i=1, #edgesOut do
				createDebugMessage(edgesOut[i]:getLabel())
			end
			
			createDebugMessage("DEPOIS: Arestas do grafo:")
			local edgesAll = SequentGraph:getEdges()
			for i=1, #edgesAll do
				createDebugMessage(edgesAll[i]:getLabel())
			end
			]]--
			-- FIM) PARA TESTAR, TIRAR! WARNING! VITOR 
			
			
			local newGraph = nil
			newGraph = LogicModule.expandNode( SequentGraph, nodeClicked )
			
			if newGraph ~= nil then
				-- Foi alterado pela expandNode e precisa ser redesenhado.
				SequentGraph = prepareGraphToDraw(newGraph)
			end
		end
		
	-- Verifica se o usuário quer arrastar um vertice.
	elseif love.mouse.isDown("l") and not isDragging then		
	
		-- INICIO WARNING - SOH PRA TESTAR A REMOCAO DE UM NODE!!! VITOR
		--[[nodeTEST = getNodeClicked()
		if nodeMoving ~= nil then
			
			createDebugMessage("ANTES: Vertices do grafo:")
			local nodesAll1 = SequentGraph:getNodes()
			for i=1, #nodesAll1 do
				createDebugMessage(nodesAll1[i]:getLabel())
			end			
			
			if getmetatable(nodeTEST) == Node_Metatable then
				SequentGraph:removeNode(nodeTEST)
			end
			
			
			createDebugMessage("DEPOIS: Vertices do grafo:")
			local nodesAll2 = SequentGraph:getNodes()
			for i=1, #nodesAll2 do
				createDebugMessage(nodesAll2[i]:getLabel())
			end				
			
		end]]--
		-- FIM WARNING - SOH PRA TESTAR A REMOCAO DE UM NODE!!! VITOR	
	
	
		nodeMoving = getNodeClicked()
		isDragging = true
		
		xInitial = love.mouse.getX()
		yInitial = love.mouse.getY()
		-- Mudar o xInicial e o yInicial sempre que o mouse parar tb seria uma boa!
		
	-- Vericia se o usuário quer arrastar a tela	
	elseif not love.mouse.isDown("l") then				
		isDragging = false
		nodeMoving = "nao vazio"
		
	-- Usuario arrastando um vertice	
	elseif nodeMoving ~= "nao vazio" and nodeMoving ~= nil then
		nodeMoving:setPosition(love.mouse.getX(), love.mouse.getY())
		ApplyForces(SequentGraph)
		
	-- Usuario arrastando toda a tela	
	elseif nodeMoving == nil then	
		nodes = SequentGraph:getNodes()
		for i=1, #nodes do			
			x,y = nodes[i]:getPosition()
			deslocamentoX = math.abs(love.mouse.getX() - xInitial)/10
			deslocamentoY = math.abs(love.mouse.getY() - yInitial)/10
			
			if love.mouse.getX() < xInitial then
				x = x - 5
			elseif love.mouse.getX() > xInitial then
				x = x + 5
			end
				
			if love.mouse.getY() < yInitial then
				y = y - 5
			elseif love.mouse.getY() > yInitial then
				y = y + 5				
			end
			
			nodes[i]:setPosition(x, y)
		end				
	end
end

function expandAllButton()
	local xPos = windowWidth - 60
	local yPos = 5
	local xLen = 55
	local yLen = 30
	if love.mouse.getX() >= xPos and love.mouse.getX() <= xPos + xLen and love.mouse.getY() >= yPos and love.mouse.getY() <= yPos + yLen then
		-- Entra aqui quando o mouse esta em cima da regiao do botao	
		if love.mouse.isDown("l") then
			-- Entra aqui quando além do if de cima o botao esquedo foi pressionado.
			createDebugMessage("Expand All called!")
			local graph = LogicModule.expandAll(SequentGraph)
			
			SequentGraph = prepareGraphToDraw(graph)
			
			love.timer.sleep(buttonTime)
		end
		love.graphics.setColor(100, 100, 200)
	else
		love.graphics.setColor(0, 100, 200)
	end
	love.graphics.rectangle("fill", xPos, yPos, xLen, yLen)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(xPos, yPos, xPos, yPos + yLen)
	love.graphics.line(xPos, yPos + yLen, xPos + xLen, yPos + yLen)
	love.graphics.setColor(255, 255, 255)
	love.graphics.line(xPos + xLen, yPos, xPos + xLen, yPos + yLen)
	love.graphics.line(xPos, yPos, xPos + xLen, yPos)
	love.graphics.setColor(0, 0, 200)
	love.graphics.printf(expandAllButtonName, xPos + 30, yPos - 5, 0, "center")
end


--[[
	Função do love usada para desenhar na tela todos os frames. Ela é chamada pelo love em intervalos de tempo
	muito curtos.
]]--
function love.draw()
	printDebugMessageTable()
	expandAllButton()
	drawGraph(SequentGraph)
	dragNodeOrScreen()		
end