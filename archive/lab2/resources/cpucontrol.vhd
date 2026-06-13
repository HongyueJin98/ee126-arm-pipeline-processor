library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPUControl is
-- Functionality should match the truth table shown in Figure 4.22 of the textbook, inlcuding the
--    output 'X' values.
-- The truth table in Figure 4.22 omits the unconditional branch instruction:
--    UBranch = '1'
--    MemWrite = RegWrite = '0'
--    all other outputs = 'X'	
port(Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     Reg2Loc  : out STD_LOGIC;
     CBranch  : out STD_LOGIC;  --conditional
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch  : out STD_LOGIC; -- This is unconditional
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end CPUControl;

architecture CPUControl_example of CPUControl is
begin
	process(Opcode)
	begin
		case Opcode is
		when "1XX0101X000" => --R-Format
			Reg2Loc <= '0';
			ALUSrc <='0';
			MemtoReg <='0';
			RegWrite <='1';
			MemRead <='0';
			MemWrite <='0';
			CBranch <='0';
			UBranch <='0';
			ALUOp <="10";
		when "11111000010" => --LDUR
			Reg2Loc <= 'X';
			ALUSrc <='1';
			MemtoReg <='1';
			RegWrite <='1';
			MemRead <='1';
			MemWrite <='0';
			CBranch <='0';
			UBranch <='0';
			ALUOp <="00";
		when "11111000000" => --STUR
			Reg2Loc <= '1';
			ALUSrc <='1';
			MemtoReg <='X';
			RegWrite <='0';
			MemRead <='0';
			MemWrite <='1';
			CBranch <='0';
			UBranch <='0';
			ALUOp <="00";
		when "10110100XXX" => --CBZ
			Reg2Loc <= '1';
			ALUSrc <='0';
			MemtoReg <='X';
			RegWrite <='0';
			MemRead <='0';
			MemWrite <='0';
			CBranch <='1';
			UBranch <='0';
			ALUOp <="01"; 
		when others =>
			Reg2Loc <= 'X';
			ALUSrc <='X';
			MemtoReg <='X';
			RegWrite <='X';
			MemRead <='X';
			MemWrite <='X';
			CBranch <='X';
			UBranch <='X';
			ALUOp <="XX"; 
		end case;
	end process;
end CPUControl_example;