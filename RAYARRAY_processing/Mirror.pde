class Mirror {
	PVector position;
	PVector start = new PVector();
	PVector end = new PVector();
    PVector normal = new PVector();
	final float mirrorRadius = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);
	float rotation;
	float rT;

	Mirror(float x, float y) {
		position = new PVector(x, y);
		rT = random(1000);

		//random initial rotation
		setRotation(random(PI));
	}

	//set start and end point according to rotation
	void setRotation(float r) {
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
		//for now rotate with noise
		rT += random(.0001);
		//rotation = radians(map(noise(rT), 0, 1, 0, 360 * 20));
		rotation = radians(map(sin(rT), 0, 1, 0, 360 * 20));

		setRotation(rotation);
	}

	//draw line to show the mirrors
	void draw() {
		strokeWeight(2);
        stroke(255);
        line(start.x, start.y, end.x, end.y);

        // draw normal (DPP)
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