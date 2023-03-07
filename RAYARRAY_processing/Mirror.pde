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

	Mirror(PVector p) {
		position = p;
		rT = random(1000);

		//random initial rotation
		setPointsAlongRadius(random(PI));
	}

	//set start and end point according to rotation
	void setPointsAlongRadius(float r) {
		
		r = -r/2; //TODO: understand why
		
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
	void update() {
		//increment "time"
		//rT += random(.002, .005);
		rT += .003;

		//rotate according to rotation_mode (set by DropdownList)
		switch(rotation_mode) {
			//sine rotation
			case 0:
				rotationDegrees = map(sin(rT), -1, 1, 0, 360);
				break;
			//noise rotation
			case 1:
				rotationDegrees = map(noise(rT), -1, 1, 0, 360);
				break;
		}

		//apply rotation speed
		rotationDegrees *= rotation_speed;

		//translate to stepper motor steps
		rotationSteps = map(rotationDegrees, 0, 360, 0, 2038);

		//translate to radians for display
		rotationRadians = radians(rotationDegrees);
		setPointsAlongRadius(rotationRadians);
	}

	//draw line to show the mirrors
	void draw() {
		strokeWeight(2);
        stroke(255);
        line(start.x, start.y, end.x, end.y);

        //draw normal (DPP)
        // strokeWeight(1);
        // final float mNormalScale = 10;
        // line(
        //     position.x,
        //     position.y,
        //     position.x + normal.x * mNormalScale,
        //     position.y + normal.y * mNormalScale
        //     );
	}
}