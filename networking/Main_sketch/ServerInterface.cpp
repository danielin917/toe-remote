#include "ServerInterface.h"
#include "lib.h"
#include <Arduino.h>
#include <RBL_services.h>
#include <RBL_nRF8001.h>
#include <acilib_defs.h>
#include <acilib_if.h>
#include <dtm.h>
#include <lib_aci.h>
#include <hal_platform.h>
#include <acilib.h>
#include <bootloader_setup.h>
#include <ble_assert.h>
#include <aci_queue.h>
#include <hal_aci_tl.h>
#include <boards.h>
#include <aci_evts.h>
#include <aci_setup.h>
#include <acilib_types.h>
#include <aci.h>
#include <aci_cmds.h>
#include <aci_protocol_defines.h>
int Button::next_id = 0;

ServerInterface::ServerInterface():device_name(NULL){}

ServerInterface::~ServerInterface(){}

int ServerInterface::create_button(unsigned char size_x, unsigned char size_y, unsigned char grid_x, unsigned char grid_y, char* text, button_func func)
{	
	if(btn_vec.size() == 16)
	{
		/*more than 16 buttons not currently supported*/
		return -1;
	}
	Button* btn = new Button(size_x, size_y, grid_x, grid_y, text);
	btn_vec.push_back(btn);
	function_map.push_back(func);		
	btn->id = Button::next_id++;
	return btn->id;	
}

bool ServerInterface::set_device_name(const char* name) 
{
	strncpy(device_name, name, 10);
}
bool ServerInterface::start_server(/* parameters */){
	if(!device_name)
		strncpy(device_name,"toe-device",10);
	
	ble_set_name(device_name);	
	ble_begin();
	return true;
}


bool ServerInterface::reset_server(uint8_t reset_pin){
	ble_reset(reset_pin);
	return true;
}


bool ServerInterface::process_command(){

	if(ble_connected())
	{
		if(ble_available() >= 2)/*only read if we have a full package*/
		{
			unsigned char cmd;
			unsigned char func_index;
			cmd = (unsigned char)ble_read();	 
			func_index = (unsigned char)ble_read();	
			switch(cmd)
			{	
				case 0x00:
					/* do response for layout */	
					send_layout();
					break;
				case 0x01:
					call_function(func_index);	
					break;
				default:
					break;
			}
		}			
		return true;
	}
	return false;	
}

bool ServerInterface::call_function(unsigned char func_index)
{
	function_map[func_index]();		
	return true;
}  

bool ServerInterface::send_layout()
{
	
	return true;
}
