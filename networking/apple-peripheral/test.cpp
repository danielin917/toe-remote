#include "../Main_sketch/ServerInterface.h"
#include "Keycodes.h"
#include "SimulateKeypress.h"

#include <array>
#include <iostream>
#include <thread>
#include <vector>

using namespace keycodes;

int main() {
    const char *name = "2048";
    std::array<toe::Button, 5> buttons = {
        toe::Button{0, 33, 33, 33, "Left", false,
                    "https://i.imgur.com/Mdr3lsf.png"},
        toe::Button{66, 33, 33, 33, "Right", false,
                    "https://i.imgur.com/eMMJAOL.png"},
        toe::Button{33, 0, 33, 33, "Up", false,
                    "https://i.imgur.com/EoJl2v2.png"},
        toe::Button{33, 66, 33, 33, "Down", false,
                    "https://i.imgur.com/26T3elm.png"},
        toe::Button{80, 0, 20, 20, "New Game", true, nullptr}};
    const std::array<SimulateKeypress, 5> funcs = {
        SimulateKeypress{kVK_LeftArrow}, SimulateKeypress{kVK_RightArrow},
        SimulateKeypress{kVK_UpArrow}, SimulateKeypress{kVK_DownArrow},
        SimulateKeypress{kVK_ANSI_R}};

    toe::ServerInterface<SimulateKeypress> server;
    server.set_device_name(name);
    for (unsigned i = 0; i < buttons.size(); ++i) {
        auto &&button = buttons[i];
        server.add_button(std::move(button), funcs[i]);
    }
    server.start_server();
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds{60});
    }
}
