-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Module to create 50byte of SSRAM                          --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;

entity mem_block is
   port( 
      abus     : in     std_logic_vector (5 downto 0);
      cen      : in     std_logic;
      din      : in     std_logic_vector (7 downto 0);
      rw       : in     std_logic;
      dout_mem : out    std_logic_vector (7 downto 0);
      clk      : in     std_logic);
end mem_block ;

architecture rtl of mem_block is

   signal wrn16     : std_logic;
   signal wrn32     : std_logic;

   signal dout16    : std_logic_vector(7 downto 0);
   signal dout32    : std_logic_vector(7 downto 0);

   signal memloc14  : std_logic_vector(7 downto 0);
   signal memloc15  : std_logic_vector(7 downto 0);

   component ram_synch_in
      generic (
         SYNCRDMEM : boolean := TRUE;
         d_width   : natural := 4;
         a_width   : natural := 8
      );
      port (
         clk  : in     std_logic;
         wre  : in     std_logic;
         din  : in     std_logic_vector(d_width-1 downto 0);
         abus : in     std_logic_vector(a_width-1 downto 0);
         dout : out    std_logic_vector(d_width-1 downto 0)
      );
   end component;

begin

    ---------------------------------------------------------------------------
    -- Create 50 bytes of synchronous memory
    ---------------------------------------------------------------------------
    process (clk)
        begin
            if rising_edge(clk) then
                if (cen='0' AND abus="001110" AND rw='0') then
                    memloc14 <= din ;
                end if;
                if (cen='0' AND abus="001111" AND rw='0') then
                    memloc15 <= din ;
                end if ;
            end if;
    end process;


    ---------------------------------------------------------------------------
    --  16x8
    ---------------------------------------------------------------------------
    wrn16 <= '1' when (cen='0' AND abus(5 downto 4)="01" AND rw='0') else '0';
    MEM1 : ram_synch_in
        generic map (SYNCRDMEM=>TRUE, d_width => 8,a_width => 4)
          port map (
             clk  => clk,
             wre  => wrn16,
             din  => din,
             abus => abus(3 downto 0),
             dout => dout16
          );
    
    ---------------------------------------------------------------------------
    -- 32x8
    ---------------------------------------------------------------------------
    wrn32 <= '1' when (cen='0' AND abus(5)='1' AND rw='0') else '0';
    MEM2 : ram_synch_in
        generic map (SYNCRDMEM=>TRUE,d_width => 8,a_width => 5)
            port map (
               clk  => clk,
               wre  => wrn32,
               din  => din,
               abus => abus(4 downto 0),
               dout => dout32
            );

    process (abus,memloc14,memloc15,dout16,dout32)
        begin
            case abus is
                when "001110"  => dout_mem <= memloc14;            
                when "001111"  => dout_mem <= memloc15; 
                when "010000"  => dout_mem <= dout16;
                when "010001"  => dout_mem <= dout16;
                when "010010"  => dout_mem <= dout16;
                when "010011"  => dout_mem <= dout16;
                when "010100"  => dout_mem <= dout16;
                when "010101"  => dout_mem <= dout16; 
                when "010110"  => dout_mem <= dout16;
                when "010111"  => dout_mem <= dout16;
                when "011000"  => dout_mem <= dout16;
                when "011001"  => dout_mem <= dout16;
                when "011010"  => dout_mem <= dout16;
                when "011011"  => dout_mem <= dout16;
                when "011100"  => dout_mem <= dout16;
                when "011101"  => dout_mem <= dout16;
                when "011110"  => dout_mem <= dout16;
                when "011111"  => dout_mem <= dout16;
                when others    => dout_mem <= dout32;  
            end case;                                       
    end process;


end architecture rtl;
