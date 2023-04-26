class Laser {
	PVector position, direction;
	boolean active;
	Ray firstRay;

	//rotation
	float rT;
	float rotationRadians;
	float rotationDegrees;
	float rotationSteps;
	int facingDirection;

	Laser(PVector p, int column, int row) {
		position = p;
		firstRay = new Ray();
		determineFacingDirection(column, row);
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
	void rotate() {
		if (rotateLasers) {
			//increment "time" and apply rotationSpeed
			rT += .002 * laserRotationSpeed;

			//map to rotationDegrees
			switch (facingDirection) {
				//somewhere inside grid
				case 0:
					rotationDegrees = map(sin(rT), -1, 1, -360, 360);
				break;
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
		
		//write to laser's rotationSteps, correct for laser's physical orientation
		rotationSteps = ((rotationDegrees+45) * stepsPerDegree);	//direction for some reason is not flipped from Arduino

		//translate to radians for display
		rotationRadians = radians(rotationDegrees);	
		setDirection(PVector.fromAngle(rotationRadians).normalize());
	}

	//bring laser to original direction
	void goHome() {
		//reset time
		rT = 0;

		//reset direction
		switch (facingDirection) {
			//somewhere in middle
			case 0:
				direction = new PVector(1, 0);
			break;
			//top left
			case 1:				
				direction = new PVector(1, 1);
			break;
			//top right
			case 2:		
				direction = new PVector(-.7, .7);
			break;
			//bottom right
			case 3:			
				direction = new PVector(-.7, -.7);
			break;
			//bottom left
			case 4:
				direction = new PVector(1, -1);
			break;
			//left side
			case 5:				
				direction = new PVector(1, 0);
			break;
			//right side
			case 6:				
				direction = new PVector(-1, 0);
			break;
			//top
			case 7:				
				direction = new PVector(0, 1);
			break;
			//bottom
			case 8:				
				direction = new PVector(0, -1);
			break;
		}

		//move laser there
		setDirection(direction);
	}

	//determine which direction the laser is facing, depending on where it is in grid, to limit its movement (it has a cable)
	void determineFacingDirection(int column, int row) {
		//first somewhere not on the edge of the grid (unused)
		if ((row != 0 && row != gridY-1 && column != 0 && column != gridX-1) || gridX == 1 && gridY == 1) {
			facingDirection = 0;
		}
		//then the corners
		else if (column == 0 & row == 0) {					//top left
			facingDirection = 1;
		} 
		else if (column == gridX-1 && row == 0) {			//top right	
			facingDirection = 2;
		} 
		else if (column == gridX-1 && row == gridY-1) {	//bottom right
			facingDirection = 3;
		} 
		else if (column == 0 && row == gridY-1) {			//bottom left
			facingDirection = 4;				
		}
		//now the edges
		else if (column == 0 ) {					//left side
			facingDirection = 5;
		} 
		else if (column == gridX-1) {				//right side
			facingDirection = 6;
		} 
		else if (row == 0 && column != 0) {		//top
			facingDirection = 7;
		} 
		else if (row == gridY-1) {				//bottom
			facingDirection = 8;
		}

		//apply that direction
		goHome();
	}
}