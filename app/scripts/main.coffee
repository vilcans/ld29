class Snake
    constructor: (@graph, startNode, nextNode) ->
        @nodes = [nextNode, startNode]
        @headDistance = 0
        @tailDistance = 0
        @nextNode = null

    move: (distance) ->
        @headDistance += distance
        edgeLength = @getEdgeLength(0)

        if @headDistance >= edgeLength

            for i in [1...@nodes.length]
                if @nodes[i] == @nodes[0]
                    console.log 'Hit myself in nodes', @nodes[..i]
                    @nodes = [@nodes[0]]
                    break

            if @nextNode == null
                @headDistance = edgeLength
                return

            @headDistance -= edgeLength
            #console.log 'Switching towards node', @nextNode
            @nodes.unshift(@nextNode)
            if @nodes.length > 8
                @nodes.pop()
            @nextNode = null

    # Get the node that this snake is moving towards
    getHeadNode: -> @graph.nodes[@nodes[0]]

    # Get the node that this snake just moved over
    getNeckNode: -> @graph.nodes[@nodes[1]]

    getTailNode: -> @graph.nodes[@nodes[@nodes.length - 1]]

    getTailBaseNode: -> @graph.nodes[@nodes[@nodes.length - 2]]

    # Get the length of an edge
    # segmentIndex is the segment to check, 0 for head to neck,
    # 1 for neck to next segment etc.
    getEdgeLength: (segmentIndex) ->
        node1 = @graph.nodes[@nodes[segmentIndex]]
        node2 = @graph.nodes[@nodes[segmentIndex + 1]]
        return Math.sqrt(
            Math.pow(node1.x - node2.x, 2) +
            Math.pow(node1.y - node2.y, 2)
        )

    getHeadPosition: ->
        headNode = @getHeadNode()
        neckNode = @getNeckNode()
        fraction = @headDistance / @getEdgeLength(0)
        return {
            x: neckNode.x + fraction * (headNode.x - neckNode.x),
            y: neckNode.y + fraction * (headNode.y - neckNode.y)
        }

graph = {
    nodes: [
        {x:   0, y:   0},  # 0
        {x: 100, y:   0},  # 1
        {x: 250, y:   0},  # 2
        {x:   0, y: 100},  # 3
        {x: 100, y: 100},  # 4
        {x: 250, y: 100},  # 5
        {x:   0, y: 200},  # 6
        {x: 100, y: 400},  # 7
        {x: 200, y: 150},  # 8
    ]
    edges: [
        # horizontal
        [0, 1], [1, 2],
        [3, 4], [4, 5],
        [6, 7], [7, 8],
        # vertical
        [0, 3], [3, 6],
        [1, 4], [4, 7],
        [2, 5], [5, 8],
    ]
}

for edge in graph.edges
    [node1Index, node2Index] = edge
    node1 = graph.nodes[node1Index]
    node2 = graph.nodes[node2Index]

    node1.neighbors ?= {}
    node1.neighbors[node2Index] = node2
    node2.neighbors ?= {}
    node2.neighbors[node1Index] = node1

tempPoint = new Phaser.Point
tempPoint2 = new Phaser.Point

class MainState
    preload: ->
        @game.load.image('head', 'assets/head.png')

    create: ->
        @graphGraphics = @game.add.graphics(0, 0)
        @graphGraphics.lineStyle(1, 0x880088, 1.0)
        @drawGraph()

        @selectedEdgeGraphics = @game.add.graphics(0, 0)

        @snakeGraphics = @game.add.graphics(0, 0)

        @snake = new Snake(graph, 0, 1)
        @snake.nextNode = 4
        @snake.sprite = @game.add.sprite(20, 20, 'head')
        @snake.sprite.anchor.set(.5, .5)

        #@game.input.onDown.add(
        #    (event) ->
        #        @select(event.worldX, event.worldY)
        #    this
        #)

    select: (x, y) ->
        head = @snake.getHeadNode()
        distanceSquared = Math.pow(head.x - x, 2) + Math.pow(head.y - y, 2)
        #if distanceSquared > 50 * 50 or distanceSquared < 10 * 10
        #    return
        directionToPointer = Phaser.Point.subtract({x: x, y: y}, head, tempPoint)
        directionToPointer.normalize()
        directionToNode = tempPoint2

        bestNodeIndex = null
        bestScore = -1.1
        for neighborIndex, neighbor of head.neighbors
            neighborIndex = +neighborIndex
            if neighborIndex == @snake.nodes[1]
                # Can't go back
                continue

            Phaser.Point.subtract neighbor, head, directionToNode
            directionToNode.normalize()
            dotprod = directionToNode.x * directionToPointer.x + directionToNode.y * directionToPointer.y
            if dotprod > bestScore
                bestScore = dotprod
                bestNodeIndex = neighborIndex

        if bestNodeIndex != null
            #console.log 'best node', bestNodeIndex, 'score', bestScore
            @snake.nextNode = bestNodeIndex

            next = graph.nodes[@snake.nextNode]
            @selectedEdgeGraphics.clear()
            @selectedEdgeGraphics.lineStyle(8, 0x8888ff, .2)
            @selectedEdgeGraphics.moveTo(head.x, head.y)
            @selectedEdgeGraphics.lineTo(next.x, next.y)

        return

    drawGraph: ->
        for edge in graph.edges
            [node1Index, node2Index] = edge
            node1 = graph.nodes[node1Index]
            node2 = graph.nodes[node2Index]
            @graphGraphics.moveTo(node1.x, node1.y)
            @graphGraphics.lineTo(node2.x, node2.y)
        return

    update: ->
        @snake.move(1)
        pos = @snake.getHeadPosition()
        @snake.sprite.position.set(pos.x, pos.y)

        @select @game.input.worldX, @game.input.worldY

        @snakeGraphics.clear()
        @snakeGraphics.lineStyle(3, 0xffffff, 1.0)
        @snakeGraphics.moveTo pos.x, pos.y
        # Drawing a line of length 0 makes the *next* line disappear,
        # hence the check for headDistance
        for i in [(if @snake.headDistance > 0 then 1 else 2)...@snake.nodes.length]
            node = graph.nodes[@snake.nodes[i]]
            @snakeGraphics.lineTo(node.x, node.y)

    render: ->

start = ->
    game = new Phaser.Game(320, 480, Phaser.AUTO, 'game')
    game.state.add('main', MainState)
    game.state.start('main')

start()
