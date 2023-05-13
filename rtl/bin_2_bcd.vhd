-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Bin 2 BCD                                                 --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bin_2_bcd is
   port(din   : in  std_logic_vector(7 downto 0);
        dout  : out std_logic_vector(6 downto 0));
end bin_2_bcd;

architecture rtl of bin_2_bcd is

signal din_s : std_logic_vector(5 downto 0);

    begin
        din_s <= din(5 downto 0);       -- Ignore bit 6,7
        
        process(din_s)
            begin
                case din_s is
                    when "000000"  => dout <= "0000000";
                    when "000001"  => dout <= "0000001";
                    when "000010"  => dout <= "0000010";
                    when "000011"  => dout <= "0000011";
                    when "000100"  => dout <= "0000100";
                    when "000101"  => dout <= "0000101";
                    when "000110"  => dout <= "0000110";
                    when "000111"  => dout <= "0000111";
                    when "001000"  => dout <= "0001000";
                    when "001001"  => dout <= "0001001";
                    when "001010"  => dout <= "0010000";
                    when "001011"  => dout <= "0010001";
                    when "001100"  => dout <= "0010010";
                    when "001101"  => dout <= "0010011";
                    when "001110"  => dout <= "0010100";
                    when "001111"  => dout <= "0010101";
                    when "010000"  => dout <= "0010110";
                    when "010001"  => dout <= "0010111";
                    when "010010"  => dout <= "0011000";
                    when "010011"  => dout <= "0011001";
                    when "010100"  => dout <= "0100000";
                    when "010101"  => dout <= "0100001";
                    when "010110"  => dout <= "0100010";
                    when "010111"  => dout <= "0100011";
                    when "011000"  => dout <= "0100100";
                    when "011001"  => dout <= "0100101";
                    when "011010"  => dout <= "0100110";
                    when "011011"  => dout <= "0100111";
                    when "011100"  => dout <= "0101000";
                    when "011101"  => dout <= "0101001";
                    when "011110"  => dout <= "0110000";
                    when "011111"  => dout <= "0110001";
                    when "100000"  => dout <= "0110010";
                    when "100001"  => dout <= "0110011";
                    when "100010"  => dout <= "0110100";
                    when "100011"  => dout <= "0110101";
                    when "100100"  => dout <= "0110110";
                    when "100101"  => dout <= "0110111";
                    when "100110"  => dout <= "0111000";
                    when "100111"  => dout <= "0111001";
                    when "101000"  => dout <= "1000000";
                    when "101001"  => dout <= "1000001";
                    when "101010"  => dout <= "1000010";
                    when "101011"  => dout <= "1000011";
                    when "101100"  => dout <= "1000100";
                    when "101101"  => dout <= "1000101";
                    when "101110"  => dout <= "1000110";
                    when "101111"  => dout <= "1000111";
                    when "110000"  => dout <= "1001000";
                    when "110001"  => dout <= "1001001";
                    when "110010"  => dout <= "1010000";
                    when "110011"  => dout <= "1010001";
                    when "110100"  => dout <= "1010010";
                    when "110101"  => dout <= "1010011";
                    when "110110"  => dout <= "1010100";
                    when "110111"  => dout <= "1010101";
                    when "111000"  => dout <= "1010110";
                    when "111001"  => dout <= "1010111";
                    when "111010"  => dout <= "1011000";
                    when "111011"  => dout <= "1011001";
                    when others    => dout <= "-------";
                end case;
        end process;
end rtl;
