.syntax unified
.cpu cortex-m0plus
.thumb

.global robot_arm_run
.type robot_arm_run, %function


robot_arm_run:
push {r4-r7, lr}

bl init_resets
bl init_gpio
bl init_pwm
bl init_adc

ra_loop:
movs r0, #0
bl adc_read
bl adc_to_pulse
mov r4, r0

movs r0, #1
bl adc_read
bl adc_to_pulse
mov r5, r0

movs r0, #2
bl adc_read
bl adc_to_pulse
mov r6, r0

ldr r0, =0x40050000
lsls r1, r5, #16
orrs r1, r1, r4
str r1, [r0, #0x0c]

ldr r1, =1500
lsls r1, r1, #16
orrs r1, r1, r6
str r1, [r0, #0x20]

ldr r0, =20000
bl delay_us

b ra_loop


init_resets:
ldr r0, =0x4000f000
ldr r1, =0x4001
str r1, [r0]
movs r1, #200
ir_w:
subs r1, r1, #1
bne ir_w
bx lr


init_gpio:
push {r4, r5, lr}

ldr r4, =0x40014000
movs r5, #4
str r5, [r4, #0x04]
str r5, [r4, #0x0c]
str r5, [r4, #0x14]

movs r5, #31
ldr r0, =0x400140d4
str r5, [r0]
ldr r0, =0x400140dc
str r5, [r0]
ldr r0, =0x400140e4
str r5, [r0]

movs r5, #0
ldr r0, =0x4001c06c
str r5, [r0]
ldr r0, =0x4001c070
str r5, [r0]
ldr r0, =0x4001c074
str r5, [r0]

pop {r4, r5, pc}


init_pwm:
ldr r0, =0x40050000

ldr r1, =0x07d0
str r1, [r0, #0x04]
ldr r1, =19999
str r1, [r0, #0x10]
ldr r1, =0x05dc05dc
str r1, [r0, #0x0c]
movs r1, #1
str r1, [r0, #0x00]

ldr r1, =0x07d0
str r1, [r0, #0x18]
ldr r1, =19999
str r1, [r0, #0x24]
ldr r1, =0x05dc05dc
str r1, [r0, #0x20]
movs r1, #1
str r1, [r0, #0x14]

bx lr


init_adc:
ldr r0, =0x4004c000
movs r1, #1
str r1, [r0]
ia_w:
ldr r2, [r0]
movs r1, #1
lsls r1, r1, #8
ands r2, r2, r1
beq ia_w
bx lr


adc_read:
push {r4, lr}
lsls r1, r0, #12
movs r0, #5
orrs r1, r1, r0
ldr r4, =0x4004c000
str r1, [r4]
ar_w:
ldr r0, [r4]
movs r1, #1
lsls r1, r1, #8
ands r0, r0, r1
beq ar_w
ldr r4, =0x4004c004
ldr r0, [r4]
ldr r1, =0xfff
ands r0, r0, r1
pop {r4, pc}


adc_to_pulse:
lsrs r0, r0, #2
ldr r1, =1000
adds r0, r0, r1
bx lr


delay_us:
push {r4, r5, lr}
ldr r4, =0x40054028
ldr r5, [r4]
du_w:
ldr r1, [r4]
subs r1, r1, r5
cmp r1, r0
blt du_w
pop {r4, r5, pc}