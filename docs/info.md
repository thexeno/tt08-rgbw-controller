<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
This is an RGBW controller, with embedded color wheel processor. It can generate a hue from the selected color index, a tint and apply a luminosity factor if desired.
It also act as a SPI to 4 channel PWM controller, to directly output 4 PWM channel with 8-bit resolution.

The system is as follow:
 asasdad

 The SPI slave will take in MODE 1(?) SPI protocol an 8 byte long command, discriminated with a preamble sequence (see Protocol and Test for the descrioption). This is fed into a data dispatcher that 

# protocol

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
