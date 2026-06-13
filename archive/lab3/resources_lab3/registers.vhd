library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity registers is
-- This component is described in the textbook, starting on section 4.3 
-- The indices of each of the registers can be found on the LEGv8 Green Card
-- Keep in mind that register 31 (XZR) has a constant value of 0 and cannot be overwritten
-- This should only write on the negative edge of Clock when RegWrite is asserted.
-- Reads should be purely combinatorial, i.e. they don't depend on Clock
-- HINT: Use the provided dmem.vhd as a starting point
generic(NUM_BYTES : integer :=32);
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (63 downto 0);
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);
     --Probe ports used for testing.
     -- Notice the width of the port means that you are 
     --      reading only part of the register file. 
     -- This is only for debugging
     -- You are debugging a sebset of registers here
     -- Temp registers: $X9 & $X10 & X11 & X12 
     -- 4 refers to number of registers you are debugging
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- Saved Registers X19 & $X20 & X21 & X22 
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end registers;

architecture registers_example of registers is
type ByteArray is array (0 to NUM_BYTES) of STD_LOGIC_VECTOR(63 downto 0);
signal regbytes : ByteArray;
begin
	process(Clock, WR, WD, RegWrite)
	variable addr: integer;
	variable first: boolean := true;
	begin
		if(first) then
			regbytes(9) <= X"0000000000000000";
			regbytes(10) <= X"0000000000000001";
			regbytes(11) <= X"0000000000000002";
			regbytes(12) <= X"0000000000000004";
			regbytes(13) <= X"0000000000000008";
			regbytes(14) <= X"0000000000000010";
			regbytes(15) <= X"0000000000000020";
               		
               		regbytes(19) <= X"0000000000000015";
			regbytes(20) <= X"0000000000000007";
             		regbytes(21) <= X"0000000000000000";
               		regbytes(22) <= X"0000000000000016";
			regbytes(31) <= X"0000000000000000"; --XZR

			first := false;
		end if;
		
		if Clock ='0' and Clock'event and RegWrite ='1' and WR /= "11111" then
			addr := to_integer(unsigned(WR));
			regbytes(addr) <= WD;
		end if;
		end process;

		RD1 <= regbytes(to_integer(unsigned(RR1)));
		RD2 <= regbytes(to_integer(unsigned(RR2)));

		DEBUG_TMP_REGS <= regbytes(9)&regbytes(10)&regbytes(11)&regbytes(12);
		DEBUG_SAVED_REGS <= regbytes(19)&regbytes(20)&regbytes(21)&regbytes(22);


end registers_example;