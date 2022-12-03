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

	//draw all the rays emitting from that diode recursively
	void drawRays() {
		firstRay.update();
		firstRay.draw();
	}
}

class Ray {
	static final int recursionGuardMax = 100;  //TORESEARCH: what does static final actually do?

	PVector origin = new PVector();
	PVector direction = new PVector();
	PVector hitPoint = null;
	Ray nextRay;

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
		strokeWeight(2);
		stroke(255, 0, 0);
			if (hitPoint != null) {
				line(
					origin.x, 
					origin.y, 
					hitPoint.x, 
					hitPoint.y
					);
			}  else {
				line(
					origin.x, 
					origin.y, 
					origin.x + direction.x * defaultRayLength, 
					origin.y + direction.y * defaultRayLength
					);
			}
	}

	//draw ray, check for hit with nearest mirror, if there is a hit draw ray to there
	//https://www.youtube.com/watch?v=TOEi6T2mtHo&t=490s&ab_channel=TheCodingTrain
	void update() {
		PVector closestHit = null;
		float record = Float.MAX_VALUE;
		Node hitNode = null;
		for (Node n : nodes) {
			PVector hit = cast(n);
			if (hit != null) {
				float distance = PVector.dist(origin, hit);
				if (distance < record && distance > n.mirrorRadius * 2) {
					record = distance;
					closestHit = hit;
					hitNode = n;
				}
			}
		}
		//DPP
        if (recursionGuard >= recursionGuardMax ) {
            println("recursion guard hit");
        }
		if (closestHit != null && hitNode != null && recursionGuard <= RECURSION_GUARD_MAX) {
			recursionGuard++;
			hitPoint = closestHit;
			nextRay = new Ray();
			nextRay.setOrigin(closestHit);

			//calculate reflection (DPP)
            PVector nextRayDirection = reflect(direction, hitNode.normal);
            nextRay.setDirection(nextRayDirection);
			
			nextRay.update();
			nextRay.draw();
		} else {
			recursionGuard = 0;
			nextRay = null;
			hitPoint = null;
		}
	}

	//get the direction vector of the reflection (thanks DPP)
	PVector reflect(PVector direction, PVector normal) {
		// r = e - 2 (e.n) n :: ( | n | = 1 )
    	// with e :: direction
    	//      r :: reflection
    	//      n :: normal
		PVector n = new PVector().set(normal).normalize();
		PVector e = new PVector().set(direction);
		float d = PVector.dot(e, n);	// d > 0 = frontface, d < 0 = backface
		n.mult(2 * d);
		PVector r = PVector.sub(e, n);	// it isn't reversed!!!
		return r;
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
        if (den == 0) {
            return null;
        }

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