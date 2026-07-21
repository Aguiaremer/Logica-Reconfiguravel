if [file exists work] { vdel -all }
vlib work

vcom -93 BRAM.vhd
vcom -93 FIFO.vhd
vcom -93 T5.vhd
vcom -93 T5_tb.vhd

vsim -voptargs="+acc" -L altera_mf work.T5_tb

add wave -divider "SINAIS GLOBAIS"
add wave /clk
add wave /rst

add wave -divider "ESCRITA"
add wave /uut/state_wr
add wave -unsigned /uut/addr1
add wave -hex /uut/di1
add wave -hex /uut/do1
add wave -hex /uut/we1
add wave -hex /uut/wr_en_fifo

add wave -divider "ESTADO DO FIFO"
add wave -unsigned /uut/usedw_fifo
add wave /uut/empty_fifo
add wave /uut/full_fifo

add wave -divider "LEITURA"
add wave /uut/state_rd
add wave -unsigned /uut/addr2
add wave -hex /uut/data_fifo_out
add wave -hex /uut/rd_en_fifo
add wave -hex /uut/we2

run 450 us

wave zoom full