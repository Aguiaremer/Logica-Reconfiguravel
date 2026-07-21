onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cont_75/CLK
add wave -noupdate /tb_cont_75/RST
add wave -noupdate /tb_cont_75/CLR
add wave -noupdate /tb_cont_75/EN
add wave -noupdate /tb_cont_75/Q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9776 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {256 ns}
