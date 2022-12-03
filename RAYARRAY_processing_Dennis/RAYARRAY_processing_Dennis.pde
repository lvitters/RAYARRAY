import netP5.*;

ArrayList<Node> nodes;
ArrayList<Laser> lasers;

int gridX = 8;
int gridY = 6;
static final int NUM_LASERS = 6;

float absoluteConnectionLength = 45.0;
float absoluteMirrorWidth = 12.0;
float scaleCentimetersToPixels = 2.5;

int recursionGuard = 0;

void setup() {
    size(1700, 900);
    frameRate(60);
    rectMode(CENTER);
    surface.setResizable(true);

    nodes = new ArrayList<Node>();
    constructGrid();

    lasers = new ArrayList<Laser>();
    createLasers();
}

void draw() {
    background(0);
    lasers.get(0).position().set(new PVector(mouseX, mouseY));
    if (mousePressed) {
        for (Laser l : lasers) {
            l.direction().set(PVector.sub(new PVector(mouseX, mouseY), l.position()).normalize());
        }
    } else {
        lasers.get(0).direction().set(PVector.sub(new PVector(width / 2, height / 2), lasers.get(0).position()).normalize());
    }
    drawNodes();
    drawLasers();
}

//draw each node
void drawNodes() {
    for (Node n : nodes) {
        if (keyPressed) {
            n.updateRotation(0.1 * 1.0/frameRate);
        }
        n.drawJoints();
        n.drawMirror();
    }
}

//draw the rays and their origins
void drawLasers() {
    for (Laser l : lasers) {
        l.drawOrigin();
        l.drawRays();
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

//for now, add one laser
void createLasers() {
    final float mLaserRadius = height * 0.4;
    for (int i=0; i< NUM_LASERS + 1; i++) {
        Laser l = new Laser();
        lasers.add(l);
        float mPositionRadiant = TWO_PI * (float)i / NUM_LASERS;
        l.position().set(
            width / 2 + sin(mPositionRadiant) * mLaserRadius,
            height / 2 + cos(mPositionRadiant) * mLaserRadius);
        float mRandomDirection = random(TWO_PI);
        l.direction().set(sin(mRandomDirection), cos(mRandomDirection));
    }
}
