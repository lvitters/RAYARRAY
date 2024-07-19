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
PFont guiFont, idFont;
CColor guiColor;
int guiOffset = 150;
DropdownList modesList;
boolean showIDs;

//nodes
ArrayList<Node> nodes = new ArrayList<Node>();
ArrayList<String> ipAdresses = new ArrayList<String>();

//grid
int gridX = 2;
int gridY = 2;
float scaleCentimetersToPixels = 2.0;	//adjust for screen size
float windowX, windowY;
float absoluteConnectionLength = 50.0;	//in cm
float absoluteMirrorWidth = 15.0;		//in cm
float offset = absoluteConnectionLength * scaleCentimetersToPixels;	//offset between nodes

//laser reflection
int recursionGuard = 0;

//auto mode(s)
boolean isAutoMode = false;
float lastSwitch = 0;
float autoInterval = 0;
boolean waitingForAllHome = false;
boolean isHalting = false;
float haltInterval = 0;
float haltDuration = 0;
float lastHalt = 0;

//rotation
boolean rotateMirror = false;
boolean rotateMirrors;
float mirrorRotationSpeed = 1;
int mirrorRotationMode = 0;
int stepsPerRevolution = 4096;
int stepZero = (stepsPerRevolution * 10000) / 2;
float stepsPerDegree = stepsPerRevolution / 360;

//sending OSC
boolean sendRotation;
int sendFreq = 100;		//in milliseconds

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

	if (isAutoMode) autoMode();
	if (isHalting) halt();
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
	//if it says it is home
	if (theOscMessage.addrPattern().equals("/home") == true) {
		//record info from node
		int id = theOscMessage.get(0).intValue();

		//write to nodes' isHome
		for (Node n : nodes) {
			if (n.nodeID == id || n.mirror == null) {
				n.isHome = true;
				println("node is home");
			}
		}

		//see if all nodes are home and switchMode only if autoMode is on
		if (checkIfAllHome()) switchModeIfAllHome();
	}

	//if it is a step
	else if (theOscMessage.addrPattern().equals("/step") == true) {
		//record info from node
		int id = theOscMessage.get(0).intValue();
		int step = theOscMessage.get(1).intValue();	//direction is inverted from physical nodes

		println("ID: " + id + " step: " + (step - (2048*10000)));
		
		// for (Node n : nodes) {
		// 	if (n.nodeID == id) {
		// 		println(n.mirror.rotationSteps);
		// 		println(n.mirror.rotationDegrees * stepsPerDegree);
		// 		println(degrees(n.mirror.rotationRadians + (PI * .75)) * stepsPerDegree);
		// 		println(step - (2048 * 10000));
		// 		n.mirror.rotationDegrees = ((step % stepsPerRevolution) / stepsPerDegree);	//direction is flipped from Arduino
		// 	}
		// }
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
	cf = new ControlFrame(this, 400, 550, "GUI");
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
		if (theEvent.getController().toString() == "restartNodes") {
			restartNodes();
		}
		//if it comes from the "getStep" controller then getSteps()
		if (theEvent.getController().toString() == "getSteps") {
			getSteps();
		}
		//if it comes from the "switchMirrorRotationMode" controller then switchMirrorRotationMode accordingly
		if (theEvent.getController().toString() == "switchMirrorRotationMode") {
			switchMirrorRotationMode(int(theEvent.getController().getValue()));
		}
	}
}

//switch between rotation modes automatically every time interval
void autoMode() {
	if ((((millis() - lastSwitch) / 1000) > (autoInterval * 60))) {
		if (!waitingForAllHome) goHome();
		waitingForAllHome = true;
		
		//after 10 seconds, switch mode regardless
		if ((((millis() - lastSwitch) / 1000) - (autoInterval * 60) > 10)) {
			println("switch mode regardless");
			switchModeIfAllHome();
		}
	}
}

//switch to the next mode, only use after checkIfAllHome is true
void switchModeIfAllHome() {
	//reset counter
	lastSwitch = millis();
	waitingForAllHome = false;

	//tell nodes they aren't home anymore
	for (Node n : nodes) n.isHome = false;

	//apply new random mode to nodes and GUI for mirrors
	int newRandomMode = (int(random(7)));
	switchMirrorRotationMode(newRandomMode);
	//cf.cp5GUI.getController("switchMirrorRotationMode").setValue(newRandomMode);
	
	//turn stuff back on after turning it off while homing
	sendRotation = true;
	cf.cp5GUI.getController("send rotation").setValue(1);
	rotateMirrors = true;
	cf.cp5GUI.getController("rotate mirrors").setValue(1);
}

//check if all nodes are home
boolean checkIfAllHome() {
	for (Node n : nodes) {
		if (!n.isHome) {
			println("not all home");
			return false;
		}
	}
	println("all home");
	return true;
}

//occasionally freeze the program to make the nodes stop
void halt() {
	if (((millis() - lastHalt) / 1000) > (haltInterval * 60)) {
		lastHalt = millis();
		if (!waitingForAllHome) delay(int(haltDuration * 1000));
	}
}

//apply from switchMirrorRotationMode controller and reset mirror variables
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
				n.mirror.setHome();
				n.mirror.rotationDirection = 1;
			}
		}
	}
	//individual noise rotation needs individual starting points for time
	else if(mirrorRotationMode == 1) {
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.setHome();
				n.mirror.rT = random(100);
			}
		}
	}
	//same direction constant rotation
	else if (mirrorRotationMode == 2) {
		int randomDirection = getRandomDirection();
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.setHome();
				n.mirror.rotationDirection = randomDirection;
			}
		}
	}
	//individual direction constant rotation
	else if (mirrorRotationMode == 3) {
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.setHome();
				n.mirror.rotationDirection = getRandomDirection();
			}
		}
	}
	//sine speed with different multipliers individually
	else if (mirrorRotationMode == 4) {
		int randomDirection = getRandomDirection();
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.setHome();
				int randEven = int(random(2, 5)) * 2;
				n.mirror.sineMultiplier = randEven;
				n.mirror.rotationDirection = randomDirection; 
			}
		}
	}
	//sine speed with different multipliers per row
	else if (mirrorRotationMode == 5) {
		int randomDirection = getRandomDirection();
		int randInt = int(random(2));
		int rowEven = 0;
		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.setHome();
				if (randInt == 0) rowEven = (n.row + 1) * 2;
				else rowEven = gridX - n.row + 1;
				n.mirror.sineMultiplier = rowEven;
				n.mirror.rotationDirection = randomDirection; 
			}
		}
	}
	//sine speed with different multipliers per column, highest towards the middle
	else if (mirrorRotationMode == 6) {
		int randomDirection = getRandomDirection();

		for (Node n : nodes) {
			if (n.mirror != null) {
				n.mirror.setHome();
				int columnEven = 0;
				if (n.column < gridX/2) {
					columnEven = (n.column+1) * 2;
				} else if (n.column >= gridX/2) {
					columnEven = (gridX) -  (((n.column+1) - (gridX/2)) - 1) * 2;	//thanks Alberto
				}
				n.mirror.sineMultiplier = columnEven;
			}
		}
	}
}

//turn off rotations and sending, set GUI elements accordingly, reset and home all nodes
void goHome() {
	println("goHome");
	sendRotation = false;
	rotateMirrors = false;
	cf.cp5GUI.getController("send rotation").setValue(0);
	cf.cp5GUI.getController("rotate mirrors").setValue(0);
	for (Node n : nodes) {
		if (n.mirror != null) {
			n.mirror.setHome();
			n.goHome();
		}
	}
}

//reset all mirrors' home positions to their current positions, only after goHome() to catch some errors?
void restartNodes() {
	println("restartNodes");
	for (Node n : nodes) {
		n.restartNode();
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

//control by hand
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
		//rotate single mirror only if RIGHT mouse button is pressed
		if (mouseButton == RIGHT) {
			rotateMirror = true;
		}
}

//reset when mouse buttons are released
void mouseReleased() {
	rotateMirror = false;
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

//save current config to JSON file
void saveConfig() {
	println("saveConfig");

	JSONArray config = new JSONArray();

	for (Node n : nodes) {
		//get location in grid and ID, save if mirror or laser
		JSONObject configNode = new JSONObject();
		configNode.setInt("x", n.column);
		configNode.setInt("y", n.row);
		configNode.setInt("ID", n.nodeID);
		if (n.mirror != null && n.laser == null) configNode.setString("mode", "mirror");
		else if (n.laser != null) configNode.setString("mode", "laser");
		else if (n.mirror == null && n.laser == null) configNode.setString("mode", "null");

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

			//get location in config and ID, check if mirror or laser
			int x = configNode.getInt("x");
			int y = configNode.getInt("y");
			int ID = configNode.getInt("ID");
			if (configNode.getString("mode").equals("laser")) {
				nodes.get(i).switchMode(1);
			} else if (configNode.getString("mode").equals("null")) {
				nodes.get(i).switchMode(2);
			}

			//write ID to corresponding node
			nodes.get(i).nodeID = ID;
		}
	}
}
