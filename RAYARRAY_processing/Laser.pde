class Laser {
	PVector position;
	ArrayList<Ray> sections;

	drawOrigin() {
		noStroke();
		fill(255, 0, 0);
		rect(position.x, position.y, 20, 2);
	}
}

class Ray () {
	PVector origin,
	PVector direction;
}