//https://www.sojamo.de/libraries/controlP5/examples/extra/ControlP5frame/ControlP5frame.pde
//https://github.com/sojamo/controlp5/issues/17

class ControlFrame extends PApplet {

	int w, h;
	PApplet parent;
	ControlP5 cp5GUI;

	public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
			super();   
			parent = _parent;
			w=_w;
			h=_h;
			PApplet.runSketch(new String[]{this.getClass().getName()}, this);
	}

	public void settings() {
			size(w, h);
	}

	//set up all GUI elements in ControlFrame and plug to variables
	//https://www.sojamo.de/libraries/controlP5/#examples
  	public void setup() {
		//location on screen (?)
		surface.setLocation(10, 10);
		//init cp5
		cp5GUI = new ControlP5(this);

		//set color for GUI
		guiColor = new CColor(	color( 40, 184,  79),	//foreground
								color(  0, 100,   0), 	//background
								color( 60, 204,  99), 	//active
								color( 255         ), 	//caption label
								color(   0         ));	//value label

		//toggle if IDs are shown
		cp5GUI.addToggle("show IDs")
			.plugTo(parent, "showIDs")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 1/3)
			.setSize(100, 20)
			.setValue(false)
			;

		//save config
		cp5GUI.addButton("save config")
			.plugTo(parent, "saveConfig")
			.setPosition(guiOffset/4 + 110, guiOffset * 1/3)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;	

		//load config
		cp5GUI.addButton("load config")
			.plugTo(parent, "loadConfig")
			.setPosition(guiOffset/4 + 220, guiOffset * 1/3)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;		
			
		//put mirror to default
		cp5GUI.addButton("go home")
			.plugTo(parent, "goHome")
			.setPosition(guiOffset/4, guiOffset * 2/3)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;		
			
		//tell node to reset its home position to the current one
		cp5GUI.addButton("reset homes")
			.plugTo(parent, "resetHomes")
			.setPosition(guiOffset/4 + 110, guiOffset * 2/3)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;
			
		//get the mirrors' current step
		cp5GUI.addButton("get steps")
			.plugTo(parent, "getSteps")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4 + 220, guiOffset * 2/3)
			.setSize(100, 20)
			;

		//toggle if mirror should rotate
		cp5GUI.addToggle("rotate mirrors")
			.plugTo(parent, "rotateMirrors")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 3/3)
			.setSize(100, 20)
			.setValue(false)
			;

		//rotation speed
		cp5GUI.addSlider("mirror speed")
			.plugTo(parent, "mirrorRotationSpeed")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4 + 110, guiOffset * 3/3)
			.setSize(200, 20)
			.setRange(.5, 5)
			.setValue(1)
			.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
			//.setDecimalPrecision(1) 
			;	

		//toggle if mirror should rotate
		cp5GUI.addToggle("rotate lasers")
			.plugTo(parent, "rotateLasers")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 4/3)
			.setSize(100, 20)
			.setValue(false)
			;

		//rotation speed
		cp5GUI.addSlider("laser speed")
			.plugTo(parent, "laserRotationSpeed")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4 + 110, guiOffset * 4/3)
			.setSize(200, 20)
			.setRange(.5, 5)
			.setValue(1)
			.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
			//.setDecimalPrecision(1) 
			;

		//toggle if mirror should rotate
		cp5GUI.addToggle("send rotation")
			.plugTo(parent, "sendRotation")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 5/3)
			.setSize(100, 20)
			.setValue(false)
			;
		
		//send_frequency slider
		cp5GUI.addSlider("send freq")
			.plugTo(parent, "sendFreq")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4 + 110, guiOffset * 5/3)
			.setSize(200, 20)
			.setRange(1, 100)
			.setValue(10)
			.getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
			;

		//rotation modes
		modesList = cp5GUI.addDropdownList("mirror rotation mode")
			.plugTo(parent, "switchMirrorRotationMode")
			.setPosition(guiOffset/4, guiOffset * 6/3)
			.setFont(guiFont)
			.setColor(guiColor)
			.setBarHeight(20)
			.setItemHeight(20)
			.setWidth(250)
			.setHeight(400)
			.setOpen(false) 
			.addItem("same noise", 0)
			.addItem("individual noise", 1)
			.addItem("same direction constant", 2)
			.addItem("individual direction constant", 3)
			.addItem("multiplied sine speed", 4)
			.addItem("row multiplied sine speed", 5)
			.addItem("column multiplied sine speed", 6)
			;
	}

	void draw() {
		background(0);
	}
}