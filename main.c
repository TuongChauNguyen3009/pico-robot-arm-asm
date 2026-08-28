#include <stdio.h>
#include "pico/stdlib.h"

extern void robot_arm_run(void);

int main(void) {
    stdio_init_all();
    sleep_ms(1500);
    robot_arm_run();
    while (true) {
        tight_loop_contents();
    }
}
