#include "ServerInterface.h"
#include "lib.h"

int Button::next_id = 0;

ServerInterface::ServerInterface() : ble(nullptr), device_name(nullptr) {}

ServerInterface::~ServerInterface()
{
    if (ble != nullptr)
        delete ble;
}

int ServerInterface::create_button(unsigned char size_x, unsigned char size_y,
                                   unsigned char grid_x, unsigned char grid_y,
                                   char *text, button_func func)
{
    if (btn_vec.size() == 16)
    {
        /*more than 16 buttons not currently supported*/
        return -1;
    }
    Button *btn = new Button(size_x, size_y, grid_x, grid_y, text);
    btn_vec.push_back(btn);
    function_map.push_back(func);
    btn->id = Button::next_id++;
    return btn->id;
}

bool ServerInterface::set_device_name(const char *name)
{
    strncpy(device_name, name, 10);
}
bool ServerInterface::start_server(/* parameters */)
{
    if (!device_name)
        strncpy(device_name, "toe-device", 10);

    ble = new BLEPeripheral(device_name);
    return true;
}

bool ServerInterface::process_command()
{

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

bool ServerInterface::send_layout() { return true; }
