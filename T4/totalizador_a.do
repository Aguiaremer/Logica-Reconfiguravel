# =====================================================================
# SCRIPT DE SIMULAÇÃO GATE-LEVEL (TIMING)
# =====================================================================
transcript on

# 1. Preparar a biblioteca de trabalho
if {[file exists gate_work]} {
    vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

# 2. Compilar o hardware gerado pelo Quartus (Netlist)
# O arquivo .vho contém a estrutura física da FPGA
vcom -93 -work work {T4.vho}

# 3. Compilar o Testbench
# Usamos ../../ para buscar o arquivo que está na raiz do projeto
vcom -93 -work work {../../totalizador_a_tb.vhd}

# 4. Iniciar a Simulação
# -t 1ps: Resolução de picosegundos para ver os atrasos
# -sdftyp: Carrega o arquivo de atrasos REAIS (.sdo)
vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /uut=T4_vhd.sdo gate_work.totalizador_a_tb

add wave /totalizador_a_tb/*
run 500 ns
wave zoom full