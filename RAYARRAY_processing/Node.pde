class Node {
	PVector position;
	int index;
	float rotation;
	float mirrorWidth;
	float mirrorHeight;
	float rT;

	Node(float x, float y) {
		position = new PVector(x, y);
		//index = i;
		mirrorWidth = absoluteMirrorWidth * scaleCentimetersToPixels;
		mirrorHeight = 2;
		rotation = 0;
		rT = random(1000);
	}

	//update the mirrors values
	void update() {
		rT += random(.001);
		rotation = radians(map(noise(rT), 0, 1, 0, 360 * 20));
	}

	//draw rect to show the mirrors
	void drawMirror() {
		noStroke();
		pushMatrix();
			translate(position.x, position.y);
			rotate(rotation);
			rect(0, 0, mirrorWidth, mirrorHeight);
		popMatrix();
	}

	//draw lines to show the connections between nodes
	void drawConnections() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			float lineEndpoint = scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2);
			lineEndpoint = lineEndpoint / 2;
			line(lineEndpoint, lineEndpoint, 0, 0);
			line(lineEndpoint, -lineEndpoint, 0, 0);
			line(-lineEndpoint, lineEndpoint, 0, 0);
			line(-lineEndpoint, -lineEndpoint, 0, 0);
		popMatrix();
	}
}