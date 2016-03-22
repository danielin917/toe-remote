#include "Arduino.h"
#include "BLEPeripheral.h"
#include "ServerInterface.h"

#include <RBL_nRF8001.h>
#include <RBL_services.h>
#include <SPI.h>
#include <boards.h>
#include <EEPROM.h>
#include <Servo.h>

using namespace toe;

ServerInterface<button_func> _interface;


void shut_off();
void randomizer();
void red();
void yellow();
void green();
void blue();


int ledPins[] = {2,3,4,5,6,7,10};
enum class ColorBtn {RAND, RED, YELLOW, GREEN, BLUE};
int rand_index;
int delayTime = 100;


void setup(){	
	for(int index = 0; index <= 6; index++)
	{
		pinMode(ledPins[index],OUTPUT);
	}
	


	_interface.set_device_name("Light Show");		
	/*create light button layout*/
	_interface.create_button(25,15,50,20,"Random", &randomizer);
	_interface.create_button(0,50,25,20, "Red", &red);
	_interface.create_button(25,50,25,20, "Yellow", &yellow);
	_interface.create_button(50,50,25,20, "Green", &green);
	_interface.create_button(75,50,25,20, "Blue", &blue);
	_interface.start_server();	
}

void loop(){
	_interface.process_command();	
}
void shut_off()
{
	for(int i = 0; i < 7; i++)
	{
		digitalWrite(ledPins[i], LOW);
	} 	
}
void blue()
{
 	shut_off();
	digitalWrite(ledPins[3], HIGH);
}
void red()
{
	shut_off();
	digitalWrite(ledPins[0], HIGH);
	digitalWrite(ledPins[6], HIGH);

}
void yellow()
{
	shut_off();
	digitalWrite(ledPins[1], HIGH);
	digitalWrite(ledPins[5], HIGH);
	
}
void green()
{
	shut_off();
	digitalWrite(ledPins[2], HIGH);
	digitalWrite(ledPins[4], HIGH);
}
void randomizer()
{
	for(int i = 0; i < 10; i++)
	{
	      shut_off();
	      rand_index = random(8);    // pick a random number between 0 and 7 	
	      digitalWrite(ledPins[i], HIGH);  // turn LED on 
	      delay(delayTime);                    // pause to slow down  
	}
}



