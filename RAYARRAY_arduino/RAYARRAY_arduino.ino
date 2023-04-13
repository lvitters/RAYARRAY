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

float FW_VERSION = 0.01; // important for the firmware ota flashing process / increment for next upload

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
float jogValue = 999999999;               //super high number as target for 'infinite' jog
int direction;

//95A Hall sensor analog input
#define HALL_SENSOR_PIN A0

float voltage;                            //voltage in this measuring cycle
float lowestVoltage = 600;                //start higher than it ever will be
float millisSinceLastHome = 0;            //how many milliseconds ago where we last home
boolean homing = false;                   //are we homing right now?

//LED pin
#define LED_PIN 2
int ledState = LOW;                       //is the LED on or off
const long flashInterval = 500;             //how quickly does the LED flash in milliseconds
unsigned long millisAtLastFlash = 0;   //how many milliseconds ago did we last turn on the LED
boolean flashing = false;

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

  //goHome if homing or jog if not homing (for testing)
  if (homing) goHome();
  else jog();

  //count since last time homing sequence was finished
  millisSinceLastHome++;

  //do whatever the stepper was told to
  stepper.run();

  //check if LED should be turned off (turned on by trigger)
  stopFlash();
}

void initStepperMotor() {
  stepper.setMaxSpeed(800);          //max 1500
  stepper.setAcceleration(1500);
}

//rotate from OSC messages
void OSCrotate(OSCMessage &msg, int addrOffset) {
  Serial.print("/rotate ");
  float inputRotation = msg.getFloat(0);
  Serial.print("\n");

  //rotation = rotation % stepsPerRevolution;

  rotation = (long) inputRotation;
  
  Serial.print(rotation);

  //set destination
  stepper.moveTo(rotation);
}

//move continuously
void jog() {
  stepper.moveTo(jogValue * direction);
}

//pick either -1 or 1
float randomDirection() {
  int n = random(-1, 2);
  while (n == 0) n = random (-1, 2);
  Serial.println("direction changed");
  return n;
}

//initialize homing sequence
void OSCinitHoming(OSCMessage &msg, int addrOffset) {
  homing = true;
}

//go to where hall sensor voltage is the highest
void goHome() {
  //read hall sensor
  float voltage = analogRead(HALL_SENSOR_PIN);
  Serial.println(voltage);

  //find lowest voltage
  if (voltage < lowestVoltage) lowestVoltage = voltage;

  //determine if we're home or not
  if (voltage > lowestVoltage) {
    jog();
  } else if (voltage <= lowestVoltage) {
    Serial.println("home");
    homing = false;
    millisSinceLastHome = 0;
    direction = randomDirection();
    stepper.stop();
    delay(2000);
  }
  Serial.println(lowestVoltage);
}

//init flashing sequence
void initFlash() {
  millisAtLastFlash = millis();
  flashing = true;
  digitalWrite(LED_PIN, HIGH); 
}

//turn off LED after flashInterval milliseconds
void stopFlash() {
  //get current millis
  float currentMillis = millis();
  
  //turn off and reset timer if interval is reached
  if (flashing == true && (currentMillis - millisAtLastFlash >= flashInterval)) {
    flashing = false;
    digitalWrite(LED_PIN, LOW);
  }
}

//do something every couple seconds
void ping() {
  if (pingTimer.hasPassed(pingInterval)) {
    pingTimer.restart();
    sendPingToProcessing();
  }
}

void updateFirmware() {
  if (UPDATE_FIRMWARE) {
    if (getFirmwareVersionFromServer()) { // check if a new version is avaiable on the server
      updateFirmwareFromServer(); // get binary and flash it.
    }
    UPDATE_FIRMWARE = false; // update done
  }
}