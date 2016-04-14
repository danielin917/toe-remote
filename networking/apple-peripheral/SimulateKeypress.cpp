#include "SimulateKeypress.h"

#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>

SimulateKeypress::SimulateKeypress()
    : keycode(0), _down(nullptr), _up(nullptr) {}

SimulateKeypress::SimulateKeypress(uint16_t keycode)
    : keycode(keycode),
      _down(CGEventCreateKeyboardEvent(nullptr, (CGKeyCode)keycode, true)),
      _up(CGEventCreateKeyboardEvent(nullptr, (CGKeyCode)keycode, false)) {
    assert(_down != nullptr && _up != nullptr);
    assert(_down != _up);
}

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

SimulateKeypress::SimulateKeypress(SimulateKeypress &&other)
    : keycode(other.keycode), _down(other._down), _up(other._up) {
    other._down = nullptr;
    other._up = nullptr;
}

void SimulateKeypress::destroy() {
    assert((_down == nullptr && _up == nullptr) || _down != _up);
    if (_down != nullptr) {
        CFRelease(_down);
        _down = nullptr;
    }
    if (_up != nullptr) {
        CFRelease(_up);
        _up = nullptr;
    }
}

SimulateKeypress::~SimulateKeypress() { destroy(); }

SimulateKeypress &SimulateKeypress::operator=(const SimulateKeypress &other) {
    if (this == &other) {
        return *this;
    }
    keycode = other.keycode;
    destroy();
    if (other._down != nullptr) {
        _down = CGEventCreateCopy(other._down);
        assert(_down != nullptr);
    }
    if (other._up != nullptr) {
        _up = CGEventCreateCopy(other._up);
        assert(_up != nullptr);
    }
    return *this;
}

SimulateKeypress &SimulateKeypress::operator=(SimulateKeypress &&other) {
    keycode = other.keycode;
    _down = other._down;
    other._down = nullptr;
    _up = other._up;
    other._up = nullptr;
    return *this;
}

void SimulateKeypress::operator()() const {
    if (_down == nullptr || _up == nullptr)
        return;
    CGEventPost(kCGAnnotatedSessionEventTap, _down);
    CGEventPost(kCGAnnotatedSessionEventTap, _up);
}