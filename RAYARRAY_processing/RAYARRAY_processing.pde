import netP5.*;

ArrayList<Node> nodes;

int gridX = 12;
int gridY = 12;
int gridWidth = 1000;
int gridHeight = 1000;

void setup() {
	size(1200, 1200);
	frameRate(60);
	rectMode(CENTER);

	nodes = new ArrayList<Node>();
	constructGrid();
}

void draw() {
	background(0);

	drawNodes();
}

//depending on the configuration, construct a grid of nodes in the given pattern
void constructGrid() {

	float cellWidth = gridWidth / gridX;

	for (int r = 1; r < gridX; r++) {
		for (int c = 1; c < gridY; c++) {
			Node n = new Node(r * cellWidth, c * cellWidth);
			nodes.add(n);
		}
	}

	/*
	//thanks DPP for this new way of constructing a grid
	for (int i = 0; i < gridX * gridY; i++) {
		int x = i % gridX;
		int y = i / gridX;
		float cellWidth = gridWidth / (float) (gridX + 1);

		Node n = new Node(x * cellWidth + cellWidth, y * cellWidth + cellWidth);
		nodes.add(n);
	}
	*/
}

//draw each node
void drawNodes() {
	for (Node n : nodes) n.draw();
}