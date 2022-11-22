class Laser {
	PVector position;
	ArrayList<Ray> rays = new ArrayList<Ray>();

	Laser(float x, float y) {
		position = new PVector(x, y);
		rays.add(new Ray(position.x, position.y));
	}

	//draw the origin of the laser diode
	void drawOrigin() {
		noStroke();
		fill(0, 255, 0);
		ellipse(position.x, position.y, 10, 10);
	}

	//draw all the rays emitting from that diode (every new reflection creates a new ray)
	void drawRays() {
		for (Ray r : rays) {
			r.draw();
		}
	}
}

class Ray {
	PVector origin;
	PVector direction;

	Ray(float x, float y) {
		origin = new PVector(x, y);
		direction = new PVector(2000, 0);
	}

	//draw the actual ray
	void draw() {
		stroke(255, 0, 0);
		strokeWeight(3);
		pushMatrix();
			translate(origin.x, origin.y);
			line(0, 0, direction.x, direction.y);
		popMatrix();
	}

	//determine if it intersects with a mirror
	void cast(Node node) {
		float x1 = node.beginning.x;
		float y1 = node.beginning.y;
		float x2 = node.end.x;
		float y2 = node.end.y;

		float x3 = origin.x;
		float y3 = origin.y;
		float x4 = origin.x + direction.x;
		float y4 = origin.y + direction.y;
	}
}