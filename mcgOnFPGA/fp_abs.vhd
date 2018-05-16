-- megafunction wizard: %ALTFP_ABS%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: ALTFP_ABS 

-- ============================================================
-- File Name: fp_abs.vhd
-- Megafunction Name(s):
-- 			ALTFP_ABS
--
-- Simulation Library Files(s):
-- 			
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 17.1.0 Build 590 10/25/2017 SJ Lite Edition
-- ************************************************************


--Copyright (C) 2017  Intel Corporation. All rights reserved.
--Your use of Intel Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Intel Program License 
--Subscription Agreement, the Intel Quartus Prime License Agreement,
--the Intel FPGA IP License Agreement, or other applicable license
--agreement, including, without limitation, that your use is for
--the sole purpose of programming logic devices manufactured by
--Intel and sold by Intel or its authorized distributors.  Please
--refer to the applicable agreement for further details.


--altfp_abs CBX_AUTO_BLACKBOX="ALL" DEVICE_FAMILY="Cyclone IV E" PIPELINE=1 WIDTH_EXP=8 WIDTH_MAN=23 clock data result
--VERSION_BEGIN 17.1 cbx_altfp_abs 2017:10:19:05:46:40:SJ cbx_mgl 2017:10:19:06:38:12:SJ  VERSION_END

--synthesis_resources = reg 31 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  fp_abs_altfp_abs_aia IS 
	 PORT 
	 ( 
		 clock	:	IN  STD_LOGIC := '0';
		 data	:	IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
		 result	:	OUT  STD_LOGIC_VECTOR (31 DOWNTO 0)
	 ); 
 END fp_abs_altfp_abs_aia;

 ARCHITECTURE RTL OF fp_abs_altfp_abs_aia IS

	 SIGNAL	 result_pipe	:	STD_LOGIC_VECTOR(30 DOWNTO 0)
	 -- synopsys translate_off
	  := (OTHERS => '0')
	 -- synopsys translate_on
	 ;
	 SIGNAL  aclr	:	STD_LOGIC;
	 SIGNAL  clk_en	:	STD_LOGIC;
	 SIGNAL  data_w :	STD_LOGIC_VECTOR (31 DOWNTO 0);
	 SIGNAL  gnd_w :	STD_LOGIC;
	 SIGNAL  wire_w_data_w_range2w	:	STD_LOGIC_VECTOR (30 DOWNTO 0);
 BEGIN

	aclr <= '0';
	clk_en <= '1';
	data_w <= ( gnd_w & data(30 DOWNTO 0));
	gnd_w <= '0';
	result <= ( data_w(31) & result_pipe(30 DOWNTO 0));
	wire_w_data_w_range2w <= data_w(30 DOWNTO 0);
	PROCESS (clock, aclr)
	BEGIN
		IF (aclr = '1') THEN result_pipe <= (OTHERS => '0');
		ELSIF (clock = '1' AND clock'event) THEN 
			IF (clk_en = '1') THEN result_pipe <= wire_w_data_w_range2w;
			END IF;
		END IF;
	END PROCESS;

 END RTL; --fp_abs_altfp_abs_aia
--VALID FILE


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fp_abs IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END fp_abs;


ARCHITECTURE RTL OF fp_abs IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (31 DOWNTO 0);



	COMPONENT fp_abs_altfp_abs_aia
	PORT (
			clock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	result    <= sub_wire0(31 DOWNTO 0);

	fp_abs_altfp_abs_aia_component : fp_abs_altfp_abs_aia
	PORT MAP (
		clock => clock,
		data => data,
		result => sub_wire0
	);



END RTL;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone IV E"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "UNUSED"
-- Retrieval info: CONSTANT: LPM_HINT STRING "UNUSED"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altfp_abs"
-- Retrieval info: CONSTANT: PIPELINE NUMERIC "1"
-- Retrieval info: CONSTANT: WIDTH_EXP NUMERIC "8"
-- Retrieval info: CONSTANT: WIDTH_MAN NUMERIC "23"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: USED_PORT: data 0 0 32 0 INPUT NODEFVAL "data[31..0]"
-- Retrieval info: CONNECT: @data 0 0 32 0 data 0 0 32 0
-- Retrieval info: USED_PORT: result 0 0 32 0 OUTPUT NODEFVAL "result[31..0]"
-- Retrieval info: CONNECT: result 0 0 32 0 @result 0 0 32 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL fp_abs.vhd TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL fp_abs.qip TRUE FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL fp_abs.bsf TRUE TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL fp_abs_inst.vhd TRUE TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL fp_abs.inc TRUE TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL fp_abs.cmp TRUE TRUE