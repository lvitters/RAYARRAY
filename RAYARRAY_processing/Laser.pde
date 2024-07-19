class Laser {
	PVector position, rayOrigin, direction, startDirection;
	boolean active;
	Ray firstRay;

	//rotation
	float rT;
	float rotationRadians;
	float rotationDegrees;
	float rotationSteps;
	int facingDirection;

	Laser(PVector p) {
		position = p;
		rayOrigin = new PVector(p.x + 18, p.y - 18);	//laser is offset to the right and the top;

		//direction laser is pointing (bottom left)
		direction = new PVector(-.75, .75);

		//create first ray
		firstRay = new Ray();
		firstRay.setOrigin(rayOrigin);
		firstRay.setDirection(direction);
	}

	//set laser diode's position
	void setPosition(PVector p) {
		//apply
		position = p;
		firstRay.setOrigin(position);
	}

	//set the laser diode's rotation
	void setDirection(PVector d) {
		direction = d;
		firstRay.setDirection(direction);
	}

	//draw all the rays emitting from that diode recursively
	void updateRays() {
		firstRay.update();
		firstRay.draw();
	}

	//draw the origin of the laser diode
	void drawOrigin() {
		noStroke();
		if (!active) fill(0, 0, 255);
		else fill(0, 255, 0);
		ellipse(rayOrigin.x, rayOrigin.y, 5, 5);
	}
}