#pragma once
#include "lib.h"
#include <Arduino.h>

typedef void (*button_func)();

/*
 *Button settings specified by developer
 */
struct Button{
	static int next_id;
	int id;
	int size_x;
	int size_y;
	int grid_x;
	int grid_y;
	char* text;
	
	Button(int _size_x, int _size_y, int _grid_x, int _grid_y, char* _text)
	:size_x(_size_x), size_y(_size_y), grid_x(_grid_x), grid_y(_grid_y){
		char * buf = new char[50];
		strncpy(buf, _text, 50);
		text = buf;
	}
};

class ServerInterface {
public:
  
	//STORAGE FOR BUTTONS
	Vector<Button*> btn_vec;
	//MAPPINNG FROM INDEX TO FUNCTION
	Vector<button_func> function_map;		  
	
//////////////////////SETTINGS//////////////////////////////////
/*
 *Create and store new button
 *RETURNS: 1 on success
 */
	int create_button(int size_x, int size_y, int grid_x, int grid_y, char* text, button_func func);		

  
//////////////////////INTERFACE/////////////////////////////////
 /**
   * Constructs the object and starts the server
   */
  ServerInterface(){}
  /**
   * Starts the server
   */
  bool startServer(/* parameters */);
  /**
   * Stops the server
   */
  bool stopServer();

  /**
   * In the case of a single threaded
   */ 
  bool process(); 

  /**
   * Stops the server if its running and destroys the object
   */
  ~ServerInterface();

  // Its going to be a bit harder to define how the communication works.
  // Probably do an example, then work it out
 };
