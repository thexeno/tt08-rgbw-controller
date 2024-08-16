# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


# Sends DATA of a specific LENGTH through spi. MOSI pin is selected by providing a MASK for ui_in
# MSB first
async def SPI_send(dut, DATA: int):

    dut.ui_in.value = dut.ui_in.value & ~(0x1 << 5) #CS low
    await ClockCycles(dut.clk, 5)
    # Send SPI data
    for i in range(8):
        dut._log.info(f"SPI send: {i}")
        if (DATA << i) & 0x80 == 0x80: # Check if highest bit is set      
        # Clear bit 7 in the current value and then set it to the desired value
        # current_value = dut.uo_out.value.integer
            dut.ui_in.value = (dut.ui_in.value) | (0x1 << 1)
            await ClockCycles(dut.clk, 1)
            dut._log.info(f"DATA: 1")
            print ((dut.ui_in))
        else:
            dut.ui_in.value = dut.ui_in.value & ~(0x1 << 1)
            await ClockCycles(dut.clk, 1)
            dut._log.info(f"DATA: 0")
            print (dut.ui_in)

         
        dut.ui_in.value = (dut.ui_in.value) | (0x1 << 0)
        await ClockCycles(dut.clk, 50)
        dut.ui_in.value = dut.ui_in.value & ~(0x1 << 0)
        await ClockCycles(dut.clk, 50)
    
    dut.ui_in.value = (dut.ui_in.value) | (0x1 << 5) #CS high
    await ClockCycles(dut.clk, 5)


@cocotb.test()
async def user_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 0
    dut.rst_n.value = 0
    
    await ClockCycles(dut.clk, 10)
    #assert (dut.uo_out.value[7]) == (0)
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut.ui_in.value = (dut.ui_in.value) | (0x1 << 5)
    await ClockCycles(dut.clk, 10)
    await SPI_send(dut, 0x55)
    await ClockCycles(dut.clk, 10)
    await SPI_send(dut, 0xAA)



    await ClockCycles(dut.clk, 100)
    print (dut.uo_out.value[0])
    print (dut.uo_out.value[1])
    print (dut.uo_out.value[2])
    print (dut.uo_out.value[3])
    print (dut.uo_out.value[4])
    print (dut.uo_out.value[5])
    print (dut.uo_out.value[6])
    dut._log.info("Test project behavior")



    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
