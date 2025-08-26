transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {top_level.vo}

vlog -vlog01compat -work work +incdir+C:/Users/santi/Arquitectura\ de\ computadores/Laboratorio\ 1/4.2 {C:/Users/santi/Arquitectura de computadores/Laboratorio 1/4.2/tb_top_level.v}

vsim -t 1ps -L altera_ver -L altera_lnsim_ver -L cyclonev_ver -L lpm_ver -L sgate_ver -L cyclonev_hssi_ver -L altera_mf_ver -L cyclonev_pcie_hip_ver -L gate_work -L work -voptargs="+acc"  tb_top_level

add wave *
view structure
view signals
run 200 ns
