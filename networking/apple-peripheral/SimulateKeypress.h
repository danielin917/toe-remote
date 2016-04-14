//
//  SimulateKeypress.h
//  osx-keypress
//
//  Created by Nick Terrell on 3/21/16.
//  Copyright © 2016 eecs481. All rights reserved.
//

#ifndef SimulateKeypress_h
#define SimulateKeypress_h

#include <stdint.h>

class SimulateKeypress {
    uint16_t keycode;

  public:
    SimulateKeypress();

    explicit SimulateKeypress(uint16_t keycode);

    // SimulateKeypress(const SimulateKeypress &other);

    SimulateKeypress(SimulateKeypress &&other);

    ~SimulateKeypress();

    // SimulateKeypress &operator=(const SimulateKeypress &other);

    SimulateKeypress &operator=(SimulateKeypress &&other);

    void operator()() const;
};

#endif /* SimulateKeypress_h */
