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

	//get rotationSteps from laser's direction to send to node
	void setRotationSteps(PVector d) {
		//get radians from direction vector
		rotationRadians = atan2(d.x, d.y);
		
		//adjust for physical node's orientation
		rotationRadians -= PI * 3/4;
		
		//shift to be from 0 to 360
		rotationDegrees = degrees(rotationRadians);

		//write to steps
		rotationSteps = int((rotationDegrees) * stepsPerDegree) * -1;		//direction is flipped from Arduino

		println(d);
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

	//determine which direction the laser is facing, depending on where it is in grid, to limit its movement (it has a cable)
	void determineFacingDirection(int column, int row) {
		//first somewhere not on the edge of the grid
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
		println(facingDirection);
	}
}