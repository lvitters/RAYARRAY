class Node {
	PVector position;
	Mirror mirror;
	Laser laser;
	int mode;
	final float jointRadius = (scaleCentimetersToPixels * absoluteConnectionLength * (sqrt(2)/2)); //TODO: figure out why it is sqrt(2)/2

	Node(PVector p) {
		position = p;
		mirror = new Mirror(position);
		mode = 0;
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
	}

	//draw lines to show the joints between the nodes
	void drawJoints() {
		strokeWeight(3);
		stroke(50);
		pushMatrix();
			translate(position.x, position.y);
			//TODO: figure out how to omit the "outer" joints of the "outer" nodes
			line(jointRadius/2, jointRadius/2, 0, 0);
			line(jointRadius/2, -jointRadius/2, 0, 0);
			line(-jointRadius/2, jointRadius/2, 0, 0);
			line(-jointRadius/2, -jointRadius/2, 0, 0);
		popMatrix();
	}

	//draw highlight for selection
	void drawHighlight() {
		if (mouseOver()) {
			fill(255, 100, 100, 50);
			noStroke();
			//rect(position.x, position.y, cellSize, cellSize);
			ellipse(position.x, position.y, cellSize, cellSize);
		}
	}

	//check if mouse is hovering over the node's area
	boolean mouseOver() {
		//circular hitbox
		if(dist(mouseX, mouseY, position.x, position.y) < cellSize/2) {
			return true;
		} else {
			return false;
		}
		
		//rect hitbox
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
	void updateMode() {
		if (mode == 0) {
			laser = null;
			if (mirror == null) mirror = new Mirror(position);
		} else if (mode == 1) {
			mirror = null;
			if (laser == null) {
				laser = new Laser(position);
				if (mouseX > width/2) laser.setDirection(new PVector(-1, 0));
			}
		} else if (mode == 2) {
			mirror = null;
			laser = null;
		}
	}
}