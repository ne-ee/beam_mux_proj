
`timescale 1ps / 1ps 
//import my_utils_pkg::*;

//package beam_utils_pkg;
//   function void dsp(input string a);
//      $display("%DSP FUNCTION: s\n", a);
//   endfunction : dsp;
//   
//endpackage // beam_utils_pkg

//include beam_utils_pkg::*;

module beam_mux_tb;

   task unload_q(input logic [31:0] q[$]);
      
     while(q.size() > 0) begin
     
        @(posedge clk)
     	
        mod_t_valid <= 1'b0;
        mod_t_data <= 32'd0;
        
        if(mod_t_ready == 1'b1) begin
     	 
          mod_t_valid <= 1'b1;	 

       	  mod_t_data <= q.pop_front();	   
        
          $display("SIZE: %d, DEC: %d BIN: %b\n", q.size(), mod_t_data, mod_t_data);
          
           if(q.size() == 1) begin
          	 mod_t_last <= 1'b1;
          end else begin
          	 mod_t_last <= 1'b0;	
          end

        end // if (mod_t_ready == 1'b1)
     
     end // while 
     
     #10ps;
     
     mod_t_last <= 1'b0;
     mod_t_valid = 1'b0;
     
     #10ps;
      
   endtask // unload_q

   //task load_q(input logic [31:0] q[$]);
   //   @(posedge clk)
   //	$display("Hello");
   //endtask // load_q

   function void dsp(input string a);
      $display("GULP: %s", a);
   endfunction // dsp
   

  logic 	clk = 1'b0;
  logic 	rst = 1'b0;
  integer 	N_BEAM_MUX_DACS = 3;
   
  logic [1:0]   dac_sel = 2'd0;
  logic [31:0]  mod_t_data = 32'd0;
  logic 	mod_t_valid = 1'd0;
  logic 	mod_t_ready;
  logic 	mod_t_last = 1'd0;
  logic [31:0]  dac1_t_data = 32'd0;
  logic 	dac1_t_valid;
  logic [31:0]	dac2_t_data = 32'd0;
  logic 	dac2_t_valid;
  logic [31:0]	dac3_t_data = 32'd0;
  logic 	dac3_t_valid;


  logic [31:0] stim_q[$];
  logic [31:0] stim_cpy_q[$];   
  logic [31:0] result_q[$];
  integer load_size = 2**10;   

   beam_mux    #( // nbld:vhdl
		  .N_BEAM_MUX_DACS(4)
                ) bm1 (
                 .clk(clk),
                 .rst(rst),
                 .dac_sel(dac_sel),
                 .mod_t_data(mod_t_data),
                 .mod_t_valid(mod_t_valid),
                 .mod_t_ready(mod_t_ready),
                 .mod_t_last(mod_t_last),
                 .dac1_t_data(dac1_t_data),
                 .dac1_t_valid(dac1_t_valid),
                 .dac2_t_data(dac2_t_data),
                 .dac2_t_valid(dac2_t_valid),
                 .dac3_t_data(dac3_t_data),
                 .dac3_t_valid(dac3_t_valid)
		);
   
initial begin

   //for(int ii = 0; ii < 2**16; ii++) begin
   //for(int ii = 0; ii < 2**15 + 2**10; ii++) begin

   ///////////////  RESET  ///////////////   

   rst = 1'b0;

   #20ps;

   rst = 1'b1;
   
   #20ps;
   
   rst = 1'b0;
   mod_t_last = 1'b0;
   mod_t_valid = 1'b0;   

   #20ps;

   dac_sel = 2'b01;

   #20ps;

   ///////////////  TEST 6 INCREASING 2^10->2^16 LOADS PARALLEL FIFOS  ///////////////   

   for (int ld = 0; ld < 6; ld++) begin
      
     for(int ii = 0; ii < load_size ; ii++) begin            
        stim_q.push_back(ii);
     end
     
     unload_q(stim_q);
     
     stim_q.delete();
      
   end // for (int ld = 0; ld < 9; ld++)

   load_size = 2*load_size;

   #20ps;

   dac_sel = 2'b10;

   #20ps;

   for (int ld = 0; ld < 6; ld++) begin
      
     for(int ii = 0; ii < load_size ; ii++) begin            
        stim_q.push_back(ii);
     end
     
     unload_q(stim_q);
     
     stim_q.delete();

   end // for (int ld = 0; ld < 9; ld++)
   
   load_size = 2*load_size;
   
   #20ps;

   dac_sel = 2'b11;

   #20ps;

   for (int ld = 0; ld < 6; ld++) begin
      
     for(int ii = 0; ii < load_size ; ii++) begin            
        stim_q.push_back(ii);
     end
     
     unload_q(stim_q);
     
     stim_q.delete();

   end // for (int ld = 0; ld < 9; ld++)
   
   load_size = 2*load_size;
   
   
   ///////////////  TEST 4 SIZE 1024 LOADS PARALLEL FIFOS  ///////////////

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();


   ///////////////  FLUSH  ///////////////      

   #10ps;
   
   mod_t_last = 1'b0;
   mod_t_valid = 1'b0;   

   #10000ps;

   dac_sel = 2'b00;

   #20ps;
   

   ///////////////  TEST 9 ROUND ROBIN SIZE 1024 LOADS PARALLEL FIFOS  ///////////////

   for (int ld = 0; ld < 9; ld++) begin
   
     for(int ii = 0; ii < 2**10 ; ii++) begin            
        stim_q.push_back(ii);
     end
     
     unload_q(stim_q);
     
     stim_q.delete();
      
   end // for (int ld = 0; ld < 9; ld++)
   

   ///////////////  FLUSH  ///////////////      

   #10ps;
   
   mod_t_last = 1'b0;
   mod_t_valid = 1'b0;   

   #10000ps;

   dac_sel = 2'b01;

   #20ps;

   
   ///////////////  RESET  ///////////////   

   rst = 1'b0;

   #20ps;

   rst = 1'b1;
   
   #10000ps;
   
   rst = 1'b0;
   mod_t_last = 1'b0;
   mod_t_valid = 1'b0;   

   #20ps;

   dac_sel = 2'b00;

   #20ps;

   ///////////////  TEST 6 SIZE 1024 LOADS PARALLEL FIFOS FOR ROUND ROBIN  ///////////////

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();

   for(int ii = 0; ii < 2**10 ; ii++) begin            
      stim_q.push_back(ii);
   end

   unload_q(stim_q);

   stim_q.delete();
   

   //while(stim_q.size() > 0) begin
   //
   //   @(posedge clk)
   //	
   //   mod_t_valid <= 1'b0;
   //   mod_t_data <= 32'd0;
   //   
   //   if(mod_t_ready == 1'b1) begin
   //	 
   //     mod_t_valid <= 1'b1;	 
   //	mod_t_data <= stim_q.pop_front();
   //   
   //     $display("SIZE: %d, DEC: %d BIN: %b\n", stim_q.size(), mod_t_data, mod_t_data);
   //     
   //     if(stim_q.size() == 1) begin
   //     	 mod_t_last <= 1'b1;
   //     end else begin
   //     	 mod_t_last <= 1'b0;	
   //     end
   //   end // if (mod_t_ready == 1'b1)
   //
   //end // while (stim_q.size() > 0 && mod_t_ready == 1'b1)
   //
   //#10ps;
   //
   //mod_t_last <= 1'b0;
   //mod_t_valid = 1'b0;
   
   dsp("Gulp");
   
end


always #5 clk = ~clk;
   
endmodule
