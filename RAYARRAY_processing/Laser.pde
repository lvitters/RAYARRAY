class Laser {
	PVector position, direction, startDirection;
	boolean active;
	Ray firstRay;

	//rotation
	float rT;
	float rotationRadians;
	float rotationDegrees;
	float rotationSteps;
	int facingDirection;
	int leftBound, rightBound;

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
				switch (laserRotationMode)	{
					//same sine rotation
					case 0:
						//increment "time" and apply rotationSpeed
						rT += .002 * laserRotationSpeed;
						//map to degrees
						rotationDegrees = map(sin(rT), -1, 1, leftBound, rightBound);
					break;
					//individual sine rotation
					case 1:
						//increment "time" and apply rotationSpeed
						rT += random(.0001, .005) * laserRotationSpeed;
						//map to degrees
						rotationDegrees = map(sin(rT), -1, 1, leftBound, rightBound);
					break;
					//individual noise rotation
					case 2:
						//increment "time" and apply rotationSpeed
						rT += random(.0001, .005) * laserRotationSpeed;
						//map to degrees
						rotationDegrees = map(noise(rT), 0, 1, leftBound, rightBound);
					break;
				}

			//translate to radians for display
			rotationRadians = radians(rotationDegrees);	
			setDirection(PVector.fromAngle(rotationRadians).normalize());
		}

		//write to laser's rotationSteps, correct for laser's physical orientation
		rotationSteps = ((rotationDegrees+135) * stepsPerDegree) + stepZero;	//direction for some reason is not flipped from motor
	}

	//bring laser to original direction
	void setHome() {
		//reset time
		rT = 0;
		//move laser there
		setDirection(new PVector(-.7, .7));
	}

	//determine which direction the laser is facing, depending on where it is in grid, to limit its movement (it has a cable)
	void determineFacingDirection(int column, int row) {
		//first somewhere not on the edge of the grid (unused)
		if ((row != 0 && row != gridY-1 && column != 0 && column != gridX-1) || gridX == 1 && gridY == 1) {
			facingDirection = 0;
			leftBound = -360;
			rightBound = 370;
		}
		//then the corners
		//top left
		else if (column == 0 & row == 0) {					
			facingDirection = 1;
			leftBound = -10;
			rightBound = 90;
		}
		//top right	
		else if (column == gridX-1 && row == 0) {			
			facingDirection = 2;
			leftBound = 80;
			rightBound = 180;
		} 
		//bottom right
		else if (column == gridX-1 && row == gridY-1) {		
			facingDirection = 3;
			leftBound = 170;
			rightBound = 270;
		}
		//bottom left
		else if (column == 0 && row == gridY-1) {			
			facingDirection = 4;
			leftBound = 260;
			rightBound = 360;		
		}
		//now the edges
		//left side
		else if (column == 0 ) {							
			facingDirection = 5;
			leftBound = -100;
			rightBound = 90;
		}
		//right side
		else if (column == gridX-1) {						
			facingDirection = 6;
			leftBound = 260;
			rightBound = 90;
		}
		//top
		else if (row == 0 && column != 0) {					
			facingDirection = 7;
			leftBound = 190;
			rightBound = 0;
		}
		//bottom
		else if (row == gridY-1) {							
			facingDirection = 8;
			leftBound = 190;
			rightBound = 370;
		}

		//apply that direction
		setHome();
	}
}