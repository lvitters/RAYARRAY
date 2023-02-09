class Node {
	PVector position;
	Mirror mirror;
	Laser laser;
	int mode;
	float jointLength = offset / 2;
	int column, row;
	int ID;
	String inputValue = "";
	String inputName;
	boolean drawInput = false;

	Node(PVector p, int x, int y, int i) {
		position = p;
		mirror = new Mirror(position);
		mode = 0;
		column = x;
		row = y;

		inputName = str(i) + " ID: ";
		setInputID();
	}

	//update and draw mirror or laser
	void update() {
		if (mirror != null) {
			mirror.update();
			mirror.draw();
		}
		if (laser != null) {
			laser.drawOrigin();
			if (mouseOver() && rotateLaser) laser.setDirection(new PVector(mouseX - laser.position.x, mouseY - laser.position.y).normalize());
			laser.update();
		}
		drawInputID();
	}

	//draw lines to show the joints between the nodes
	void drawJoints() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
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
			ellipse(position.x, position.y, offset, offset);
		}
	}

	//check if mouse is hovering over the node's area
	boolean mouseOver() {
		//circular hitbox
		if(dist(mouseX, mouseY, position.x, position.y) < offset/2) {
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
					laser = new Laser(position);
					if (mouseX > width/2) laser.setDirection(new PVector(-1, 0));
				}
			break;
			//node is empty
			case 2:
				mirror = null;
				laser = null;
			break;
		}
	}

	// ------------------------ ControlP5 input field for ID ------------------------ //
	void setInputID() {
		cp5.addTextfield(inputName)
		.setPosition(position.x, position.y)
		.setSize(100, 20)
		.setFocus(true)
		.setColor(color(255, 0, 0))
		;
	}

	void drawInputID() {
		cp5.get(Textfield.class, inputName).setVisible(drawInput);
		text(cp5.get(Textfield.class, inputName).getText(), 360, 130);
  		text(inputValue, 360, 180);
	}

	void controlEvent(ControlEvent theEvent) {
		if(theEvent.isAssignableFrom(Textfield.class)) {
			println("controlEvent: accessing a string from controller '"
					+theEvent.getName()+"': "
					+theEvent.getStringValue()
					);
		}
	}
}