
There's a 1-bit error that needs to be addressed with rounding. 
The current implementation does not account for NaN (Not a Number) and infinity cases; these should be handled appropriately.
