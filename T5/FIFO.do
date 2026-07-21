vlib work
vcom -93 FIFO.vhd
vcom -93 FIFO_tb.vhd

vsim -voptargs="+acc" -L altera_mf work.FIFO_tb

add wave -divider "Controle"
add wave -hex /FIFO_tb/clock
add wave -hex /FIFO_tb/wrreq
add wave -hex /FIFO_tb/rdreq

add wave -divider "Status"
add wave -hex /FIFO_tb/full
add wave -hex /FIFO_tb/empty
add wave -unsigned /FIFO_tb/usedw

add wave -divider "Dados"
add wave -hex /FIFO_tb/data
add wave -hex /FIFO_tb/q

run 500 ns
wave zoom full