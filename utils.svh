
`ifndef utils
`define utils

package utils_pkg;
   typedef logic [15:0] q_log[$];
endpackage // utils_pkg

import utils_pkg::*;

package my_utils_pkg;
   

  class rand_prbs;
     rand logic signed [15:0] 	i_data_qam4;
     rand logic signed [15:0] 	q_data_qam4;
     rand logic signed [15:0] 	i_data_qam16;
     rand logic signed [15:0] 	q_data_qam16;
     rand logic signed [15:0] 	i_data_qam64;
     rand logic signed [15:0] 	q_data_qam64;
  
     constraint qam4 {
	              i_data_qam4 != 0;
	              i_data_qam4 > -2;
	              i_data_qam4 < 2;
	              q_data_qam4 != 0;
	              q_data_qam4 > -2;
	              q_data_qam4 < 2;
     }

     constraint qam16 {
	              i_data_qam16 != 0;
	              i_data_qam16 > -3;
	              i_data_qam16 < 3;
	              q_data_qam16 != 0;
	              q_data_qam16 > -3;
	              q_data_qam16 < 3;
     }

     constraint qam64 {
	              i_data_qam64 != 0;
	              i_data_qam64 > -5;
	              i_data_qam64 < 5;
	              q_data_qam64 != 0;
	              q_data_qam64 > -5;
	              q_data_qam64 < 5;
     }
  
     
  endclass // rand_prbs

  class utils;
     static int 		write_count = 0;
  
  
    //  "r"	Open for reading
    //  "w"	Create for writing, overwrite if it exists
    //  "a"	Create if file does not exist, else append; open for writing at end of file
    //  "r+"	Open for update (reading and writing)
    //  "w+"	Truncate or create for update
    //  "a+"	Append, open or create for update at EOF
  
    static function void read_data(input string data_type, data_width, dec_places, is_signed);
       
       
       
    endfunction // read_data

    static function void writef16(input logic [15:0] arr[], string fname, string write_append);
       integer file;
       file = $fopen(fname, write_append);
       if(file == 0) begin
         $display("Error: could not open file\n");
         $finish;
       end
       
       foreach (arr[jj]) begin
          $display("JJ: %d, %p", jj, arr[jj]);
          $fwrite(file, "%b\n", arr[jj]);
          write_count++;
       end
    
       $fclose(file);
       
    endfunction

    static function void writef16_signed(input logic signed [15:0] arr[], string fname, string write_append);
       integer file;
       file = $fopen(fname, write_append);
       if(file == 0) begin
         $display("Error: could not open file\n");
         $finish;
       end
       
       foreach (arr[jj]) begin
          $display("JJ: %d, %p", jj, arr[jj]);
          $fwrite(file, "%b\n", arr[jj]);
          write_count++;
       end
    
       $fclose(file);
       
    endfunction
    
    static function void writeq(input logic [15:0] q[$], string fname, string write_append);
       integer file;
       file = $fopen(fname, write_append);
       if(file == 0) begin
         $display("Error: could not open file\n");
         $finish;
       end
       
       foreach (q[jj]) begin
          $display("JJ: %d, %p", jj, q[jj]);
          //$fwrite(file, "%b\n", q[jj]);
          $fwrite(file, "%d\n", q[jj]);	
          write_count++;
       end
    
       $fclose(file);
       
    endfunction

    static function void writeq_signed(input logic signed [15:0] q[$], string fname, string write_append);
       integer file;
       file = $fopen(fname, write_append);
       if(file == 0) begin
         $display("Error: could not open file\n");
         $finish;
       end
       
       foreach (q[jj]) begin
          $display("JJ: %d, %p", jj, q[jj]);
          //$fwrite(file, "%b\n", q[jj]);
          //$fwrite(file, "%d\n", q[jj]);
          $fwrite(file, "%f\n", $itor(q[jj])*(2**-14.0));		  
          write_count++;
       end
    
       $fclose(file);
       
    endfunction

    static function void writeq_signed_32(input logic signed [31:0] q[$], string fname, string write_append);
       integer file;
       file = $fopen(fname, write_append);
       if(file == 0) begin
         $display("Error: could not open file\n");
         $finish;
       end
       
       foreach (q[jj]) begin
          $display("JJ: %d, %p", jj, q[jj]);
          $display("JJ: %d, %b", jj, q[jj]);	  
          //$fwrite(file, "%b\n", q[jj]);
          //$fwrite(file, "%d\n", q[jj]);
          $fwrite(file, "%f\n", $itor(q[jj])*(2**-30.0));		  
          write_count++;
       end
    
       $fclose(file);
       
    endfunction
    
    static function void writeq_bit(input logic q[$], string fname, string write_append);
       integer file;
       file = $fopen(fname, write_append);
       if(file == 0) begin
         $display("Error: could not open file\n");
         $finish;
       end
       
       foreach (q[jj]) begin
          $display("JJ: %d, %p", jj, q[jj]);
          $fwrite(file, "%b\n", q[jj]);
          write_count++;
       end
    
       $fclose(file);
       
    endfunction // writeq_bit

     

//     static function automatic void print_fixed(input logic [0:$] a, input logic is_signed, integer word_bits, integer frac_bits);
//	$display("%f", $itor(a)*(2**-frac_bits));
//	
//     endfunction : print_fixed;
     
    
    static function void prbs_lfsrq(input logic [15:0] lfsr_poly_a, input integer seed, input integer len, ref logic q[$]);      
    
        logic [15:0] lfsr_ply = lfsr_poly_a;
        //lfsr_ply[15] = 0;
        //lfsr_ply[0] = 0;
        logic [15:0] tap_vals = seed;
        logic [15:0] tap_vals_next = tap_vals;
        $display("BIN: %b", tap_vals);      
        q.push_back(tap_vals[0]);
        for(int tt = 1; tt < len; tt++) begin
    	tap_vals_next[15] = tap_vals[0];
          for(int ii = 16-2; ii >= 0 ; ii--) begin
     	   if(lfsr_ply[ii] == 1'b1) begin
    	      tap_vals_next[ii] = tap_vals[0] ^ tap_vals[ii+1];
     	   end else begin
    	      tap_vals_next[ii] = tap_vals[ii+1];	      
    	   end
     	end
    	tap_vals = tap_vals_next;
    	$display("TAPS: %p", tap_vals);
          $display("BIN: %b", tap_vals);      	 
     	q.push_back(tap_vals[0]);
        end
    
    endfunction // prbs_lfsrq
    
    //static function void read_coeff(input integer num_cols,
    //			       input string  file_path, 
    //			       input string  file_name, 
    //			       ref real_q real_arr[]);
    //	 
    //
    //	 int file_id;
    //	 int num_read;
    //	 real real_tmp[4];
    //
    //	 file_id = $fopen({file_path,file_name}, "r");
    //	 if(file_id == 0) begin
    //	    $display("Error, file open error, file_path: %s, file_name: %s", file_path, file_name); //
    //	    $finish;
    //	 end
    //
    //	 while(!$feof(file_id)) begin
    //	   case(num_cols)
    //	     1: begin 
    //		//num_read = $fscanf(file_id, "%2.8f\n", real_tmp[0]);
    //		num_read = $fscanf(file_id, "%f\n", real_tmp[0]);
    //		real_arr[0].push_back(real_tmp[0]);
    //		end
    //	     2: begin 
    //		//num_read = $fscanf(file_id, "%2.8f %2.8f\n", real_tmp[0], real_tmp[1]);
    //		num_read = $fscanf(file_id, "%f,%f\n", real_tmp[0], real_tmp[1]);		
    //		real_arr[0].push_back(real_tmp[0]);
    //		real_arr[1].push_back(real_tmp[1]);		
    //		end
    //	     3: begin
    //		//num_read = $fscanf(file_id, "%2.8f %2.8f %2.8f\n", real_tmp[0], real_tmp[1], real_tmp[2]);
    //		num_read = $fscanf(file_id, "%f,%f,%f\n", real_tmp[0], real_tmp[1], real_tmp[2]);*		
    //		real_arr[0].push_back(real_tmp[0]);
    //		real_arr[1].push_back(real_tmp[1]);
    //		real_arr[2].push_back(real_tmp[2]);				
    //		end
    //	     4: begin
    //		//num_read = $fscanf(file_id, "%2.8f %2.8f %2.8f %2.8f\n", real_tmp[0], real_tmp[1], real_tmp[2], real_tmp[3]);
    //		num_read = $fscanf(file_id, "%f,%f,%f,%f\n", real_tmp[0], real_tmp[1], real_tmp[2], real_tmp[3]);		
    //		real_arr[0].push_back(real_tmp[0]);
    //		real_arr[1].push_back(real_tmp[1]);
    //		real_arr[2].push_back(real_tmp[2]);
    //		real_arr[3].push_back(real_tmp[3]);						
    //		end
    //	   default: begin 
    //	      //num_read = $fscanf(file_id, "%2.8f", real_tmp[0]);
    //	      num_read = $fscanf(file_id, "%f", real_tmp[0]);	      
    //	      real_arr[0].push_back(real_tmp[0]);	      
    //	      end
    //	   endcase // case (num_cols)
    //	    
    //	 end // while (!$feof(file_id))
    //
    //	 $fclose(file_id);
    //	 
    //endfunction
     
     
  endclass // utils
   
  `endif //  `ifndef utils

endpackage
    

    //static rand_class rand_bit = new();
    //
    //string msg1_16 = "My name is Jonas";
    //string msg2_16 = " Im carryin the ";
    //string msg3_16 = "will thanks for ";
    //string msg4_16 = "all ve shown us ";
    //
    //string msg1_64 = {msg1_16, msg2_16, msg3_16, msg4_16};
    //string msg1_128 = {msg1_64, msg1_64};      
    //string msg1_256 = {msg1_64, msg1_64, msg1_64, msg1_64};
    //string msg1_1024 = {msg1_256, msg1_256, msg1_256, msg1_256};
    //string msg1_4096 = {msg1_1024, msg1_1024, msg1_1024, msg1_1024};
    //
    //byte   msg_bytes[];
    //
    //logic  msg1_bits[1024]; 
    //logic  msg2_bits[1024]; 
    //logic  msg3_bits[1024]; 
    //logic  msg4_bits[1024]; 
    //logic  msg5_bits[1024]; 
    //logic  msg6_bits[1024]; 
    //logic  msg7_bits[1024]; 
    //logic  msg8_bits[1024];
    //
    //byte   rx_msg_bytes[];
    //logic  [7:0] msg_bits[];
    //logic  all_bits;
    //
    //string rx_msg_string[];
    //string unbounded;
    //msg_bits = new[msg1_128.len()];
    //
    //// Breakdown to bits
    //for (int ii = 0; ii < msg1_128.len(); ii++) begin
    //	 msg_bits[ii] = msg1_128[ii];
    //	 $display("Byte #: %d, Char val: %c, Bin val: %b\n", ii, msg1_128[ii], msg_bits[ii]);
    //end
    //
    //$display("Byte1 : %b\n", msg_bits[1]);
    //$display("Byte2 : %b\n", msg_bits[2]);
    //$display("Byte3 : %b\n", msg_bits[3]);
    //
    //rx_msg_string = new[128];
    //for (int ii = 0; ii < 128; ii++) begin
    //	 //rx_msg_string[ii] = msg_bits[ii];
    //	 //rx_msg_string[ii] = $sformatf("%0b", msg_bits[ii]);
    //	 rx_msg_string[ii] = $sformatf("%0c", msg_bits[ii]);
    //	 //unbounded = {unbounded, rx_msg_string[ii]};
    //	 unbounded = {unbounded, $sformatf("%0c", msg_bits[ii])};
    //end
    //
    //$display("Whole Message:\n %p", rx_msg_string);
    //$display("Whole Message:\n %s", unbounded);      
    
    //msg1_bits = msg1_128;      

    //for( int ii  = 0; ii < 128; ii++) begin
    //	 rx_msg_bytes[ii] = msg1_bits[ii+7:ii];
    //end
    //
    //for( int ii = 0; ii < 128; ii++) begin
    //	 rx_msg_string = {rx_msg_string, rx_msg_bytes[ii]};
    //end
    
    //$display("Your message: \n%s", msg1_4096);
    //$display("Your message: \n%s", msg1_4096);
   
