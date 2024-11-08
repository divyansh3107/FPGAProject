# Define the project directory and project name
set project_dir "/home/iiitb/Downloads/vga_bram-main/project"       ;
set project_name "project"                   ;

# Open the project
open_project "$project_dir/$project_name.xpr"
puts "BRAM synthesis..."
update_compile_order -fileset sources_1
set_property CONFIG.Coe_File {/home/iiitb/Downloads/vga_bram-main/image_output.coe} [get_ips blk_mem_gen_1]
generate_target all [get_files  /home/iiitb/Downloads/vga_bram-main/project/project.srcs/sources_1/ip/blk_mem_gen_1/blk_mem_gen_1.xci]
catch { config_ip_cache -export [get_ips -all blk_mem_gen_1] }
export_ip_user_files -of_objects [get_files /home/iiitb/Downloads/vga_bram-main/project/project.srcs/sources_1/ip/blk_mem_gen_1/blk_mem_gen_1.xci] -no_script -sync -force -quiet
reset_run blk_mem_gen_1_synth_1
launch_runs blk_mem_gen_1_synth_1 -jobs 32
export_simulation -of_objects [get_files /home/iiitb/Downloads/vga_bram-main/project/project.srcs/sources_1/ip/blk_mem_gen_1/blk_mem_gen_1.xci] -directory /home/iiitb/Downloads/vga_bram-main/project/project.ip_user_files/sim_scripts -ip_user_files_dir /home/iiitb/Downloads/vga_bram-main/project/project.ip_user_files -ipstatic_source_dir /home/iiitb/Downloads/vga_bram-main/project/project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/iiitb/Downloads/vga_bram-main/project/project.cache/compile_simlib/modelsim} {questa=/home/iiitb/Downloads/vga_bram-main/project/project.cache/compile_simlib/questa} {xcelium=/home/iiitb/Downloads/vga_bram-main/project/project.cache/compile_simlib/xcelium} {vcs=/home/iiitb/Downloads/vga_bram-main/project/project.cache/compile_simlib/vcs} {riviera=/home/iiitb/Downloads/vga_bram-main/project/project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
wait_on_run [get_runs blk_mem_gen_1_synth_1]
puts "BRAM Completed..."
# Launch Synthesis

puts "Starting synthesis..."
reset_run synth_1
launch_runs synth_1 -jobs 32
# Wait for Synthesis to finish
wait_on_run [get_runs synth_1]
puts "Synthesis completed."

# Launch Implementation
puts "Starting implementation..."
reset_run impl_1
launch_runs impl_1 -jobs 32
wait_on_run [get_runs impl_1]
puts "Implementation completed."

# Generate Bitstream
puts "Starting bitstream generation..."
launch_runs impl_1 -to_step write_bitstream -jobs 32
wait_on_run [get_runs impl_1]
puts "Bitstream generation completed."

# hardware manager
open_hw_manager
connect_hw_server
if {[llength [get_hw_targets]] > 0} {
    open_hw_target [lindex [get_hw_targets] 0]
} else {
    puts "ERROR: No hardware target found."
    exit
}

set_property PROGRAM.FILE {/home/iiitb/Downloads/vga_bram-main/project/project.runs/impl_1/vga.bit} [get_hw_devices xc7a35t_0]
current_hw_device [get_hw_devices xc7a35t_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7a35t_0] 0]
set_property PROBES.FILE {} [get_hw_devices xc7a35t_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7a35t_0]
program_hw_devices [get_hw_devices xc7a35t_0]
refresh_hw_device [lindex [get_hw_devices xc7a35t_0] 0]