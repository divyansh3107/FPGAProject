#!/bin/bash
vivado_path="/home/iiitb/Xilinx/Vivado/2022.2/bin/vivado"
tcl_script="/home/iiitb/Downloads/vga_bram-main/run.tcl"

$vivado_path -mode batch -source $tcl_script
