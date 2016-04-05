#include "../Main_sketch/ServerInterface.h"
#include "Keycodes.h"
#include "SimulateKeypress.h"

#include <array>
#include <iostream>
#include <thread>
#include <vector>

using namespace keycodes;

int main() {
    const char *name = "test-app";
    const std::array<toe::Button, 5> buttons = {
        toe::Button{0,  33, 33, 33, "Left"},
        toe::Button{66, 33, 33, 33, "Right"},
        toe::Button{33, 0,  33, 33, "Up"},
        toe::Button{33, 66, 33, 33, "Down"},
        toe::Button{80, 0,  20, 20, "New Game"}};
    const std::array<SimulateKeypress, 5> funcs = {
        SimulateKeypress{kVK_LeftArrow}, SimulateKeypress{kVK_RightArrow},
        SimulateKeypress{kVK_UpArrow}, SimulateKeypress{kVK_DownArrow},
        SimulateKeypress{kVK_ANSI_R}};

    toe::ServerInterface<SimulateKeypress> server;
    server.set_device_name(name);
    for (unsigned i = 0; i < buttons.size(); ++i) {
        const auto &button = buttons[i];
        server.create_button(button.x, button.y, button.width, button.height,
                             button.text, funcs[i]);
    }
    server.start_server();
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds{60});
    }
}
