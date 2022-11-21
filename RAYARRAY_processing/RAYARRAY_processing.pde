import netP5.*;

ArrayList<Node> nodes;

int gridX = 8;
int gridY = 6;

float absoluteConnectionLength = 45.0;
float absoluteMirrorWidth = 12.0;
float scaleCentimetersToPixels = 2.0;

void setup() {
	size(1200, 700);
	frameRate(60);
	rectMode(CENTER);
	surface.setResizable(true);

	nodes = new ArrayList<Node>();
	constructGrid();
}

void draw() {
	background(0);

	drawNodes();
}

//depending on the configuration, construct a grid of nodes in the given pattern
void constructGrid() {

	//add one to grid because one will be removed later so the grid looks symmetrical
	gridX += 1;
	gridY += 1;

	//calculate offset between nodes
	float offsetX = (sqrt(2) * absoluteConnectionLength) * scaleCentimetersToPixels;
	float offsetY = offsetX/2;

	//calculate width of the entire grid
	float gridWidth = gridX * offsetX;

	//find position where center of grid will be center of window
	float xPos = (width - gridWidth)/2 + offsetX/2;
	float yPos = (height - gridWidth/2)/2 + offsetY;

	//add nodes depending on grid size
	for (int x = 0; x < gridX; x++) {
		for (int y = 0; y < gridY; y++) {
			Node n;
			//offset every second row
			if (y % 2 == 0) {
				//omit last column for symmetry
				if (x != gridX-1) {
					n = new Node(xPos + (x * offsetX) + offsetX/2, yPos + (y * offsetY));
					nodes.add(n);
				}
			} else {
				//omit last row for symmetry
				if (y != gridY-1) {
					n = new Node(xPos + (x * offsetX), yPos + (y * offsetY));
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