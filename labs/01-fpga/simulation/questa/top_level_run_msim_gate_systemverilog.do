transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -sv -work work +incdir+. {top_level.svo}

vlog -sv -work work +incdir+C:/intelFPGA/LABORATORIOS {C:/intelFPGA/LABORATORIOS/tb_top_level.sv}

vsim -t 1ps -L altera_ver -L altera_lnsim_ver -L cyclonev_ver -L lpm_ver -L sgate_ver -L cyclonev_hssi_ver -L altera_mf_ver -L cyclonev_pcie_hip_ver -L gate_work -L work -voptargs="+acc"  top_level

add wave *
view structure
view signals
run 200 ns
