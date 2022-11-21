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

	//calculate offset between nodes
	float offsetX = gridWidth / gridX;
	float offsetY = offsetX/2;

	//add nodes depending on grid size
	for (int x = 0; x < gridX; x++) {
		for (int y = 0; y < gridY; y++) {
			Node n;
			//offset every second row
			if (y % 2 == 0) {
				//omit last column
				if (x != gridX-1) {
					n = new Node((x * offsetX) + offsetX/2, y * offsetY);
					nodes.add(n);
				}
			} else {
				//omit last row
				if (y != gridY-1) {
					n = new Node(x * offsetX, y * offsetY);
					nodes.add(n);
				}
			}
		}
	}
}

//draw each node
void drawNodes() {
	for (Node n : nodes) {
		n.update();
		n.drawConnections();
		n.drawMirror();
	} 
}