class Node {
	PVector position;
	PVector start = new PVector();
	PVector end = new PVector();
	final float mirrorRadius = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);
	final float jointRadius = (scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2)); //TODO: figure out why it is sqrt(2)/2
	float rotation;
	float rT;

	Node(float x, float y) {
		position = new PVector(x, y);
		rT = random(1000);

		//random initial rotation
		setRotation(PI/4);
	}

	//update the mirrors values
	void updateRotation() {
		//for now rotate with noise
		rT += random(.001);
		rotation = radians(map(noise(rT), 0, 1, 0, 360 * 20));

		setRotation(rotation);
	}

	//set start and end point according to rotation
	void setRotation(float r) {
		//apply rotation to beginning and end point of mirror here instead of using rotate() so that the cast() method knows all the absolute points
		start.set(mirrorRadius * sin(r), mirrorRadius * cos(r));
		end.set(-mirrorRadius * sin(r), -mirrorRadius * cos(r));

		//add position here instead of using translate() so that the cast() function knows all the absolute points
		start.add(position);
		end.add(position);
	}

	//draw line to show the mirrors
	void drawMirror() {
		strokeWeight(3);
		stroke(255);
		line(start.x, start.y, end.x, end.y);
	}

	//draw lines to show the joints between the nodes
	void drawJoints() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			//TODO: figure out to omit the "outer" joints of the "outer" nodes
			line(jointRadius/2, jointRadius/2, 0, 0);
			line(jointRadius/2, -jointRadius/2, 0, 0);
			line(-jointRadius/2, jointRadius/2, 0, 0);
			line(-jointRadius/2, -jointRadius/2, 0, 0);
		popMatrix();
	}
}