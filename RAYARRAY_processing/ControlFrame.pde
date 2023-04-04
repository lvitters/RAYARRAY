//https://github.com/sojamo/controlp5/issues/17

class ControlFrame extends PApplet {

	int w, h;
	PApplet parent;
	ControlP5 cp5;

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
		cp5 = new ControlP5(this);

		//set color for GUI
		guiColor = new CColor(	color( 40, 184,  79),	//foreground
								color(  0, 100,   0), 	//background
								color( 60, 204,  99), 	//active
								color( 255         ), 	//caption label
								color(   0         ));	//value label
		
		//send_OSC toggle
		cp5.addToggle("send OSC")
			.plugTo(parent, "sendOSC")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(offset/2 + offset * 1.5, height - guiHeight)
			.setSize(100, 20)
			.setValue(false)
			;
		
		//send_frequency slider
		cp5.addSlider("send freq")
			.plugTo(parent, "sendFreq")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(offset/2, height - guiHeight + offset * 2/3)
			.setSize(200, 20)
			.setRange(1, 100)
			.setValue(50)
			;

		//toggle if IDs are shown
		cp5.addToggle("show IDs")
			.plugTo(parent, "showIDs")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(offset/2 + offset * 2.5, height - guiHeight)
			.setSize(100, 20)
			.setValue(true)
			;

		//rotation speed
		cp5.addSlider("rotation speed")
			.plugTo(parent, "rotationSpeed")
			.setFont(guiFont)
			.setColor(guiColor)
			.setPosition(offset/2, height - guiHeight + offset)
			.setSize(200, 20)
			.setRange(.1, 10)
			.setValue(1)
			//.setDecimalPrecision(1) 
			;

		//rotation modes
		modesList = cp5.addDropdownList("rotation mode")
			.plugTo(parent, "rotationMode")
			.setPosition(offset/2, height - guiHeight)
			.setFont(guiFont)
			.setColor(guiColor)
			.setBarHeight(20)
			.setItemHeight(20)
			.setWidth(150)
			.addItem("sine rotation", 0)
			.addItem("noise rotation", 1)
			;

		//save config
		cp5.addButton("save config")
			.plugTo(parent, "saveConfig")
			.setPosition(width - offset - offset/2, height - guiHeight + offset/3)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;

		//load config
		cp5.addButton("load config")
			.plugTo(parent, "loadConfig")
			.setPosition(width - offset - offset/2, height - guiHeight)
			.setSize(100, 20)
			.setFont(guiFont)
			.setColor(guiColor)
			;
	}

	void draw() {
		background(0);
	}
}