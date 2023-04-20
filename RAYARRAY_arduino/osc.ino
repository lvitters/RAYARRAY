//when OSC message comes
void onPacketOSC(AsyncUDPPacket packet) {
  if (LOCK_UDP_RECEIVER) { //lock from firmware flash process
    packet.flush();
    return; //do nothing!
  }
  OSCMessage msgIn;
  if ((packet.length() > 0)) {
    msgIn.fill(packet.data(), packet.length());
    packet.flush();
    if (!msgIn.hasError()) {
      
      msgIn.route("/goHome", OSCgoHome);

      msgIn.route("/jog", OSCtoggleJogging);

      msgIn.route("/rotate", OSCrotate);

      msgIn.route("/getStep", OSCsendStepToProcessing);

      msgIn.route("/pingNode", OSCincomingPing);

      msgIn.route("/updateFirmware", OSCupdateFirmware);
      msgIn.route("/ufversionurl", OSCupdateFirmwareSetVersionURL);
      msgIn.route("/ufbinaryurl", OSCupdateFirmwareSetBinaryURL);

      packet.flush();
    }
  }
  packet.flush();
}

void OSCupdateFirmware(OSCMessage &msg, int addrOffset) {
  Serial.print("/updatefirmware");

  UPDATE_FIRMWARE = true; // set the hook for the main loop
  //update procedure has to be initiated from the "main" loop other wise memory acces is limited.
}

void OSCupdateFirmwareSetVersionURL(OSCMessage &msg, int addrOffset) {
  Serial.print(">> /ufversionurl ");
  char tmpstr[512];
  int retlength = msg.getString(0, tmpstr, 512);
  Serial.print(tmpstr);
  Serial.print(" ( ");
  Serial.print(retlength);
  Serial.println(" )");
  if (retlength > 20) {
    strncpy(URL_FW_VERSION, tmpstr, retlength);
    Serial.print("new URL_FW_VERSION = ");
    Serial.println(URL_FW_VERSION);
  }
}

void OSCupdateFirmwareSetBinaryURL(OSCMessage &msg, int addrOffset) {
  Serial.print(">> /ufbinaryurl ");
  char tmpstr[512];
  int retlength = msg.getString(0, tmpstr, 512); // xxx.xxx.xxx.xxx = 15 + string ende char = 16
  Serial.print(tmpstr);
  Serial.print(" ( ");
  Serial.print(retlength);
  Serial.println(" )");
  if (retlength > 20) {
    strncpy(URL_FW_BINARY, tmpstr, retlength);
    Serial.print("new URL_FW_BINARY = ");
    Serial.println(URL_FW_BINARY);
  }
}