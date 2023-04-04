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
		
		//send_OSC toggle
		cp5GUI.addToggle("send OSC")
			.plugTo(parent, "sendOSC")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 1/3)
			.setSize(100, 20)
			.setValue(false)
			;

		//toggle if IDs are shown
		cp5GUI.addToggle("show IDs")
			.plugTo(parent, "showIDs")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 2/3)
			.setSize(100, 20)
			.setValue(true)
			;
		
		//send_frequency slider
		cp5GUI.addSlider("send freq")
			.plugTo(parent, "sendFreq")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset)
			.setSize(200, 20)
			.setRange(1, 100)
			.setValue(50)
			;

		//rotation speed
		cp5GUI.addSlider("rotation speed")
			.plugTo(parent, "rotationSpeed")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(guiOffset/4, guiOffset * 4/3)
			.setSize(200, 20)
			.setRange(.1, 10)
			.setValue(1)
			//.setDecimalPrecision(1) 
			;

		//rotation modes
		modesList = cp5GUI.addDropdownList("rotation mode")
			.plugTo(parent, "rotationMode")
			.setPosition(guiOffset * 1.5, guiOffset * 1/3)
			.setFont(guiFont)
			.setColor(guiColor)
			.setBarHeight(20)
			.setItemHeight(20)
			.setWidth(150)
			.addItem("sine rotation", 0)
			.addItem("noise rotation", 1)
			;

		//save config
		cp5GUI.addButton("save config")
			.plugTo(parent, "saveConfig")
			.setPosition(guiOffset/4, guiOffset * 5/3)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;

		//load config
		cp5GUI.addButton("load config")
			.plugTo(parent, "loadConfig")
			.setPosition(guiOffset/4, (guiOffset * 5/3) +20)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;
	}

	void draw() {
		background(0);
	}
}