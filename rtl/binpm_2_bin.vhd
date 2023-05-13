-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Convert hour binary input format to 24hour binary format  --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity binpm_2_bin is
   port(din   : in  std_logic_vector(7 downto 0);
        dout  : out std_logic_vector(4 downto 0));
end binpm_2_bin;

architecture rtl of binpm_2_bin is

signal din_s : std_logic_vector(5 downto 0);

    begin
        din_s <= din(7)&din(4 downto 0);        -- din(7)=pm/am indicator
        process(din_s)
            begin
                case din_s is
                    when "001100"  => dout <= "00000";
                    when "000001"  => dout <= "00001";
                    when "000010"  => dout <= "00010";
                    when "000011"  => dout <= "00011";
                    when "000100"  => dout <= "00100";
                    when "000101"  => dout <= "00101";
                    when "000110"  => dout <= "00110";
                    when "000111"  => dout <= "00111";
                    when "001000"  => dout <= "01000";
                    when "001001"  => dout <= "01001";
                    when "001010"  => dout <= "01010";
                    when "001011"  => dout <= "01011";
                    when "101100"  => dout <= "01100";
                    when "100001"  => dout <= "01101";
                    when "100010"  => dout <= "01110";
                    when "100011"  => dout <= "01111";
                    when "100100"  => dout <= "10000";
                    when "100101"  => dout <= "10001";
                    when "100110"  => dout <= "10010";
                    when "100111"  => dout <= "10011";
                    when "101000"  => dout <= "10100";
                    when "101001"  => dout <= "10101";
                    when "101010"  => dout <= "10110";
                    when "101011"  => dout <= "10111";
                    when others    => dout <= "-----";
                end case;
        end process;
end rtl;
