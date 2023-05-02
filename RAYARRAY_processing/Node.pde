class Node {
	PVector position;
	Mirror mirror;
	Laser laser;
	int mode;
	float jointLength = offset / 2;
	int column, row;
	int index;

	String inputValue = "";
	String inputName;
	Textfield inputField;

	int nodeID = -1;
	String nodeIP = null;
	NetAddress remoteLocation;
	long lastSend = 0;
	boolean isHome = false;

	Node(PVector p, int x, int y, int i) {
		position = p;
		mirror = new Mirror(position);
		mode = 0;
		column = x;
		row = y;
		index = i;

		inputName = "inputField" + str(i);
		setNodeID();
	}

	//update and draw mirror or laser
	void update() {
		if (mirror != null) {
			//rotate by hand
			if (mouseOver() && rotateMirror && !rotateMirrors) {
				float r = 0;
				//sorry about this, it's a couple days before the deadline so this is what it's gonna be
				if (mouseX > mirror.position.x) {
					r = PVector.angleBetween(
						new PVector(mouseX - mirror.position.x, mouseY - mirror.position.y).normalize(),
						new PVector(0, 1));
				} else if (mouseX <= mirror.position.x) {
					r = PVector.angleBetween(
						new PVector(mouseX - mirror.position.x, mouseY - mirror.position.y).normalize(), 
						new PVector(0, -1));
				}
				mirror.rotationDegrees = -degrees(r - (PI * .75));
			}
			//apply and/or rotate automatically
			mirror.rotate();
			mirror.draw();
		}
		if (laser != null) {
			laser.drawOrigin();
			//rotate by hand
			if (mouseOver() && rotateLaser) {
				laser.setDirection(new PVector(mouseX - laser.position.x, mouseY - laser.position.y).normalize());
			}
			//apply rotation to steps and rays
			laser.writeToSteps();
			laser.updateRays();
		}
		//close input field when mouse is not over field
		if (!mouseOver()) {
			setInputfieldActive(false);
		}
	}

	//draw lines to show the joints between the nodes
	void drawJoints() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			//omit joints for nodes along the edges
			if (column != 0)		line(-jointLength, 0, 0, 0);
			if (row != 0)			line(0, -jointLength, 0, 0);
			if (column != gridX-1)	line(0, 0, jointLength, 0);
			if (row != gridY-1)		line(0, 0, 0, jointLength);
		popMatrix();
	}

	//draw highlight for selection
	void drawHighlight() {
		if (mouseOver()) {
			fill(100, 255, 100, 50);
			noStroke();
			ellipse(position.x, position.y, .75 * offset, .75 * offset);
		}
	}

	//draw the ID under the node if there is one; draw green if it has an associated IP and red if it doesn't
	void drawID() {
		if (nodeIP != null) fill(color( 60, 204,  99));
		else fill(255, 0, 0);
		textSize(20);
		text(nodeID, position.x + 15, position.y + 25);
	}

	//check if mouse is hovering over the node's area
	boolean mouseOver() {
		//circular hitbox
		if(dist(mouseX, mouseY, position.x, position.y) < (offset/2 * .75)) {
			return true;
		} else {
			return false;
		}
		
		//rectangular hitbox
		// if (position.x - cellSize/2 < mouseX &&
		// 	position.x + cellSize/2 > mouseX &&
		// 	position.y - cellSize/2 < mouseY &&
		// 	position.y + cellSize/2 > mouseY ) 
		// {	
		// 	return true;
		// } else {
		// 	return false;
		// }
	}

	//check if node has mirror or laser or nothing
	void switchMode(int mode) {
		//an excuse to use switch/case for no reason other than: look mom no if statements 
		switch(mode) {
			//node has a mirror
			case 0: 
				laser = null;
				if (mirror == null) mirror = new Mirror(position);
			break;
			//node has a laser
			case 1: 
				mirror = null;
				if (laser == null) {
					laser = new Laser(position, column, row);
				}
			break;
			//node is empty
			case 2:
				mirror = null;
				laser = null;
			break;
		}
	}

	// ---------------------------- OSC messages to node ---------------------------- //

	//send rotation to node every x milliseconds
	void sendRotationToNode() {
		if (millis() - lastSend > sendFreq && nodeIP != null && sendRotation) {
			remoteLocation = new NetAddress(nodeIP, remotePort);
			lastSend = millis();
			OscMessage rotationMessage = new OscMessage("/rotate");
			if (mirror != null) {
				rotationMessage.add(mirror.rotationSteps);
			} else if (laser != null) {
				rotationMessage.add(laser.rotationSteps);
			}
			oscP5.send(rotationMessage, remoteLocation);
			//println("sent " + mirror.rotationSteps + " to: " + nodeID + " @" + nodeIP);
		}
	}

	//initiate homing sequence
	void goHome() {
		remoteLocation = new NetAddress(nodeIP, remotePort);
		OscMessage homeMessage = new OscMessage("/goHome");
		oscP5.send(homeMessage, remoteLocation);
	}

	//reset node's home position
	void resetHome() {
		remoteLocation = new NetAddress(nodeIP, remotePort);
		OscMessage homeResetMessage = new OscMessage("/resetHome");
		oscP5.send(homeResetMessage, remoteLocation);
	}

	//send message to nodes to retrieve step
	void getStep() {
		remoteLocation = new NetAddress(nodeIP, remotePort);
		OscMessage stepMessage = new OscMessage("/getStep");
		oscP5.send(stepMessage, remoteLocation);
	}

	//confirm if node receives ping and turn on its LED
	void pingNode(String ip) {
		remoteLocation = new NetAddress(nodeIP, remotePort);
		OscMessage pingMessage = new OscMessage("/pingNode");
		pingMessage.add(ip);
		oscP5.send(pingMessage, remoteLocation);
	}

	// //init jogging by sending /jog OSC message
	// void jog(int direction) {
	// 	NetAddress remoteLocation= new NetAddress(nodeIP, remotePort);
	// 	OscMessage homeMessage = new OscMessage("/jog");
	// 	homeMessage.add(direction);
	// 	oscP5.send(homeMessage, remoteLocation);
	// }

	// ------------------------ ControlP5 input field for ID ------------------------ //
	void setNodeID() {
		inputField = cp5InputFields.addTextfield(inputName)
		.setFont(idFont)
		.setCaptionLabel("")
		.setPosition(position.x - 25, position.y - 25)
		.setSize(50, 50)
		.setColor(color(255, 0, 0))
		.setInputFilter(ControlP5.INTEGER)
		.setVisible(false)		//init as not visible
		;
	}

	//change status of inputfield
	void setInputfieldActive(boolean active) {
		inputField.setVisible(active);
		inputField.setFocus(active);
		inputField.setLock(active);
	}

	//get text input on submit
	void submitID() {
		int id = int(inputField.getText());

		//if the submitted ID is different from before
		if (nodeID != id) {
			//set node ID to input
			nodeID = id;

			//ping node with something that is not its IP so it knows it is not assigned anymore (turn LED off)
			if (nodeIP != null) pingNode("wrong IP");
			
			//reset node IP to possibly be assigned again with next ping
			nodeIP = null;
		
		//if it has not been set yet at all, just assign the submitted ID
		} else if (nodeID == -1) {
			nodeID = id;
		}

		//println("nodeID: " + nodeID);
	}
}