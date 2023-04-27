//network
import netP5.*;
import oscP5.*;
OscP5 oscP5;
int remotePort = 8888;
String firmwareVersionURL = "http://192.168.1.162:8080/release/version.txt";	//change both when router gives new IP with DHCP
String firmwareBinaryURL = "http://192.168.1.162:8080/release/firmware.bin";

//GUI
import controlP5.*;
ControlP5 cp5InputFields;
ControlFrame cf;
Toggle jogToggle;		//global so it can be toggled off by other buttons
PFont guiFont, idFont;
CColor guiColor;
int guiOffset = 150;
DropdownList modesList;
boolean showIDs;
boolean sendRotation;
int sendFreq = 100;		//in milliseconds

//nodes
ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<String> ipAdresses = new ArrayList<String>();

//grid
int gridX = 10;
int gridY = 5;

float scaleCentimetersToPixels = 3.0;	//adjust for screen size
float windowX, windowY;
float absoluteConnectionLength = 50.0;	//in cm
float absoluteMirrorWidth = 15.0;		//in cm
float offset = absoluteConnectionLength * scaleCentimetersToPixels;	//offset between nodes

//laser reflection
int recursionGuard = 0;

//rotation
boolean rotateLaser = false;
boolean rotateLasers = false;
float laserRotationSpeed = 1;

boolean rotateMirrors;
float mirrorRotationSpeed = 1;
int mirrorRotationMode = 0;

int stepsPerRevolution = 4096;
int stepZero = (stepsPerRevolution * 10000) / 2;
float stepsPerDegree = stepsPerRevolution / 360;

void settings() {
	//scale window size according to grid measurements
	windowX = gridX * absoluteConnectionLength * scaleCentimetersToPixels;
	windowY = gridY * absoluteConnectionLength * scaleCentimetersToPixels;

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
	guiFont = createFont("arial", 11);

	//init oscP5
  	oscP5 = new OscP5(this, 9999);

	setupGUI();

	constructGrid();

	//try to load config also at startup, if there is one
	loadConfig();
}

void draw() {
	background(0);

	updateNodes();
}

//depending on the configuration, construct a grid of nodes in the given pattern
void constructGrid() {
	//calculate width of the entire grid
	float gridWidth = gridX * offset;
	float gridHeight = gridY * offset;

	//find position where center of grid will be center of window
	float xPos = (width - gridWidth)/2 + offset/2;
	float yPos = (height - gridHeight)/2 + offset/2;

	//add nodes depending on grid dimensions, go through rows first for ID numbering
	for (int y = 0; y < gridY; y++) {
		for (int x = 0; x < gridX; x++) {
			Node n;
			n = new Node(new PVector(xPos + (x * offset), yPos + (y * offset)), x, y, nodes.size());
			nodes.add(n);
		}
	}
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

//incoming OSC messages from nodes
void oscEvent(OscMessage theOscMessage) {
	//if it is a step
	if (theOscMessage.addrPattern().equals("/step") == true) {
		//record info from node
		int id = theOscMessage.get(0).intValue();
		int step = theOscMessage.get(1).intValue();	//direction is inverted from physical nodes

		//println("ID: " + id + " step: " + (step - (2048*10000)));
		
		for (Node n : nodes) {
			if (n.nodeID == id) {
				println(n.mirror.rotationSteps);
				println(n.mirror.rotationDegrees * stepsPerDegree);
				println(degrees(n.mirror.rotationRadians + (PI * .75)) * stepsPerDegree);
				println(step - (2048 * 10000));
				n.mirror.rotationDegrees = ((step % stepsPerRevolution) / stepsPerDegree);	//direction is flipped from Arduino
			}
		}
	}

	//if it is a ping
	else if (theOscMessage.addrPattern().equals("/ping") == true) {
		//record info from node
		int id = theOscMessage.get(1).intValue();
		String ip = theOscMessage.get(2).stringValue();
		//String mac = theOscMessage.get(3).stringValue();
		float fw_version = theOscMessage.get(4).floatValue();

		// println("got a ping from:");
		// println("ID: " + id + " with IP: " + ip);
		// println("id         : " + id);
		// println("fw_version : " + fw_version);
		
		//add IP from ping to list of IPs
		if (!ipAdresses.contains(ip)) ipAdresses.add(ip);
		//println(pings);
	
		//for all nodes
		for (Node n : nodes) {
			//set nodeIP to ping's IP if there is a match in IDs
			if (n.nodeID == id) {
				//print only if IP hasn't been set yet
				if (n.nodeIP == null) println("node with ID: " + n.nodeID + " has IP: " + ip + " and firmware v" + fw_version);
				n.nodeIP = ip;
				n.pingNode(n.nodeIP);
			}
		}

	//if something goes wrong
	} else {
		print("### received an osc message.");
		print(" addrpattern: "+theOscMessage.addrPattern());
		println(" typetag: "+theOscMessage.typetag());
	}
}

//init CP5 instance for ID inputfields and ControlFrame for GUI window, set GUI elements in "ControlFrame.pde"
void setupGUI() {
	//init cp5
	cp5InputFields = new ControlP5(this);

	//init controlFrame
	cf = new ControlFrame(this, 400, 500, "GUI");
	surface.setLocation(420, 10);
}

//controlP5 event handler
void controlEvent(ControlEvent theEvent) {
	//check if event comes from a controller - see setupGUI()	
	if (theEvent.isController()) {
    	//println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());

		//the following if statements can only call a function inside them with the same name as the controller?
		//probably better for readability to have separate functions for everything anyways 

		//if it comes from the "saveConfig" controller then saveConfig()
		if (theEvent.getController().toString() == "saveConfig") {
			saveConfig();
		}
		//if it comes from the "loadConfig" controller then saveConfig()
		if (theEvent.getController().toString() == "loadConfig") {
			loadConfig();
		}
		//if it comes from the "goHome" controller then goHome()
		if (theEvent.getController().toString() == "goHome") {
			goHome();
		}
		//if it comes from the "resetHomes" controller then resetHomes()
		if (theEvent.getController().toString() == "resetHomes") {
			resetHomes();
		}
		//if it comes from the "getStep" controller then getSteps()
		if (theEvent.getController().toString() == "getSteps") {
			getSteps();
		}
		//if it comes from the "rotationModeMirrors" controller then switchrotationModeMirrors accordingly
		if (theEvent.getController().toString() == "switchMirrorRotationMode") {
			switchMirrorRotationMode(int(theEvent.getController().getValue()));
		}
	}
}

//set directions between rotationModeMirrorss when mode was changed
void switchMirrorRotationMode(int mode) {
	//apply rotation mode
	mirrorRotationMode = mode;
	println("mirrorRotationMode: " + mirrorRotationMode);

	//turn off rotation
	rotateMirrors = false;

	//noise modes, keep/reset to "regular" direction since noise moves both directions anyways
	if(mirrorRotationMode == 0) {
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.goHome();
				n.mirror.rotationDirection = 1;
			}
		}
	}
	//individual noise rotation needs individual starting points for time
	else if(mirrorRotationMode == 1) {
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.goHome();
				n.mirror.rT = random(100);
			}
		}
	}
	//same direction constant rotation
	else if (mirrorRotationMode == 2) {
		int randomDirection = getRandomDirection();
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.goHome();
				n.mirror.rotationDirection = randomDirection;
			}
		}
	}
	//individual direction constant rotation
	else if (mirrorRotationMode == 3) {
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.goHome();
				n.mirror.rotationDirection = getRandomDirection();
			}
		}
	}
	//sine speed with different multipliers
	else if (mirrorRotationMode == 4) {
		int randomDirection = getRandomDirection();
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.goHome();
				int randEven = int(random(2, 5)) * 2;
				n.mirror.sineMultiplier = randEven;
				n.mirror.rotationDirection = randomDirection; 
			}
		}
	}
	//sine distance with different multipliers
	else if (mirrorRotationMode == 5) {
		int randomDirection = getRandomDirection();
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.goHome();
				int randEven = int(random(2, 5)) * 2;
				n.mirror.sineMultiplier = randEven;
				n.mirror.rotationDirection = randomDirection; 
			}
		}
	}
}

//save current config to JSON file
void saveConfig() {
	println("saveConfig");

	JSONArray config = new JSONArray();

	for (Node n : nodes) {
		//get location in grid and ID
		JSONObject configNode = new JSONObject();
		configNode.setInt("x", n.column);
		configNode.setInt("y", n.row);
		configNode.setInt("ID", n.nodeID);

		//set to config JSONArray
		config.setJSONObject(n.index, configNode);
	}

	//save to file with grid dimensions in name
	saveJSONArray(config, "configs/" + gridX + "x" + gridY + ".json");
}

//load config from file with current grid dimensions and write to grid; if there is a config file
void loadConfig() {
	println("loadConfig");

	JSONArray config = new JSONArray();

	//load from file with same grid dimensions as the sketch currently has
	config = loadJSONArray("configs/" + gridX + "x" + gridY + ".json");

	//only read from file if it exists
	if (config != null) {
		for (int i = 0; i < config.size(); i++) {
			
			//get JSON object
			JSONObject configNode = config.getJSONObject(i);

			//get location in config and ID
			int x = configNode.getInt("x");
			int y = configNode.getInt("y");
			int ID = configNode.getInt("ID");

			//write ID to corresponding node
			nodes.get(i).nodeID = ID;
		}
	}
}

//turn off rotation and sending, set GUI elements accordingly, init homing sequence for all nodes, move virtual mirror back to 0
void goHome() {
	println("goHome");
	rotateMirrors = false;
	rotateLasers = false;
	sendRotation = false;
	cf.cp5GUI.getController("rotate mirrors").setValue(0);
	cf.cp5GUI.getController("rotate lasers").setValue(0);
	cf.cp5GUI.getController("send rotation").setValue(0);
	for (Node n : nodes) {
		if (n.mirror != null || n.laser != null) n.goHome();
		if (n.mirror != null) {
			n.mirror.rT = 0;
			n.mirror.rotationRadians = (-PI * 3/4);
			n.mirror.rotationDegrees = 0;
			n.mirror.rotationSteps = 0;
		} else if (n.laser != null) {
			n.laser.goHome();
		}
	}
}

//reset all mirrors' home positions to their current positions, only after goHome() to catch some errors?
void resetHomes() {
	println("resetHomes");
	for (Node n : nodes) {
		n.resetHome();
	}
}

//get current step from all nodes
void getSteps() {
	println("get current step from nodes");
	for (Node n : nodes) {
		n.getStep();
	}
}

//return either 1 or -1
int getRandomDirection() {
	float n = random(2);
	if (n >= 1) n = 1;
	else n = -1;
  	return (int)n;
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
	//input node's IDs
	if (keyCode == 'I') {
		for (Node n : nodes) {
			//set inputField to active only when there is a mirror or laser, the mouse is over it and it isn't active yet
			if (n.mouseOver() && (n.mirror != null || n.laser!= null) && n.inputField.isVisible() == false) {
				n.setInputfieldActive(true);
			} else {
				n.setInputfieldActive(false);
			}
		}
	}
	//submit ID and disable input field when pressing ENTER
	if (keyCode == ENTER) {
		for (Node n : nodes) {
			if (n.inputField.isVisible()) {
				n.submitID();
				n.setInputfieldActive(false);
			}
		}
	}

	//update firmware
	if (keyCode == 'U') {
		//update all nodes from list of IP adresses
		for (String ip : ipAdresses) {
			NetAddress remoteLocation= new NetAddress(ip, remotePort);

			//tell node where 'version.txt' is located
			OscMessage versionURLmessage = new OscMessage("/ufversionurl");
			versionURLmessage.add(firmwareVersionURL);
			oscP5.send(versionURLmessage, remoteLocation);

			//tell node where 'firmware.bin' is located
			OscMessage binaryURLmessage = new OscMessage("/ufbinaryurl");
			binaryURLmessage.add(firmwareBinaryURL);
			oscP5.send(binaryURLmessage, remoteLocation);

			//tell node to update firmware from that location
			OscMessage updateMessage = new OscMessage("/updateFirmware");
			oscP5.send(updateMessage, remoteLocation);

			println("sent firmware update to: " + ip);
		}
	}
}