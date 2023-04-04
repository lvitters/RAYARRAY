import netP5.*;
import oscP5.*;

OscP5 oscP5;
int remotePort = 8888;

import controlP5.*;
ControlP5 cp5;
DropdownList modesList;
CColor guiColor;
boolean show_IDs;
boolean send_OSC;
int send_freq = 100;		//in milliseconds

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
float rotation_speed = 1;
int rotation_mode = 0;

PFont guiFont, idFont;

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

	//init grid
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
		if (show_IDs) n.drawID();
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

//init controllers for GUI
//GUI variables and labels have their words separated by underscores to remain legible in the GUI and to differentiate in the code between internal and GUI namings
void setupGUI() {
	//init controlP5
	cp5 = new ControlP5(this);

	guiColor = new CColor(	color( 40, 184,  79),	//foreground
							color(  0, 100,   0), 	//background
							color( 60, 204,  99), 	//active
							color( 255         ), 	//caption label
							color(   0         ));	//value label
	
	//send_OSC toggle
	cp5.addToggle("send_OSC")
		.setFont(guiFont)
		.setColor(guiColor)
		.setPosition(offset/2 + offset * 1.5, height - guiHeight)
		.setSize(100, 20)
		.setValue(false)
		;
	
	//send_frequency slider
	cp5.addSlider("send_freq")
		.setFont(guiFont)
		.setColor(guiColor)
		.setPosition(offset/2, height - guiHeight + offset * 2/3)
		.setSize(200, 20)
		.setRange(1, 100)
		.setValue(50)
		;

	//toggle if IDs are shown
	cp5.addToggle("show_IDs")
		.setFont(guiFont)
		.setColor(guiColor)
		.setPosition(offset/2 + offset * 2.5, height - guiHeight)
		.setSize(100, 20)
		.setValue(true)
		;

	//rotation speed
	cp5.addSlider("rotation_speed")
		.setFont(guiFont)
		.setColor(guiColor)
		.setPosition(offset/2, height - guiHeight + offset)
		.setSize(200, 20)
		.setRange(.1, 10)
		.setValue(1)
		//.setDecimalPrecision(1) 
		;

	//rotation modes
	modesList = cp5.addDropdownList("rotation_mode")
		.setPosition(offset/2, height - guiHeight)
		.setFont(guiFont)
		.setColor(guiColor)
		.setBarHeight(20)
		.setItemHeight(20)
		.setWidth(150)
		.addItem("sine_rotation", 0)
		.addItem("noise_rotation", 1)
		;

	//save config
	cp5.addButton("save_config")
		.setPosition(width - offset - offset/2, height - guiHeight + offset/3)
		.setSize(100, 20)
		.setFont(guiFont)
		.setColor(guiColor)
		;

	//load config
	cp5.addButton("load_config")
		.setPosition(width - offset - offset/2, height - guiHeight)
		.setSize(100, 20)
		.setFont(guiFont)
		.setColor(guiColor)
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

//controlP5 event handler
void controlEvent(ControlEvent theEvent) {
	//check if event comes from a controller - see setupGUI()	
	if (theEvent.isController()) {
    	//println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());

		//if it comes from the "rotation_mode" controller apply that to rotation_mode variable
		if (theEvent.getController().toString() == "rotation_mode")  rotation_mode = int(theEvent.getController().getValue());
		//println("rotation_mode: " + rotation_mode);
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