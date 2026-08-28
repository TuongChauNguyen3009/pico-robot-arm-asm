# Robot Arm on Raspberry Pi Pico (ARM assembly)

A 3-joint robot arm driven by a Raspberry Pi Pico. The control logic is written in
ARM Cortex-M0+ assembly and writes directly to the RP2040 hardware registers, so no
Pico SDK driver functions are used.

Each joint is moved by turning its own potentiometer. The pots are read on the ADC
and mapped straight to servo pulse widths. The main loop repeats every 20 ms.

## Wiring

| Function          | Pin     | Notes                          |
|-------------------|---------|--------------------------------|
| Base servo        | GPIO 0  | PWM0 A, follows pot on ADC0    |
| Shoulder servo    | GPIO 1  | PWM0 B, follows pot on ADC1    |
| Elbow servo       | GPIO 2  | PWM1 A, follows pot on ADC2    |
| PWM1 B            | GPIO 3  | held at 1500 us, not used      |
| Base pot          | GPIO 26 | ADC0                           |
| Shoulder pot      | GPIO 27 | ADC1                           |
| Elbow pot         | GPIO 28 | ADC2                           |

All three servos share the ground and 5V supply. Do not power them from the Pico's
3V3 pin.

## PWM setup

The clock divider is set to 125.0, so with the 125 MHz system clock one PWM tick is
1 us. TOP is 19999, which gives a 20 ms period (50 Hz). That is what hobby servos
expect.

Pulse width comes from the ADC value:

    pulse_us = (adc_raw >> 2) + 1000

The ADC is 12 bit, so this covers 1000 us to 2023 us, which is roughly the full
travel of a standard servo.

## Files

    main.c         starts stdio, waits a moment, then calls robot_arm_run()
    robot_arm.S    all of the actual work
    CMakeLists.txt build setup for the Pico SDK

Routines in robot_arm.S:

    init_resets    brings the ADC and PWM blocks out of reset
    init_gpio      GPIO 0-2 to PWM function, GPIO 26-28 to analog
    init_pwm       divider, wrap value and starting duty for both slices
    init_adc       enables the ADC and waits for it to be ready
    adc_read       reads one channel, channel number in r0
    adc_to_pulse   scales a raw ADC value into a pulse width
    delay_us       busy wait on the hardware timer at 0x40054028

## Building

You need the Pico SDK and PICO_SDK_PATH pointing at it.

    export PICO_SDK_PATH=/path/to/pico-sdk
    mkdir build && cd build
    cmake ..
    make

## Flashing

Hold BOOTSEL while plugging in the USB cable. The Pico appears as a USB drive.
Copy build/robot_arm.uf2 onto it and it will reboot and run.
