class Node {
	PVector position;
	int index;
	int mirrorWidth;
	int mirrorHeight;
	float rotation;

	Node(float x, float y) {
		position = new PVector(x, y);
		//index = i;
		mirrorWidth = 24;
		mirrorHeight = 4;
		rotation = radians(random(361));
	}

	void update() {

	}

	void drawMirror() {
		noStroke();
		pushMatrix();
			//translate(-width/2, -height/2);
			//rotate(rotation);
			rect(position.x, position.y, mirrorHeight, mirrorHeight);
		popMatrix();
	}

	void drawConnections() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
		translate(position.x, position.y);
			line(-20, -20, 20, 20);
			line(20, -20, -20, 20);
		popMatrix();
	}
}