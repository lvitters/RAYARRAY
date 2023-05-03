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
	ArrayList<Integer> directions = new ArrayList<Integer>();

	Laser(PVector p, int column, int row) {
		position = p;

		//original direction, when laser is homed
		direction = new PVector(-.75, .75);

		determineDirections(column, row);

		//create first ray
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
		rotationDegrees = degrees(atan2(direction.y, direction.x) - (PI * .75));

		//write to laser's rotationSteps, correct for laser's physical orientation
		rotationSteps = ((rotationDegrees) * stepsPerDegree) + stepZero;	//direction for some reason is not flipped from motor
	}

	//bring laser to original direction
	void setHome() {
		//reset time
		rT = 0;
		//move laser there
		setDirection(new PVector(-.7, .7));
	}

	//determine which directions the laser can face depending on where it is in grid, to limit its movement (it has a cable); sorry to whomever sees this
	void determineDirections(int column, int row) {
		//first somewhere not on the edge of the grid (unused)
		if ((row != 0 && row != gridY-1 && column != 0 && column != gridX-1) || gridX == 1 && gridY == 1) {
			for (int i = 0; i < 8; i++) {
				directions.add(stepsPerRevolution * (i+1)/8);
			}
		}
		//then the corners
		//top left
		else if (column == 0 & row == 0) {					
			facingDirection = 1;
			directions.add(stepsPerRevolution * 4/8);
			directions.add(stepsPerRevolution * 5/8);
			directions.add(stepsPerRevolution * 6/8);

		}
		//top right	
		else if (column == gridX-1 && row == 0) {			
			facingDirection = 2;
			directions.add(stepsPerRevolution * 6/8);
			directions.add(stepsPerRevolution * 7/8);
			directions.add(stepsPerRevolution * 8/8);
		} 
		//bottom right
		else if (column == gridX-1 && row == gridY-1) {		
			facingDirection = 3;
			directions.add(stepsPerRevolution * 8/8);
			directions.add(stepsPerRevolution * 1/8);
			directions.add(stepsPerRevolution * 2/8);
		}
		//bottom left
		else if (column == 0 && row == gridY-1) {			
			directions.add(stepsPerRevolution * 4/8);
			directions.add(stepsPerRevolution * 3/8);
			directions.add(stepsPerRevolution * 2/8);
		}
		//now the edges
		//left side
		else if (column == 0 ) {							
			facingDirection = 5;
			directions.add(stepsPerRevolution * 2/8);
			directions.add(stepsPerRevolution * 3/8);
			directions.add(stepsPerRevolution * 4/8);
			directions.add(stepsPerRevolution * 5/8);
			directions.add(stepsPerRevolution * 6/8);
		}
		//right side
		else if (column == gridX-1) {						
			facingDirection = 6;
			directions.add(stepsPerRevolution * 6/8);
			directions.add(stepsPerRevolution * 7/8);
			directions.add(stepsPerRevolution * 8/8);
			directions.add(stepsPerRevolution * 1/8);
			directions.add(stepsPerRevolution * 2/8);
		}
		//top
		else if (row == 0 && column != 0) {					
			facingDirection = 7;
			directions.add(stepsPerRevolution * 4/8);
			directions.add(stepsPerRevolution * 5/8);
			directions.add(stepsPerRevolution * 6/8);
			directions.add(stepsPerRevolution * 7/8);
			directions.add(stepsPerRevolution * 8/8);
		}
		//bottom
		else if (row == gridY-1) {							
			facingDirection = 8;
			directions.add(stepsPerRevolution * 8/8);
			directions.add(stepsPerRevolution * 1/8);
			directions.add(stepsPerRevolution * 2/8);
			directions.add(stepsPerRevolution * 3/8);
			directions.add(stepsPerRevolution * 4/8);
		}
	}
}