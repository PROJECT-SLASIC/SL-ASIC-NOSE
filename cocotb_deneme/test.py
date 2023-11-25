from cocotb.triggers import *
from cocotb.clock import *
from divider_model import *
from cocotb.binary import *

@cocotb.test()
async def divider_test(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    await FallingEdge(dut.clk)

    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)
    assert dut.out_reg.value == 0, "Output should be 0 after reset"

    for i in range (20000):
        a = random.randrange(0x5fff0000, 0x7f7fffff) #0x4872d2de
        b = random.randrange(0x3f800000, 0x5fff0000) #0x48524a0a
        print(a)
        print(b)
        dut.dividend.value = a
        dut.divisor.value = b
        dut.start.value = 1
        for i in range(1):
            await RisingEdge(dut.clk)
        dut.start.value = 0

        res = ieeeDivider(a,b)
        print("result:",res)
        await RisingEdge(dut.valid)
        res = BinaryValue(res, n_bits=32)
        BinaryValue.get_value(res)

        print(res)
        print(dut.out_reg.value)
        print("çıkarma:", abs(convert_to_int(dut.out_reg.value[1:31]) - convert_to_int(res[0:30])))


        assert abs(convert_to_int(dut.out_reg.value[1:31]) - convert_to_int(res[0:30])) <= 4 , "results doesnt match"