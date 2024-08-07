//take specific libraries for ESP8266
//board file from here: https://arduino.esp8266.com/stable/package_esp8266com_index.json
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>
#include <ESPAsyncUDP.h> //https://github.com/me-no-dev/ESPAsyncUDP

//not board specific libraries
#include <Chrono.h>
#include <OSCBundle.h>
#include <EEPROM.h>

#define EEPROM_SIZE 12

int NODE_ID = -1; // the final NODE_ID is not set here, it will be stored and read from EEPROM.
// this will allow you to use the "same" code on
// all nodes without setting the node in the code here.
// before you have to set (write to the eeprom) the node ID via the setNodeID arduino sketch.
// upload this sketch afterwads.

float FW_VERSION = 0.25; //important for the firmware ota flashing process / increment for next upload

//server location of your new firmware (export firmware with arduino IDE , change version.txt as well)
//change server IP if needed
//can be set via osc as well

const char DEFAULT_URL_FW_VERSION[] = "http://192.168.1.164:8080/release/version.txt";
const char  DEFAULT_URL_FW_BINARY[] = "http://192.168.1.164:8080/release/firmware.bin";

boolean LOCK_UDP_RECEIVER = false; //lock UDP/OSC receiver to avoid shit while flashing a new firmware
char URL_FW_VERSION[512];
char URL_FW_BINARY[512];
boolean UPDATE_FIRMWARE = false; //hook in firmwareupdate

long pingInterval = 2000;     //every 2 seconds
int networkLocalPort = 8888;  //remote port to receive OSC
int networkOutPort = 9999;    //port for broadcasting

ESP8266WiFiMulti wifiMulti;
Chrono pingTimer;
AsyncUDP udp;
AsyncUDP udpOut;

// -------------------------------------- ^ RALF ^ ---------------------------------------- //

#include <AccelStepper.h>

//ULN2003 Motor Driver Pins
#define IN1 16
#define IN2 5
#define IN3 4
#define IN4 0

//initialize the stepper library
AccelStepper stepper(AccelStepper::HALF4WIRE, IN1, IN3, IN2, IN4);

//The stepper motor actually has a different number of teeth in its gears than is stated in the spec sheet, so we counted the teeth, 
//calculated all the gear ratios, and have this precise measurement of the actual number of steps per revolution.
//The spec sheet says it would be 2037.8864, so we are lucky it is an integer, sparing us from doing weird datatype casting in order
//to compute a float with the %(remainder)operator. Unfortunately for some reason it still doesn't seem to be 100% precise. Maybe
//there are even differences between the motors from a single order? 

const int stepsPerRevolution = 4096;
long rotationSteps = 0;                           //current rotation in steps
int direction;                                    //direction of rotation
long jogValue = 10000 * stepsPerRevolution;       //super high number as target for 'infinite' jog
boolean jogging = false;                          //are we jogging right now?

//95A Hall sensor analog input
#define HALL_SENSOR_PIN A0

//homing
boolean homing = true;                  //are we homing (finding home) right now?
unsigned int homingDuration = 25000;    //in milliseconds
float previousVoltage = 0;              //voltage in the previous measuring cycle
float lowestVoltage = 600;              //higher than it will ever be
float smoothAlpha = 0.5;                //how much does the previous value affect the smoothed one
long homeStep;                          //step with the lowest voltage
boolean goingHome = false;              //are we going home right now?

long loopCount = 0;

//LED pin
#define LED_PIN 2

void setup() {
  //do something with the firmware URLs?
  strncpy(URL_FW_VERSION, DEFAULT_URL_FW_VERSION, strlen(DEFAULT_URL_FW_VERSION));
  strncpy(URL_FW_BINARY, DEFAULT_URL_FW_BINARY, strlen(DEFAULT_URL_FW_BINARY));
  
  //empty Serial port, not sure if this does anything
  Serial.flush();

  //init serial port
  Serial.begin(115200);
  delay(50);

  //get and print NODE_ID
  NODE_ID = readNodeIDfromEEPROM();
  Serial.print(" --> NODE_ID: ");
  Serial.println(NODE_ID);

  //print FW_VERSION
  Serial.print(" --> FW_VERSION: ");
  Serial.println(FW_VERSION);
  
  //init networking stuff
  initWIFI();
  initUDP();

  //init stepper and set to random direction for now, record where homing began
  initStepperMotor();
  direction = 1;

  //init hall sensor
  pinMode(HALL_SENSOR_PIN, INPUT);

  //init LED
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  updateFirmware();
  ping();

  //for homingDuration milliseconds after startup, find the home step
  setHomeStep();

  //if goingHome is true, then goHome
  if (goingHome) goHome();

  //do whatever the stepper was told to
  stepper.run();
}

void initStepperMotor() {
  stepper.setMaxSpeed(1000);
  stepper.setAcceleration(2000);
}

//rotate from OSC messages
void OSCrotate(OSCMessage &msg, int addrOffset) {
  // //get value
  // float inputRotation = msg.getFloat(0); 
  // //write to rotationSteps
  // long rotationSteps = (long)msg.getFloat(0);

  //move there, adjust with home position of mirror (jogValue/2)
  stepper.moveTo((long)msg.getFloat(0));
}

//read voltage and record lowest one and the step where it is at
void findLowestVoltage() {
  //read hall sensor
  float voltage = analogRead(HALL_SENSOR_PIN);

  //smoothing formula from Felix Fisgus
  float smoothVoltage = smoothAlpha * voltage + (1-smoothAlpha) * previousVoltage;  

  //get current step
  long currentStep = stepper.currentPosition();

  //change direction if "out of bounds"
  if (currentStep > stepsPerRevolution + 100) {
    direction = -1;
  } else if (currentStep < -100) {
    direction = 1;
  }

  //move along
  stepper.moveTo(jogValue * direction);

  //find lowest voltage
  if (smoothVoltage <= lowestVoltage && smoothVoltage > 450) {  //TODO: hardcoded number is bad!
    lowestVoltage = smoothVoltage;
    homeStep = currentStep;
  }

  //record voltage for next measuring cycle
  previousVoltage = voltage;
}

//find where the homeStep is and go there
void setHomeStep() {
  //after starting the program for x milliseconds and every x milliseconds
  if ((millis() < homingDuration) && (millis() % 5 == 0) && homing == true) {
    findLowestVoltage();
  
  //if the lowest voltage was found after x milliseconds
  } else if ((millis() > homingDuration) && homing) {
    //move to recorded homeStep
    stepper.moveTo(homeStep);

    //if we're at that step, set to 0 and set homing to false to stop this nightmare
    if (stepper.currentPosition() == homeStep) {
      stepper.setCurrentPosition(jogValue/2);
      Serial.println("home found");
      homing = false;
    }
  }
}

void OSCinitGoingHome(OSCMessage &msg, int addrOffset) {
  goingHome = true;
  Serial.println("going home");
}

//go to the position recorded as home
void goHome() {
  //get current position
  long currentPosition = stepper.currentPosition();

  //always go the "nearest" home
  long nextHome = currentPosition - (currentPosition % stepsPerRevolution);

  //reset home to current position after every time it goes home
  if (currentPosition == nextHome) {
    goingHome = false;
    stepper.setCurrentPosition(jogValue/2);
    tellProcessingHome();
    Serial.println("home reset");
  } else {
    //move there
    stepper.moveTo((long)nextHome);
  }
}

//send a message to Processing saying home
void tellProcessingHome() {
  AsyncUDPMessage udpMsgHome;
  OSCMessage oscMsgHome("/home");
  oscMsgHome.add(NODE_ID);
  oscMsgHome.send(udpMsgHome);
  oscMsgHome.empty();
  udpOut.broadcastTo(udpMsgHome, networkOutPort);
}

//restart the entire ESP, only when Processing says so
void OSCrestart(OSCMessage &msg, int addrOffset) {
  ESP.restart();
}

//reset the current position to home position (jogValue/2), only when Processing says so
void OSCresetHome(OSCMessage &msg, int addrOffset) {
  stepper.setCurrentPosition(jogValue/2);
  Serial.println("home reset");
}

//send the node's current step to Processing after OSC command
void OSCsendStepToProcessing(OSCMessage &msg, int addrOffset) {
  sendStepToProcessing();
}

//send current step to Processing (maybe this will be used even without the incoming OSC command, so it's its own function)
void sendStepToProcessing() {
  AsyncUDPMessage udpMsgStep;
  OSCMessage oscMsgPing("/step");
  oscMsgPing.add(NODE_ID);
  oscMsgPing.add((int)stepper.currentPosition());
  oscMsgPing.send(udpMsgStep);
  oscMsgPing.empty();
  udpOut.broadcastTo(udpMsgStep, networkOutPort);
}

//ping Processing every couple seconds
void ping() {
  if (pingTimer.hasPassed(pingInterval)) {
    pingTimer.restart();
    sendPingToProcessing();
  }
}

//send a ping with node info to processing
void sendPingToProcessing() {
  AsyncUDPMessage udpMsgPing;
  OSCMessage oscMsgPing("/ping");
  oscMsgPing.add(int(millis()));
  oscMsgPing.add(NODE_ID);
  oscMsgPing.add(WiFi.localIP().toString().c_str());
  oscMsgPing.add(WiFi.macAddress().c_str());
  oscMsgPing.add(FW_VERSION);
  oscMsgPing.send(udpMsgPing);
  oscMsgPing.empty();
  udpOut.broadcastTo(udpMsgPing, networkOutPort);
}

//turn LED on or off depending on if IP was set correctly in processing
void OSCincomingPing(OSCMessage &msg, int addrOffset) {
  char tmpstr[512];
  msg.getString(0, tmpstr);
  String ip = (char*)tmpstr;
  if (ip == WiFi.localIP().toString().c_str()) {
    digitalWrite(LED_PIN,  !digitalRead(LED_PIN));
  }
}

//check for new firmware on the server
void updateFirmware() {
  if (UPDATE_FIRMWARE) {
    if (getFirmwareVersionFromServer()) { // check if a new version is avaiable on the server
      updateFirmwareFromServer(); // get binary and flash it.
    }
    UPDATE_FIRMWARE = false; // update done
  }
}

// //init jogging toggle
// void OSCtoggleJogging(OSCMessage &msg, int addrOffset) {
//   int OSCdirection = msg.getInt(0);
//   if (!jogging) {
//     direction = OSCdirection;
//     jogging = true;
//     jog();
//   } else {
//     jogging = false;
//     stepper.stop();
//   }
// }

// //move continuously
// void jog() {
//   stepper.moveTo(jogValue * direction);
// }

// //pick either -1 or 1
// float randomDirection() {
//   int n = random(-1, 2);
//   while (n == 0) n = random (-1, 2);
//   Serial.println("direction: " + (String)n);
//   return n;
// }