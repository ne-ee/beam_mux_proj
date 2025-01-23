This take-home should be completed in about an evening’s worth of time.
Please provide ample comments, testcases, and a write-up of your design and verification.

Design considerations for the 'beam_mux' implementation:

       *** MY DESIGN SUMMARY: ***
       
       To meet all the requirements, I instantiate two connected bram based axi_data_fifos from xilinx, this will allow me to capture all valid data samples
       up to the max burst, allowing for a contigious block of valid data samples going out to the selected dac.  I chose these fifos because they
       are very basic other than the addition of axi stream support which uses tvalid, tdata, tlast, tready.

       To minimize latency, I chose to make a generically expandable set of parallel fifo (see block diagram) pairs of, given the ratio of burst lengths of 1:64,
       and the requrement to
       release a contigious block of valid data samples to dacs, I decided it makes sense for a user to have the option to choose how many parallel pairs of fifos
       which can take on new bursts.  In my example I have set the parallel width to 4.  This means I can have a max length 1st burst, and 3 more minimum length bursts
       with minimal latency, in fact, there would be no latency other than the time to propogate through the fifo unless, you added a 5, 6, 7 ... addiotional minimum
       burst without interruption while the 1st burst was still unloading.

       The fifo pair that is selected for a given burst is selected in a circular fashion with an rx_fifo and tx_fifo select construct, where once fifo pair is contains
       the contigious data samples and tlast has signaled they are all captured in the fifo, rx_fifo increments ready for new valid data samples. Once tlast propogates
       to the 2nd stage of the fifo pair, the tx_fifo_sel is incrmented to catch up to rx_fifo_sel.  The tx_fifo_select is used to direct the outgoing contigious
       stream of data samples from the fifo to the appropriate dac which is specified by dac_sel.

       The dac selection supports a mechanism to guarantee that if dac_select is changed while a burst is being directed to a dac, that it only changes after
       the burst completes. There are some conditions, a user cannot arbitrarly change dac select pre-burst, a 1-2 cycles are required of a stable dac_sel before a burst
       for this guarantee to be made.  Additionally, Round Robin is supported, however, there is still a bug which needs fixing where round robin only alternates
       between dac1 and dac2.  This can be fixed easily. The locked dac_select value during a burst is accomplished by storing the previous cycle value of dac_sel
       and locking the value when a transition to a non-burst to burst is oberved.  This same principle is used for initializing the round robin mechanism to initialize
       with a to start at dac1.  All dacs are passed the outgoing samples, however, only the selected dac will have the respective valid assertion.

       The system verilog testbench uses dynamic queues to load up 32 bit data and assert valid to the dut when tready is asserted from the dut.  The current state
       of the test bench sends 3 consecutive 2^10 bursts.  I have tested the maximum 2^16 bursts as well, but admittedly would need to clean the testbench up and use
       tasks instead of copy and pasted loops which unload and reload the queues.  However, the testbench demonstrates the basic stimulus of the dut and how one might
       expand testing to cover all test cases.  Test cases that come to mind:

       	      a. Is any data lost or invalid data getting through? make copy of stimulus queue, unload queue as stimulus, then compare
	      	 outputs based on valid asserted data coming out dut.
		 
	      	  i. TODO: it appears I currently am off by a cycle on my output data, I lose the very last value
		  
	      b. Do arbitrary burst sizes cause corrupted output data?  This test case lends itself best to system verilog with random distributions.
	         You could create a constraint class to create a typical distribution of burst lenghts, or a uniformly random distribution which may not be as likely,
		 you could also increase the probabity of what would be rare cases using class constraints that use implication.

	      c. You could constintly monitor for violations of illegal combinations of dacX_valid signals, only one should be high at a single cycle.

	      d. Randomly distribute test lengths between valid data bursts coming in, may reveal bugs or corner cases.

	      e. Monitor for any additional known illegal dut internal/external signal combinations.

       *** REQUIREMENT REVIEW: ***

       1. Each transmission out of the modulator is bursty, and will have a duration between 1024 and 65536 samples. The end of the burst is
       	  signified by axis_source.tlast being asserted on its final sample.

	  a. Given that the size is 65536 or 2^16, and I have a data sample of width 32 bits, (16 I, 16 Q I'm assuming),
	     typically, Xilinx brams for fifo implementations are half that size, without using pre-built Xilinx iP
	     to connect two fifos for me, I instantiate two axi_data_fifos with tvalid, tdata, tready, tlast stream interfaces connected together.
	     If a max length of 2^16 was the only constraint, I could use a single fifo, but given that I need to guarantee a continious stream
	     of valid data samples, I must capture all of the max 2^16 samples in the 2 fifos together, before releasing the data samples.
	     I rely on a tlast running into the first fifo, and that being passed along to the second fifo in order to assert valid at the correct DAC selection.
	     
	  b. Additionally, to reduce latency
	  
       2. The modulator supports backpressure, and will output valid samples at arbitrary rates. The Beam Mux must support arbitrary-rate samples
       	  coming in at the axis_source interface as well.

	  a. Backpressure is applied if all available fifo pairs are in use.

       3. A DAC should receive an uninterrupted stream of samples; once data is fed into it, its axis_dac[n].tvalid should be asserted every clock
       	  cycle throughout the duration of the burst.

	  a. This is the most burdensome requirement, as it forces the use of paired fifos to contain 2^16 which is double the depth of a typical bram based fifo.

       4. dac_sel is used to select which DAC is being fed samples. When dac_sel is updated, the DAC currently receiving samples should finish
       	  its burst before samples are fed to the newly selected DAC.

	  a. I implemented a burst lock mechanism as explained in the summary above.
	  
       5. dac_sel routes samples as follows:
            dac_sel = 0 : DAC selection operates in a round-robin fashion; one burst gets output through DAC 1, the next through DAC 2, and so on
            dac_sel = 1 : all samples flow through DAC 1
            dac_sel = 2 : all samples flow through DAC 2
            dac_sel = 3 : all samples flow through DAC 3

	  a. explained in summary, or see beam_mux.vhd
	    
       6. DACs that are not currently transmitting or selected should not be fed valid samples.
       	  System latency between samples being output from the modulator and output by the DAC should be minimized, and the downtime of no
	  DAC being fed samples should be kept to a minimum.

	  a. See summary above.
	  
       7. The design will be running on a Xilinx Ultrascale+ FPGA. All inputs, outputs, and resets are assumed synchronous; assume clk to be
       	  running at a 300 MHz rate.

