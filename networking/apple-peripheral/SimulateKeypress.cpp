#include "SimulateKeypress.h"

#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

#include <iostream>

SimulateKeypress::SimulateKeypress() : keycode(0) {}

SimulateKeypress::SimulateKeypress(uint16_t keycode) : keycode(keycode) {}
/*
SimulateKeypress::SimulateKeypress(const SimulateKeypress &other)
    : keycode(other.keycode) {
    if (this == &other) {
        return;
    }
    if (other._down != nullptr) {
        _down = CGEventCreateCopy(other._down);
        assert(_down != nullptr);
    }
    if (other._up != nullptr) {
        _up = CGEventCreateCopy(other._up);
        assert(_up != nullptr);
    }
}
*/
SimulateKeypress::SimulateKeypress(SimulateKeypress &&other)
    : keycode(other.keycode) {}

SimulateKeypress::~SimulateKeypress() {}
/*
SimulateKeypress &SimulateKeypress::operator=(const SimulateKeypress &other) {
    keycode = other.keycode;
    return *this;
}
*/
SimulateKeypress &SimulateKeypress::operator=(SimulateKeypress &&other) {
    keycode = other.keycode;
    return *this;
}

void SimulateKeypress::operator()() const {
    std::cout << keycode << std::endl;
    auto up = CGEventCreateKeyboardEvent(nullptr, (CGKeyCode)keycode, true);
    if (up == nullptr) {
        return;
    }
    auto down = CGEventCreateKeyboardEvent(nullptr, (CGKeyCode)keycode, false);
    if (down == nullptr) {
        CFRelease(up);
        return;
    }
    CGEventPost(kCGAnnotatedSessionEventTap, down);
    CGEventPost(kCGAnnotatedSessionEventTap, up);
    CFRelease(up);
    CFRelease(down);
}