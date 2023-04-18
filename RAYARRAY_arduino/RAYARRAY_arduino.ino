//take specific libraries for ESP8266
//board file from here: https://arduino.esp8266.com/stable/package_esp8266com_index.json
#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>
#include <ESPAsyncUDP.h> // https://github.com/me-no-dev/ESPAsyncUDP

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

float FW_VERSION = 0.04; // important for the firmware ota flashing process / increment for next upload

// server location of your new firmware (export firmware with arduino IDE , change version.txt as well)
// change server IP if needed
// can be set via osc as well

const char DEFAULT_URL_FW_VERSION[] = "http://192.168.1.164:8080/release/version.txt";
const char  DEFAULT_URL_FW_BINARY[] = "http://192.168.1.164:8080/release/firmware.bin";

boolean LOCK_UDP_RECEIVER = false; // lock UDP/OSC receiver to avoid shit while flashing a new firmware
char URL_FW_VERSION[512];
char URL_FW_BINARY[512];
boolean UPDATE_FIRMWARE = false; // hook in firmwareupdate

long pingInterval = 2000; // every 2 seconds
int networkLocalPort = 8888;  // remote port to receive OSC
int networkOutPort = 9999; 

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

const int stepsPerRevolution = 2038;      //change this to fit the number of steps per revolution
long rotation = 0;
int direction;
float jogValue = 999999999;               //super high number as target for 'infinite' jog
boolean jogging = false;                  //are we jogging right now?

//95A Hall sensor analog input
#define HALL_SENSOR_PIN A0

//homing
boolean homing = true;                  //are we homing right now?
unsigned int homingDuration = 25000;    //in milliseconds
float previousVoltage = 0;              //voltage in the previous measuring cycle
float lowestVoltage = 600;              //higher than it will ever be
float smoothAlpha = 0.5;                //how much does the previous value affect the smoothed one
int homeStep;                           //step with the lowest voltage

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

  //init stepper and set to random direction for now
  initStepperMotor();
  direction = randomDirection();

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

  //do whatever the stepper was told to
  stepper.run();
}

void initStepperMotor() {
  stepper.setMaxSpeed(800);          //max 1500
  stepper.setAcceleration(1500);
}

//init jogging toggle
void OSCtoggleJogging(OSCMessage &msg, int addrOffset) {
  if (!jogging) {
    direction = randomDirection();
    jogging = true;
    jog();
  } else {
    jogging = false;
    stepper.stop();
  }
}

//move continuously
void jog() {
  stepper.moveTo(jogValue * direction);
}

//pick either -1 or 1
float randomDirection() {
  int n = random(-1, 2);
  while (n == 0) n = random (-1, 2);
  Serial.println("direction: " + (String)n);
  return n;
}

//read voltage and record lowest one and the step where it is at
void findLowestVoltage() {
  //read hall sensor
  float voltage = analogRead(HALL_SENSOR_PIN);

  //formula from Felix Fisgus
  float smoothVoltage = smoothAlpha * voltage + (1-smoothAlpha) * previousVoltage;

  //move along
  stepper.moveTo(jogValue);

  //find lowest voltage
  if (smoothVoltage <= lowestVoltage && smoothVoltage > 450) {  //TODO: hardcoded number is bad!
    lowestVoltage = smoothVoltage;
    homeStep = stepper.currentPosition() % stepsPerRevolution;
  }

  //Serial.println("voltage: " + (String)voltage + " smoothVoltage: " + (String)smoothVoltage + " lowestVoltage: " + (String)lowestVoltage);

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
    //Serial.println("homeStep: " + (String)homeStep + " currentStep: " + (String)stepper.currentPosition());
    //if we're at that step, set to 0
    if (stepper.currentPosition() % stepsPerRevolution == homeStep) {
      stepper.setCurrentPosition(0);
      Serial.println("home found");
      //set homing to false to stop this nightmare
      homing = false;
    }
  }
}

//go to the position recorded as home
void OSCgoHome(OSCMessage &msg, int addrOffset) {
  jogging = false;
  Serial.println("going home");
  stepper.moveTo(0);
}

//do something every couple seconds
void ping() {
  if (pingTimer.hasPassed(pingInterval)) {
    pingTimer.restart();
    sendPingToProcessing();
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