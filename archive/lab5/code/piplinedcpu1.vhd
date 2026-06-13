library ieee;  
use ieee.std_logic_1164.all;  

entity PipelinedCPU1 is
port(
     clk : in STD_LOGIC;
     rst : in STD_LOGIC;
     --Probe ports used for testing
     --The current address (AddressOut from the PC)
     DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
     DEBUG_FORWARDB : out std_logic_vector(1 downto 0);
     DEBUG_PC : out STD_LOGIC_VECTOR(63 downto 0);
     --The current instruction (Instruction output of IMEM)
     DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;

     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS     : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_SAVED_REGS   : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end PipelinedCPU1;

architecture structure of PipelinedCPU1 is

component MUX64 is 
port(
    in0    : in STD_LOGIC_VECTOR(63 downto 0); 
    in1    : in STD_LOGIC_VECTOR(63 downto 0); 
    sel    : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(63 downto 0)
);
end component;

component PC is 
port(
     clk          : in  STD_LOGIC; 
     write_enable : in  STD_LOGIC; 
     rst          : in  STD_LOGIC; 
     AddressIn    : in  STD_LOGIC_VECTOR(63 downto 0); 
     AddressOut   : out STD_LOGIC_VECTOR(63 downto 0)
);
end component;

component ADD is
port(
     in0    : in  STD_LOGIC_VECTOR(63 downto 0);
     in1    : in  STD_LOGIC_VECTOR(63 downto 0);
     output : out STD_LOGIC_VECTOR(63 downto 0)
);
end component;

component IMEM is
generic(NUM_BYTES : integer := 64);
port(
     Address  : in  STD_LOGIC_VECTOR(63 downto 0); 
     ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component IfId is 
port(
	  write_enable         : in std_logic;
          IfId_instr_in        : in std_logic_vector(31 downto 0);
          IfId_pc_in           : in std_logic_vector(63 downto 0);
          clk                  : in std_logic;
          IfId_instr_out       : out std_logic_vector(31 downto 0);
          IfId_pc_out          : out std_logic_vector(63 downto 0));
end component;

component MUX5 is 
port(
    in0    : in STD_LOGIC_VECTOR(4 downto 0); 
    in1    : in STD_LOGIC_VECTOR(4 downto 0); 
    sel    : in STD_LOGIC; -- selects in0 or in1
    output : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component registers is
port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (63 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (63 downto 0);
     RD2      : out STD_LOGIC_VECTOR (63 downto 0);
     --Probe ports used for testing
     -- $t0 & $t1 & t2 & t3
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0);
     -- $s0 & $s1 & s2 & s3
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(64*4 - 1 downto 0)
);
end component;

component SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) 
);
end component;

component CPUControl is
port(
     write_enable : in STD_LOGIC;
     Opcode   : in  STD_LOGIC_VECTOR(10 downto 0);
     CBranch   : out STD_LOGIC;
     MemRead  : out STD_LOGIC;
     MemtoReg : out STD_LOGIC;
     MemWrite : out STD_LOGIC;
     ALUSrc   : out STD_LOGIC;
     RegWrite : out STD_LOGIC;
     UBranch     : out STD_LOGIC;
     ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end component;

component IdEx is 
port(
	  clk              : in STD_LOGIC;
          IdEx_CBranch_in  : in STD_LOGIC;
          IdEx_MemRead_in  : in STD_LOGIC;
          IdEx_MemtoReg_in : in STD_LOGIC;
          IdEx_MemWrite_in : in STD_LOGIC;
          IdEx_ALUSrc_in   : in STD_LOGIC;
          IdEx_RegWrite_in : in STD_LOGIC;
          IdEx_UBranch_in  : in STD_LOGIC;
          IdEx_ALUOp_in    : in STD_LOGIC_VECTOR(1 downto 0);
          IdEx_RD1_in       : in STD_LOGIC_VECTOR (63 downto 0); 
          IdEx_RD2_in       : in STD_LOGIC_VECTOR (63 downto 0);       
          IdEx_pc_in       : in std_logic_vector(63 downto 0);   
          IdEx_signextend_in       : in std_logic_vector(63 downto 0);  
          IdEx_instr11_in       : in std_logic_vector(10 downto 0);  
          IdEx_instr5_in       : in std_logic_vector(4 downto 0); 
          IdEx_Rn_in       : in std_logic_vector(4 downto 0);    
          IdEx_Rm_in       : in std_logic_vector(4 downto 0);    
          IdEx_Rd_in       : in std_logic_vector(4 downto 0);   
          IdEx_sturins_in  : in std_logic_vector(10 downto 0);   	
                 
          IdEx_CBranch     : out STD_LOGIC;
          IdEx_MemRead     : out STD_LOGIC;
          IdEx_MemtoReg    : out STD_LOGIC;
          IdEx_MemWrite    : out STD_LOGIC;
          IdEx_ALUSrc      : out STD_LOGIC;
          IdEx_RegWrite    : out STD_LOGIC;
          IdEx_UBranch     : out STD_LOGIC;
          IdEx_ALUOp       : out STD_LOGIC_VECTOR(1 downto 0);
          IdEx_RD1          : out STD_LOGIC_VECTOR (63 downto 0); 
          IdEx_RD2          : out STD_LOGIC_VECTOR (63 downto 0);
          IdEx_pc       : out std_logic_vector(63 downto 0);  
          IdEx_signextend       : out std_logic_vector(63 downto 0);  
          IdEx_instr11       : out std_logic_vector(10 downto 0);  
          IdEx_instr5       : out std_logic_vector(4 downto 0);
          IdEx_Rn_out       : out std_logic_vector(4 downto 0);    
          IdEx_Rm_out       : out std_logic_vector(4 downto 0);    
          IdEx_Rd_out       : out std_logic_vector(4 downto 0);  
          IdEx_sturins_out       : out std_logic_vector(10 downto 0)	
);   
end component;

component ShiftLeft2 is
port(
     x : in  STD_LOGIC_VECTOR(63 downto 0);
     y : out STD_LOGIC_VECTOR(63 downto 0) 
);
end component;

component ALUControl is    
port(
     ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
     Opcode    : in   STD_LOGIC_VECTOR(10 downto 0);
     Operation : out STD_LOGIC_VECTOR(3 downto 0)
);
end component;

component ALU is
port(
     in0         : in     STD_LOGIC_VECTOR(63 downto 0);
     in1         : in     STD_LOGIC_VECTOR(63 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : out STD_LOGIC_VECTOR(63 downto 0);
     zero      : out STD_LOGIC;
     overflow  : out STD_LOGIC
);
end component;

component ExMem is 
port(
	  clk              : in STD_LOGIC;
          ExMem_CBranch_in  : in STD_LOGIC;
          ExMem_MemRead_in  : in STD_LOGIC;
          ExMem_MemtoReg_in : in STD_LOGIC;
          ExMem_MemWrite_in : in STD_LOGIC;
          ExMem_RegWrite_in : in STD_LOGIC;
          ExMem_UBranch_in  : in STD_LOGIC;
          ExMem_Addin_in    : in STD_LOGIC_VECTOR (63 downto 0); 
          ExMem_Zero_in     : in STD_LOGIC;     
          ExMem_Aluresult_in       : in std_logic_vector(63 downto 0);   
          ExMem_RD2_in      : in std_logic_vector(63 downto 0);  
          ExMem_instr5_in       : in std_logic_vector(4 downto 0); 
          ExMem_Rd_in       : in std_logic_vector(4 downto 0);  
     
          ExMem_CBranch     : out STD_LOGIC;
          ExMem_MemRead     : out STD_LOGIC;
          ExMem_MemtoReg    : out STD_LOGIC;
          ExMem_MemWrite    : out STD_LOGIC;
          ExMem_RegWrite    : out STD_LOGIC;
          ExMem_UBranch     : out STD_LOGIC;
          ExMem_Addin    : out STD_LOGIC_VECTOR (63 downto 0); 
          ExMem_Zero     : out STD_LOGIC;     
          ExMem_Aluresult       : out std_logic_vector(63 downto 0);   
          ExMem_RD2      : out std_logic_vector(63 downto 0);  
          ExMem_instr5       : out std_logic_vector(4 downto 0);
          ExMem_Rd_out       : out std_logic_vector(4 downto 0)
		  );     
          
end component;

component AND2 is
port (
      in0    : in  STD_LOGIC;
      in1    : in  STD_LOGIC;
      output : out STD_LOGIC -- in0 and in1
);
end component;

component DMEM is
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

component MemWb is 
port(
	  clk              : in STD_LOGIC;
          MemWb_MemWtoReg_in : in STD_LOGIC;
          MemWb_RegWrite_in : in STD_LOGIC; 
          MemWb_Aluresult_in       : in std_logic_vector(63 downto 0);   
          MemWb_RD_in       : in std_logic_vector(63 downto 0);         
          MemWb_instr5_in       : in std_logic_vector(4 downto 0);   
             MemWb_Rd_in1       : in std_logic_vector(4 downto 0); 
		 
          MemWb_MemWtoReg : out STD_LOGIC;
          MemWb_RegWrite : out STD_LOGIC; 
          MemWb_Aluresult       : out std_logic_vector(63 downto 0);   
          MemWb_RD       : out std_logic_vector(63 downto 0);  
          MemWb_instr5       : out std_logic_vector(4 downto 0);
          MemWb_Rd_out       : out std_logic_vector(4 downto 0) 
		  );   
          
end component;


component harzarddetect is
port(
	 hazard_idex_Rd   : in  STD_LOGIC_VECTOR(4 downto 0);
	 hazard_Rn        : in  STD_LOGIC_VECTOR(4 downto 0);
	 hazard_Rm  	  : in  STD_LOGIC_VECTOR(4 downto 0);
     hazard_idex_Memread   : in STD_LOGIC;

     PCWrite  	: out STD_LOGIC;
     IfIdwrite  : out STD_LOGIC;
     Choice	    : out STD_LOGIC

);
end component;

component Forwarding is
port(
	 forwarding_Rn    : in  STD_LOGIC_VECTOR(4 downto 0);
	 forwarding_Rm	  : in  STD_LOGIC_VECTOR(4 downto 0);
	 forwarding_exmem_Rd    : in  STD_LOGIC_VECTOR(4 downto 0);
	 forwarding_memwb_Rd    : in  STD_LOGIC_VECTOR(4 downto 0);
     forwarding_exmem_regwrite   : in STD_LOGIC;
     forwarding_memwb_regwrite   : in STD_LOGIC;
	 forwarding_Rd    : in  STD_LOGIC_VECTOR(4 downto 0);
	forwarding_sturins :in STD_LOGIC_VECTOR(10 downto 0);

     ForwardA  	: out STD_LOGIC_VECTOR(1 downto 0);
     ForwardB   : out STD_LOGIC_VECTOR(1 downto 0)


);
end component;

component MUX64_3 is -- Two by one mux with 32 bit inputs/outputs
port(
    in0    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 00
    in1    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 01
    in2    : in STD_LOGIC_VECTOR(63 downto 0); -- sel == 10
    sel    : in STD_LOGIC_VECTOR(1 downto 0);
    output : out STD_LOGIC_VECTOR(63 downto 0)
);
end component;


signal IdEx_pc,IdEx_RD2, IdEx_RD1,WD, Fadd_output, PCAddressIn, PCAddressOut, RD1, RD2, Signextendout, Slout, Sadd_output, ALUin, ALUresult, 
ExMem_Addin, ExMem_Aluresult, ReadData, MemWb_Aluresult, MemWb_RD, IdEx_signextend,IfId_pc_out,DMEM_writedata, MUX64_3A, MUX64_3B:STD_LOGIC_VECTOR(63 downto 0);
signal CBranch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,UBranch, PCSrc, MemWb_RegWrite,IdEx_CBranch,IdEx_MemRead,IdEx_MemtoReg,IdEx_MemWrite,
IdEx_ALUSrc,IdEx_RegWrite,IdEx_UBranch, zero, overflow, ExMem_CBranch,ExMem_MemRead, ExMem_MemtoReg,ExMem_MemWrite, CPU_enable, IFID_enable,
ExMem_RegWrite,ExMem_UBranch, ExMem_Zero, MemWb_MemWtoReg:STD_LOGIC;
signal PCout,IfId_instr_out:STD_LOGIC_VECTOR(31 downto 0);
signal ALUOp, IdEx_ALUOp,ForwardA1, ForwardB1:STD_LOGIC_VECTOR(1 downto 0);
signal Readr, WR, ExMem_instr5,  IdEx_instr5, IdEx_Rn_out, IdEx_Rm_out, ExMem_Rd_out,IdEx_Rd_out,MemWb_Rd_out:STD_LOGIC_VECTOR(4 downto 0);
signal ALUcontrolout:STD_LOGIC_VECTOR(3 downto 0);
signal PCwrite_enable :STD_LOGIC;
signal Fadd_in1:STD_LOGIC_VECTOR(63 downto 0):="0000000000000000000000000000000000000000000000000000000000000100";
signal IdEx_instr11,IdEx_sturins_out:STD_LOGIC_VECTOR(10 downto 0);
begin

U1: MUX64 port map(in0=>Fadd_output,in1=>ExMem_Addin,sel=>PCSrc,output=>PCAddressIn);   --PC MUX
U2: PC port map(clk=>clk,write_enable=>PCwrite_enable,rst=>rst,AddressIn=>PCAddressIn,AddressOut=>PCAddressOut);  
U3: ADD port map(in0=>PCAddressOut,in1=>Fadd_in1,output=>Fadd_output);   --first add (pc+4)
U4: IMEM port map(Address=>PCAddressOut,ReadData=>PCout);   --imem
U5: IfId port map(write_enable=>IFID_enable, clk=>clk,IfId_instr_in=>PCout,IfId_pc_in=>PCAddressOut,IfId_instr_out=>IfId_instr_out,IfId_pc_out=>IfId_pc_out);   --IfId
U6: MUX5 port map(in0=>IfId_instr_out(20 downto 16),in1=>IfId_instr_out(4 downto 0),sel=>IfId_instr_out(28),output=>Readr);   --MUX for registers
U7: registers port map(RR1=>IfId_instr_out(9 downto 5),RR2=>Readr,WR=>WR,WD=>WD,RegWrite=>MemWb_RegWrite,Clock=>clk,RD1=>RD1,RD2=>RD2,DEBUG_TMP_REGS=>DEBUG_TMP_REGS,DEBUG_SAVED_REGS=>DEBUG_SAVED_REGS);   --register
U8: SignExtend port map(x=>IfId_instr_out,y=>Signextendout);   --signextend
U9: CPUControl port map(write_enable=>CPU_enable, Opcode=>IfId_instr_out(31 downto 21),CBranch=>CBranch,MemRead=>MemRead,MemWrite=>MemWrite,ALUSrc=>ALUSrc,RegWrite=>RegWrite,UBranch=>UBranch,ALUOp=>ALUOp,MemtoReg=>MemtoReg);   --control

U10: IdEx port map(IdEx_sturins_in=>IfId_instr_out(31 downto 21),IdEx_sturins_out=>IdEx_sturins_out, IdEx_Rn_in=>IfId_instr_out(9 downto 5),IdEx_Rm_in=>IfId_instr_out(20 downto 16),
IdEx_Rd_in=>IfId_instr_out(4 downto 0),IdEx_Rn_out=>IdEx_Rn_out,IdEx_Rm_out=>IdEx_Rm_out,IdEx_Rd_out=>IdEx_Rd_out,clk=>clk,IdEx_CBranch_in=>CBranch,IdEx_MemRead_in=>MemRead,IdEx_MemtoReg_in=>MemtoReg,IdEx_MemWrite_in=>MemWrite,
IdEx_ALUSrc_in=>ALUSrc,IdEx_RegWrite_in=>RegWrite,IdEx_UBranch_in=>UBranch,IdEx_ALUOp_in=>ALUOp, IdEx_RD1_in=>RD1,IdEx_RD2_in=>RD2,
IdEx_pc_in=>IfId_pc_out,IdEx_signextend_in=>Signextendout, IdEx_instr11_in=>IfId_instr_out(31 downto 21),IdEx_instr5_in=>IfId_instr_out(4 downto 0), 
IdEx_CBranch=>IdEx_CBranch,IdEx_MemRead=>IdEx_MemRead,IdEx_MemtoReg=>IdEx_MemtoReg,IdEx_MemWrite=>IdEx_MemWrite, IdEx_ALUSrc=>IdEx_ALUSrc,
IdEx_RegWrite=>IdEx_RegWrite,IdEx_UBranch=>IdEx_UBranch,IdEx_ALUOp=>IdEx_ALUOp, IdEx_RD1=>IdEx_RD1,IdEx_RD2=>IdEx_RD2,IdEx_pc=>IdEx_pc,IdEx_signextend=>IdEx_signextend, 
IdEx_instr11=>IdEx_instr11,IdEx_instr5=>IdEx_instr5);   --IdEx
U11: ShiftLeft2 port map(x=>IdEx_signextend,y=>Slout);   --ShiftLeft2
U12: ADD port map(in0=>IdEx_pc,in1=>Slout,output=>Sadd_output);   --ADD for Shiftleft2
U13: MUX64 port map(in0=>MUX64_3B,in1=>IdEx_signextend,sel=>IdEx_ALUSrc,output=>ALUin);   --mux for ALU
U14: ALUControl port map(ALUOp=>IdEx_ALUOp,Opcode=>IdEx_instr11,Operation=>ALUcontrolout);   --ALUControl
U15: ALU port map(in0=>MUX64_3A,in1=>ALUin,operation=>ALUcontrolout,result=>ALUresult,zero=>zero,overflow=>overflow);   --ALU

U16: ExMem port map(ExMem_Rd_out=>ExMem_Rd_out,ExMem_Rd_in=>IdEx_Rd_out,clk=>clk, ExMem_CBranch_in=>IdEx_CBranch,ExMem_MemRead_in=>IdEx_MemRead,
ExMem_MemtoReg_in=>IdEx_MemtoReg,ExMem_MemWrite_in=>IdEx_MemWrite, ExMem_RegWrite_in=>IdEx_RegWrite,ExMem_UBranch_in=>IdEx_UBranch,ExMem_Addin_in=>Sadd_output,
ExMem_Zero_in=>zero, ExMem_Aluresult_in=>ALUresult,ExMem_RD2_in=>MUX64_3B,ExMem_instr5_in=>IdEx_instr5, 
ExMem_CBranch=>ExMem_CBranch,ExMem_MemRead=>ExMem_MemRead, ExMem_MemtoReg=>ExMem_MemtoReg,ExMem_MemWrite=>ExMem_MemWrite,
ExMem_RegWrite=>ExMem_RegWrite,ExMem_UBranch=>ExMem_UBranch, ExMem_Addin=>ExMem_Addin, ExMem_Zero=>ExMem_Zero,ExMem_Aluresult=>ExMem_Aluresult,
ExMem_RD2=>DMEM_writedata,ExMem_instr5=>ExMem_instr5);   --ExMem
U17: AND2 port map(in0=>ExMem_CBranch,in1=>ExMem_Zero,output=>PCSrc);   --And gate
U18: DMEM port map(WriteData=>DMEM_writedata,Address=>ExMem_Aluresult,MemRead=>ExMem_MemRead,MemWrite=>ExMem_MemWrite,Clock=>clk,ReadData=>ReadData,DEBUG_MEM_CONTENTS=>DEBUG_MEM_CONTENTS);   --DMEM
U19: MemWb port map(MemWb_Rd_in1=>ExMem_Rd_out, MemWb_Rd_out=>MemWb_Rd_out,clk=>clk, MemWb_instr5_in=>ExMem_instr5,MemWb_RD=>MemWb_RD, MemWb_MemWtoReg_in=>ExMem_MemtoReg,
MemWb_RegWrite_in=>ExMem_RegWrite,MemWb_Aluresult_in=>ExMem_Aluresult,MemWb_RD_in=>ReadData,MemWb_MemWtoReg=>MemWb_MemWtoReg,
 MemWb_RegWrite=>MemWb_RegWrite, MemWb_Aluresult=>MemWb_Aluresult, MemWb_instr5 =>WR);   --MemWb
U20: MUX64 port map(in0=>MemWb_Aluresult,in1=>MemWb_RD,sel=>MemWb_MemWtoReg,output=>WD);   --mux in the end
U21: harzarddetect port map(hazard_idex_Rd=>IdEx_Rd_out,hazard_Rn=>IfId_instr_out(9 downto 5),hazard_Rm=>IfId_instr_out(20 downto 16),
hazard_idex_Memread=>IdEx_MemRead,Choice=>CPU_enable,IfIdwrite=>IFID_enable,PCWrite=>PCwrite_enable); 
U22: Forwarding port map(forwarding_Rd=>IdEx_Rd_out,forwarding_Rn=>IdEx_Rn_out, forwarding_sturins=>IdEx_sturins_out,
forwarding_Rm=>IdEx_Rm_out,forwarding_exmem_Rd=>ExMem_Rd_out,forwarding_memwb_Rd=>MemWb_Rd_out, 
forwarding_exmem_regwrite=>ExMem_RegWrite,forwarding_memwb_regwrite=>MemWb_RegWrite, ForwardA=>ForwardA1,ForwardB=>ForwardB1);   

U23: MUX64_3 port map(in0=>IdEx_RD1,in1=>WD,in2=>ExMem_Aluresult,sel=>ForwardA1,output=>MUX64_3A); 
U24: MUX64_3 port map(in0=>IdEx_RD2,in1=>WD,in2=>ExMem_Aluresult,sel=>ForwardB1,output=>MUX64_3B); 
DEBUG_PC <= PCAddressOut;
DEBUG_INSTRUCTION <= PCout;
DEBUG_PC_WRITE_ENABLE <= PCwrite_enable;
DEBUG_FORWARDA <=ForwardA1;
DEBUG_FORWARDB <=ForwardB1;


end;
