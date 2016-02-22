#include <RBL_nRF8001.h>
#include <RBL_services.h>


#include <SPI.h>
#include <boards.h>
#include <EEPROM.h>
#include <Servo.h>

int ledPins[] = {2,3,4,5,6,7,10};
//RedPins[] = {2,10}
//YellowPins[] = {3,7}
//GreenPins[] = {4,6}
//BluePins[] = {5}
enum class ColorBtn {RAND, RED, YELLOW, GREEN, BLUE};
ColorBtn color = ColorBtn::RAND;

void setup()
{
  int index;

  for(index = 0; index <= 6; index++)
  {
    pinMode(ledPins[index],OUTPUT);
  }

  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(9, 8);
  
  // Set your BLE Shield name here, max. length 10
  ble_set_name("On/Off");
  
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600);
}


void loop()
{
  int index;
  int delayTime = 100;
  
  // If data is ready
  while(ble_available()) {
    for(index = 0; index <= 7; index++)
    {
      digitalWrite(ledPins[index], LOW);   // turn LED off
    }
    // read out command and data
    byte data = ble_read();

    if (data == 0x00) {
      Serial.write('0');
      color = ColorBtn::RAND;
    } else if (data == 0x01) {
      Serial.write('1');
      color = ColorBtn::RED;
    } else if (data == 0x02) {
      Serial.write(data);
      color = ColorBtn::YELLOW;
    } else if (data == 0x03) {
      Serial.write(data);
      color = ColorBtn::GREEN;
    } else if (data == 0x04) {
      Serial.write(data);
      color = ColorBtn::BLUE;
    } else {
      Serial.write(data);
    }
    Serial.println();
  }
  
  while(!ble_available())
  {
    
    if(color == ColorBtn::RAND) {
      index = random(8);    // pick a random number between 0 and 7
  
      digitalWrite(ledPins[index], HIGH);  // turn LED on
      delay(delayTime);                    // pause to slow down
      digitalWrite(ledPins[index], LOW);   // turn LED off

    } else if (color == ColorBtn::RED) {
      digitalWrite(ledPins[0], HIGH);
      digitalWrite(ledPins[6], HIGH);
    } else if (color == ColorBtn::YELLOW) {
      digitalWrite(ledPins[1], HIGH);
      digitalWrite(ledPins[5], HIGH);
    } else if (color == ColorBtn::GREEN) {
      digitalWrite(ledPins[2], HIGH);
      digitalWrite(ledPins[4], HIGH);
    } else if (color == ColorBtn::BLUE) {
      digitalWrite(ledPins[0], HIGH);
    }
    ble_do_events(); 
  }
  // Allow BLE Shield to send/receive data
  ble_do_events();  
}

