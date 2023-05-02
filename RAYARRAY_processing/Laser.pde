class Laser {
	PVector position, direction, startDirection;
	boolean active;
	Ray firstRay;

	//rotation
	float rT;
	float rotationRadians;
	float rotationDegrees;
	float rotationSteps;

	Laser(PVector p, int column, int row) {
		position = p;
		direction = new PVector(-.7, .7);
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
		ellipse(position.x, position.y, 10, 10);
	}
	
	//update the mirrors values
	void writeToSteps() {
		//get degrees from direction vector
		rotationDegrees = -degrees(atan2(direction.x, direction.y) - (PI/2));

		//write to laser's rotationSteps, correct for laser's physical orientation
		rotationSteps = ((rotationDegrees+225) * stepsPerDegree) + stepZero;	//direction for some reason is not flipped from motor
	}

	//bring laser to original direction
	void setHome() {
		//reset time
		rT = 0;
		//move laser there
		setDirection(new PVector(-.7, .7));
	}
}