/* autogenerated by Processing revision 1283 on 2022-11-17 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import netP5.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class RAYARRAY_processing extends PApplet {



ArrayList<Node> nodes;

int gridX = 12;
int gridY = 12;
int gridWidth = 1000;
int gridHeight = 1000;

 public void setup() {
	/* size commented out by preprocessor */;
	frameRate(60);
	rectMode(CENTER);

	nodes = new ArrayList<Node>();
	constructGrid();
}

 public void draw() {
	background(0);

	drawNodes();
}

//depending on the configuration, construct a grid of nodes in the given pattern
 public void constructGrid() {

	//thanks DPP for this new way of constructing a grid
	for (int i = 0; i < gridX * gridY; i++) {
		int x = i % gridX;
		int y = i / gridX;
		float cellWidth = gridWidth / (float) (gridX + 1);

		Node n = new Node(x * cellWidth + cellWidth, y * cellWidth + cellWidth);
		nodes.add(n);
	}
}

//draw each node
 public void drawNodes() {
	for (Node n : nodes) n.draw();
}
class Node {
	PVector position;
	int index;
	int mirrorWidth;
	int mirrorHeight;

	Node(float x, float y) {
		position = new PVector(x, y);
		//index = i;
		mirrorWidth = 24;
		mirrorHeight = 4;
	}

	 public void update() {

	}

	 public void draw() {
		noStroke();
		rect(position.x, position.y, mirrorWidth, mirrorHeight);
	}
}
interface Renderable {
  public void draw();
  public PVector get_position();
  public void set_position(PVector position);
}
interface Rotatable extends Renderable {
  void set_rotation(float rotation);
  void set_rotation_offset(float rotationOffset);
  float get_rotation();
  float get_rotation_offset();
  void set_rotation_speed(float rotationSpeed);
  void set_rotation_direction(boolean rotationDirection);
  void update(float pDelta);
}


  public void settings() { size(1200, 1200); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "RAYARRAY_processing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
