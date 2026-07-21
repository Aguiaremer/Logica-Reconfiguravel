vlib work

# Compila as bibliotecas da Altera/Intel (necessário para BRAM/FIFO)
vcom -93 -work work BRAM.vhd
vcom -93 -work work BRAM_tb.vhd

vsim -voptargs="+acc" -L altera_mf work.BRAM_tb

add wave -divider "Sinais de Controle"
add wave -hex /BRAM_tb/clock
add wave -hex /BRAM_tb/wren
add wave -hex /BRAM_tb/rden

add wave -divider "Escrita"
add wave -hex /BRAM_tb/wraddress
add wave -hex /BRAM_tb/data

add wave -divider "Leitura"
add wave -hex /BRAM_tb/rdaddress
add wave -hex /BRAM_tb/q

run 500 ns

wave zoom full