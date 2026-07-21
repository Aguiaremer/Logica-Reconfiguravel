-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus II 64-Bit"
-- VERSION "Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"

-- DATE "04/06/2026 18:49:04"

-- 
-- Device: Altera EP4CGX15BF14C6 Package FBGA169
-- 

-- 
-- This VHDL file should be used for ModelSim-Altera (VHDL) only
-- 

LIBRARY ALTERA;
LIBRARY CYCLONEIV;
LIBRARY IEEE;
USE ALTERA.ALTERA_PRIMITIVES_COMPONENTS.ALL;
USE CYCLONEIV.CYCLONEIV_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	cont_75 IS
    PORT (
	CLK : IN std_logic;
	RST : IN std_logic;
	CLR : IN std_logic;
	EN : IN std_logic;
	Q : OUT std_logic_vector(7 DOWNTO 0)
	);
END cont_75;

-- Design Ports Information
-- Q[0]	=>  Location: PIN_A11,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[1]	=>  Location: PIN_A12,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[2]	=>  Location: PIN_B10,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[3]	=>  Location: PIN_A13,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[4]	=>  Location: PIN_B8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[5]	=>  Location: PIN_C8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[6]	=>  Location: PIN_B13,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Q[7]	=>  Location: PIN_C6,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- CLR	=>  Location: PIN_B11,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- EN	=>  Location: PIN_G13,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- CLK	=>  Location: PIN_J7,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- RST	=>  Location: PIN_J6,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF cont_75 IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_CLK : std_logic;
SIGNAL ww_RST : std_logic;
SIGNAL ww_CLR : std_logic;
SIGNAL ww_EN : std_logic;
SIGNAL ww_Q : std_logic_vector(7 DOWNTO 0);
SIGNAL \RST~inputclkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \CLK~inputclkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \Q[0]~output_o\ : std_logic;
SIGNAL \Q[1]~output_o\ : std_logic;
SIGNAL \Q[2]~output_o\ : std_logic;
SIGNAL \Q[3]~output_o\ : std_logic;
SIGNAL \Q[4]~output_o\ : std_logic;
SIGNAL \Q[5]~output_o\ : std_logic;
SIGNAL \Q[6]~output_o\ : std_logic;
SIGNAL \Q[7]~output_o\ : std_logic;
SIGNAL \CLK~input_o\ : std_logic;
SIGNAL \CLK~inputclkctrl_outclk\ : std_logic;
SIGNAL \EN~input_o\ : std_logic;
SIGNAL \CLR~input_o\ : std_logic;
SIGNAL \uni|count_reg[0]~3_combout\ : std_logic;
SIGNAL \uni|count_reg[2]~5_combout\ : std_logic;
SIGNAL \uni|count_reg[2]~6_combout\ : std_logic;
SIGNAL \RST~input_o\ : std_logic;
SIGNAL \RST~inputclkctrl_outclk\ : std_logic;
SIGNAL \uni|Add0~0_combout\ : std_logic;
SIGNAL \uni|count_reg[3]~7_combout\ : std_logic;
SIGNAL \uni|count_reg[3]~1_combout\ : std_logic;
SIGNAL \uni|count_reg[3]~2_combout\ : std_logic;
SIGNAL \uni|count_reg[1]~4_combout\ : std_logic;
SIGNAL \clr_geral~0_combout\ : std_logic;
SIGNAL \dez|count_reg[0]~0_combout\ : std_logic;
SIGNAL \dez|count_reg[0]~1_combout\ : std_logic;
SIGNAL \dez|count_reg[0]~2_combout\ : std_logic;
SIGNAL \dez|count_reg[3]~3_combout\ : std_logic;
SIGNAL \dez|count_reg[1]~4_combout\ : std_logic;
SIGNAL \dez|Add0~0_combout\ : std_logic;
SIGNAL \dez|count_reg[2]~5_combout\ : std_logic;
SIGNAL \dez|Add0~1_combout\ : std_logic;
SIGNAL \dez|count_reg[3]~6_combout\ : std_logic;
SIGNAL \clr_geral~1_combout\ : std_logic;
SIGNAL \clr_geral~combout\ : std_logic;
SIGNAL \uni|count_reg[0]~0_combout\ : std_logic;
SIGNAL \dez|count_reg\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \uni|count_reg\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \ALT_INV_RST~inputclkctrl_outclk\ : std_logic;
SIGNAL \dez|ALT_INV_count_reg\ : std_logic_vector(0 DOWNTO 0);
SIGNAL \uni|ALT_INV_count_reg\ : std_logic_vector(2 DOWNTO 0);

BEGIN

ww_CLK <= CLK;
ww_RST <= RST;
ww_CLR <= CLR;
ww_EN <= EN;
Q <= ww_Q;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;

\RST~inputclkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \RST~input_o\);

\CLK~inputclkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \CLK~input_o\);
\ALT_INV_RST~inputclkctrl_outclk\ <= NOT \RST~inputclkctrl_outclk\;
\dez|ALT_INV_count_reg\(0) <= NOT \dez|count_reg\(0);
\uni|ALT_INV_count_reg\(2) <= NOT \uni|count_reg\(2);
\uni|ALT_INV_count_reg\(0) <= NOT \uni|count_reg\(0);

-- Location: IOOBUF_X20_Y31_N2
\Q[0]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \uni|ALT_INV_count_reg\(0),
	devoe => ww_devoe,
	o => \Q[0]~output_o\);

-- Location: IOOBUF_X20_Y31_N9
\Q[1]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \uni|count_reg\(1),
	devoe => ww_devoe,
	o => \Q[1]~output_o\);

-- Location: IOOBUF_X24_Y31_N9
\Q[2]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \uni|ALT_INV_count_reg\(2),
	devoe => ww_devoe,
	o => \Q[2]~output_o\);

-- Location: IOOBUF_X26_Y31_N2
\Q[3]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \uni|count_reg\(3),
	devoe => ww_devoe,
	o => \Q[3]~output_o\);

-- Location: IOOBUF_X22_Y31_N2
\Q[4]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dez|ALT_INV_count_reg\(0),
	devoe => ww_devoe,
	o => \Q[4]~output_o\);

-- Location: IOOBUF_X22_Y31_N9
\Q[5]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dez|count_reg\(1),
	devoe => ww_devoe,
	o => \Q[5]~output_o\);

-- Location: IOOBUF_X26_Y31_N9
\Q[6]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dez|count_reg\(2),
	devoe => ww_devoe,
	o => \Q[6]~output_o\);

-- Location: IOOBUF_X14_Y31_N2
\Q[7]~output\ : cycloneiv_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => \dez|count_reg\(3),
	devoe => ww_devoe,
	o => \Q[7]~output_o\);

-- Location: IOIBUF_X16_Y0_N15
\CLK~input\ : cycloneiv_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_CLK,
	o => \CLK~input_o\);

-- Location: CLKCTRL_G17
\CLK~inputclkctrl\ : cycloneiv_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \CLK~inputclkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \CLK~inputclkctrl_outclk\);

-- Location: IOIBUF_X33_Y16_N22
\EN~input\ : cycloneiv_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_EN,
	o => \EN~input_o\);

-- Location: IOIBUF_X24_Y31_N1
\CLR~input\ : cycloneiv_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_CLR,
	o => \CLR~input_o\);

-- Location: LCCOMB_X24_Y30_N22
\uni|count_reg[0]~3\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[0]~3_combout\ = (\CLR~input_o\) # (\EN~input_o\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \CLR~input_o\,
	datad => \EN~input_o\,
	combout => \uni|count_reg[0]~3_combout\);

-- Location: LCCOMB_X24_Y30_N20
\uni|count_reg[2]~5\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[2]~5_combout\ = (\uni|count_reg[3]~2_combout\ & (\uni|count_reg\(2) $ (((\uni|count_reg\(0)) # (!\uni|count_reg\(1))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0100101100000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \uni|count_reg\(0),
	datab => \uni|count_reg\(1),
	datac => \uni|count_reg\(2),
	datad => \uni|count_reg[3]~2_combout\,
	combout => \uni|count_reg[2]~5_combout\);

-- Location: LCCOMB_X24_Y30_N4
\uni|count_reg[2]~6\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[2]~6_combout\ = (!\uni|count_reg[2]~5_combout\ & ((\uni|count_reg[0]~3_combout\ & ((!\clr_geral~combout\))) # (!\uni|count_reg[0]~3_combout\ & (\uni|count_reg\(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0001000000110010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \uni|count_reg[0]~3_combout\,
	datab => \uni|count_reg[2]~5_combout\,
	datac => \uni|count_reg\(2),
	datad => \clr_geral~combout\,
	combout => \uni|count_reg[2]~6_combout\);

-- Location: IOIBUF_X16_Y0_N22
\RST~input\ : cycloneiv_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_RST,
	o => \RST~input_o\);

-- Location: CLKCTRL_G19
\RST~inputclkctrl\ : cycloneiv_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \RST~inputclkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \RST~inputclkctrl_outclk\);

-- Location: FF_X24_Y30_N5
\uni|count_reg[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \uni|count_reg[2]~6_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \uni|count_reg\(2));

-- Location: LCCOMB_X24_Y30_N30
\uni|Add0~0\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|Add0~0_combout\ = \uni|count_reg\(3) $ (((\uni|count_reg\(1) & (!\uni|count_reg\(2) & !\uni|count_reg\(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100110011000110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \uni|count_reg\(1),
	datab => \uni|count_reg\(3),
	datac => \uni|count_reg\(2),
	datad => \uni|count_reg\(0),
	combout => \uni|Add0~0_combout\);

-- Location: LCCOMB_X24_Y30_N18
\uni|count_reg[3]~7\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[3]~7_combout\ = (\uni|count_reg[0]~3_combout\ & (\uni|Add0~0_combout\ & ((\uni|count_reg[3]~2_combout\)))) # (!\uni|count_reg[0]~3_combout\ & ((\uni|count_reg\(3)) # ((\uni|Add0~0_combout\ & \uni|count_reg[3]~2_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1101110001010000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \uni|count_reg[0]~3_combout\,
	datab => \uni|Add0~0_combout\,
	datac => \uni|count_reg\(3),
	datad => \uni|count_reg[3]~2_combout\,
	combout => \uni|count_reg[3]~7_combout\);

-- Location: FF_X24_Y30_N19
\uni|count_reg[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \uni|count_reg[3]~7_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \uni|count_reg\(3));

-- Location: LCCOMB_X24_Y30_N10
\uni|count_reg[3]~1\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[3]~1_combout\ = (!\uni|count_reg\(0) & (\uni|count_reg\(2) & \uni|count_reg\(3)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011000000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \uni|count_reg\(0),
	datac => \uni|count_reg\(2),
	datad => \uni|count_reg\(3),
	combout => \uni|count_reg[3]~1_combout\);

-- Location: LCCOMB_X24_Y30_N24
\uni|count_reg[3]~2\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[3]~2_combout\ = (\EN~input_o\ & (!\CLR~input_o\ & ((\uni|count_reg\(1)) # (!\uni|count_reg[3]~1_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0010000000100010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \EN~input_o\,
	datab => \CLR~input_o\,
	datac => \uni|count_reg\(1),
	datad => \uni|count_reg[3]~1_combout\,
	combout => \uni|count_reg[3]~2_combout\);

-- Location: LCCOMB_X24_Y30_N26
\uni|count_reg[1]~4\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[1]~4_combout\ = (\uni|count_reg\(1) & (((\uni|count_reg[3]~2_combout\ & \uni|count_reg\(0))) # (!\uni|count_reg[0]~3_combout\))) # (!\uni|count_reg\(1) & (((\uni|count_reg[3]~2_combout\ & !\uni|count_reg\(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1101000001011100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \uni|count_reg[0]~3_combout\,
	datab => \uni|count_reg[3]~2_combout\,
	datac => \uni|count_reg\(1),
	datad => \uni|count_reg\(0),
	combout => \uni|count_reg[1]~4_combout\);

-- Location: FF_X24_Y30_N27
\uni|count_reg[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \uni|count_reg[1]~4_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \uni|count_reg\(1));

-- Location: LCCOMB_X24_Y30_N28
\clr_geral~0\ : cycloneiv_lcell_comb
-- Equation(s):
-- \clr_geral~0_combout\ = (!\uni|count_reg\(1) & (!\uni|count_reg\(0) & (\uni|count_reg\(2) & \uni|count_reg\(3))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0001000000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \uni|count_reg\(1),
	datab => \uni|count_reg\(0),
	datac => \uni|count_reg\(2),
	datad => \uni|count_reg\(3),
	combout => \clr_geral~0_combout\);

-- Location: LCCOMB_X23_Y30_N28
\dez|count_reg[0]~0\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[0]~0_combout\ = (!\clr_geral~combout\ & (\dez|count_reg\(0) $ (((\clr_geral~0_combout\ & \EN~input_o\)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000001111000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \clr_geral~0_combout\,
	datab => \EN~input_o\,
	datac => \dez|count_reg\(0),
	datad => \clr_geral~combout\,
	combout => \dez|count_reg[0]~0_combout\);

-- Location: FF_X23_Y30_N29
\dez|count_reg[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \dez|count_reg[0]~0_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \dez|count_reg\(0));

-- Location: LCCOMB_X23_Y30_N16
\dez|count_reg[0]~1\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[0]~1_combout\ = (!\CLR~input_o\ & ((!\clr_geral~0_combout\) # (!\EN~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000001100001111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \EN~input_o\,
	datac => \CLR~input_o\,
	datad => \clr_geral~0_combout\,
	combout => \dez|count_reg[0]~1_combout\);

-- Location: LCCOMB_X23_Y30_N22
\dez|count_reg[0]~2\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[0]~2_combout\ = ((\dez|count_reg\(2)) # ((\dez|count_reg\(1)) # (\dez|count_reg\(0)))) # (!\dez|count_reg\(3))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111111101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|count_reg\(3),
	datab => \dez|count_reg\(2),
	datac => \dez|count_reg\(1),
	datad => \dez|count_reg\(0),
	combout => \dez|count_reg[0]~2_combout\);

-- Location: LCCOMB_X23_Y30_N20
\dez|count_reg[3]~3\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[3]~3_combout\ = (\dez|count_reg[0]~2_combout\ & (\EN~input_o\ & (\clr_geral~0_combout\ & !\clr_geral~combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000010000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|count_reg[0]~2_combout\,
	datab => \EN~input_o\,
	datac => \clr_geral~0_combout\,
	datad => \clr_geral~combout\,
	combout => \dez|count_reg[3]~3_combout\);

-- Location: LCCOMB_X23_Y30_N14
\dez|count_reg[1]~4\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[1]~4_combout\ = (\dez|count_reg\(1) & ((\dez|count_reg[0]~1_combout\) # ((\dez|count_reg\(0) & \dez|count_reg[3]~3_combout\)))) # (!\dez|count_reg\(1) & (!\dez|count_reg\(0) & ((\dez|count_reg[3]~3_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110010111000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|count_reg\(0),
	datab => \dez|count_reg[0]~1_combout\,
	datac => \dez|count_reg\(1),
	datad => \dez|count_reg[3]~3_combout\,
	combout => \dez|count_reg[1]~4_combout\);

-- Location: FF_X23_Y30_N15
\dez|count_reg[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \dez|count_reg[1]~4_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \dez|count_reg\(1));

-- Location: LCCOMB_X23_Y30_N26
\dez|Add0~0\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|Add0~0_combout\ = \dez|count_reg\(2) $ (((!\dez|count_reg\(0) & \dez|count_reg\(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100111100110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \dez|count_reg\(0),
	datac => \dez|count_reg\(1),
	datad => \dez|count_reg\(2),
	combout => \dez|Add0~0_combout\);

-- Location: LCCOMB_X23_Y30_N24
\dez|count_reg[2]~5\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[2]~5_combout\ = (\dez|Add0~0_combout\ & ((\dez|count_reg[3]~3_combout\) # ((\dez|count_reg[0]~1_combout\ & \dez|count_reg\(2))))) # (!\dez|Add0~0_combout\ & (\dez|count_reg[0]~1_combout\ & (\dez|count_reg\(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110101011000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|Add0~0_combout\,
	datab => \dez|count_reg[0]~1_combout\,
	datac => \dez|count_reg\(2),
	datad => \dez|count_reg[3]~3_combout\,
	combout => \dez|count_reg[2]~5_combout\);

-- Location: FF_X23_Y30_N25
\dez|count_reg[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \dez|count_reg[2]~5_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \dez|count_reg\(2));

-- Location: LCCOMB_X23_Y30_N12
\dez|Add0~1\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|Add0~1_combout\ = \dez|count_reg\(3) $ (((\dez|count_reg\(2) & (\dez|count_reg\(1) & !\dez|count_reg\(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010101001101010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|count_reg\(3),
	datab => \dez|count_reg\(2),
	datac => \dez|count_reg\(1),
	datad => \dez|count_reg\(0),
	combout => \dez|Add0~1_combout\);

-- Location: LCCOMB_X23_Y30_N30
\dez|count_reg[3]~6\ : cycloneiv_lcell_comb
-- Equation(s):
-- \dez|count_reg[3]~6_combout\ = (\dez|Add0~1_combout\ & ((\dez|count_reg[3]~3_combout\) # ((\dez|count_reg[0]~1_combout\ & \dez|count_reg\(3))))) # (!\dez|Add0~1_combout\ & (\dez|count_reg[0]~1_combout\ & (\dez|count_reg\(3))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110101011000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|Add0~1_combout\,
	datab => \dez|count_reg[0]~1_combout\,
	datac => \dez|count_reg\(3),
	datad => \dez|count_reg[3]~3_combout\,
	combout => \dez|count_reg[3]~6_combout\);

-- Location: FF_X23_Y30_N31
\dez|count_reg[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \dez|count_reg[3]~6_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \dez|count_reg\(3));

-- Location: LCCOMB_X23_Y30_N8
\clr_geral~1\ : cycloneiv_lcell_comb
-- Equation(s):
-- \clr_geral~1_combout\ = (\dez|count_reg\(3) & (\dez|count_reg\(0) & (!\dez|count_reg\(1) & !\dez|count_reg\(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000001000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \dez|count_reg\(3),
	datab => \dez|count_reg\(0),
	datac => \dez|count_reg\(1),
	datad => \dez|count_reg\(2),
	combout => \clr_geral~1_combout\);

-- Location: LCCOMB_X23_Y30_N18
clr_geral : cycloneiv_lcell_comb
-- Equation(s):
-- \clr_geral~combout\ = (\CLR~input_o\) # ((\EN~input_o\ & (\clr_geral~1_combout\ & \clr_geral~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110110011001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \EN~input_o\,
	datab => \CLR~input_o\,
	datac => \clr_geral~1_combout\,
	datad => \clr_geral~0_combout\,
	combout => \clr_geral~combout\);

-- Location: LCCOMB_X24_Y30_N8
\uni|count_reg[0]~0\ : cycloneiv_lcell_comb
-- Equation(s):
-- \uni|count_reg[0]~0_combout\ = (!\clr_geral~combout\ & (\EN~input_o\ $ (\uni|count_reg\(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000001011010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \EN~input_o\,
	datac => \uni|count_reg\(0),
	datad => \clr_geral~combout\,
	combout => \uni|count_reg[0]~0_combout\);

-- Location: FF_X24_Y30_N9
\uni|count_reg[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \CLK~inputclkctrl_outclk\,
	d => \uni|count_reg[0]~0_combout\,
	clrn => \ALT_INV_RST~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \uni|count_reg\(0));

ww_Q(0) <= \Q[0]~output_o\;

ww_Q(1) <= \Q[1]~output_o\;

ww_Q(2) <= \Q[2]~output_o\;

ww_Q(3) <= \Q[3]~output_o\;

ww_Q(4) <= \Q[4]~output_o\;

ww_Q(5) <= \Q[5]~output_o\;

ww_Q(6) <= \Q[6]~output_o\;

ww_Q(7) <= \Q[7]~output_o\;
END structure;


