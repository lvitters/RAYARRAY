class Node {
	PVector position;
	PVector beginning;
	PVector end;
	float mirrorRadius = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);
	float connectionRadius = (scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2)) / 2; //TODO: figure out why it is sqrt(2)/2
	float rotation;
	float rT;

	Node(float x, float y) {
		position = new PVector(x, y);
		rotation = 0;
		rT = random(1000);
	}

	//update the mirrors values
	void update() {

		//for now rotate with noise
		rT += random(.001);
		rotation = radians(map(noise(rT), 0, 1, 0, 360 * 20));

		//apply rotation to beginning and end point of mirror like this instead of using rotate() so that the cast() method knows all the points
		beginning = new PVector(mirrorRadius * sin(rotation), mirrorRadius * cos(rotation));
		end = new PVector(-mirrorRadius * sin(rotation), -mirrorRadius * cos(rotation));
	}

	//draw rect to show the mirrors
	void drawMirror() {
		strokeWeight(3);
		stroke(255);
		pushMatrix();
			translate(position.x, position.y);
			line(beginning.x, beginning.y, end.x, end.y);
		popMatrix();
	}

	//draw lines to show the connections between nodes
	void drawConnections() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			line(connectionRadius, connectionRadius, 0, 0);
			line(connectionRadius, -connectionRadius, 0, 0);
			line(-connectionRadius, connectionRadius, 0, 0);
			line(-connectionRadius, -connectionRadius, 0, 0);
		popMatrix();
	}
}