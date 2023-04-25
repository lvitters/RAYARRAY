class Laser {
	PVector position, direction;
	boolean active;
	Ray firstRay;

	float rotationRadians;
	float rotationDegrees;
	float previousDegrees;
	int rotationSteps;
	int revolutions = 0;

	Laser(PVector p) {
		position = p;
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

	//set the laser diode's rotation
	void setDirection(PVector d) {
		direction = d;
		firstRay.setDirection(direction);

		setRotationSteps(direction);
	}

	//get rotationSteps from laser's direction to send to node
	void setRotationSteps(PVector d) {
		//get radians from direction vector
		rotationRadians = atan2(d.x, d.y);
		
		//adjust for physical node's orientation
		rotationRadians -= PI * 3/4;
		
		//shift to be from 0 to 360
		rotationDegrees = degrees(rotationRadians) + 315;
		
		//count revolutions
		if(rotationDegrees >= (360)) {
			revolutions++;
		} else if (rotationDegrees <= (0)) {
			revolutions--;
		}
		rotationDegrees += revolutions * 360;
		previousDegrees = rotationDegrees;

		println("revs: " + revolutions + " rotationDegrees: " + rotationDegrees);

		//write to steps
		rotationSteps = int((rotationDegrees - 315) * stepsPerDegree) * -1;		//direction is flipped from Arduino
	}

	//draw all the rays emitting from that diode recursively
	void update() {
		firstRay.update();
		firstRay.draw();
	}

	//draw the origin of the laser diode
	void drawOrigin() {
		noStroke();
		if (!active) fill(0, 0, 255);
		else fill(0, 255, 0);
		ellipse(position.x, position.y, 10, 10);
	}
}