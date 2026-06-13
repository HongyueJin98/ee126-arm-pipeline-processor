library IEEE;  
use IEEE.STD_LOGIC_1164.all;  
use IEEE.STD_LOGIC_UNSIGNED.all;  

entity singlecyclecpu_tb is   
end singlecyclecpu_tb; 

 
architecture singlecyclecpu_tb of singlecyclecpu_tb is  
  component SingleCycleCPU
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
  end component;  
  
  signal clk              :std_logic;
  signal rst              :std_logic:='1';
  signal DEBUG_PC : STD_LOGIC_VECTOR(63 downto 0);
  signal DEBUG_INSTRUCTION :  STD_LOGIC_VECTOR(31 downto 0);
  signal DEBUG_TMP_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0);
  signal DEBUG_SAVED_REGS :  STD_LOGIC_VECTOR(64*4 - 1 downto 0);
  signal DEBUG_MEM_CONTENTS : STD_LOGIC_VECTOR(64*4 - 1 downto 0);    
  constant clk_period :time :=400 ns;    
    
  begin  
    uut: SingleCycleCPU port map  
    (  
      clk=>clk,
      rst=>rst,
      DEBUG_PC => DEBUG_PC,
      DEBUG_INSTRUCTION  => DEBUG_INSTRUCTION,
      DEBUG_TMP_REGS     => DEBUG_TMP_REGS,
      DEBUG_SAVED_REGS   => DEBUG_SAVED_REGS,
      DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS
      );  
      
  time_gen_proc:process  
    begin      
    wait for clk_period/2;  
    clk<='1';    
    wait for clk_period/2;  
    clk<='0';  
  end process; 
  
  stim_proc:process
  begin      
  rst<='0';
  wait ;
  

  end process;  
end;