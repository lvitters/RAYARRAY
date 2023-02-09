import netP5.*;
import oscP5.*;

ArrayList<Node> nodes;

int gridX = 10;
int gridY = 5;

float absoluteConnectionLength = 45.0;
float absoluteMirrorWidth = 12.0;
float scaleCentimetersToPixels = 3.0;
float cellSize = absoluteConnectionLength * 2.5;

float windowX, windowY;

int recursionGuard = 0;

boolean rotateLaser = false;

//set window size in settings() to determine it according to the grid size
void settings() {
	windowX = gridX * 140;
	windowY = gridY * 140;

	size(int(windowX), int(windowY));
}

void setup() {
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

	//calculate offset between nodes
	float offsetX = absoluteConnectionLength * scaleCentimetersToPixels;
	float offsetY = offsetX;

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
			n = new Node(new PVector(xPos + (x * offsetX), yPos + (y * offsetY)), x, y);
			nodes.add(n);
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