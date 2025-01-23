
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
--use ieee.math_complex.all;
use ieee.math_real.all;
use work.beam_mux_pkg.all;

entity beam_mux is

  generic (
    --N_BEAM_MUX_DACS : natural := work.beam_mux_pkg.N_DACS
    N_BEAM_MUX_DACS : natural := 4
    );

  port (
    clk : in std_logic;
    rst : in std_logic;
    
    dac_sel : in std_logic_vector(1 downto 0);
    mod_t_data : in std_logic_vector(31 downto 0);
    mod_t_valid : in std_logic;
    mod_t_ready : out std_logic;
    mod_t_last  : in std_logic;
    
    dac1_t_data : out std_logic_vector(31 downto 0);
    dac1_t_valid : out std_logic;
    
    dac2_t_data : out std_logic_vector(31 downto 0);
    dac2_t_valid : out std_logic;
    
    dac3_t_data : out std_logic_vector(31 downto 0);
    dac3_t_valid : out std_logic
    );

end entity beam_mux;

architecture behav of beam_mux is

  COMPONENT axis_data_fifo_0
    PORT (
      s_axis_aresetn : IN STD_LOGIC;
      s_axis_aclk : IN STD_LOGIC;
      s_axis_tvalid : IN STD_LOGIC;
      s_axis_tready : OUT STD_LOGIC;
      s_axis_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axis_tlast : IN STD_LOGIC;
      m_axis_tvalid : OUT STD_LOGIC;
      m_axis_tready : IN STD_LOGIC;
      m_axis_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_tlast : OUT STD_LOGIC;
      axis_wr_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      axis_rd_data_count : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      almost_empty : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC 
    );
  END COMPONENT;

  constant N_FIFOS : integer := 4;
  type axis_arr_m2s is array (0 to N_DACS-1) of axis_m2s;
  type axis_arr_s2m is array (0 to N_DACS-1) of axis_s2m;
  type axis is record
    m : axis_arr_m2s;
    s : axis_arr_s2m;
  end record axis;
  
  type axis_arr is array (0 to N_DACS-1) of axis;

  signal dac_arr : axis_arr_m2s;
  signal rx_fifo_sel : unsigned(1 downto 0) := "00";
  signal tx_fifo_sel : unsigned(1 downto 0) := "00";
  signal fifo_cnt : unsigned(1 downto 0) := "00";
  signal tx_ready_en : std_logic_vector(N_FIFOS-1 downto 0) := "0000";
  signal tx_ready_en_r : std_logic_vector(N_FIFOS-1 downto 0) := "0000";  
  
  subtype s_axis_tdata_arr_sub is STD_LOGIC_VECTOR(31 DOWNTO 0);
  subtype axis_wr_data_count_arr_sub is STD_LOGIC_VECTOR(31 DOWNTO 0);  
  subtype m_axis_tdata_arr_sub is STD_LOGIC_VECTOR(31 DOWNTO 0);  
  subtype axis_rd_data_count_arr_sub is STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  type s_axis_aresetn_arr      is array (0 to N_FIFOS-1) of STD_LOGIC;
  type s_axis_aclk_arr         is array (0 to N_FIFOS-1) of STD_LOGIC;
  type s_axis_tvalid_arr       is array (0 to N_FIFOS-1) of STD_LOGIC;
  type s_axis_tready_arr       is array (0 to N_FIFOS-1) of STD_LOGIC;
  type s_axis_tdata_arr        is array (0 to N_FIFOS-1) of s_axis_tdata_arr_sub;  
  type s_axis_tlast_arr        is array (0 to N_FIFOS-1) of STD_LOGIC;
  type m_axis_tvalid_arr       is array (0 to N_FIFOS-1) of STD_LOGIC;
  type m_axis_tready_arr       is array (0 to N_FIFOS-1) of STD_LOGIC;
  type m_axis_tdata_arr        is array (0 to N_FIFOS-1) of m_axis_tdata_arr_sub;
  type m_axis_tlast_arr        is array (0 to N_FIFOS-1) of STD_LOGIC;
  type axis_wr_data_count_arr  is array (0 to N_FIFOS-1) of axis_wr_data_count_arr_sub;  
  type axis_rd_data_count_arr  is array (0 to N_FIFOS-1) of axis_rd_data_count_arr_sub;  
  type almost_empty_arr        is array (0 to N_FIFOS-1) of STD_LOGIC;
  type almost_full_arr         is array (0 to N_FIFOS-1) of STD_LOGIC;

  signal s_axis_aresetn     : s_axis_aresetn_arr      := (others => '0');
  signal s_axis_aclk        : s_axis_aclk_arr         := (others => '0');
  signal s_axis_tvalid      : s_axis_tvalid_arr       := (others => '0');
  signal s_axis_tready      : s_axis_tready_arr       := (others => '0');
  signal s_axis_tdata       : s_axis_tdata_arr        := (others => (others => '0'));
  signal s_axis_tlast       : s_axis_tlast_arr        := (others => '0');
  signal m_axis_tvalid      : m_axis_tvalid_arr       := (others => '0');
  signal m_axis_tready      : m_axis_tready_arr       := (others => '0');
  signal m_axis_tdata       : m_axis_tdata_arr        := (others => (others => '0'));
  signal m_axis_tlast       : m_axis_tlast_arr        := (others => '0');
  signal axis_wr_data_count : axis_wr_data_count_arr  := (others => (others => '0'));
  signal axis_rd_data_count : axis_rd_data_count_arr  := (others => (others => '0'));
  signal almost_empty       : almost_empty_arr        := (others => '0');
  signal almost_full        : almost_full_arr         := (others => '0');

  signal s_axis_aresetn_2     : s_axis_aresetn_arr      := (others => '0');
  signal s_axis_aclk_2        : s_axis_aclk_arr         := (others => '0');
  signal s_axis_tvalid_2      : s_axis_tvalid_arr       := (others => '0');
  signal s_axis_tready_2      : s_axis_tready_arr       := (others => '0');
  signal s_axis_tdata_2       : s_axis_tdata_arr        := (others => (others => '0'));
  signal s_axis_tlast_2       : s_axis_tlast_arr        := (others => '0');
  signal m_axis_tvalid_2      : m_axis_tvalid_arr       := (others => '0');
  signal m_axis_tready_2      : m_axis_tready_arr       := (others => '0');
  signal m_axis_tdata_2       : m_axis_tdata_arr        := (others => (others => '0'));
  signal m_axis_tlast_2       : m_axis_tlast_arr        := (others => '0');
  signal axis_wr_data_count_2 : axis_wr_data_count_arr  := (others => (others => '0'));
  signal axis_rd_data_count_2 : axis_rd_data_count_arr  := (others => (others => '0'));
  signal almost_empty_2       : almost_empty_arr        := (others => '0');
  signal almost_full_2        : almost_full_arr         := (others => '0');

  signal dac_round_robin_sel : unsigned(1 downto 0) := "00";
  signal dac_sel_r : unsigned(1 downto 0) := "00";
  signal dac_sel_locked : unsigned(1 downto 0) := "00";
  
begin

  gen_fifos : for ii in 0 to N_FIFOS-1 generate
    
    stage1_fifo : axis_data_fifo_0
    PORT MAP (
      s_axis_aresetn       => not rst,
      s_axis_aclk          => clk,
      s_axis_tvalid        => s_axis_tvalid(ii),
      s_axis_tready        => s_axis_tready(ii),
      s_axis_tdata         => s_axis_tdata(ii),
      s_axis_tlast         => s_axis_tlast(ii), 
      m_axis_tvalid        => m_axis_tvalid(ii),
      m_axis_tready        => m_axis_tready(ii) or tx_ready_en(ii), -- needed for
                                                                -- worst case
      m_axis_tdata         => m_axis_tdata(ii),
      m_axis_tlast         => m_axis_tlast(ii),
      axis_wr_data_count   => axis_wr_data_count(ii),
      axis_rd_data_count   => axis_rd_data_count(ii),
      almost_empty         => almost_empty(ii),
      almost_full          => almost_full(ii)
      );

   stage2_fifo : axis_data_fifo_0
    PORT MAP (
      s_axis_aresetn       => not rst,
      s_axis_aclk          => clk,
      s_axis_tvalid        => m_axis_tvalid(ii),
      s_axis_tready        => m_axis_tready(ii),        
      s_axis_tdata         => m_axis_tdata(ii),         
      s_axis_tlast         => m_axis_tlast(ii),         
      m_axis_tvalid        => m_axis_tvalid_2(ii),      
      m_axis_tready        => m_axis_tready_2(ii),      
      m_axis_tdata         => m_axis_tdata_2(ii),       
      m_axis_tlast         => m_axis_tlast_2(ii),       
      axis_wr_data_count   => axis_wr_data_count_2(ii), 
      axis_rd_data_count   => axis_rd_data_count_2(ii), 
      almost_empty         => almost_empty_2(ii),       
      almost_full          => almost_full_2(ii)         
      );

  end generate gen_fifos;
  

  tx_burst : process(clk)
  begin
    if rising_edge(clk) then

      if rst = '1' then
        
        tx_ready_en <= (others => '0');
        tx_ready_en_r <= (others => '0');        
        rx_fifo_sel <= "00";
        tx_fifo_sel <= "00";
        dac_sel_r <= "00";
        dac_round_robin_sel <= "00";
        fifo_cnt <= "00";
        dac1_t_data <= (others => '0');
        dac2_t_data <= (others => '0');
        dac3_t_data <= (others => '0');
        dac1_t_valid <= '0';
        dac2_t_valid <= '0';
        dac3_t_valid <= '0';



        -- Flush during reset, requires sustained reset
        mod_t_ready <= '0';        
        for ii in 0 to N_FIFOS-1 loop
          m_axis_tready_2(ii) <= '1';
        end loop;

      else

        -- Drive AXI S protocol to receiving fifo
        s_axis_tvalid(to_integer(rx_fifo_sel)) <= mod_t_valid;
        mod_t_ready <= s_axis_tready(to_integer(rx_fifo_sel));
        s_axis_tdata(to_integer(rx_fifo_sel)) <= mod_t_data;
        s_axis_tlast(to_integer(rx_fifo_sel)) <= mod_t_last;

        -- Assign axi stream values to signals not indexed with receiving fifo
        -- index
        for ii in 0 to N_FIFOS-1 loop

          --Type indexing quark btween custom arrays and std_logic_vector, just
          --connnecting them
          m_axis_tready_2(ii) <= tx_ready_en(ii);

          --update tlast that is not currently receiving
          if ii /= to_integer(rx_fifo_sel) then
            s_axis_tvalid(ii) <= '0';
            s_axis_tlast(ii)  <= '0';
          end if;

         end loop;

        -- Capture tlast
        tx_ready_en(to_integer(rx_fifo_sel)) <= tx_ready_en(to_integer(rx_fifo_sel));
        if mod_t_last = '1' then
          if fifo_cnt /= "10" then
            tx_ready_en(to_integer(rx_fifo_sel)) <= '1';
            rx_fifo_sel <= rx_fifo_sel + 1;
          else
            rx_fifo_sel <= rx_fifo_sel;
            tx_ready_en(to_integer(rx_fifo_sel)) <= '0';
            mod_t_ready <= '0';
          end if;
        end if;

        -- release tlast, re-apply backpressure
        if m_axis_tlast_2(to_integer(tx_fifo_sel)) = '1' then
          tx_ready_en(to_integer(tx_fifo_sel)) <= '0';
          tx_fifo_sel <= tx_fifo_sel + 1;
        end if;

        -- 
        dac_sel_r <= unsigned(dac_sel);
        if dac_sel_r /= "00" and dac_sel = "00"  then
          dac_round_robin_sel <= (others => '0');
        elsif dac_sel_r = "00" and dac_sel = "00" then
          dac_round_robin_sel <= dac_round_robin_sel;
          if dac_round_robin_sel = "11" then
            dac_round_robin_sel <= (others => '0');
          end if;
        else 
          dac_round_robin_sel <= unsigned(dac_sel);
        end if;

        -- Lock dac select to current burst
        tx_ready_en_r <= tx_ready_en;        
        --tx_ready_en_r(to_integer(tx_fifo_sel)) <= tx_ready_en(to_integer(tx_fifo_sel));
        if tx_ready_en_r(to_integer(tx_fifo_sel)) = '0' and tx_ready_en(to_integer(tx_fifo_sel)) = '1' then
          if dac_sel = "00" then
            dac_sel_locked <= dac_round_robin_sel;
            dac_round_robin_sel <= dac_round_robin_sel + 1;
          else
            dac_sel_locked <= unsigned(dac_sel);
          end if;
        elsif tx_ready_en_r(to_integer(tx_fifo_sel)) = '1' and tx_ready_en(to_integer(tx_fifo_sel)) = '1' then
          dac_sel_locked <= dac_sel_locked;
        else
          dac_sel_locked <= unsigned(dac_sel);          
        end if;

        -- Drive data to all dacs, however, only validate selected
        dac1_t_data <= m_axis_tdata_2(to_integer(tx_fifo_sel));
        dac2_t_data <= m_axis_tdata_2(to_integer(tx_fifo_sel));
        dac3_t_data <= m_axis_tdata_2(to_integer(tx_fifo_sel));


        -- Default all to zero
        -- Decode which of the 3 dacs is valid based on fifo with valid data,
        -- and the locked dac_sel
        dac1_t_valid <= '0';
        dac2_t_valid <= '0';
        dac3_t_valid <= '0';
        case tx_ready_en(to_integer(tx_fifo_sel)) & dac_sel_locked is
          when "100" => dac1_t_valid <= '1';
          when "101" => dac2_t_valid <= '1';
          when "110" => dac3_t_valid <= '1';
          when others => null;
        end case;
        
      end if;
    end if;
    
  end process tx_burst;

end architecture behav;





