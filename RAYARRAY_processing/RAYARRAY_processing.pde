import netP5.*;
import oscP5.*;

import controlP5.*;
ControlP5 cp5;

ArrayList<Node> nodes;

int gridX = 10;
int gridY = 5;

float windowX, windowY;

float absoluteConnectionLength = 45.0;
float absoluteMirrorWidth = 12.0;
float scaleCentimetersToPixels = 3.0;
float offset = absoluteConnectionLength * scaleCentimetersToPixels;	//offset between nodes

int recursionGuard = 0;

boolean rotateLaser = false;

PFont font;

//scale window size according to grid measurements
void settings() {
	windowX = gridX * absoluteConnectionLength * scaleCentimetersToPixels;
	windowY = gridY * absoluteConnectionLength * scaleCentimetersToPixels;

	size(int(windowX), int(windowY));
}

void setup() {
	frameRate(60);
	rectMode(CENTER);
	ellipseMode(CENTER);
	surface.setResizable(true);
	font = createFont("arial", 20);

	//init ControlP5
	cp5 = new ControlP5(this);

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

	//calculate width of the entire grid
	float gridWidth = gridX * offset;
	float gridHeight = gridY * offset;

	//find position where center of grid will be center of window
	float xPos = (width - gridWidth)/2 + offset/2;
	float yPos = (height - gridHeight)/2 + offset/2;

	//add nodes depending on grid size
	for (int x = 0; x < gridX; x++) {
		for (int y = 0; y < gridY; y++) {
			Node n;
			n = new Node(new PVector(xPos + (x * offset), yPos + (y * offset)), x, y, nodes.size() + 1);
			nodes.add(n);
		}
	}
}

//control lasers
void mousePressed() {
		//switch mode for the node that was clicked on with LEFT mouse button
		if (mouseButton == LEFT) {
			for (Node n : nodes) {
				if (n.mouseOver()) {
					if (n.mode < 2) n.mode++;
					else n.mode = 0;
				}
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

void keyPressed() {
	//input node's ID
	if (keyCode == 'I') {
		for (Node n : nodes) {
			if (n.mouseOver() && n.mirror != null && n.inputField.isVisible() == false) {
				n.setInputfieldActive(true);
			} else {
				n.setInputfieldActive(false);
			}
		}
	}
	if (keyCode == ENTER) {
		for (Node n : nodes) {
			if (n.inputField.isVisible()) {
				n.submit();
				n.setInputfieldActive(false);
			}
		}
	}
}