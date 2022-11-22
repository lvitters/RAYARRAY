class Node {
	PVector position;
	float mirrorEndpoint = scaleCentimetersToPixels * absoluteMirrorWidth/2 * (sqrt(2)/2);
	float connectionEndpoint = (scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2)) / 2;
	float rotation;
	float rT;

	Node(float x, float y) {
		position = new PVector(x, y);
		//index = i;
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
		strokeWeight(3);
		stroke(255);
		pushMatrix();
			translate(position.x, position.y);
			rotate(rotation);
			line(-mirrorEndpoint, -mirrorEndpoint, mirrorEndpoint, mirrorEndpoint);
		popMatrix();
	}

	//draw lines to show the connections between nodes
	void drawConnections() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			line(connectionEndpoint, connectionEndpoint, 0, 0);
			line(connectionEndpoint, -connectionEndpoint, 0, 0);
			line(-connectionEndpoint, connectionEndpoint, 0, 0);
			line(-connectionEndpoint, -connectionEndpoint, 0, 0);
		popMatrix();
	}
}