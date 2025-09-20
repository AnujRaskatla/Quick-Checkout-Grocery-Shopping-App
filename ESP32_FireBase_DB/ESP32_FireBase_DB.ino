#include <FirebaseESP32.h>
#include <HX711.h>

#define FIREBASE_HOST "https://esp32-e3373-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "AIzaSyDPTOp4u6Ge3MhD4smBhrceIRmbpjWkMnU"

#define WIFI_SSID "Anuj's Oneplus"
#define WIFI_PASSWORD "12345678"

#define HX711_DOUT_PIN 19 // Replace with your actual pin number
#define HX711_SCK_PIN 18   // Replace with your actual pin number

HX711 scale;
FirebaseData firebaseData;
float CALIBRATION_FACTOR = 391.00;
float tarey = -67.1;

void setup() {
  Serial.begin(115200);
  Serial.println("Serial communication started...");

  // Connect to Wi-Fi
  Serial.print("Connecting to Wi-Fi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");

  // Initialize Firebase
  Serial.println("Initializing Firebase...");
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Serial.println("Firebase initialized");

  // Initialize the HX711 scale
  Serial.println("Initializing HX711...");
  scale.begin(HX711_DOUT_PIN, HX711_SCK_PIN);
  scale.set_scale(CALIBRATION_FACTOR);
  scale.tare(tarey);
  Serial.println("HX711 initialized");
}

void loop() {
  // Read weight from the load cell
  float weight = scale.get_units(10); // Read the weight 10 times for accuracy
  Serial.print("Weight: ");
  Serial.println(weight);

  // Send weight to Firebase under the branch "Counter Number 2"
  Serial.print("Sending weight to Firebase... ");
  String firebasePath = "Counter_No 2:/ESPweight"; // Firebase path
  Firebase.setFloat(firebaseData, firebasePath.c_str(), weight);
  if (firebaseData.dataAvailable()) {
    Serial.println("Success!");
  } else {
    Serial.print("Failed. Reason: ");
    Serial.println(firebaseData.errorReason());
  }

  delay(1000); // Update every second
}
