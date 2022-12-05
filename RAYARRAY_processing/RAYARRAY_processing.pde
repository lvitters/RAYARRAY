import netP5.*;

ArrayList<Node> nodes;
ArrayList<Laser> lasers;

int gridX = 8;
int gridY = 6;

float absoluteConnectionLength = 45.0;
float absoluteMirrorWidth = 12.0;
float scaleCentimetersToPixels = 2.5;

float diodeRotation = PI/2;

int activeLaser = 0;

float defaultRayLength = 2000;

int recursionGuard = 0;

void setup() {
	size(1700, 900);
	frameRate(60);
	rectMode(CENTER);
	surface.setResizable(true);

	nodes = new ArrayList<Node>();
	constructGrid();

	//init laser list and add first one
	lasers = new ArrayList<Laser>();
	lasers.add(new Laser(50, height/2));
}

void draw() {
	background(0);

	updateNodes();
	updateLasers();
}

//draw each node
void updateNodes() {
	for (Node n : nodes) {
		n.update();
	} 
}

//draw the rays and their origins
void updateLasers() {
	for (int i = 0; i < lasers.size(); i++) {
		Laser l = lasers.get(i);
		l.drawOrigin();
		l.update();

		//this can't be a good way to do this
		if (i == activeLaser) {
			l.active = true;
		} else {
			l.active = false;
		}
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

	//find position where center of grid will be center of window
	float xPos = (width - gridWidth)/2 + offsetX/2;
	float yPos = (height - gridWidth/2)/2 + offsetY; //TODO: not the middle for some reason?

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

void keyPressed() {
	Laser l = lasers.get(activeLaser);
	
	//set rotation
	if (keyCode == RIGHT) {
		l.setDirection(new PVector(l.direction.x += .01, l.direction.y += .01));
	}
	if (keyCode == LEFT) {
		l.setDirection(new PVector(l.direction.x -= .01, l.direction.y -= .01));
	}

	//set position
	if (keyCode == UP) {
		l.setPosition(new PVector(l.position.x, l.position.y -= 5));
	}
	if (keyCode == DOWN) {
		l.setPosition(new PVector(l.position.x, l.position.y += 5));
	}

	//set which laser is active
	if (key == '2') {
		if (activeLaser < lasers.size() - 1) activeLaser += 1;
	}
	if (key == '1') {
		if (activeLaser > 0) activeLaser -= 1;
	}

	//delete last laser
	if (keyCode == BACKSPACE) {
		if (lasers.size() > 1) lasers.remove(lasers.size() - 1);
	}
}

//add new lasers
void mousePressed() {
		// lasers.add(new Laser(mouseX, mouseY));
		// if (mouseX > width/2) lasers.get(lasers.size() - 1).setDirection(new PVector(-1, 0));
}