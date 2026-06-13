library ieee;
use ieee.std_logic_1164.all;
-- define the empy entity for testbench
entity AND2_tb is
end AND2_tb;
ARCHITECTURE AND2_tb OF AND2_tb IS 
    COMPONENT AND2
    PORT(
         in0 : IN  std_logic;
         in1 : IN  std_logic;
         output : OUT  std_logic
        );
    END COMPONENT;
    
   signal in0_test : std_logic := '0';
   signal in1_test: std_logic := '0';
   signal output_test: std_logic;
BEGIN
        uut: entity work.AND2 PORT MAP (
          in0 => in0_test,
          in1 => in1_test,
          output => output_test
        );
   stim_proc: process
   begin  
     
   in0_test <= '0';
   in1_test <= '0';
      wait for 50 ns; 
   in0_test <= '0';
   in1_test <= '1';
      wait for 50 ns; 
   in0_test <= '1';
   in1_test <= '0';
      wait for 50 ns; 
   in0_test <= '1';
   in1_test <= '1';
      wait;
   end process;
END;