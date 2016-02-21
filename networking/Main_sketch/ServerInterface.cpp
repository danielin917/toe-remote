#include "ServerInterface.h"
#include "lib.h"
#include <Arduino.h>

int Button::next_id = 0;


int ServerInterface::create_button(int size_x, int size_y, int grid_x, int grid_y, char* text, button_func func)
{
	Button* btn = new Button(size_x, size_y, grid_x, grid_y, text);
	btn_vec.push_back(btn);
	function_map.push_back(func);		
	btn->id = Button::next_id++;
	return btn->id;	
}

bool ServerInterface::startServer(/* parameters */){return true;}


bool ServerInterface::stopServer(){return true;}


bool ServerInterface::process(){
return true;
}

  
ServerInterface::~ServerInterface(){}

