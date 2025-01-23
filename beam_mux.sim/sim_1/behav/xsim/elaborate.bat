@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.2 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Wed Jan 22 20:41:21 -0700 2025
REM SW Build 3671981 on Fri Oct 14 05:00:03 MDT 2022
REM
REM IP Build 3669848 on Fri Oct 14 08:30:02 MDT 2022
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
REM elaborate design
echo "xelab --incr --debug typical --relax --mt 2 -L xil_defaultlib -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_9 -L uvm -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot beam_mux_tb_behav xil_defaultlib.beam_mux_tb xil_defaultlib.glbl -log elaborate.log"
call xelab  --incr --debug typical --relax --mt 2 -L xil_defaultlib -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_9 -L uvm -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot beam_mux_tb_behav xil_defaultlib.beam_mux_tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
