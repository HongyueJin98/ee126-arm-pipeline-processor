The entire pipelinedcpu contants 24 ".vhd" files in the "code" folder. First, you can add all 23 to a vhdl project and compile them. The compile order is:

Firstly the basic components: AND2.vhd, add.vhd, OR2.vhd, MUX5.vhd, MUX64.vhd, MUX64_3.vhd.
And then the critical components of the CPU: alu.vhd, alucontrol.vhd, cpucontrol.vhd, PC.vhd, registers_p1.vhd, ShiftLeft2.vhd, SignExtend.vhd, lab5_dmem.chd, lab5_imem.vhd.
After that, we should compile the caches between the stages: IFID.vhd, IDEX.vhd, EXMEM.vhd, MEMWB.vhd，cbz.vhd.
Finally, the top-level design of the entire system: piplinedcpu1.vhd and my own testbench piplinedcpu1_tb.vhd (could be removed if you don’t want it).

Thank you!:)