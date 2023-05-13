-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Purpose       : Clock and SQW Generator                                   --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 0.1  27/07/2002   Created HT-LAB                          --
--               : 1.0  20/07/2013   Updated OSC1 Clock Divider              --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
-- 32768Hz Time Base only                                                    --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;

entity clock_gen is
   port( 
      clk          : in     std_logic;
      dv           : in     std_logic_vector (2 downto 0);
      osc1         : in     std_logic;
      resetn       : in     std_logic;
      rs           : in     std_logic_vector (3 downto 0);
      sqwe         : in     std_logic;
      sqw          : out    std_logic;
      uip          : out    std_logic;
      setpf        : out    std_logic;
      onehzpulse   : out    std_logic;
      en_pulse_1hz : in     std_logic;
      pulse_1hz    : in     std_logic);
end clock_gen ;

architecture rtl of clock_gen is


    component redge3ff
        port(clk        : in     std_logic;
             ena        : in     std_logic;
             stbin      : in     std_logic;
             stbout     : out    std_logic;
             redge      : out    std_logic);
    end component;

    component redge
        port(clk        : in     std_logic;
             stbin      : in     std_logic;
             redge      : out    std_logic);
    end component;

    signal div_reset_s  : std_logic;                -- Divider sync reset signal
    signal ena_osc1_s   : std_logic;                -- Enable OSC1
    signal osc1pulse_s  : std_logic;                -- Rising edge of clk32768
    
    signal onehzpulse_s : std_logic;               

    signal sqw_s        : std_logic;

    signal div32768_s   : unsigned(15 downto 0);    -- Divider for oneHzpulse
    signal div1Hzclk_s  : std_logic;                -- Internale Divider generated one Hz clock
    signal div1Hzpulse_s: std_logic;                -- Internal Divider generated one Hz pulse

BEGIN

    -- Dual FF MetaStability synchroniser Rising_edge clk pulse output  
    META1 : redge3ff
        PORT MAP (
            clk     => clk,
            ena     => ena_osc1_s,
            stbin   => osc1,
            stbout  => OPEN,
            redge   => osc1pulse_s
        );
    
    -- Rising_edge Detector for Periodic Interrupt  
    EDGE1 : redge
        PORT MAP (
            clk     => clk,
            stbin   => sqw_s,
            redge   => setpf                            -- Periodic interrupt set signal
        );

    -- Rising_edge Detector for one second pulse 
    EDGE2 : redge 
        PORT MAP (
            clk     => clk,
            stbin   => div1Hzclk_s,
            redge   => div1Hzpulse_s
        );


    ---------------------------------------------------------------------------
    -- Select between internal generated One Hz Pulse (div1Hzpulse_s) or external one (pulse_1hz). 
    -- Note that the external generated pulse_1hz should have a period equal to the
    -- system clock 'clk'.
    ---------------------------------------------------------------------------
    onehzpulse_s <= pulse_1hz when en_pulse_1hz='1' else div1Hzpulse_s;  
    onehzpulse   <= onehzpulse_s;

    ---------------------------------------------------------------------------
    -- Keep dividers in reset when DV2..0 = 110 or 111 or onehzpulse_s is asserted
    -- Note the onehzpulse_s signal was added incase an external pulse_1hz signal
    -- is used. In this case the counter needs to be synchronised to this signal
    -- inorder for the UIP signal to be asserted at the right time.
    ---------------------------------------------------------------------------
    div_reset_s<='1' when (dv(2 downto 1)="11" or onehzpulse_s='1') else '0';
    -- OSC1 is enable only when DV2..0=010
    ena_osc1_s<='1' when dv="010" else '0';

    ---------------------------------------------------------------------------
    -- n-stage divider to create 1Hz pulse and SQW output signals
    ---------------------------------------------------------------------------
    process (clk,resetn)  
        begin
            if resetn='0' then                     
                div32768_s <= (others => '0'); 
            elsif (rising_edge(clk)) then 
                if div_reset_s='1' then
                    div32768_s <= (others => '0');
                elsif osc1pulse_s='1' then  
                    div32768_s <= div32768_s + 1;
                end if;  
            end if;   
    end process;

    ---------------------------------------------------------------------------
    -- SQW output selector
    ---------------------------------------------------------------------------
    process (rs,div32768_s)
        begin
            case rs is
                when "0000"  => sqw_s <= '0';            -- No output
                when "0001"  => sqw_s <= div32768_s(8);  -- 256Hz
                when "0010"  => sqw_s <= div32768_s(9);  -- 128Hz  
                when "0011"  => sqw_s <= div32768_s(3);  -- 8KHz  
                when "0100"  => sqw_s <= div32768_s(4);  -- 4KHz  
                when "0101"  => sqw_s <= div32768_s(5);  -- 2KHz  
                when "0110"  => sqw_s <= div32768_s(6);  -- 1KHz  
                when "0111"  => sqw_s <= div32768_s(7);  -- 512Hz  
                when "1000"  => sqw_s <= div32768_s(8);  -- 256Hz  
                when "1001"  => sqw_s <= div32768_s(9);  -- 128Hz  
                when "1010"  => sqw_s <= div32768_s(10); -- 64Hz  
                when "1011"  => sqw_s <= div32768_s(11); -- 32Hz  
                when "1100"  => sqw_s <= div32768_s(12); -- 16Hz  
                when "1101"  => sqw_s <= div32768_s(13); -- 8Hz  
                when "1110"  => sqw_s <= div32768_s(14); -- 4Hz  
                when others  => sqw_s <= div32768_s(15); -- 2Hz  
            end case;                                       
    end process;

    div1Hzclk_s<=div32768_s(15);


    ---------------------------------------------------------------------------
    -- 244us before oneHzpulse signal the UIP bit should be set. 
    -- 244us is 4096Hz thus 32768-4096 is the counter value to act on.
    -- Note that if OSC1 is derived from an external divider then make
    -- sure the counter is always running slightly faster. This will result
    -- in UIP to occur earlier than 244us before the update cycle. If you make 
    -- the counter running slower then in the worst case the UIP is never set.
    ---------------------------------------------------------------------------
    process (clk,resetn)
        begin
            if resetn='0' then                     
                uip <= '0';                           
            elsif (rising_edge(clk)) then 
                if div32768_s=X"7FF8" then              -- reset when oneHzpulse=1
                    uip<='1';                           -- 244us before update set UIP flag
                elsif oneHzpulse_s='1' then             -- Note : can use pulse_1hz signal!
                    uip <= '0';
                end if;  
            end if;   
    end process;

    ---------------------------------------------------------------------------
    -- Output SQW pin controlled by SQWE
    -- Output FF required??
    ---------------------------------------------------------------------------
    process (clk,resetn)
        begin
            if resetn='0' then                     
                sqw <= '0'; 
            elsif (rising_edge(clk)) then 
                if sqwe='1' then
                    sqw<=sqw_s;
                end if;  
            end if;   
    end process;

end architecture rtl;
