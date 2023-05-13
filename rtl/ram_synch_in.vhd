-------------------------------------------------------------------------------
--  Generic Memory Model                                                     --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Used to create 50 bytes of memory                         --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all ;
USE ieee.NUMERIC_STD.all;

entity ram_synch_in is
   generic (SYNCRDMEM : boolean := TRUE;
            d_width   : natural := 4;
            a_width   : natural := 8);
    port (clk       : in  std_logic;
          wre       : in  std_logic;
          din       : in  std_logic_vector(d_width-1 downto 0);
          abus      : in  std_logic_vector(a_width-1 downto 0);
          dout      : out std_logic_vector(d_width-1 downto 0));
end entity ;

architecture infer of ram_synch_in is
 
  type mem_type is array (2**a_width downto 0) of std_logic_vector(d_width - 1 downto 0);
  signal mem: mem_type ;

begin

    MEMSYNC: if SYNCRDMEM generate                      -- Generate Synchronous Read
        begin
            ram : process (clk)
                begin
                    if rising_edge(clk) then
                        if (wre = '1') then
                            mem(TO_INTEGER(UNSIGNED(abus))) <= din ;
                        end if ;
                        dout <= mem(TO_INTEGER(UNSIGNED(abus)));
                    end if;
            end process ram;
        end generate MEMSYNC;

    MEMASYNC: if NOT SYNCRDMEM generate                 -- Generate Asynchronous Read
        begin

            ram : process (clk)
                begin
                    if rising_edge(clk) then
                        if (wre = '1') then
                            mem(TO_INTEGER(UNSIGNED(abus))) <= din ;
                        end if ;
                    end if;
            end process ram;
            dout <= mem(TO_INTEGER(UNSIGNED(abus)));
    end generate MEMASYNC;

end architecture ;