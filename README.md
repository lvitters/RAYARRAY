# RAYARRAY  

## a pattern beyond control

*RAYARRAY* is a kinetic light installation consisting of an array of rays that move accross a network of nodes.

<br> 

in collaboration with [Simon Lang](https://simonslang.de)

many thanks to [Dennis Paul](https://www.dennisppaul.de/) and [Ralf Bäcker](https://rlfbckr.io/) for the coding guidance

<br>

## ARRAY

![RAYARRAY-1](./img/SDIM4040.JPG)

RAYARRAY consists of 50 nodes, 100 jumpers, and 10 laser diodes which, if assembled, form a physical array controlled by a Processing Sketch and an Arduino Sketch. The grid is completely modular and can be set up vertically hanging as well as horizontally lying in different configurations. 

<br>

## NODE

![RAYARRAY-2](./img/SDIM3802.JPG)

![RAYARRAY-3](./img/PCB.PNG)

Each node is a self-contained system built from a stepper motor, a PCB with ESP8266, Hall sensor and motor controller and four connectors for jumpers. The case is a 3D-printed bracket that houses all the components. The motor is mounted vertically in the bracket, so that the motor shaft extends horizontally out of the housing. The mirror is placed in the center via a small mount. There is also a tiny magnet on the underside of the mirror, so that the zero position of the motor/mirror can be determined in combination with the Hall sensor installed in the case. The ESP8266 is used to control the node and can receive signals via WIFI.

<br>

## JUMPER

The jumpers consist of a 10mm diameter and 35cm long aluminum tubes with a connection for a node at both ends. A ¼ inch jack connector is used as the connector, as this can rotate and also provides the necessary structural stability. The jumpers also serve as the power supply for the entire grid. The tip of the jack provides the required 5V voltage and the sleeve represents the neutral conductor. Inside the aluminum tube runs a wire for the 5V, and the tube itself is the neutral conductor. Thus, the physical array is a power grid.

<br>

## RAY

![RAYARRAY-4](./img/SDIM4085.JPG)

The laser diodes' rays are reflected in controlled or uncontrolled patterns from both sides of the attached mirrors.

<br>
<br>
<br>

# SIMULATION

![RAYARRAY-5](./img/screenshot2.png)

![RAYARRAY-6](./img/screenshot1.png)

![RAYARRAY-7](./img/screenshot3.png)

A central Processing sketch that simulates the installation's components controls the mirrors' rotations. The simulation applies a range of generative choreographies, resulting in either uniform or entirely chaotic patterns. The rotation values for the individual stepper motors are then send over WIFI to the microcontrollers. The simulation can save and load custom grid dimensions and positions of the mirrors and laser diodes, so that different setups of the installation can be controlled.

<br>
<br>

## RAYARRAY_processing

Start *'RAYARRAY_processing.pde'* to start the *RAYARRAY* simulation Processing sketch. Pressing on the nodes with the left mouse button will cycle them from being a mirror, a laser or an empty node. Dragging with the right mouse button will rotate the lasers or mirrors. 
<br><br>
On startup, *RAYARRAY_processing* will look for ESP8266 microcontrollers broadcasting their IP on the same network as *RAYARRAY_processing*. 
<br><br>
Hovering over the nodes and pressing the 'I' key will let you input an ID, which should correspond to the ID of the node at the same position inside the physical *RAYARRAY* grid. 
<br><br>
If the IDs from the nodes' broadcasts and the IDs that have been assigned in *RAYARRAY_processing* are them same, the ID numbers in the Processing sketch will go from red to green.
<br><br>

**SHOW IDS** will switch between the node's ID numbers being displayed or not.
<br><br>
**SAVE CONFIG** will save the current config (dimensions of grid; are the nodes mirrors, lasers, or empty) into a JSON file with the same name as the grid dimensions. *RAYARRAY_processing* will also attempt to load this config from a JSON file with the same dimensions as the Processing sketch currently has on startup. The same applies to the **LOAD CONFIG** button. 
<br><br>
**GO HOME** will send an OSC message to all connected nodes that tells them to move to their home positions. 
<br><br>
**RESTART NODES** will send an OSC message to all connected nodes that restarts the ESP8266 entirely. 
<br><br>
**GET STEPS** will send an OSC message to all connected nodes that asks for the motor's current step, the answer will be displayed in the console. 
<br><br>
**ROTATE MIRRORS** will start the rotation of the mirrors according to the current rotation mode, which can be changed in the **MIRROR ROTATION MODE** dropdown. 
<br><br>
**MIRROR SPEED** controls the rotation speed. 
<br><br>
**SEND ROTATION** will send the node's orientation to the corresponding ESP8266 as stepper motor steps via OSC messages in the same network. 
<br><br>
**SEND FREQ** is the frequency with which the nodes are updated with motor positions in milliseconds. 
<br><br>
**AUTO MODE** will change the **MIRROR ROTATION MODE** after intervals that can be set by **AUTO INTERVAL**, which is in minutes. 
<br><br>
**AUTO LASER** will aim the lasers to one of the mirrors around them at the same time as the **MIRROR ROTATION MODE** changes in 'AUTO MODE'. 
<br><br>
**ARM HALT** will arm the entire progam to halt for a duration set in **HALT DURATION** so that the nodes will stop rotating. This will happen after intervals set in **HALT INTERVAL**. 
<br><br>
**MIRROR ROTATION MODE** changes the rotation mode of the mirrors. The modes will apply universal 'choreographed' or individual rotations to the mirrors. 
<br><br>

The dimensions of the *RAYARRAY_processing* can be changed before startup with the 'gridX' and 'gridY' variables. *RAYARRAY_processing* will look for a JSON config file of the same dimensions at startup. 
<br><br>
The pysical dimensions of and between the node's mirrors can be changed by the variables 'absoluteConnectionLength' (length from the center of one node to the next in cm) and 'absoluteMirrorWidth' (width of the attached mirrors in cm). 
<br><br>
The variable 'scaleFromCentimetersToPixels' changes how large the simulation is displayed on the screen. <br>
<br><br>

## RAYARRAY_arduino

*RAYARRAY_arduino* contains the files to be uploaded to the ESP8266 microcontrollers that control the *RAYARRAY* installation. They broadcast their IDs and IPs over an assigned network so that the *RAYARRAY* simulation can assign them to their physical positions inside the *RAYARRAY* grid. 
<br><br>
On startup, they perform a homing sequence using a hall sensor attached to the node, so that the mirrors (or lasers) will receive a home position. After that, they are ready to receive absolute stepper motor positions or other control commands via OSC messages. 
<br><br>

## firmware_server

'firmware_server.js' is a node.js program that will enable the ESP8266 nodes to fetch a new firmware from a server, if the firmware version number exceeds the version number of their current firmware.
<br><br>

'moveFirmware.command' will move and rename the output of the Arduino IDE's "export compiled binary" function so that it can be used by 'firmware_server.js'. It will also open the file 'version.txt' so that the firmware version number can be updated. 
<br><br>
After that, 'startNode.command' will start the 'firmware_server.js' node program. Both commands are written for macOS and use absolute paths, so they have to be changed if used on another machine.
<br><br>


## setNodeID_arduino

'setNodeID_arduino.ino' is an Arduino program that will write an ID number to the ESP8266's EEPROM onboard storage. 
<br><br>
This will enable the *RAYARRAY_processing* to differentiate between the otherwise identical nodes.
<br><br>

<br><br><br><br>

photos: [Hsun Hsiang Hsu](https://www.hsunhsianghsu.com/)
