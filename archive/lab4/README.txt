This package contains all the components for lab 4. To compile the files, just open the folder "lab4" and then compile the files in it. The components that the cpu use include:

"MUX64.vhd" "PC.vhd" "add.vhd" "imem_p1.chd" "IFID.vhd" "MUX5.vhd" "registers_p1.vhd" "SignExtend.vhd" "cpucontrol.vhd" "IDEX.vhd" "ShiftLeft2.vhd" "alucontrol.vhd" "alu.vhd" "EXMEM.vhd" "AND2.vhd" "dmem.vhd" "MEMWB.vhd" "piplinedcpu0.vhd"

The piplinedcpu is designed mainly based on the lab 3, which is the singlecycle cpu. I added for registers to the orignal single cycle cpu. Thus performed different stages in every instruction. Specific discription for some of the most important signals is given in the lab report. And I've also output all the signals simulated. The entire process is breaked into four files: "wave1.ps", "wave2.ps", "wave3.ps" and "wave4.ps"
