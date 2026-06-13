library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity SingleCycleCPU is
port(clk :in STD_LOGIC;
     rst :in STD_LOGIC;
     --Probe ports used for testing
     --The current address (AddressOut from the PC)
     DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
     --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end SingleCycleCPU;

architecture SingleCycleCPU_example of SingleCycleCPU is

component PC is 
port(
	clk : in STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
	write_enable : in STD_LOGIC; -- Only write if 
	rst : in STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
	AddressIn : in STD_LOGIC_VECTOR(63 downto 0); -- Next PC address
	AddressOut : out STD_LOGIC_VECTOR(63 downto 0) -- Current PC address
);
end component;

component ADD is
port(
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0)
);
end component;

component ALU is
port(     
     in0       : in     STD_LOGIC_VECTOR(63 downto 0);
     in1       : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(63 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
    );
end component;

component ALUControl is
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in  STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
end component;

component AND2 is
port (
      in0    : in  STD_LOGIC;
      in1    : in  STD_LOGIC;
      output : out STD_LOGIC 
);
end component;

component OR2 is
port (
in0 : in STD_LOGIC;
in1 : in STD_LOGIC;
output : out STD_LOGIC 
);
end component;

component CPUControl is
port(
     Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
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
end component;

component DMEM is
generic(NUM_BYTES : integer := 64); --changed as initializing the dmem to 1KB
port(
     WriteData          : in  STD_LOGIC_VECTOR(63 downto 0); -- Input data
     Address            : in  STD_LOGIC_VECTOR(63 downto 0); -- Read/Write address
     MemRead            : in  STD_LOGIC; -- Indicates a read operation
     MemWrite           : in  STD_LOGIC; -- Indicates a write operation
     Clock              : in  STD_LOGIC; -- Writes are triggered by a rising edge
     ReadData           : out STD_LOGIC_VECTOR(63 downto 0); -- Output data
     --Probe ports used for testing
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end component; 

component IMEM is
generic(NUM_BYTES : integer := 64);
-- NUM_BYTES is the number of bytes in the memory (small to save computation resources)
port(
     Address  : in  STD_LOGIC_VECTOR(63 downto 0); -- Address to read from
     ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component MUX5 is
port(
in0 : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 0
in1 : in STD_LOGIC_VECTOR(4 downto 0); -- sel == 1
sel : in STD_LOGIC; -- selects in0 or in1
output : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component MUX64 is
port(
	in0 : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 0
	in1 : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 1
	sel : in STD_LOGIC; -- selects in0 or in1
	output : out STD_LOGIC_VECTOR(63 downto 0)
);
end component;

component registers is
generic(NUM_BYTES : integer :=64);
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
end component;


component ShiftLeft2 is
port(
	x: in STD_LOGIC_VECTOR(63 downto 0);
	y: out STD_LOGIC_VECTOR(63 downto 0)
);
end component;

component SignExtend is
port(
	x : in STD_LOGIC_VECTOR(31 downto 0);
	y : out STD_LOGIC_VECTOR(63 downto 0) -- sign-extend(x)
);
end component;


signal PCwrite_enable:STD_LOGIC:='1';
signal PCIn,PCOut,PC4:STD_LOGIC_VECTOR(63 downto 0); --PC and ADD4 out

signal RD1,RD2,WD:STD_LOGIC_VECTOR(63 downto 0);
signal RR2:STD_LOGIC_VECTOR(4 downto 0); --Registers

signal Shiftout, Signextendout :STD_LOGIC_VECTOR(63 downto 0); --Signextend and shiftleft

signal BranchAddr:STD_LOGIC_VECTOR(63 downto 0); --Add64

signal ALUIn2,ALUResult:STD_LOGIC_VECTOR(63 downto 0);
signal Zero:STD_LOGIC; --ALU

signal Readdata:STD_LOGIC_VECTOR(63 downto 0); --DMEM

--signal pcaddr,PCchoice1,PCchoice0:STD_LOGIC_VECTOR(63 downto 0);

signal Andout,Orout:STD_LOGIC; -- And and Or out
signal Reg2Loc, UBranch, CBranch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite : STD_LOGIC;
signal ALUOp:STD_LOGIC_VECTOR(1 downto 0); --CPUControl

signal Instruction:STD_LOGIC_VECTOR(31 downto 0); --IMEM

signal ALUControlout:STD_LOGIC_VECTOR(3 downto 0); --ALUControl

constant clk_period :time :=50 ns;    
signal ADD4:STD_LOGIC_VECTOR(63 downto 0):=X"0000000000000004";



begin

U1: PC port map(clk=>clk,write_enable=>PCwrite_enable,rst=>rst,AddressIn=>PCIn,AddressOut=>PCOut); DEBUG_PC <= PCOut;
U2: IMEM port map(Address=>PCOut,ReadData=>Instruction); DEBUG_INSTRUCTION <= instruction;
U3: CPUControl port map(Opcode=>Instruction(31 downto 21),Reg2Loc=>Reg2Loc,CBranch=>CBranch,MemRead=>MemRead,MemWrite=>MemWrite,ALUSrc=>ALUSrc,RegWrite=>RegWrite,UBranch=>UBranch,ALUOp=>ALUOp,MemtoReg=>MemtoReg);
U4: MUX5 port map(in0=>Instruction(20 downto 16),in1=>Instruction(4 downto 0),sel=>Reg2Loc,output=>RR2);
U5: registers port map(RR1=>Instruction(9 downto 5),RR2=>RR2,WR=>Instruction(4 downto 0),WD=>WD,RegWrite=>RegWrite,Clock=>clk,RD1=>RD1,RD2=>RD2,DEBUG_TMP_REGS => DEBUG_TMP_REGS, DEBUG_SAVED_REGS => DEBUG_SAVED_REGS);
U6: SignExtend port map(x=>Instruction(31 downto 0),y=>Signextendout);
U7: ShiftLeft2 port map(x=>Signextendout,y=>Shiftout);
U8: ADD port map(in0=>PCOut,in1=>Shiftout,output=>BranchAddr);
U9: MUX64 port map(in0=>PC4,in1=>BranchAddr,sel=>Orout,output=>PCIn);
U10: ALU port map(in0=>RD1,in1=>ALUIn2,operation=>ALUControlout,result=>ALUResult,zero=>zero,overflow=>open);
U11: ALUControl port map(ALUOp=>ALUOp,Opcode=>Instruction(31 downto 21),Operation=>ALUControlout);
U12: AND2 port map(in0=>CBranch,in1=>zero,output=>Andout);
U13: DMEM port map(WriteData=>RD2,Address=>ALUResult,MemRead=>MemRead,MemWrite=>MemWrite,Clock=>clk,ReadData=>Readdata,DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS);
U14: ADD port map(in0=>PCOut,in1=>ADD4,output=>PC4);
U16: MUX64 port map(in0=>ALUResult,in1=>Readdata,sel=>MemtoReg,output=>WD);
U17: MUX64 port map(in0=>RD2,in1=>Signextendout,sel=>ALUSrc,output=>ALUIn2);
U18: OR2 port map(in0=>Andout,in1=>UBranch,output=>Orout);


end;