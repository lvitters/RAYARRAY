class Laser {
	PVector position;
	ArrayList<Ray> rays = new ArrayList<Ray>();

	Laser(float x, float y) {
		position = new PVector(x, y);
		rays.add(new Ray(position, new PVector(width, height - position.y), true));
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
	void drawRays(Laser l) {
		for (Ray r : rays) {
			r.checkHitsAndDrawToClosestHit(l);
		}
	}

	/*
	//draw reflected rays at closest hit
	void addOrRemoveReflectedRays(Ray ray) {
		if (ray != null) {
			rays.add(ray);
		} else {
			println(rays.size());
		}
	}
	*/
}

class Ray {
	PVector origin;
	PVector direction = new PVector();
	PVector nextRayOrigin, nextRayDirection;
	float angleOfAttack;
	boolean isFirst;

	Ray(PVector o, PVector d, boolean i) {
		origin = o;
		setDirection(d);
		isFirst = i;
	}

	//update the ray's position
	void setPosition(PVector p) {
		origin = p;
	}

	//update the ray's direction
	void setDirection(PVector d) {
		direction.x = d.x - origin.x;
		direction.y = d.y - origin.y;
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

	//draw ray, check for hit with nearest mirror, if there is a hit draw ray to there
	//https://www.youtube.com/watch?v=TOEi6T2mtHo&t=490s&ab_channel=TheCodingTrain
	void checkHitsAndDrawToClosestHit(Laser l) {
		//set to position of laser if it is the first ray
		if (isFirst) setPosition(l.position);
			PVector closestHit = null;
			float record = width*2;
			float angleOfAttack = 0;
			for (Node n : nodes) {
				PVector hit = cast(n);
				angleOfAttack = PVector.angleBetween(PVector.add(n.start, n.end), PVector.add(origin, direction));
				if (hit != null) {
					float distance = PVector.dist(origin, hit);
					if (distance < record) {
						record = distance;
						closestHit = hit;
					}
				}
			}
			if (closestHit != null) {
				setDirection(closestHit);
				nextRayOrigin = closestHit;
				nextRayDirection = PVector.fromAngle(degrees(-angleOfAttack));
				Ray nextRay = new Ray(nextRayOrigin, nextRayDirection, false);
				nextRay.checkHitsAndDrawToClosestHit(l);
				nextRay = null;
			}
			draw();
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