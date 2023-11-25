from bitstring import *
from cocotb.binary import *
def ieeeDivider(dividend: int, divisor: int) -> int:
    dividend = BitArray(int=dividend, length=32)
    divisor = BitArray(int=divisor, length=32)

    dividend_float = dividend.float
    divisor_float = divisor.float

    res = dividend_float / divisor_float
    result = BitArray(float=res, length=32)
    result_int = result.int
    return result_int


def convert_to_int(a: BinaryValue) -> int:
    res = 0
    for i in range(len(a)):
        if a[i] == 1:
            res = res + 2 ** (len(a)-i)
        else:
            i = i + 1
    return res

print(convert_to_int(BinaryValue(0x455568ac, n_bits=32)))

