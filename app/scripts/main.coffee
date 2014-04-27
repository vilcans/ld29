class Snake
    constructor: (@graph, startNode, nextNode) ->
        @nodes = [nextNode, startNode]
        @headDistance = 0
        @tailDistance = 0
        @nextNode = null

    canMove: ->
        @nodes.length >= 2

    move: (distance) ->
        if not @canMove()
            console.log 'cannot move'
            return false

        @headDistance += distance
        edgeLength = @getEdgeLength(0)

        if @headDistance >= edgeLength

            i = @nodes.length
            while --i >= 1
                if @nodes[i] == @nodes[0]
                    closedLoop = @nodes[..i]
                    console.log 'Hit myself in nodes', closedLoop
                    console.log 'nodes are', @nodes
                    captureNodes(closedLoop)
                    @nodes = [@nodes[0]]
                    break

            if @nextNode? and not graph.nodes[@nextNode].neighbors[@nodes[0]]
                # No edge between these nodes
                console.log 'nextNode not valid any more'
                @nextNode = null

            if @nextNode == null
                @headDistance = edgeLength
                return

            @headDistance -= edgeLength
            #console.log 'Switching towards node', @nextNode
            @nodes.unshift(@nextNode)
            #if @nodes.length > 8
            #    @nodes.pop()
            @nextNode = null

        return true

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
        unless neckNode
            return {
                x: headNode.x
                y: headNode.y
            }
        fraction = @headDistance / @getEdgeLength(0)
        return {
            x: neckNode.x + fraction * (headNode.x - neckNode.x),
            y: neckNode.y + fraction * (headNode.y - neckNode.y)
        }


graph = {
    nodes: [
        {x:  10, y:   0},  # 0   neighbors: {nodeId: node, ...}
        {x: 100, y:   0},  # 1
        {x: 250, y:   0},  # 2
        {x:  10, y: 100},  # 3
        {x: 100, y: 100},  # 4
        {x: 250, y: 100},  # 5
        {x:  10, y: 200},  # 6
        {x: 100, y: 400},  # 7
        {x: 200, y: 190},  # 8
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
    faces: [
        {x:  50, y:  50, nodes: [0, 1, 4, 3], neighbors: [1, 2]},  # edgeKeys: [...]
        {x: 150, y:  50, nodes: [1, 2, 5, 4], neighbors: [0, 3]},
        {x:  50, y: 200, nodes: [3, 4, 7, 6], neighbors: [0, 3]},
        {x: 150, y: 150, nodes: [4, 5, 8, 7], neighbors: [1, 2]},
    ]
    # Map edge ID to array of faces that have this edge (1 or 2)
    facesByEdge: {}
}

getEdgeKey = (nodeIndex1, nodeIndex2) ->
    if nodeIndex1 < nodeIndex2
        "#{nodeIndex1}-#{nodeIndex2}"
    else
        "#{nodeIndex2}-#{nodeIndex1}"

# Create facesByEdge map
for face, faceIndex in graph.faces
    face.id = faceIndex
    face.edgeKeys = []
    for i in [0...face.nodes.length]
        nodeIndex1 = face.nodes[i]
        nodeIndex2 = face.nodes[(i + 1) % face.nodes.length]
        key = getEdgeKey(nodeIndex1, nodeIndex2)
        face.edgeKeys.push(key)
        faceList = (graph.facesByEdge[key] ?= [])
        faceList.push(face)

console.log 'facesByEdge', graph.facesByEdge
console.log 'faces', graph.faces

for edge in graph.edges
    [node1Index, node2Index] = edge
    node1 = graph.nodes[node1Index]
    node2 = graph.nodes[node2Index]

    node1.neighbors ?= {}
    node1.neighbors[node2Index] = node2
    node2.neighbors ?= {}
    node2.neighbors[node1Index] = node1


captureNodes = (nodes) ->
    points = (new Phaser.Point(graph.nodes[n].x, graph.nodes[n].y) for n in nodes)
    #points.push(points[0])
    polygon = new Phaser.Polygon(points)

    # Faces to remove
    toRemove = []

    visited = {}

    maybeDelete = (faceId) ->
        if visited[faceId]
            return

        visited[faceId] = true
        face = graph.faces[faceId]
        if not face
            throw "no face with id #{faceId}"
        if polygon.contains(face.x, face.y)
            #console.log 'delete face', faceId, ', poly contains', face.x, face.y
            visited[faceId] = true
            toRemove.push(face)
            for neighborId in face.neighbors
                maybeDelete(neighborId)
        else
            console.log faceId, 'is not inside'
        return

    firstFaces = graph.facesByEdge[getEdgeKey(nodes[0], nodes[1])]
    maybeDelete(firstFaces[0].id)
    if firstFaces.length > 1
        maybeDelete(firstFaces[1].id)

    console.log 'Removing faces...'
    for face in toRemove
        console.log 'Removing face', face.id
        for edgeKey in face.edgeKeys
            neighbors = graph.facesByEdge[edgeKey]
            if neighbors.length == 1
                # This face was the only one using this edge
                console.log '...removing edge', edgeKey
                graph.facesByEdge[edgeKey] = []
                nodeIds = edgeKey.split('-')

                # Remove neighbor connections
                nodeId0 = +nodeIds[0]
                nodeId1 = +nodeIds[1]
                console.log '......old neighbors from', nodeId0, graph.nodes[nodeId0].neighbors
                console.log '......old neighbors from', nodeId1, graph.nodes[nodeId1].neighbors
                delete graph.nodes[nodeId0].neighbors[nodeId1]
                delete graph.nodes[nodeId1].neighbors[nodeId0]
                console.log '......new neighbors from', nodeId0, graph.nodes[nodeId0].neighbors
                console.log '......new neighbors from', nodeId1, graph.nodes[nodeId1].neighbors

            else if neighbors.length == 2
                neighbor = neighbors[if neighbors[0] == face then 1 else 0]
                console.log '...removing from edge', edgeKey, 'only', neighbor.id, 'left'
                graph.facesByEdge[edgeKey] = [neighbor]
            else
                throw "Unexpected number of faces on edge #{edgeKey}: #{neighbors.length}"
    return

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
        for face in graph.faces
            @graphGraphics.drawCircle(face.x, face.y, 5)
        return

    update: ->
        if @snake
            @moveSnake()

    moveSnake: ->
        canMove = @snake.move(2)
        unless canMove
            @killSnake()
            return
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

        return

    killSnake: ->
        @snake = null

    render: ->

start = ->
    game = new Phaser.Game(320, 480, Phaser.AUTO, 'game')
    game.state.add('main', MainState)
    game.state.start('main')

start()
