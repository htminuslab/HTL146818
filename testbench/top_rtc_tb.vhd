-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Unit          : top_rtc_tb                                                --
-- Library       : I146818                                                   --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity HTL146818_tb is
end HTL146818_tb ;

architecture struct of HTL146818_tb is

   signal abus     : std_logic_vector(5 downto 0);
   signal alarm    : std_logic;
   signal cen      : std_logic;
   signal clk      : std_logic;
   signal clredge  : std_logic;
   signal dbus_in  : std_logic_vector(7 downto 0);
   signal dbus_out : std_logic_vector(7 downto 0);
   signal dout     : std_logic;
   signal dout1    : std_logic;
   signal dout2    : std_logic;
   signal irq      : std_logic;
   signal mux      : std_logic_vector(1 downto 0);
   signal osc1     : std_logic;
   signal reset    : std_logic;
   signal resetn   : std_logic;
   signal rflag    : std_logic;
   signal rw       : std_logic;
   signal sqw      : std_logic;
   signal time     : std_logic;

   signal mw_U_3clk : std_logic;

signal osc1_s : std_logic:='0';

   component HTL146818
   port (
      abus         : in     std_logic_vector (5 downto 0);
      cen          : in     std_logic ;
      clk          : in     std_logic ;
      dbus_in      : in     std_logic_vector (7 downto 0);
      en_pulse_1hz : in     std_logic ;
      osc1         : in     std_logic ;
      pulse_1hz    : in     std_logic ;
      resetn       : in     std_logic ;
      rw           : in     std_logic ;
      dbus_out     : out    std_logic_vector (7 downto 0);
      irq          : out    std_logic ;
      sqw          : out    std_logic 
   );
   end component;

   component edge_flag
   generic (
      RESVAL : std_logic := '0'
   );
   port (
      clk        : in     std_logic ;
      clredge_in : in     std_logic ;
      reset      : in     std_logic ;
      strobe_in  : in     std_logic ;
      fedge      : out    std_logic ;
      fflag      : out    std_logic ;
      redge      : out    std_logic ;
      rflag      : out    std_logic 
   );
   end component;

   component top_rtc_tester
   port (
      clk      : in     std_logic ;
      dbus_out : in     std_logic_vector (7 downto 0);
      irq      : in     std_logic ;
      rflag    : in     std_logic ;
      sqw      : in     std_logic ;
      abus     : out    std_logic_vector (5 downto 0);
      cen      : out    std_logic ;
      clredge  : out    std_logic ;
      dbus_in  : out    std_logic_vector (7 downto 0);
      mux      : out    std_logic_vector (1 downto 0);
      resetn   : out    std_logic ;
      rw       : out    std_logic 
   );
   end component;


begin

   osc1_s <= not osc1_s after 15258.7890625 ns; -- 32.768KHz 
   osc1   <= osc1_s;
   alarm  <= '0';
   time   <='0';  

   u_3clk_proc: process
   begin
      loop
         mw_U_3clk <= '0', '1' after 1.67 us;
         wait for 3.33 us;
      end loop;
      wait;
   end process u_3clk_proc;
   clk <= mw_U_3clk;

   dout1 <= '0';
   dout2 <= '0';
   reset <= not(resetn);

   u_4combo_proc: process(sqw, irq, alarm, time, mux)
   begin
      case mux is
      when "00" => dout <= sqw;
      when "01" => dout <= irq;
      when "10" => dout <= alarm;
      when "11" => dout <= time;
      when others => dout <= 'X';
      end case;
   end process u_4combo_proc;

   U_0 : HTL146818
      port map (
         abus         => abus,
         cen          => cen,
         clk          => clk,
         dbus_in      => dbus_in,
         en_pulse_1hz => dout2,
         osc1         => osc1,
         pulse_1hz    => dout1,
         resetn       => resetn,
         rw           => rw,
         dbus_out     => dbus_out,
         irq          => irq,
         sqw          => sqw
      );
   U_2 : edge_flag
      generic map (
         RESVAL => '0'
      )
      port map (
         clk        => clk,
         clredge_in => clredge,
         reset      => reset,
         strobe_in  => dout,
         fedge      => open,
         fflag      => open,
         redge      => open,
         rflag      => rflag
      );
   U_1 : top_rtc_tester
      port map (
         clk      => clk,
         dbus_out => dbus_out,
         irq      => irq,
         rflag    => rflag,
         sqw      => sqw,
         abus     => abus,
         cen      => cen,
         clredge  => clredge,
         dbus_in  => dbus_in,
         mux      => mux,
         resetn   => resetn,
         rw       => rw
      );

end struct;
