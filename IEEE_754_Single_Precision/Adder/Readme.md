During tests with 100K inputs, the last one bits of the mantissa occasionally returned incorrect values. The configuration for Openlane is detailed in the following config.tcl file.
There's a 1-bit error that needs to be addressed with rounding. 
The current implementation does not account for NaN (Not a Number) and infinity cases; these should be handled appropriately.
