-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Convert hour BCD input format to 24hour binary format     --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bcdpm_2_bin is
   port(din   : in  std_logic_vector(7 downto 0);
        dout  : out std_logic_vector(4 downto 0));
end bcdpm_2_bin;

architecture rtl of bcdpm_2_bin is
    begin
        process(din)
            begin
                case din is
                    when "00010010"  => dout <= "00000";    -- 12
                    when "00000001"  => dout <= "00001";
                    when "00000010"  => dout <= "00010";
                    when "00000011"  => dout <= "00011";
                    when "00000100"  => dout <= "00100";
                    when "00000101"  => dout <= "00101";
                    when "00000110"  => dout <= "00110";
                    when "00000111"  => dout <= "00111";
                    when "00001000"  => dout <= "01000";
                    when "00001001"  => dout <= "01001";
                    when "00010000"  => dout <= "01010";    -- 10
                    when "00010001"  => dout <= "01011";    -- 11
                    when "10010010"  => dout <= "01100";    -- 12 pm
                    when "10000001"  => dout <= "01101";    -- 1
                    when "10000010"  => dout <= "01110";
                    when "10000011"  => dout <= "01111";
                    when "10000100"  => dout <= "10000";
                    when "10000101"  => dout <= "10001";
                    when "10000110"  => dout <= "10010";
                    when "10000111"  => dout <= "10011";
                    when "10001000"  => dout <= "10100";
                    when "10001001"  => dout <= "10101";
                    when "10010000"  => dout <= "10110";    -- 10
                    when "10010001"  => dout <= "10111";    -- 11
                    when others      => dout <= "-----";
                end case;
        end process;
end rtl;
