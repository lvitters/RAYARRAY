import netP5.*;
import oscP5.*;

OscP5 oscP5;
int remotePort = 8888;

import controlP5.*;
ControlP5 cp5;
boolean show_IDs;
boolean send_OSC;
int send_freq = 100;		//in milliseconds

Toggle send_OSC_toggle;

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

PFont guiFont, idFont;

//scale window size according to grid measurements
void settings() {
	windowX = gridX * absoluteConnectionLength * scaleCentimetersToPixels;
	windowY = (gridY * absoluteConnectionLength * scaleCentimetersToPixels) + guiHeight;

	size(int(windowX), int(windowY));

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

	//init grid
	constructGrid();
}

void draw() {
	background(0);

	updateNodes();
}

//draw each node
void updateNodes() {
	
	//draw all nodes first so they are in the background
	for (Node n : nodes) {
		//joints and highlights
		n.drawJoints();
		n.drawHighlight();

		//draw IDs if toggle is set to true
		if (show_IDs) n.drawID();
	}

	//then draw the mirrors or lasers on top of everything else
	for (Node n : nodes) {
		n.update();
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

	//add nodes depending on grid size
	for (int x = 0; x < gridX; x++) {
		for (int y = 0; y < gridY; y++) {
			Node n;
			n = new Node(new PVector(xPos + (x * offset), yPos + (y * offset)), x, y, nodes.size() + 1);
			nodes.add(n);
		}
	}
}

//init objects for GUI
//all values changed by GUI have their words separated by underscores to remain legible in the GUI
void setupGUI() {
	//init controlP5
	cp5 = new ControlP5(this);
	
	//send_OSC toggle
	send_OSC_toggle = cp5.addToggle("send_OSC")
		.setFont(guiFont)
		.setPosition(offset/2, height - guiHeight)
		.setSize(100, 20)
		.setValue(false)
		;
	
	//send_frequency slider
	cp5.addSlider("send_freq")
		.setFont(guiFont)
		.setPosition(offset/2, height - guiHeight + offset/2)
		.setSize(200, 20)
		.setRange(1, 200)
		.setValue(50)
		;

	//toggle if IDs are shown
	cp5.addToggle("show_IDs")
		.setFont(guiFont)
		.setPosition(offset/2 + offset, height - guiHeight)
		.setSize(100, 20)
		.setValue(true)
		;
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