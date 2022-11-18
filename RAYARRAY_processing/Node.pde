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

	void draw() {
		noStroke();
		pushMatrix();
			rect(position.x, position.y, mirrorWidth, mirrorHeight);
		popMatrix();
	}
}