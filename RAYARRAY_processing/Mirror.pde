class Mirror {
	PVector position;
	PVector start = new PVector();
	PVector end = new PVector();
    PVector normal = new PVector();
	final float mirrorRadius = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);
	float rT;
	float rotationRadians;
	float rotationDegrees;
	float rotationSteps;
	float rotationDirection = 1;

	Mirror(PVector p) {
		position = p;

		//initial time at 0
		rT = 0;
	}

	//set start and end point according to rotation
	void setPointsAlongRadius(float r) {
		
		//r = -r/2; 	//TODO: why was this ever here? let's leave for now so I remember this might have fixed something at some point

		//to correct for the physical nodes orientation
		r += PI/4;
		
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
			switch(rotationMode) {
				//same noise rotation
				case 0:
					//increment "time" and apply rotationSpeed
					rT += .001 * rotationSpeed;
					//map to rotationDegrees
					rotationDegrees = map(sin(rT), -1, 1, 0, 360);
					break;
				//individual noise rotation
				case 1:
					//increment "time" individually and apply rotationSpeed
					rT += random(.001, .01) * rotationSpeed;
					//map to rotationDegrees
					rotationDegrees = map(noise(rT), -1, 1, 0, 360);
					break;
				//same direction constant rotation
				case 2:
					//increment time and apply rotationSpeed
					rT += .001 * rotationSpeed;
					//map to rotationDegrees
					rotationDegrees = rT * 360;
					break;
				//individual direction constant rotation
				case 3:
					//increment time and apply rotationSpeed
					rT +=  .001 * rotationSpeed;
					//map to rotationDegrees
					rotationDegrees = rT * 360;
			}
		}

		//apply direction
		rotationDegrees *= rotationDirection;

		//translate to stepper motor steps
		rotationSteps = (rotationDegrees * (stepsPerRevolution / 360)) * -1;	//direction in flipped from Arduino

		//translate to radians for display
		rotationRadians = radians(rotationDegrees);
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

	//go to default mirror position
	void goHome() {
		rotationDegrees = 0;
	}
}