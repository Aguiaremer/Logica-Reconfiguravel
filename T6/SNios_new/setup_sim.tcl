# Script de Automacao para ModelSim (Versao Debug Master)
# Salve este arquivo como setup_sim.tcl na raiz do projeto (C:/SNios_new/)

echo "--- Iniciando Script de Setup Nios II ---"

# 1. Caminhos
set PROJECT_ROOT "C:/SNios_new"
set SIM_PATH "$PROJECT_ROOT/HSys/testbench/mentor"

# 2. Ir para a pasta de simulacao
cd $SIM_PATH

# 3. Carregar o ambiente do Qsys
if {[file exists msim_setup.tcl]} {
    do msim_setup.tcl
    
    # Copia o arquivo HEX da memoria (garante que o hardware use o software mais recente)
    file_copy
    
    # Elabora e carrega o projeto
    ld
} else {
    echo "ERRO: msim_setup.tcl nao encontrado em $SIM_PATH"
}

# 4. Configurar a Waveform (Sinais organizados)
delete waves

add wave -divider "SISTEMA"
add wave -hex -label "Clock" sim:/hsys_tb/hsys_inst_clk_bfm_clk_clk
add wave -hex -label "Reset_n" sim:/hsys_tb/hsys_inst_reset_bfm_reset_reset

add wave -divider "CPU_MASTER (Saida do Processador)"
add wave -hex -label "Master_Addr"    sim:/hsys_tb/hsys_inst/cpu/d_address
add wave -hex -label "Master_Write"   sim:/hsys_tb/hsys_inst/cpu/d_write
add wave -hex -label "Master_WData"   sim:/hsys_tb/hsys_inst/cpu/d_writedata
add wave -hex -label "Master_ByteEn"  sim:/hsys_tb/hsys_inst/cpu/d_byteenable
add wave -hex -label "Master_Wait"    sim:/hsys_tb/hsys_inst/cpu/d_waitrequest

add wave -divider "TOP_AVALON (Seu Componente)"
add wave -hex -label "ChipSelect"   sim:/hsys_tb/hsys_inst/top_avalon_0/chipselect
add wave -hex -label "Offset"       sim:/hsys_tb/hsys_inst/top_avalon_0/add
add wave -hex -label "WriteData"    sim:/hsys_tb/hsys_inst/top_avalon_0/writedata
add wave -hex -label "Write_En"     sim:/hsys_tb/hsys_inst/top_avalon_0/write_en
add wave -hex -label "ReadData"     sim:/hsys_tb/hsys_inst/top_avalon_0/readdata

add wave -divider "CPU_PC (Controle)"
add wave -hex -label "PC_Endereco" sim:/hsys_tb/hsys_inst/cpu/i_address

# 5. Rodar a simulacao
echo "--- Script Finalizado. Rodando 5ms de simulacao... ---"
run 25 ms
