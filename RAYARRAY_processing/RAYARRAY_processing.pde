import netP5.*;
import oscP5.*;

ArrayList<Node> nodes;

int gridX = 4;
int gridY = 8;

float absoluteConnectionLength = 45.0;
float absoluteMirrorWidth = 12.0;
float scaleCentimetersToPixels = 3.0;
float cellSize = absoluteConnectionLength * 2.5;

int recursionGuard = 0;

boolean rotateLaser = false;

void setup() {
	//settings
	size(900, 900);
	frameRate(60);
	rectMode(CENTER);
	ellipseMode(CENTER);
	surface.setResizable(true);

	//init grid
	nodes = new ArrayList<Node>();
	constructGrid();
}

void draw() {
	background(0);

	updateNodes();
}

//draw each node
void updateNodes() {
	//draw joints and highlights for all nodes first so they are in the background
	for (Node n : nodes) {
		n.drawJoints();
		n.drawHighlight();
	}
	//then draw the mirrors or lasers on top
	for (Node n : nodes) {
		n.update();
	} 
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
	float gridHeight = gridY * offsetY;

	//find position where center of grid will be center of window
	float xPos = (width - gridWidth)/2 + offsetX/2;
	float yPos = (height - gridHeight)/2 + offsetY/2;

	//add nodes depending on grid size
	for (int x = 0; x < gridX; x++) {
		for (int y = 0; y < gridY; y++) {
			Node n;
			//offset every second row
			if (y % 2 == 0) {
				//omit last column for symmetry
				if (x != gridX-1) {
					n = new Node(new PVector(xPos + (x * offsetX) + offsetX/2, yPos + (y * offsetY)));
					nodes.add(n);
				}
			} else {
				//omit last row for symmetry
				if (y != gridY-1) {
					n = new Node(new PVector(xPos + (x * offsetX), yPos + (y * offsetY)));
					nodes.add(n);
				}
			}
		}
	}
}

//control lasers
void mousePressed() {
		//switch mode for the node that was clicked on with LEFT mouse button
		if (mouseButton == LEFT) {
			for (Node n : nodes) {
				if (n.mouseOver()) 
				{	
					if (n.mode < 2) n.mode++;
					else n.mode = 0;
				}
				n.switchMode(n.mode);
			}
		}
		//rotate laser only if RIGHT mouse button is pressed
		if (mouseButton == RIGHT) {
			rotateLaser = true;
		}
}

//reset when mouse buttons are released
void mouseReleased() {
	rotateLaser = false;
}