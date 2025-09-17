# test_my_design.py
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

@cocotb.test()
async def test_my_design(dut):
    """Test that data_out follows data_in after one clock cycle"""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # Drive the reset signal low. As the reset is active low, this resets the DUT.
    dut.rst_n.value = 0
    # This will wait for two rising edges of the clock
    await Timer(20, unit="ns")
    dut.rst_n.value = 1

    # At this point we have dut reset and we start in a known state


    # Test data pass-through
    test_data = 0x55
    dut.data_in.value = test_data
    await RisingEdge(dut.clk)

    # After this the always_ff block will execute but we are not safe to check
    # dut.data_out yet as it uses <= which means the change is scheduled but has
    # not happen yet.
    
    await RisingEdge(dut.clk)  # Wait one cycle for output to update

    # At this point is safe to check because the change has happened

    
    assert dut.data_out.value == test_data, f"Expected {test_data}, got {dut.data_out.value}"
    dut._log.info("Test passed!")