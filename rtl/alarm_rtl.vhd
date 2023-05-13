-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : AF (Alarm Flag) signal generator                          --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;

entity alarm is
   port( 
      abus       : in     std_logic_vector (5 downto 0);
      checkalarm : in     std_logic;
      clk        : in     std_logic;
      din        : in     std_logic_vector (7 downto 0);
      hours      : in     std_logic_vector (4 downto 0);
      minutes    : in     std_logic_vector (5 downto 0);
      resetn     : in     std_logic;
      seconds    : in     std_logic_vector (5 downto 0);
      wr_time    : in     std_logic;
      hour_alarm : out    std_logic_vector (7 downto 0);
      min_alarm  : out    std_logic_vector (7 downto 0);
      sec_alarm  : out    std_logic_vector (7 downto 0);
      setaf      : out    std_logic
   );
end alarm ;

architecture rtl of alarm is
    
    signal matchsec_s   : std_logic;
    signal matchmin_s   : std_logic;
    signal matchhr_s    : std_logic;

    signal sec_alarm_s  : std_logic_vector(7 downto 0);
    signal min_alarm_s  : std_logic_vector(7 downto 0);
    signal hr_alarm_s   : std_logic_vector(7 downto 0);

    signal checkalarm_d : std_logic_vector(4 downto 0); -- Check Alarm signal delayed 5 clk cycles

BEGIN

    process (clk,resetn)  
        begin
            if (resetn='0') then                     
                sec_alarm_s <=(others => '0');
                min_alarm_s <=(others => '0');
                hr_alarm_s  <=(others => '0');
                checkalarm_d<=(others => '0');
            elsif (rising_edge(clk)) then 
                if (wr_time='1' and abus(3 downto 0)="0001") then
                    sec_alarm_s<=din;
                end if;
                if (wr_time='1' and abus(3 downto 0)="0011") then
                    min_alarm_s<=din;
                end if;
                if (wr_time='1' and abus(3 downto 0)="0101") then
                    hr_alarm_s<=din;
                end if;
                checkalarm_d <= checkalarm_d(3 downto 0) & checkalarm; -- Delayed 5 clk cycle
            end if;   
    end process;
    sec_alarm  <= sec_alarm_s;                          -- Connect to outside world
    min_alarm  <= min_alarm_s;
    hour_alarm <= hr_alarm_s;

    
    matchsec_s <= '1' when (seconds=sec_alarm_s(5 downto 0) OR sec_alarm_s(7 downto 6)="11") else '0';
    matchmin_s <= '1' when (minutes=min_alarm_s(5 downto 0) OR min_alarm_s(7 downto 6)="11") else '0';
    matchhr_s  <= '1' when (hours  =hr_alarm_s(4 downto 0)  OR hr_alarm_s(7 downto 6)="11")  else '0';

    process (clk,resetn)  
        begin
            if (resetn='0') then                     
                setaf <= '0';                           -- /set or a read of registerC clears the Alarm Flag
            elsif (rising_edge(clk)) then 
                if (checkalarm_d(4)='1' and matchsec_s='1' and matchmin_s='1' and matchhr_s='1') then
                    setaf<='1';
                else 
                    setaf<='0';
                end if;  
            end if;   
    end process;
    
end architecture rtl;
