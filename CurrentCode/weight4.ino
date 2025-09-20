#include <WiFi.h>
#include <WebServer.h>
#include "HX711.h"

const char* ssid = "linksys";
const char* password = "penthouse7";

#define DOUT_PIN 19
#define CLK_PIN 18

HX711 scale;
WebServer server(80);

void setup() {
    Serial.begin(115200);
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");
     Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    scale.begin(DOUT_PIN, CLK_PIN);
    scale.set_scale();
    scale.tare();

    server.on("/getWeight", HTTP_GET, handleGetWeight);
    server.begin();
    
    Serial.println("Server started");
}

void loop() {
    server.handleClient();
}

void handleGetWeight() {
    Serial.println("Received GET request for weight");
    
    float weight = scale.get_units();
    String weightStr = String(weight,1);
    
    Serial.print("Weight: ");
    Serial.println(weightStr);
    
    server.send(200, "text/plain", weightStr);
}
