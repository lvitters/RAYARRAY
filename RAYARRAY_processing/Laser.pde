class Laser {
	PVector position, direction;
	Ray firstRay;

	Laser(float x, float y) {
		position = new PVector(x, y);
		direction = new PVector(1, 0);
		firstRay = new Ray();
		firstRay.setOrigin(position);
		firstRay.setDirection(direction);
	}

	//set laser diode's position
	void setPosition(PVector p) {
		position = p;
		firstRay.setOrigin(position);
	}

	//draw the origin of the laser diode
	void drawOrigin() {
		noStroke();
		fill(0, 0, 255);
		ellipse(position.x, position.y, 10, 10);
	}

	//draw all the rays emitting from that diode
	void drawRays() {
		firstRay.update();
	}
}

class Ray {
	PVector origin = new PVector();
	PVector direction = new PVector();
	Ray nextRay;
	int recursionGuard = 10;
	PVector hitPoint = null;
	PVector nextRayDirection;

	//update the ray's position
	void setOrigin(PVector p) {
		origin.set(p);
	}

	//update the ray's direction
	void setDirection(PVector d) {
		direction.set(d);
	}

	//draw the ray
	void draw() {
		strokeWeight(3);
			if (hitPoint != null) {
				stroke(0, 255, 0);
				line(origin.x, origin.y, hitPoint.x, hitPoint.y);
			} else {
				stroke(255, 0, 0);
				line(	origin.x, 
						origin.y, 
						origin.x + direction.x * width, 
						origin.y + direction.y * height);
			}
	}

	//draw ray, check for hit with nearest mirror, if there is a hit draw ray to there
	//https://www.youtube.com/watch?v=TOEi6T2mtHo&t=490s&ab_channel=TheCodingTrain
	void update() {
			PVector closestHit = null;
			float record = width * 2;
			Node hitNode = null;
			for (Node n : nodes) {
				PVector hit = cast(n);
				if (hit != null) {
					float distance = PVector.dist(origin, hit);
					if (distance < record) {
						record = distance;
						closestHit = hit;
						hitNode = n;
					}
				}
			}
			if (closestHit != null) {
				hitPoint = closestHit;
				float nextRayAngle = (hitNode.rotation - direction.heading() - PI/2) * 2; //TODO: NOT REFLECTING RIGHT
				println(direction.heading());
				nextRay = new Ray();
				nextRay.setOrigin(closestHit);
				nextRay.setDirection(new PVector(sin(nextRayAngle), cos(nextRayAngle)));
				nextRay.update();
			} else {
				nextRay = null;
				hitPoint = null;
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