describe 'Snake', ->
    graph = snake = null
    startNode = 0
    nextNode = 1

    beforeEach ->
        graph = new Graph(window.graphData['debug'])
        snake = new Snake(graph, startNode, nextNode)

    describe 'node list', ->
        it 'should contain head first, then previous node', ->
            assert.deepEqual snake.nodes, [nextNode, startNode]

    it 'should be able to advance to next node', ->
        snake.nextNode = 2
        snake.goToNextNode()
        assert.deepEqual snake.nodes, [2, 1, 0]

describe 'Real graph', ->
    graph = snake = null
    startNode = 0
    nextNode = 1

    beforeEach ->
        graph = new Graph(window.graphData['layer1'])
        snake = new Snake(graph, startNode, nextNode)

    it 'should work with magic sequence', ->
        for nodeId in [
            0, 1, 18, 0, 10, 62, 40, 41, 39, 62, 10, 62,
            39, 62
        ]
            snake.nextNode = nodeId
            snake.goToNextNode()
        head = snake.getHeadNode()
        console.log 'neighbors:', head.neighbors
