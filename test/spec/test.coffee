describe 'Snake', ->
    graph = new Graph(window.graphData['debug'])
    snake = new Snake(graph, startNode, nextNode)

    startNode = 0
    nextNode = 1

    describe 'node list', ->
        it 'should contain head first, then previous node', ->
            assert.deepEqual snake.nodes, [nextNode, startNode]

    it 'should be able to advance to next node', ->
        snake.nextNode = 2
        snake.goToNextNode()
        assert.deepEqual snake.nodes, [2, 1, 0]
