#include <ESP8266WiFi.h>        // Include the Wi-Fi library
const char *ssid = "OpenWrt"; // The name of the Wi-Fi network that will be created
const char *password = "";   // The password required to connect to it, leave blank for an open network

#include <AccelStepper.h>
const int stepsPerRevolution = 2048;  // change this to fit the number of steps per revolution

// ULN2003 Motor Driver Pins
#define IN1 5
#define IN2 4
#define IN3 14
#define IN4 12

// 95A Hall sensor analog input
#define Hall_Sensor_Pin A0

// initialize the stepper library
AccelStepper stepper(AccelStepper::HALF4WIRE, IN1, IN3, IN2, IN4);

void setup() {

  //connectToWifi();

  initStepperMotor();

  //initHallSensor();
}

void loop() {
  // check current stepper motor position to invert direction
  if (stepper.distanceToGo() == 0){
    stepper.moveTo(-stepper.currentPosition());
    Serial.println("Changing direction");
  }

  // move the stepper motor (one step at a time)
  stepper.run();

  /*
  if (millis() % 250 == 0) {
    //hall sensor: read analog voltage
    float voltage;
    voltage = analogRead(Hall_Sensor_Pin);
    Serial.println(voltage);
  }
  */
}

void initStepperMotor() {
  //initialize the serial port
  Serial.begin(115200);
  //set the speed and acceleration
  stepper.setMaxSpeed(500);          //max 1950
  stepper.setAcceleration(10000);     //max 50000
  //set target position
  stepper.moveTo(stepsPerRevolution*3);
}

void initHallSensor() {
  //hall sensor
  pinMode(Hall_Sensor_Pin, INPUT);
  Serial.begin(9600);
}

void connectToWifi() {
  Serial.print("Connecting to ");
  Serial.print(ssid); Serial.println(" ...");

  int i = 0;
  while (WiFi.status() != WL_CONNECTED) { //wait for the Wi-Fi to connect
    delay(1000);
    Serial.print(++i); Serial.print(' ');
  }

  Serial.println('\n');
  Serial.println("Connection established!");  
  Serial.print("IP address:\t");
  Serial.println(WiFi.localIP());         //send the IP address of the ESP8266 to the computer
}