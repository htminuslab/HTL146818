-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Convert binary hour to BCD AM/PM format                   --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity bin_2_bcdpm is
   port(din   : in  std_logic_vector(7 downto 0);
        dout  : out std_logic_vector(7 downto 0));
end bin_2_bcdpm;

architecture rtl of bin_2_bcdpm is

signal din_s : std_logic_vector(4 downto 0);

    begin
    
        din_s <= din(4 downto 0);       
        process(din_s)
            begin
                case din_s is
                    when "00000"  => dout <= "00010010";    -- 12
                    when "00001"  => dout <= "00000001";
                    when "00010"  => dout <= "00000010";
                    when "00011"  => dout <= "00000011";
                    when "00100"  => dout <= "00000100";
                    when "00101"  => dout <= "00000101";
                    when "00110"  => dout <= "00000110";
                    when "00111"  => dout <= "00000111";
                    when "01000"  => dout <= "00001000";
                    when "01001"  => dout <= "00001001";
                    when "01010"  => dout <= "00010000";    -- 10
                    when "01011"  => dout <= "00010001";    -- 11
                    when "01100"  => dout <= "10010010";    -- 12 pm
                    when "01101"  => dout <= "10000001";    -- 1
                    when "01110"  => dout <= "10000010";
                    when "01111"  => dout <= "10000011";
                    when "10000"  => dout <= "10000100";
                    when "10001"  => dout <= "10000101";
                    when "10010"  => dout <= "10000110";
                    when "10011"  => dout <= "10000111";
                    when "10100"  => dout <= "10001000";
                    when "10101"  => dout <= "10001001";
                    when "10110"  => dout <= "10010000";    -- 10
                    when "10111"  => dout <= "10010001";    -- 11
                    when others   => dout <= "--------";
                end case;
        end process;
end rtl;
