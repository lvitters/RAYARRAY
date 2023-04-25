class Laser {
	PVector position, direction;
	boolean active;
	Ray firstRay;

	float rotationRadians;
	float rotationDegrees;
	float previousDegrees;
	int rotationSteps;
	int revolutions = 0;
	int facingDirection;
	float rT;

	Laser(PVector p, int column, int row) {
		position = p;
		determineFacingDirection(column, row);
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
	void rotate() {
		if (rotateLasers) {
			//increment "time" and apply rotationSpeed
			rT += .002 * rotationSpeed;
			//map to rotationDegrees
			switch (facingDirection) {
				//top left
				case 1:
					rotationDegrees = map(sin(rT), -1, 1, 0, 90);
				break;
				//top right
				case 2:
					rotationDegrees = map(sin(rT), -1, 1, 90, 180);
				break;
				//bottom right
				case 3:
					rotationDegrees = map(sin(rT), -1, 1, 180, 270);
				break;
				//bottom left
				case 4:
					rotationDegrees = map(sin(rT), -1, 1, 270, 360);
				break;
				//left side
				case 5:
					rotationDegrees = map(sin(rT), -1, 1, -90, 90);
				break;
				//right side
				case 6:
					rotationDegrees = map(sin(rT), -1, 1, 270, 90);
				break;
				//top
				case 7:
					rotationDegrees = map(sin(rT), -1, 1, 180, 0);
				break;
				//bottom
				case 8:
					rotationDegrees = map(sin(rT), -1, 1, 180, 360);
				break;
			}
		}

		//translate to radians for display
		rotationRadians = radians(rotationDegrees);

		//get new vector
		PVector newDirection = PVector.fromAngle(rotationRadians).normalize();

		//set to direction
		setDirection(newDirection);
	}

	//get rotationSteps from laser's direction to send to node
	void setRotationSteps(PVector d) {
		//get radians from direction vector
		float rotationRadiansForSteps = atan2(d.x, d.y);
		
		//adjust for physical node's orientation
		rotationRadiansForSteps -= PI * 3/4;
		
		//change to degrees
		rotationDegrees = degrees(rotationRadians);

		println(rotationDegrees);

		//write to steps
		rotationSteps = int((rotationDegrees) * stepsPerDegree) * -1;		//direction is flipped from Arduino
	}

	//determine which direction the laser is facing, depending on where it is in grid, to limit its movement (it has a cable)
	void determineFacingDirection(int column, int row) {
		//first somewhere not on the edge of the grid (unused)
		if (row != 0 && row != gridY-1 && column != 0 && column != gridX-1) {
			facingDirection = 0;
			direction = new PVector(random(-1, 1), random(-1,1));
		}
		//then the corners
		else if (column == 0 & row == 0) {					//top left
			facingDirection = 1;				
			direction = new PVector(1, 1);
		} else if (column == gridX-1 && row == 0) {			//top right	
			facingDirection = 2; 				
			direction = new PVector(-.7, .7);
		} else if (column == gridX-1 && row == gridY-1) {	//bottom right
			facingDirection = 3;				
			direction = new PVector(-.7, -.7);
		} else if (column == 0 && row == gridY-1) {			//bottom left
			facingDirection = 4;				
			direction = new PVector(1, -1);
		}
		//now the edges
		else if (column == 0 ) {					//left side
			facingDirection = 5;				
			direction = new PVector(1, 0);
		} else if (column == gridY-1) {				//right side
			facingDirection = 6;				
			direction = new PVector(-1, 0);
		} else if (row == 0 && column != 0) {		//top
			facingDirection = 7;				
			direction = new PVector(0, 1);
		} else if (row == gridY-1) {				//bottom
			facingDirection = 8;				
			direction = new PVector(0, -1);
		}
		//println(facingDirection);
	}
}