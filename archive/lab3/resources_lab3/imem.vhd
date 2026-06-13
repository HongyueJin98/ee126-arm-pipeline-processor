library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IMEM is
-- The instruction memory is a byte addressable, little-endian, read-only memory
-- Reads occur continuously
-- HINT: Use the provided dmem.vhd as a starting point
generic(NUM_BYTES : integer := 128);
-- NUM_BYTES is the number of bytes in the memory (small to save computation resources)
port(
     Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
     ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end IMEM;

architecture IMEM_example of IMEM is
type ByteArray is array (0 to NUM_BYTES) of STD_LOGIC_VECTOR(7 downto 0);
signal imemBytes : ByteArray;
begin
	process(Address)
	variable first:boolean := true;
	begin
		if (first) then
      --ADDI X10, X11, 1
      imemBytes(3) <= B"10010001";
      imemBytes(2) <= B"00000000";
      imemBytes(1) <= B"00000101";
      imemBytes(0) <= B"01101010";
       --ADDI X10, X11, 2
 
      imemBytes(7) <= B"10010001";
      imemBytes(6) <= B"00000000";
      imemBytes(5) <= B"00001001";
      imemBytes(4) <= B"01101010";

      -- ADDI X9, X9, 1 
      imemBytes(11) <= B"10010001";
      imemBytes(10) <= B"00000000";
      imemBytes(9)  <= B"00000101"; 
      imemBytes(8)  <= B"00101001"; 
      
      -- SUBI X9, X9, 1

      imemBytes(15) <= B"11010001";
      imemBytes(14) <= B"00000000";
      imemBytes(13) <= B"00000101";
      imemBytes(12) <= B"00101001";

      -- ADD  X10, X9, X11
      imemBytes(19) <= B"10001011";
      imemBytes(18) <= B"00001011";
      imemBytes(17) <= B"00000001";
      imemBytes(16) <= B"00101010";

			--imemBytes(1) <= X"00";
			--imemBytes(2) <= X"00";
			--imemBytes(3) <= X"00";
			--imemBytes(4) <= X"00";

			--imemBytes(5) <= X"FF";
			--imemBytes(6) <= X"FF";
			--imemBytes(7) <= X"FF";
			--imemBytes(8) <= X"FF";
			first := false;
		end if;
	if ((to_integer(unsigned(Address))+3)<NUM_BYTES) then
	ReadData<=imemBytes(to_integer(unsigned(Address))+3) & imemBytes(to_integer(unsigned(Address))+2) & imemBytes(to_integer(unsigned(Address))+1) & imemBytes(to_integer(unsigned(Address))+0);
			--ReadData <= imemBytes(to_integer(unsigned(Address)))&
				--imemBytes(to_integer(unsigned(Address))+1)&
				--imemBytes(to_integer(unsigned(Address))+2)&
				--imemBytes(to_integer(unsigned(Address))+3);
	else report "error" severity error;
	end if;
	end process;

end IMEM_example;
