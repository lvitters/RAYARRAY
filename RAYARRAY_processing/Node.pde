class Node {
	PVector position;
	Mirror mirror;
	//Laser laser;
	final float jointRadius = (scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2)); //TODO: figure out why it is sqrt(2)/2

	Node(float x, float y) {
		position = new PVector(x, y);
		mirror = new Mirror(x, y);
	}

	//update and draw mirror or laser
	void update() {
		drawJoints();
		mirror.update();
		mirror.draw();
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