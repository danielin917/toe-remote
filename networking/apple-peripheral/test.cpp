#include "../Main_sketch/ServerInterface.h"
#include "BLEPeripheral.h"

#include <array>
#include <vector>
#include <iostream>

void a() { std::cout << "Button A pressed" << std::endl; }
void b() { std::cout << "Button B pressed" << std::endl; }
void c() { std::cout << "Button C pressed" << std::endl; }
void r() { std::cout << "Button Rest pressed" << std::endl; }

int main() {
    const char *name = "test-app";
    const std::array<Button, 4> buttons = {
        Button{0, 0, 30, 30, "Button A"},
        Button{33, 0, 30, 30, "Button B"},
        Button{66, 0, 30, 30, "Button C"},
        Button{0, 33, 100, 67, "The Rest of the Screen"}};
    const std::vector<button_func> funcs = {&a, &b, &c, &r};
    ServerInterface<button_func> server;
    server.set_device_name(name);
    for (unsigned i = 0; i < buttons.size(); ++i) {
        const auto &button = buttons[i];
        server.create_button(button.x, button.y, button.width, button.height,
                             button.text, funcs[i]);
    }
    server.start_server();
    while (true) {
        while (server.process_command()) {}
        sleep(1);
    }
}
