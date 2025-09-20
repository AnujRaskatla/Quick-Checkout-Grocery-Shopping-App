#include <WiFi.h>

const char* ssid = "linksys";
const char* password = "penthouse7";

WiFiServer server(80);
int ledPin = 2;  // Pin connected to the LED

void setup() {
  pinMode(ledPin, OUTPUT);
  Serial.begin(115200);
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  server.begin();
  Serial.println("Server started");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  WiFiClient client = server.available();
  if (client) {
    Serial.println("New client connected");
    
    while (client.connected()) {
      if (client.available()) {
        String request = client.readStringUntil('\r');
        client.flush();
        
        if (request.indexOf("LED=ON") != -1) {
          digitalWrite(ledPin, HIGH);
        } else if (request.indexOf("LED=OFF") != -1) {
          digitalWrite(ledPin, LOW);
        }
        
        client.println("HTTP/1.1 200 OK");
        client.println("Content-Type: text/html");
        client.println();
        client.println("<!DOCTYPE HTML>");
        client.println("<html>");
        client.println("<p>LED Control</p>");
        client.println("<p><a href='/LED=ON'>Turn On</a></p>");
        client.println("<p><a href='/LED=OFF'>Turn Off</a></p>");
        client.println("</html>");
        break;
      }
    }
    
    delay(10);
    client.stop();
    Serial.println("Client disconnected");
  }
}
