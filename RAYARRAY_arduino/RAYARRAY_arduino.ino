// take specific libraries for ESP8266
// board file from here: https://arduino.esp8266.com/stable/package_esp8266com_index.json
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

float FW_VERSION = 0.02; // important for the firmware ota flashing process / increment for next upload

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

const int stepsPerRevolution = 2038;  // change this to fit the number of steps per revolution
long rotation = 0;
float jogValue = 999999999;
int direction;

//95A Hall sensor analog input
#define Hall_Sensor_Pin A0

float lowestVoltage = 600;      //start higher than it ever will be
float lastVoltage = 600;        //store the voltage of the cycle before, init higher than it will ever be
float millisSinceLastHome = 0;  //how many milliseconds ago where we last home
boolean homing = false;         //are we homing right now?

//LED pin
#define LED_PIN 2

void setup() {
  // ---------------------------------------------------------------------------------------- //
  strncpy(URL_FW_VERSION, DEFAULT_URL_FW_VERSION, strlen(DEFAULT_URL_FW_VERSION));
  strncpy(URL_FW_BINARY, DEFAULT_URL_FW_BINARY, strlen(DEFAULT_URL_FW_BINARY));
  
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
  
  initWIFI();
  initUDP();
  // ---------------------------------------------------------------------------------------- //

  //init stepper motor
  stepper.setMaxSpeed(800);          //max 1500
  stepper.setAcceleration(1500);
  direction = randomDirection();

  //init hall sensor
  pinMode(Hall_Sensor_Pin, INPUT);

  //init LED
  //pinMode(LED_PIN, OUTPUT);
}

void loop() {
  updateFirmware();
  
  if (homing) goHome();
  else jog();

  millisSinceLastHome++;

  stepper.run();

  //testLED();
}

//move continuously
void jog() {
  stepper.moveTo(jogValue * direction);
}

//go to where hall sensor voltage is the highest
void goHome() {
  //hall sensor: read analog voltage
  float voltage;
  voltage = analogRead(Hall_Sensor_Pin);
  if (voltage > 533) {
    jog();
  } else if (voltage <= 533) {
    Serial.println("home");
    homing = false;
    millisSinceLastHome = 0;
    direction = randomDirection();
    stepper.stop();
    delay(2000);
  }
  Serial.println(voltage);
}

//pick either -1 or 1
float randomDirection() {
  int n = random(-1, 2);
  while (n == 0) n = random (-1, 2);
  Serial.println("direction changed");
  return n;
}

void testLED() {
  // turn on LED
  digitalWrite(LED_PIN, HIGH);
  delay(1000);
  // turn off LED
  digitalWrite(LED_PIN, LOW);
  delay(1000);
}

//initialize homing sequence
void OSCinitHoming(OSCMessage &msg, int addrOffset) {
  homing = true;
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

void updateFirmware() {
  if (UPDATE_FIRMWARE) {
    if (getFirmwareVersionFromServer()) { // check if a new version is avaiable on the server
      updateFirmwareFromServer(); // get binary and flash it.
    }
    UPDATE_FIRMWARE = false; // update done
  }
  if (pingTimer.hasPassed(pingInterval)) {
    pingTimer.restart();
    sendPingOSC();
  }
}