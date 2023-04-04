import netP5.*;
import oscP5.*;

OscP5 oscP5;
int remotePort = 8888;

import controlP5.*;
ControlP5 cp2;
ControlFrame cf;

//GUI appearance
PFont guiFont, idFont;
CColor guiColor;

DropdownList modesList;
boolean showIDs;
boolean sendOSC;
int sendFreq = 100;		//in milliseconds

ArrayList<Node> nodes;

int gridX = 10;
int gridY = 5;

float windowX, windowY;
float guiHeight = 200;

float absoluteConnectionLength = 45.0;	//in cm
float absoluteMirrorWidth = 12.0;		//in cm
float scaleCentimetersToPixels = 3.0;
float offset = absoluteConnectionLength * scaleCentimetersToPixels;	//offset between nodes

int recursionGuard = 0;

boolean rotateLaser = false;
float rotationSpeed = 1;
int rotationMode = 0;

void settings() {
	//scale window size according to grid measurements
	windowX = gridX * absoluteConnectionLength * scaleCentimetersToPixels;
	windowY = (gridY * absoluteConnectionLength * scaleCentimetersToPixels) + guiHeight;

	size(int(windowX), int(windowY));

	//anti aliasing
	smooth();
}

void setup() {
	frameRate(60);
	rectMode(CENTER);
	ellipseMode(CENTER);
	surface.setResizable(true);
	idFont = createFont("arial", 20);
	guiFont = createFont("arial", 12);

	//init oscP5
  	oscP5 = new OscP5(this, 9999);

	setupGUI();

	constructGrid();
}

void draw() {
	background(0);

	updateNodes();
}

//draw each node
void updateNodes() {
	
	//draw all graphical elements first so they are in the background
	for (Node n : nodes) {
		//joints and highlights
		n.drawJoints();
		n.drawHighlight();

		//draw IDs if toggle is set to true
		if (showIDs) n.drawID();
	}

	//then draw the mirrors or lasers on top of everything else and update them
	for (Node n : nodes) {
		n.update();
		n.sendRotationToNode();
	}
}

//depending on the configuration, construct a grid of nodes in the given pattern
void constructGrid() {
	//init arrayList
	nodes = new ArrayList<Node>();

	//calculate width of the entire grid
	float gridWidth = gridX * offset;
	float gridHeight = gridY * offset;

	//find position where center of grid will be center of window
	float xPos = (width - gridWidth)/2 + offset/2;
	float yPos = ((height - gridHeight)/2 + offset/2) - guiHeight/2;

	//add nodes depending on grid size, go through rows first for ID numbering
	for (int y = 0; y < gridY; y++) {
		for (int x = 0; x < gridX; x++) {
			Node n;
			n = new Node(new PVector(xPos + (x * offset), yPos + (y * offset)), x, y, nodes.size() + 1);
			nodes.add(n);
		}
	}
}

//init CP5 instance for ID inputfields and ControlFrame for GUI window, set GUI elements in "ControlFrame.pde"
void setupGUI() {

	//init cp5
	cp2 = new ControlP5(this);

	//init controlFrame
	cf = new ControlFrame(this, 400, 800, "GUI");
	surface.setLocation(420, 10);
}

//control lasers
void mousePressed() {		
		//switch mode for the node that was clicked on with LEFT mouse button
		if (mouseButton == LEFT) {
			for (Node n : nodes) {
				n.setInputfieldActive(false);
				if (n.mouseOver()) {
					if (n.mode < 2) n.mode++;
					else n.mode = 0;
					n.switchMode(n.mode);
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
				n.submitID();
				n.setInputfieldActive(false);
			}
		}
	}

	/*
	//update firmware
	if (key == 'U') {
		NetAddress myRemoteLocation= new NetAddress(remoteIP, remotePort);
		println("firmware update");
		OscMessage myMessage = new OscMessage("/updatefirmware");
		oscP5.send(myMessage, myRemoteLocation);
	}
	*/
}

//controlP5 event handler
void controlEvent(ControlEvent theEvent) {
	//check if event comes from a controller - see setupGUI()	
	if (theEvent.isController()) {
    	//println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());

		//if it comes from the "rotationMode" controller apply that to rotationMode variable
		if (theEvent.getController().toString() == "rotationMode")  rotationMode = int(theEvent.getController().getValue());
		//println("rotationMode: " + rotationMode);
  	}
}

//incoming pings from nodes (OSC messages)
void oscEvent(OscMessage theOscMessage) {
	if (theOscMessage.addrPattern().equals("/ping") == true) {
		int id = theOscMessage.get(1).intValue();
		String ip = theOscMessage.get(2).stringValue();
		String mac = theOscMessage.get(3).stringValue();
		float fw_version = theOscMessage.get(4).floatValue();
		
		println("got a ping from:");
		println("ID: " + id + " with IP: " + ip);
		// println("id         : " + id);
		// println("fw_version : " + fw_version);
		// println("mac        : " + mac);
	
		//set ping IP to node IP if there is a match in IDs
		for (Node n : nodes) {
			if (id == n.inputID) {
				n.nodeIP = ip;
				println("inputID: " + n.inputID + " has IP: " + n.nodeIP);
			} else {
				n.nodeIP = "";
			}
		}

	} else {
		print("### received an osc message.");
		print(" addrpattern: "+theOscMessage.addrPattern());
		println(" typetag: "+theOscMessage.typetag());
	}
}