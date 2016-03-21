#include "BLEPeripheral.h"

#include <unistd.h>
#include <iostream>

int main() {
    BLEPeripheral p("hello");
    unsigned count = 0;
    for (;;) {
        if (p.connected()) {
            std::cout << "connected" << std::endl;
            const char *hello = "hello";
            p.write((const unsigned char*)hello, 6);
            while (p.bytes_available() > 0) {
                std::cout << '0' + p.read_byte() << std::endl;
            }
        } else {
            std::cout << "not connected" << std::endl;
        }
        ++count;
        sleep(1);
    }
}
