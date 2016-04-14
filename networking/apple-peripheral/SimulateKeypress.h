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

struct __CGEvent;

class SimulateKeypress {
    uint16_t keycode;
    struct __CGEvent *_down;
    struct __CGEvent *_up;

    void destroy();

  public:
    SimulateKeypress();

    explicit SimulateKeypress(uint16_t keycode);

    SimulateKeypress(const SimulateKeypress &other);

    SimulateKeypress(SimulateKeypress &&other);

    ~SimulateKeypress();

    SimulateKeypress &operator=(const SimulateKeypress &other);

    SimulateKeypress &operator=(SimulateKeypress &&other);

    void operator()() const;
};

#endif /* SimulateKeypress_h */
