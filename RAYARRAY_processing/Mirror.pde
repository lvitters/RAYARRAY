class Mirror {
	PVector position;
	PVector start = new PVector();
	PVector end = new PVector();
    PVector normal = new PVector();
	final float mirrorRadius = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);

	//rotation
	float rT;
	float rotationRadians;
	float rotationDegrees;
	float rotationOffset = random(360);
	float rotationSteps = 0;
	float rotationDirection = 1;
	float sineMultiplier;

	Mirror(PVector p) {
		position = p;

		//initial time at 0
		rT = 0;
	}

	//set start and end point according to rotation
	void setPointsAlongRadius(float r) {		
		
		//apply rotation to beginning and end point of mirror here instead of using rotate() so that the cast() method knows all the absolute points
		start.set(mirrorRadius * sin(r), mirrorRadius * cos(r));
		end.set(-mirrorRadius * sin(r), -mirrorRadius * cos(r));
		
		//apply rotation to normal (DPP)
		normal.set(sin(r - PI/2), cos(r - PI/2)); // rotated by 90° or PI/2
		
		//add position here instead of using translate() so that the cast() function knows all the absolute points
		start.add(position);
		end.add(position);
	}

	//update the mirrors values
	void rotate() {
		if (rotateMirrors) {
			//rotate according to rotation_mode (set by DropdownList)
			switch(mirrorRotationMode) {
				//same noise rotation, same direction
				case 0:
					//increment "time" and apply rotationSpeed
					rT += .2 * mirrorRotationSpeed;
					//map to rotationDegrees
					rotationDegrees += map(noise(rT), 0, 1, -.2, .2);
				break;
				//same noise rotation, individual direction
				case 1:
					//increment "time" and apply rotationSpeed
					rT += .2 * mirrorRotationSpeed;
					//map to rotationDegrees
					rotationDegrees += map(noise(rT), 0, 1, -.2, .2) * rotationDirection;
				break;
				//individual noise rotation
				case 2:
					//increment "time" individually and apply rotationSpeed
					rT += random(.1, .5) * mirrorRotationSpeed;
					//map to rotationDegrees
					rotationDegrees += map(noise(rT), 0, 1, -.2, .2);
				break;
				//same direction constant rotation
				case 3:
					//increment time and apply rotationSpeed
					rT += .5 * mirrorRotationSpeed;
					//map to rotationDegrees
					rotationDegrees = rT * rotationDirection;
				break;
				//same direction constant rotation, with offset
				case 4:
					//increment time and apply rotationSpeed
					rT += .5 * mirrorRotationSpeed;
					//map to rotationDegrees
					rotationDegrees = rT * rotationDirection;
					rotationDegrees += rotationOffset;
				break;
				//individual direction random rotation
				case 5:
					//increment time and apply rotationSpeed
					rT += random(.3, .6) * mirrorRotationSpeed;
					//map to rotationDegrees
					rotationDegrees = rT * rotationDirection;
				break;
				//sine speed with different multipliers, same direction
				case 6:
					//increment time
					rT += .00001;
					//map to rotationDegrees
					rotationDegrees += map(sin(rT), -1, 1, 0, 1) * (mirrorRotationSpeed/4) * sineMultiplier  * rotationDirection;
				break;
				//sine peed with different multipliers per row, same direction
				case 7:
					//increment time
					rT += .00001;
					//map to rotationDegrees
					rotationDegrees += map(sin(rT), -1, 1, 0, 1) * (mirrorRotationSpeed/4) * sineMultiplier  * rotationDirection;
				break;
				//sine peed with different multipliers per column, same direction
				case 8:
					//increment time
					rT += .00001;
					//map to rotationDegrees
					rotationDegrees += map(sin(rT), -1, 1, 0, 1) * (mirrorRotationSpeed/4) * sineMultiplier  * rotationDirection;
				break;
			}
		}

		//translate to stepper motor steps
		rotationSteps = (rotationDegrees * stepsPerDegree) + stepZero;

		//translate to radians for display, flip direction because Arduino is flipped, adjust for mirror's physical orientation
		rotationRadians = radians(-rotationDegrees) - (PI * .75);
		setPointsAlongRadius(rotationRadians);
	}

	//draw line to show the mirrors
	void draw() {
		strokeWeight(2);
        stroke(255);
        line(start.x, start.y, end.x, end.y);

        //draw normal (from DPP)
        // strokeWeight(1);
        // final float mNormalScale = 10;
        // line(
        //     position.x,
        //     position.y,
        //     position.x + normal.x * mNormalScale,
        //     position.y + normal.y * mNormalScale
        //     );
	}

	//reset mirror to original rotation
	void setHome() {
		rT = 0;
		rotationRadians = (-PI * 3/4);
		rotationDegrees = 0;
		rotationSteps = 0;
	}
}