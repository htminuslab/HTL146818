-------------------------------------------------------------------------------
--  HTL146818 - RTC                                                          --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : RTC                                                       --
-- Unit          : timefsm                                                   --
-- Library       : I146818                                                   --
--                                                                           --
-- Version       : 0.1  08/12/2009   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity timefsm is
   port( 
      abus       : in     std_logic_vector (5 downto 0);
      clk        : in     std_logic;
      din        : in     std_logic_vector (7 downto 0);
      leap_year  : in     std_logic;
      onehzpulse : in     std_logic;
      resetn     : in     std_logic;
      set        : in     std_logic;
      wr_time    : in     std_logic;
      checkalarm : out    std_logic;
      hours      : out    std_logic_vector (4 downto 0);
      minutes    : out    std_logic_vector (5 downto 0);
      monthday   : out    std_logic_vector (5 downto 0);
      months     : out    std_logic_vector (3 downto 0);
      seconds    : out    std_logic_vector (5 downto 0);
      setuf      : out    std_logic;
      weekday    : out    std_logic_vector (2 downto 0);
      years      : out    std_logic_vector (6 downto 0)
   );

end timefsm ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.STD_LOGIC_UNSIGNED.all;
 
architecture fsm of timefsm is

   type state_type is (
      s0,
      s1,
      s2,
      s3,
      s4,
      s5,
      s6,
      s7
   );
 
   -- Declare current and next state signals
   signal current_state : state_type;
   signal next_state : state_type;

   -- Declare any pre-registered internal signals
   signal hours_cld : std_logic_vector (4 downto 0);
   signal minutes_cld : std_logic_vector (5 downto 0);
   signal monthday_cld : std_logic_vector (5 downto 0);
   signal months_cld : std_logic_vector (3 downto 0);
   signal seconds_cld : std_logic_vector (5 downto 0);
   signal weekday_cld : std_logic_vector (2 downto 0);
   signal years_cld : std_logic_vector (6 downto 0);

begin

   -----------------------------------------------------------------
   clocked_proc : process ( 
      clk,
      resetn
   )
   -----------------------------------------------------------------
   begin
      if (resetn = '0') then
         current_state <= s0;
         -- Default Reset Values
         hours_cld <= "01011";
         minutes_cld <= "011110";
         monthday_cld <= "011011";
         months_cld <= "0111";
         seconds_cld <= "111010";
         weekday_cld <= "001";
         years_cld <= "0001000";
      elsif (clk'event and clk = '1') then
         current_state <= next_state;

         -- Combined Actions
         case current_state is
            when s1 => 
               if wr_time='1' then
               case abus(3 downto 0) is
                  when "0000" => seconds_cld <= din(5 downto 0);
                  when "0010" => minutes_cld <= din(5 downto 0);
                  when "0100" => hours_cld <= din(4 downto 0);
                  when "0110" => weekday_cld<=din(2 downto 0);
                  when "0111" => monthday_cld <= din(5 downto 0);
                  when "1000" => months_cld <= din(3 downto 0);
                  when "1001" => years_cld <= din(6 downto 0);
                  when others => years_cld <= years_cld;
               end case;
               end if;
            when s2 => 
               seconds_cld<=seconds_cld+'1';
            when s3 => 
               seconds_cld<=(others=>'0');
               minutes_cld<=minutes_cld+'1';
            when s4 => 
               minutes_cld<=(others=>'0');
               hours_cld<=hours_cld+'1';
            when s5 => 
               hours_cld<=(others=>'0');
               monthday_cld<=monthday_cld+'1';
                -- Sunday=day1
               if (weekday_cld="111") then weekday_cld<="001";
                else weekday_cld<=weekday_cld+'1'; 
               end if;
            when s6 => 
               monthday_cld<="000001";
               months_cld<=months_cld+'1';
            when s7 => 
               months_cld<="0001";
               years_cld<=years_cld+'1';
            when others =>
               null;
         end case;
      end if;
   end process clocked_proc;
 
   -----------------------------------------------------------------
   nextstate_proc : process ( 
      current_state,
      hours_cld,
      leap_year,
      minutes_cld,
      monthday_cld,
      months_cld,
      onehzpulse,
      seconds_cld,
      set,
      wr_time
   )
   -----------------------------------------------------------------
   begin
      -- Default Assignment
      checkalarm <= '0';
      setuf <= '0';

      -- Combined Actions
      case current_state is
         when s0 => 
            if (wr_time='1') then 
               next_state <= s1;
            elsif (oneHzpulse='1' AND set='0') then 
               next_state <= s2;
            else
               next_state <= s0;
            end if;
         when s1 => 
            if (wr_time='0') then 
               next_state <= s0;
            else
               next_state <= s1;
            end if;
         when s2 => 
            checkalarm<='1';
            if (seconds_cld="111011") then 
               next_state <= s3;
            else
               setuf<='1';
               next_state <= s0;
            end if;
         when s3 => 
            if (minutes_cld="111011") then 
               next_state <= s4;
            else
               setuf<='1';
               next_state <= s0;
            end if;
         when s4 => 
            if (hours_cld="10111") then 
               next_state <= s5;
            else
               setuf<='1';
               next_state <= s0;
            end if;
         when s5 => 
            if ((monthday_cld="011111") OR
                (monthday_cld="011110" AND (months_cld="0100" OR months_cld="0110"
                OR months_cld="1001" OR months_cld="1011")) OR
                (monthday_cld="011101") OR
                (monthday_cld="011100" AND months_cld="0010" AND leap_year='0')) then 
               next_state <= s6;
            else
               setuf<='1';
               next_state <= s0;
            end if;
         when s6 => 
            if (months_cld="1100") then 
               next_state <= s7;
            else
               setuf<='1';
               next_state <= s0;
            end if;
         when s7 => 
            setuf<='1';
            next_state <= s0;
         when others =>
            next_state <= s0;
      end case;
   end process nextstate_proc;
 
   -- Concurrent Statements
   -- Clocked output assignments
   hours <= hours_cld;
   minutes <= minutes_cld;
   monthday <= monthday_cld;
   months <= months_cld;
   seconds <= seconds_cld;
   weekday <= weekday_cld;
   years <= years_cld;
end fsm;
