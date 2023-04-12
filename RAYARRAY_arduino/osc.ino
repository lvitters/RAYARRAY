void onPacketOSC(AsyncUDPPacket packet) {
  if (LOCK_UDP_RECEIVER) { // lock from firmware flash process
    packet.flush();
    return; // do nothing!
  }
  OSCMessage msgIn;
  if ((packet.length() > 0)) {
    msgIn.fill(packet.data(), packet.length());
    packet.flush();
    if (!msgIn.hasError()) {

      msgIn.route("/rotate", OSCrotate);
      
      msgIn.route("/goHome", OSCinitHoming);

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

  UPDATE_FIRMWARE = true; // set the hook for the main loooooop
  // update procedure has to be initiated from the "main" loop other wise memory acces is limited.
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

void sendPingToProcessing() {
  AsyncUDPMessage udpMsg;
  OSCMessage oscMsg("/ping");
  oscMsg.add(int(millis()));
  oscMsg.add(NODE_ID);
  oscMsg.add(WiFi.localIP().toString().c_str());
  oscMsg.add(WiFi.macAddress().c_str());
  oscMsg.add(FW_VERSION);
  oscMsg.add(123); // send some other data
  oscMsg.send(udpMsg);
  oscMsg.empty();
  udpOut.broadcastTo(udpMsg, networkOutPort);
}