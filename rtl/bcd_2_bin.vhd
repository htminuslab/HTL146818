-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : BCD input to BIN ROM File                                 --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bcd_2_bin is
   port(din   : in  std_logic_vector(7 downto 0);
        dout  : out std_logic_vector(5 downto 0));
end bcd_2_bin;

architecture rtl of bcd_2_bin is

signal din_s : std_logic_vector(6 downto 0);

    begin
        
        din_s <= din(6 downto 0);       -- Ignore bit 7

        process(din_s)
            begin
                case din_s is
                    when "0000000"  => dout <= "000000";
                    when "0000001"  => dout <= "000001";
                    when "0000010"  => dout <= "000010";
                    when "0000011"  => dout <= "000011";
                    when "0000100"  => dout <= "000100";
                    when "0000101"  => dout <= "000101";
                    when "0000110"  => dout <= "000110";
                    when "0000111"  => dout <= "000111";
                    when "0001000"  => dout <= "001000";
                    when "0001001"  => dout <= "001001";
                    when "0010000"  => dout <= "001010";
                    when "0010001"  => dout <= "001011";
                    when "0010010"  => dout <= "001100";
                    when "0010011"  => dout <= "001101";
                    when "0010100"  => dout <= "001110";
                    when "0010101"  => dout <= "001111";
                    when "0010110"  => dout <= "010000";
                    when "0010111"  => dout <= "010001";
                    when "0011000"  => dout <= "010010";
                    when "0011001"  => dout <= "010011";
                    when "0100000"  => dout <= "010100";
                    when "0100001"  => dout <= "010101";
                    when "0100010"  => dout <= "010110";
                    when "0100011"  => dout <= "010111";
                    when "0100100"  => dout <= "011000";
                    when "0100101"  => dout <= "011001";
                    when "0100110"  => dout <= "011010";
                    when "0100111"  => dout <= "011011";
                    when "0101000"  => dout <= "011100";
                    when "0101001"  => dout <= "011101";
                    when "0110000"  => dout <= "011110";
                    when "0110001"  => dout <= "011111";
                    when "0110010"  => dout <= "100000";
                    when "0110011"  => dout <= "100001";
                    when "0110100"  => dout <= "100010";
                    when "0110101"  => dout <= "100011";
                    when "0110110"  => dout <= "100100";
                    when "0110111"  => dout <= "100101";
                    when "0111000"  => dout <= "100110";
                    when "0111001"  => dout <= "100111";
                    when "1000000"  => dout <= "101000";
                    when "1000001"  => dout <= "101001";
                    when "1000010"  => dout <= "101010";
                    when "1000011"  => dout <= "101011";
                    when "1000100"  => dout <= "101100";
                    when "1000101"  => dout <= "101101";
                    when "1000110"  => dout <= "101110";
                    when "1000111"  => dout <= "101111";
                    when "1001000"  => dout <= "110000";
                    when "1001001"  => dout <= "110001";
                    when "1010000"  => dout <= "110010";
                    when "1010001"  => dout <= "110011";
                    when "1010010"  => dout <= "110100";
                    when "1010011"  => dout <= "110101";
                    when "1010100"  => dout <= "110110";
                    when "1010101"  => dout <= "110111";
                    when "1010110"  => dout <= "111000";
                    when "1010111"  => dout <= "111001";
                    when "1011000"  => dout <= "111010";
                    when "1011001"  => dout <= "111011";
                    when others     => dout <= "------";
                end case;
        end process;
end rtl;
