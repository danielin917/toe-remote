#include "Arduino.h"
#include "BLEPeripheral.h"
#include "ServerInterface.h"

#include <RBL_nRF8001.h>
#include <RBL_services.h>
#include <SPI.h>
#include <boards.h>
#include <EEPROM.h>
#include <Servo.h>
ServerInterface<button_func> _interface;

int ledPins[] = {2,3,4,5,6,7,10};

void setup(){	
	_interface.set_device_name("arduino");	
	_interface.create_button
	_interface.start_server();	
}

void loop(){
	

}
