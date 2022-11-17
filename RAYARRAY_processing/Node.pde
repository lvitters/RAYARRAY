class Node {
	PVector position;
	int index;
	int mirrorWidth;
	int mirrorHeight;

	Node(float x, float y) {
		position = new PVector(x, y);
		//index = i;
		mirrorWidth = 24;
		mirrorHeight = 4;
	}

	void update() {

	}

	void draw() {
		noStroke();
		rect(position.x, position.y, mirrorWidth, mirrorHeight);
	}
}