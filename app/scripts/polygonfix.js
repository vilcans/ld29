Phaser.Polygon.prototype.contains = function (x, y) {

    var inside = false;

    // use some raycasting to test hits https://github.com/substack/point-in-polygon/blob/master/index.js
    for (var i = 0, j = this.points.length - 1; i < this.points.length; j = i++)
    {
        var xi = this.points[i].x;
        var yi = this.points[i].y;
        var xj = this.points[j].x;
        var yj = this.points[j].y;

        var intersect = ((yi > y) !== (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

        if (intersect)
        {
            inside = !inside;
        }
    }

    return inside;

};
