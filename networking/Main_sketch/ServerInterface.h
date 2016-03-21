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
	unsigned char x;
	unsigned char y;
	unsigned char width;
	unsigned char height;
	char* text;

        Button(unsigned char _x, unsigned char _y,
               unsigned char _width, unsigned char _height, const char *_text)
            : x(_x), y(_y), width(_width),
              height(_height), text(nullptr)
        {
                text = new char[50];
                strncpy(text, _text, 50);
        }

        ~Button()
        {
            if (text != nullptr)
                delete text;
        }
};

template <typename Callable>
class ServerInterface
{
    // BLEPeripheral
    BLEPeripheral *ble;
    // Broadcast Name
    char device_name[11] = "toe-device";
    // Storage for Buttons
    Vector<Button *> btn_vec;
    // Mapping from Index to Function
    Vector<Callable> function_map;
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
    int create_button(unsigned char x, unsigned char y, unsigned char width,
                      unsigned char height, char *text, Callable func);
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

template <typename Callable>
ServerInterface<Callable>::ServerInterface()
    : ble(nullptr)
{
}

template <typename Callable>
ServerInterface<Callable>::~ServerInterface()
{
    if (ble != nullptr)
        delete ble;
}

template <typename Callable>
int ServerInterface<Callable>::create_button(unsigned char x, unsigned char y,
                                               unsigned char width,
                                               unsigned char height, char *text,
                                               Callable func)
{
    if (btn_vec.size() == 16)
    {
        /*more than 16 buttons not currently supported*/
        return -1;
    }
    Button *btn = new Button(x, y, width, height, text);
    btn_vec.push_back(btn);
    function_map.push_back(func);
    btn->id = Button::next_id++;
    return btn->id;
}

template <typename Callable>
bool ServerInterface<Callable>::set_device_name(const char *name)
{
    if (!name)
        return false;
    strncpy(device_name, name, 10);
    return true;
}

template <typename Callable>
bool ServerInterface<Callable>::start_server(/* parameters */)
{
    ble = new BLEPeripheral(device_name);
    return true;
}

template <typename Callable>
bool ServerInterface<Callable>::process_command()
{
    if (!ble)
    {
        return false;
    }
    ble->process();
    if (ble->connected())
    {
        if (ble->bytes_available() >= 2) /*only read if we have a full package*/
        {
            unsigned char cmd;
            unsigned char func_index;
            cmd = (unsigned char)ble->read_byte();
            func_index = (unsigned char)ble->read_byte();
            switch (cmd)
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
            return true;
        }
    }
    return false;
}

template <typename Callable>
bool ServerInterface<Callable>::call_function(unsigned char func_index)
{
    function_map[func_index]();
    return true;
}

template <typename Callable>
bool ServerInterface<Callable>::send_layout()
{
    if (!ble)
    {
        return false;
    }
    if (btn_vec.size() == 0)
        return false;
    unsigned char num_buttons = (unsigned char)btn_vec.size();
    ble->write(&num_buttons, 1);

    unsigned char buf[55];
    for (int i = 0; i < btn_vec.size(); i++)
    {
        buf[0] = btn_vec[i]->id;
        buf[1] = btn_vec[i]->x;
        buf[2] = btn_vec[i]->y;
        buf[3] = btn_vec[i]->width;
        buf[4] = btn_vec[i]->height;
        strncpy((char *)(buf + 5), btn_vec[i]->text, 50);
        ble->write(buf, 55);
        ble->process();
    }
    return true;

}
