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

float FW_VERSION = 0.03; // important for the firmware ota flashing process / increment for next upload

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
boolean jogging = false;

//95A Hall sensor analog input
#define HALL_SENSOR_PIN A0

float voltage;                            //voltage in this measuring cycle
boolean homing = false;                   //are we homing right now?
float lowestVoltage = 600;                //start higher than it ever will be
boolean lowestVoltageFound = false;       //has the lowest voltage been found
float lastVoltage;
float voltageFindingCounter;
float avrgVltg[5];
unsigned int arraySize = 5;
unsigned int homingCounter = 0;

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

  // //do whatever
  if (homing && !lowestVoltageFound) {
    findLowestVoltage();
  }
  else if (homing && lowestVoltageFound) {
    goHome();
  }

  //do whatever the stepper was told to
  stepper.run();
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

//init jogging toggle
void OSCtoggleJogging(OSCMessage &msg, int addrOffset) {
  if (!jogging) {
    homing = false;
    jogging = true;
    jog();
  } else {
    homing = false;
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
  Serial.println("direction changed");
  return n;
}

//initialize homing sequence
void OSCinitHoming(OSCMessage &msg, int addrOffset) {
  jogging = false;
  homing = true;
}

//read voltage and record lowest one
void findLowestVoltage() {
  //read hall sensor
  float voltage = analogRead(HALL_SENSOR_PIN);
  float averageVoltage;

  stepper.moveTo(jogValue);

  //homingCounter++;

  //move everything one index and add to averageVoltage
  // for(int i = arraySize; i > 0; i--)  {
  //   avrgVltg[i] = avrgVltg[i-1];
  //   averageVoltage += avrgVltg[i-1];
  // }

  //write new voltage to first index
  //avrgVltg[0] = voltage;
    
  //get average of last arraySize measurements
  //averageVoltage /= arraySize;
  
  //Serial.println("voltage: " + (String)voltage + " averageVoltage: " + (String)averageVoltage + " lowestVoltage: " + (String)lowestVoltage);

  Serial.println("voltage: " + (String)voltage);

  //only start homing after avrgVltg is filled with measurements
  // if (homingCounter > arraySize * 2) {
  //   //find lowest voltage
  //   if (averageVoltage <= lowestVoltage) {
  //     lowestVoltage = averageVoltage;
  //   }
  //   else if (averageVoltage > lowestVoltage) {
  //     //lowestVoltageFound = true;
  //     //Serial.println("lowest voltage found");
  //   }
  // }
}

//go to where hall sensor voltage is the highest
void goHome() {
  //read hall sensor
  float voltage = analogRead(HALL_SENSOR_PIN);

  Serial.println("voltage: " + (String)voltage + " lowestVoltage: " + (String)lowestVoltage);

  //determine if we're home or not
  if (voltage <= lowestVoltage) {
    stepper.moveTo(jogValue);
  } else if (voltage > lowestVoltage) {
    stepper.stop();
    Serial.println("home");
    homing = false;
    direction = randomDirection();
  }
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

// THIS WILL INTERRUPT THE ROTATION AND IS NOT IMPORTANT ENOUGH TO DEAL WITH FOR THE MOMENT
// //init flashing sequence
// void initFlash() {
//   millisAtLastFlash = millis();
//   flashing = true;
//   digitalWrite(LED_PIN, HIGH); 
// }

// //turn off LED after flashInterval milliseconds
// void stopFlash() {
//   //get current millis
//   float currentMillis = millis();
  
//   //turn off and reset timer if interval is reached
//   if (flashing == true && (currentMillis - millisAtLastFlash >= flashInterval)) {
//     flashing = false;
//     digitalWrite(LED_PIN, LOW);
//   }
// }