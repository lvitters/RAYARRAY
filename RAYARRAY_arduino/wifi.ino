/*
   init functions for WIFI and UDP
*/
void initWIFI() {
  WiFi.mode(WIFI_STA);
  wifiMulti.addAP("OpenWrt", "12345678");     //change to "RAYARRAY"
  int n = WiFi.scanNetworks();
  if (WiFi.scanNetworks() == 0) {
    Serial.println(" no networks found");
  } else {
    Serial.print(n);
    Serial.println(" networks found");

    //list networks
    /*
    for (int i = 0; i < n; ++i) {
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.print(")");
      Serial.println((WiFi.encryptionType(i) == AUTH_OPEN) ? " " : "*");
      delay(10);
    }
    */

  }

  Serial.println("Connecting Wifi...");

  if (wifiMulti.run() == WL_CONNECTED) {
    Serial.println("WiFi connected");
    Serial.print(" SSID      : ");  Serial.println(WiFi.SSID());
    Serial.print(" IP address: ");  Serial.println(WiFi.localIP());
  }
}

void initUDP() {
  if (!udp.listen(networkLocalPort)) {
    Serial.println(" Error starting UDP server.");
  } else {
    Serial.print(" localIP = ");
    Serial.println(WiFi.localIP());
    Serial.print(" UDP listening on port ");
    Serial.println(networkLocalPort);
  }
  udp.onPacket(onPacketOSC);
}
