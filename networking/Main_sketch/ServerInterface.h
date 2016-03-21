#pragma once
#include "lib.h"
#include "BLEPeripheral.h"

#include <string.h>
#include <stdint.h>

/*
 *button functions defined as function pointers
 */
typedef void (*button_func)();

/*
 *Button settings specified by developer
 */
struct Button{
	static int next_id;
	unsigned char id;
	unsigned char size_x;
	unsigned char size_y;
	unsigned char grid_x;
	unsigned char grid_y;
	char* text;
	
	Button(unsigned char _size_x, unsigned char _size_y, unsigned char _grid_x, unsigned char _grid_y, char* _text)
	:size_x(_size_x), size_y(_size_y), grid_x(_grid_x), grid_y(_grid_y){
		char * buf = new char[49];
		strncpy(buf, _text, 49);
		text = buf;
	}
};

class ServerInterface {
    // BLEPeripheral
    BLEPeripheral *ble;
    // Broadcast Name
    char *device_name;
    // Storage for Buttons
    Vector<Button *> btn_vec;
    // Mapping from Index to Function
    Vector<button_func> function_map;
    /*
     *Send layout of buttons
     */
    bool send_layout();
    /*
     *Uses the function mapping to button command
     */
    bool call_function(unsigned char func_index);

  public:
    //////////////////////SETTINGS//////////////////////////////////
    /*
     *Create and store new button
     *RETURNS: Button id for function on success, -1 on failure
     */
    int create_button(unsigned char size_x, unsigned char size_y,
                      unsigned char grid_x, unsigned char grid_y, char *text,
                      button_func func);
    /*
     *Sets the broadcast name for your device. Name can only be 10 characters
     *long
     *and default is toe-device. RETURNS true on success
     */
    bool set_device_name(const char *name);

    //////////////////////INTERFACE/////////////////////////////////
    /**
      * Constructs the object
      */
    ServerInterface();
    /**
     * Starts the server
     */
    bool start_server(/* parameters */);

    /**
     * In the case of a single threaded
     */
    bool process_command();

    /**
     * Stops the server if its running and destroys the object
     */
    ~ServerInterface();

    // Its going to be a bit harder to define how the communication works.
    // Probably do an example, then work it out
};
