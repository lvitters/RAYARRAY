class Laser {
	PVector position;
	ArrayList<Ray> rays = new ArrayList<Ray>();

	Laser(float x, float y) {
		position = new PVector(x, y);
		rays.add(new Ray(position, true));
	}

	//set laser diode's position
	void setPosition(PVector p) {
		position = p;
	}

	//draw the origin of the laser diode
	void drawOrigin() {
		noStroke();
		fill(0, 0, 255);
		ellipse(position.x, position.y, 10, 10);
	}

	//draw all the rays emitting from that diode
	//https://www.youtube.com/watch?v=TOEi6T2mtHo&t=490s&ab_channel=TheCodingTrain
	void checkHitsAndDrawRays(Laser l) {
		for (Ray r : rays) {
			r.setPosition(l.position);
			PVector closestHit = null;
			float record = width*2;
			for (Node n : nodes) {
				PVector hit = r.cast(n);
				if (hit != null) {
					float distance = PVector.dist(r.origin, hit);
					if (distance < record) {
						record = distance;
						closestHit = hit;
					}
				}
			}
			if (closestHit != null) {
				r.setDirection(closestHit);
			}
			r.draw();
		}
	}
}

class Ray {
	PVector origin;
	PVector direction = new PVector();
	boolean isFirst;

	Ray(PVector o, boolean f) {
		origin = o;
		isFirst = f;
		setDirection(new PVector(width, height - origin.y));
	}

	//update the ray
	void setPosition(PVector p) {
		origin = p;
	}

	//update the ray
	void setDirection(PVector d) {
		direction.x = d.x - origin.x;
		direction.y = d.y - origin.y;
		//direction.normalize();
	}

	//draw the ray
	void draw() {
		stroke(255, 0, 0);
		strokeWeight(3);
		pushMatrix();
			translate(origin.x, origin.y);
			line(0, 0, direction.x, direction.y);
		popMatrix();
	}

	//determine if it intersects with a mirror
	//https://www.youtube.com/watch?v=TOEi6T2mtHo&t=490s&ab_channel=TheCodingTrain
	PVector cast(Node node) {
		float x1 = node.start.x;
		float y1 = node.start.y;
		float x2 = node.end.x;
		float y2 = node.end.y;

		float x3 = origin.x;
		float y3 = origin.y;
		float x4 = origin.x + direction.x;
		float y4 = origin.y + direction.y;

		float den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
		if (den == 0) return null;

		float t =   ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
		float u = - ((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den;

		if (t > 0 && t < 1 && u > 0) {
			PVector pt = new PVector();
			pt.x = x1 + t * (x2 - x1);
			pt.y = y1 + t * (y2 - y1);
			return pt;
		} else {
			return null;
		}
	}
}