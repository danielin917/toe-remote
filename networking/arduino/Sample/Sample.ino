//"services.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include <RBL_services.h>

void setup() {
  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(3, 2);
  
  // Set your BLE Shield name here, max. length 10
  ble_set_name("On/Off");
  
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600);
}

void loop() {
  // If data is ready
  while(ble_available()) {
    // read out command and data
    byte data = ble_read();

    if (data == 0x00) {
      Serial.write('0');
      // Do something
    } else if (data == 0x01) {
      Serial.write('1');
      // Do something else
    } else {
      Serial.write('f');
    }
    Serial.println();
  }
  // Allow BLE Shield to send/receive data
  ble_do_events();  
}
