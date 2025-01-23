
library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package beam_mux_pkg is

  constant AXIS_BYTE_WIDTH : natural := 4;
  constant N_DACS : natural := 3;
  constant BURST_MIN : integer := 1024;
  constant BURST_MAX : integer := 65536;

  
  --type axis is record
  --  tdata  : std_logic_vector((AXIS_BYTE_WIDTH*8)-1 downto 0);
  --  tvalid : std_logic;
  --  tready : std_logic;
  --  tlast  : std_logic;
  --end record axis;

  type axis_m2s is record
    tdata  : std_logic_vector((AXIS_BYTE_WIDTH*8)-1 downto 0);
    tvalid : std_logic;
    tlast  : std_logic;
  end record axis_m2s;

  type axis_s2m is record
    tready : std_logic;
  end record axis_s2m;
  
  --type axis_arr_m2s is array (0 to N_DACS-1) of axis_m2s;
  --type axis_arr_s2m is array (0 to N_DACS-1) of axis_s2m;

  function zero_rst_m2s return axis_m2s;
  

end package beam_mux_pkg;

package body beam_mux_pkg is

  function zero_rst_m2s return axis_m2s is
    variable zero_m2s : axis_m2s := (
      tdata => (others => '0'),
      tvalid => '0',
      tlast => '0'
      );
  begin
    return zero_m2s;
  end function zero_rst_m2s;

end package body beam_mux_pkg;

