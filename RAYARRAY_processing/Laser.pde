class Laser {
	PVector position;
	ArrayList<Ray> rays = new ArrayList<Ray>();

	Laser(float x, float y) {
		position = new PVector(x, y);
		rays.add(new Ray(position.x, position.y));
	}

	void drawOrigin() {
		noStroke();
		fill(0, 255, 0);
		ellipse(position.x, position.y, 10, 10);
	}

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
		direction = new PVector(1, 0);
	}

	void draw() {
		stroke(255, 0, 0);
		strokeWeight(3);
		pushMatrix();
			translate(origin.x, origin.y);
			line(0, 0, direction.x * 100, direction.y * 100);
		popMatrix();
	}

	void cast(Node node) {
		
	}
}