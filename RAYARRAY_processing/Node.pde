class Node {
	PVector position;
	PVector start = new PVector();
	PVector end = new PVector();
    PVector normal = new PVector();
	final float mirrorRadius = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);
	final float jointRadius = (scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2)); //TODO: figure out why it is sqrt(2)/2
	float rotation;
	float rT;

	Node(float x, float y) {
		position = new PVector(x, y);
		rT = random(1000);

		//random initial rotation
		setRotation(random(PI));
	}

	//update the mirrors values
	void updateRotation() {
		//for now rotate with noise
		rT += random(.0005);
		rotation = radians(map(noise(rT), 0, 1, 0, 360 * 20));

		setRotation(rotation);
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

	//draw line to show the mirrors
	void drawMirror() {
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

	//draw lines to show the joints between the nodes
	void drawJoints() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			//TODO: figure out how to omit the "outer" joints of the "outer" nodes
			line(jointRadius/2, jointRadius/2, 0, 0);
			line(jointRadius/2, -jointRadius/2, 0, 0);
			line(-jointRadius/2, jointRadius/2, 0, 0);
			line(-jointRadius/2, -jointRadius/2, 0, 0);
		popMatrix();
	}
}