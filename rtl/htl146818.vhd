-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Unit          : HTL146818                                                 --
-- Library       : RTC                                                       --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;

entity HTL146818 is
   port( 
      abus         : in     std_logic_vector (5 downto 0);
      cen          : in     std_logic;
      clk          : in     std_logic;
      dbus_in      : in     std_logic_vector (7 downto 0);
      en_pulse_1hz : in     std_logic;
      osc1         : in     std_logic;
      pulse_1hz    : in     std_logic;
      resetn       : in     std_logic;
      rw           : in     std_logic;
      dbus_out     : out    std_logic_vector (7 downto 0);
      irq          : out    std_logic;
      sqw          : out    std_logic);
end HTL146818 ;

architecture struct of HTL146818 is

    signal aie        : std_logic;
    signal ampm       : std_logic;
    signal checkalarm : std_logic;
    signal clr_regc   : std_logic;
    signal cs_time    : std_logic;
    signal dbus_in2   : std_logic_vector(4 downto 0);
    signal dbus_in3   : std_logic_vector(5 downto 0);
    signal dbus_in4   : std_logic_vector(4 downto 0);
    signal dbus_out2  : std_logic_vector(7 downto 0);
    signal dbus_out3  : std_logic_vector(6 downto 0);
    signal dbus_out4  : std_logic_vector(7 downto 0);
    signal din        : std_logic_vector(7 downto 0);
    signal dm         : std_logic;
    signal dout       : std_logic_vector(7 downto 0);
    signal dout_mem   : std_logic_vector(7 downto 0);
    signal dse        : std_logic;
    signal dv         : std_logic_vector(2 downto 0);
    signal hour_alarm : std_logic_vector(7 downto 0);
    signal hours      : std_logic_vector(4 downto 0);
    signal iomux      : std_logic_vector(1 downto 0);
    signal leap_year  : std_logic;
    signal min_alarm  : std_logic_vector(7 downto 0);
    signal minutes    : std_logic_vector(5 downto 0);
    signal monthday   : std_logic_vector(5 downto 0);
    signal months     : std_logic_vector(3 downto 0);
    signal onehzpulse : std_logic;
    signal pie        : std_logic;
    signal rd_regcn   : std_logic;
    signal regA       : std_logic_vector(7 downto 0);
    signal regB       : std_logic_vector(7 downto 0);
    signal regC       : std_logic_vector(7 downto 0);
    signal regD       : std_logic_vector(7 downto 0);
    signal rs         : std_logic_vector(3 downto 0);
    signal sec_alarm  : std_logic_vector(7 downto 0);
    signal seconds    : std_logic_vector(5 downto 0);
    signal set        : std_logic;
    signal set_redge  : std_logic;
    signal setaf      : std_logic;
    signal setpf      : std_logic;
    signal setuf      : std_logic;
    signal sqwe       : std_logic;
    signal uie        : std_logic;
    signal uip        : std_logic;
    signal weekday    : std_logic_vector(2 downto 0);
    signal wr_time    : std_logic;
    signal years      : std_logic_vector(6 downto 0);


    signal irqf       : std_logic;
    signal pf         : std_logic;
    signal uf         : std_logic;
    signal af           : std_logic;

    component alarm
    port (
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
    end component;

    component bcd_2_bin
    port (
      din  : in     std_logic_vector (7 downto 0);
      dout : out    std_logic_vector (5 downto 0)
    );
    end component;

    component bcdpm_2_bin
    port (
      din  : in     std_logic_vector (7 downto 0);
      dout : out    std_logic_vector (4 downto 0)
    );
    end component;

    component bin_2_bcd
    port (
      din  : in     std_logic_vector (7 downto 0);
      dout : out    std_logic_vector (6 downto 0)
    );
    end component;

    component bin_2_bcdpm
    port (
      din  : in     std_logic_vector (7 downto 0);
      dout : out    std_logic_vector (7 downto 0)
    );
    end component;

    component bin_2_pmbin
    port (
      din  : in     std_logic_vector (7 downto 0);
      dout : out    std_logic_vector (7 downto 0)
    );
    end component;

    component binpm_2_bin
    port (
      din  : in     std_logic_vector (7 downto 0);
      dout : out    std_logic_vector (4 downto 0)
    );
    end component;
    component clock_gen
    port (
        clk          : in     std_logic;
        dv           : in     std_logic_vector (2 downto 0);
        en_pulse_1hz : in     std_logic;
        osc1         : in     std_logic;
        pulse_1hz    : in     std_logic;
        resetn       : in     std_logic;
        rs           : in     std_logic_vector (3 downto 0);
        sqwe         : in     std_logic;
        onehzpulse   : out    std_logic;
        setpf        : out    std_logic;
        sqw          : out    std_logic;
        uip          : out    std_logic
    );
    end component;
    component mem_block
    port (
        abus     : in     std_logic_vector (5 downto 0);
        cen      : in     std_logic;
        clk      : in     std_logic;
        din      : in     std_logic_vector (7 downto 0);
        rw       : in     std_logic;
        dout_mem : out    std_logic_vector (7 downto 0)
    );
    end component;
    component redge
    port (
        clk   : in     std_logic ;
        stbin : in     std_logic ;
        redge : out    std_logic 
    );
    end component;

    component timefsm
    port (
        abus       : in     std_logic_vector (5 downto 0);
        clk        : in     std_logic ;
        din        : in     std_logic_vector (7 downto 0);
        leap_year  : in     std_logic ;
        onehzpulse : in     std_logic ;
        resetn     : in     std_logic ;
        set        : in     std_logic ;
        wr_time    : in     std_logic ;
        checkalarm : out    std_logic ;
        hours      : out    std_logic_vector (4 downto 0);
        minutes    : out    std_logic_vector (5 downto 0);
        monthday   : out    std_logic_vector (5 downto 0);
        months     : out    std_logic_vector (3 downto 0);
        seconds    : out    std_logic_vector (5 downto 0);
        setuf      : out    std_logic ;
        weekday    : out    std_logic_vector (2 downto 0);
        years      : out    std_logic_vector (6 downto 0)
    );
    end component;

begin

       ---------------------------------------------------------------------------    
       -- Select between BIN or BCD type input
       -- 00 not writing to HOUR register, input is BIN (no conversion required)
       -- 01 writing to HOUR register in AM/PM mode, input it BIN, convert AM/PM BIN to BIN
       -- 10 not writing to HOUR register, input is BCD, convert BCD to BIN
       -- 11 writing to HOUR register in AM/PM mode, input is BCD, convert AM/PM BCD to BIN
       -- dbus_in(7 downto 6) are unmodified in case the user specifies a don't care value
       -- of 0xC0
       ---------------------------------------------------------------------------    
       process(iomux,dbus_in,dbus_in2,dbus_in3,dbus_in4)
           begin
               case iomux is
                   when "00"   => din <= dbus_in;
                   when "01"   => din <= dbus_in(7 downto 6) & '0' & dbus_in2;   
                   when "10"   => din <= dbus_in(7 downto 6) & dbus_in3;   
                   when others => din <= dbus_in(7 downto 6) & '0' & dbus_in4;
               end case;
       end process;

       ---------------------------------------------------------------------------    
       -- leap_lut 3                                        
       -- 2000, 2004, 2008, 2012, 2016, 2020, 2024, 2028, 2032, 2036, 2040, 2044, and 2048
       ---------------------------------------------------------------------------    
       leap_year<='1' when years(1 downto 0)="00" else '0';

       ---------------------------------------------------------------------------    
       -- SQW output selector
       ---------------------------------------------------------------------------    
       process (abus,seconds,sec_alarm,minutes,min_alarm,hours,hour_alarm,weekday,monthday,months,
               years,regA,regB,regC,regD,dout_mem)
           begin
               case abus is
                   when "000000"  => dout <= "00" & seconds;            
                   when "000001"  => dout <= sec_alarm;  
                   when "000010"  => dout <= "00" & minutes;
                   when "000011"  => dout <= min_alarm;
                   when "000100"  => dout <= "000" & hours;
                   when "000101"  => dout <= hour_alarm;
                   when "000110"  => dout <= "00000" & weekday;
                   when "000111"  => dout <= "00" & monthday;
                   when "001000"  => dout <= "0000" & months;
                   when "001001"  => dout <= '0' & years;
                   when "001010"  => dout <= regA;
                   when "001011"  => dout <= regB;
                   when "001100"  => dout <= regC;
                   when "001101"  => dout <= regD;
                   when others    => dout <= dout_mem;  
               end case;                                       
       end process;

       ---------------------------------------------------------------------------    
       -- Select between BIN or BCD type input
       -- 00 not writing to HOUR register, input is BIN (no conversion required)
       -- 01 writing to HOUR register in AM/PM mode, input it BIN, convert AM/PM BIN to BIN
       -- 10 not writing to HOUR register, input is BCD, convert BCD to BIN
       -- 11 writing to HOUR register in AM/PM mode, input is BCD, convert AM/PM BCD to BIN
       ---------------------------------------------------------------------------    
       process(iomux,dout,dbus_out2,dbus_out3,dbus_out4)
           begin
               case iomux is
                   when "00"   => dbus_out <= dout;
                   when "01"   => dbus_out <= dbus_out2;   
                   when "10"   => dbus_out <= '0'&dbus_out3;   
                   when others => dbus_out <= dbus_out4;
               end case;
       end process;

       ---------------------------------------------------------------------------    
       -- Time/Date registers 0 to 9
       ---------------------------------------------------------------------------    
       cs_time <= '1' when (abus<="001001" AND cen='0') else '0';
       wr_time <= '1' when (cs_time='1' and rw='0') else '0';
   
       ---------------------------------------------------------------------------    
       -- Read RegisterC, used to clear Interrupt flags, not active low
       ---------------------------------------------------------------------------    
       rd_regcn <= '0' when (abus="001100" AND cen='0' AND rw='1') else '1'; 
   
       ---------------------------------------------------------------------------    
       -- Input Select Multiplexer
       -- dm = binary/bcd select
       -- 00 not writing to HOUR register,           input is BIN, no conversion required
       -- 01 writing to HOUR register in AM/PM mode, input it BIN, convert AM/PM BIN to BIN
       -- 10 not writing to HOUR register,           input is BCD, convert BCD to BIN
       -- 11 writing to HOUR register in AM/PM mode, input is BCD, convert AM/PM BCD to BIN
       ---------------------------------------------------------------------------    
       iomux(0) <= '1' when ((abus="000100" or abus="000101") AND cen='0' AND ampm='0') else '0';
       iomux(1) <= '1' when (dm='0' and abus<="001001") else '0'; -- select BCD or BIN
   
       ---------------------------------------------------------------------------
       -- Control Register A
       -- All bit are R/W except bit7 UIP
       ---------------------------------------------------------------------------
       process (clk)                                    
           begin
               if (rising_edge(clk)) then 
                   if (cen='0' AND abus="001010" AND rw='0') then   
                       dv  <= dbus_in(6 downto 4);
                       rs  <= dbus_in(3 downto 0);
                   end if;       
               end if;   
       end process;
                                      
       ---------------------------------------------------------------------------
       -- Control Register B bits not affected by reset
       ---------------------------------------------------------------------------
       process (clk)                                    
           begin
               if (rising_edge(clk)) then 
                  if (cen='0' AND abus="001011" AND rw='0') then   
                       set <= dbus_in(7);                  -- set=1, update date/time regs    
                       dm  <= dbus_in(2);                  -- 1=BIN, 0=BCD  
                       ampm<= dbus_in(1);                  -- 1=24hour 0=AM/PM  
                       dse <= dbus_in(0);                  -- Not available on 146818     
                   end if;       
               end if;   
       end process;
   
       ---------------------------------------------------------------------------   
       -- Control Register B bits affected by reset
       ---------------------------------------------------------------------------    
       process (clk,resetn)                                    
           begin
               if resetn='0' then
                   pie <= '0';
                   aie <= '0';
                   sqwe<= '0';
               elsif (rising_edge(clk)) then 
                   if (cen='0' AND abus="001011" AND rw='0') then   
                       pie <= dbus_in(6);              -- 1=enable    
                       aie <= dbus_in(5);              -- 1=permit alarms  
                       sqwe<= dbus_in(3);              -- 1= enable sqw output       
                   end if;       
               end if;   
       end process;
   
      ---------------------------------------------------------------------------    
      -- UIE bit affected by reset and rising edge SET bit
      ---------------------------------------------------------------------------    
      process (clk,resetn)                                    
         begin
           if resetn='0' then
               uie <= '0';
           elsif (rising_edge(clk)) then 
               if set_redge='1' then           -- Rising edge when set bit is asserted
                   uie <= '0';
               elsif (cen='0' AND abus="001011" AND rw='0') then   
                   uie <= dbus_in(4);          -- 1=enable ended interrupt enable    
               end if;       
           end if;   
      end process;
   
      regA <= uip & dv & rs;                   -- Read back values of control regs A,B,C and D
      regB <= set & pie & aie & uie & sqwe & dm &ampm & dse;
      regC <= irqf & pf & af & uf &"0000";
      regD <= "10000000";                  -- VRT bit is always set.
   
       ---------------------------------------------------------------------------    
       -- Interrupt logic
       -- Create Alarm Flag AF, cleared by /rst and reading registerC
       ---------------------------------------------------------------------------    
       process (clk, resetn)        
           begin
               if (resetn='0') then
                  af <= '0';                
               elsif (rising_edge(clk)) then 
                   if (clr_regc='1') then       -- Reading regC
                       af<='0';
                   elsif setaf='1' then
                       af<='1';
                   end if;
               end if;    
       end process;
       
       ---------------------------------------------------------------------------    
       -- Create Periodic Flag PF, cleared by /rst and reading registerC
       ---------------------------------------------------------------------------    
       process (clk, resetn)        
           begin
               if (resetn='0') then
                  pf <= '0';                
               elsif (rising_edge(clk)) then 
                   if (clr_regc='1') then       -- Reading regC
                       pf<='0';
                   elsif setpf='1' then
                       pf<='1';
                   end if;
               end if;    
       end process;
       
       ---------------------------------------------------------------------------    
       -- Create Update Flag UF, cleared by /rst and reading registerC
       ---------------------------------------------------------------------------    
       process (clk, resetn)        
           begin
               if (resetn='0') then
                  uf <= '0';                
               elsif (rising_edge(clk)) then 
                   if (clr_regc='1') then       -- Reading regC
                       uf<='0';
                   elsif setuf='1' then
                       uf<='1';
                   end if;
               end if;    
       end process;
   
       irqf<= (pf AND pie) or (uf AND uie) or (af AND aie);
       irq <= not irqf;
   
   --    -- Create vrt flag, set by reading registerD, assume vrt FF powers up with a 0 (Actel not the case!)
   --    process (clk)        
   --        begin
   --            if (rising_edge(clk)) then 
   --                if (rd_regD='1') then       -- Reading regD
   --                    vrt<='1';
   --                end if;
   --            end if;    
   --    end process;


   -- Instance port mappings.
   U_8 : alarm
      port map (
         abus       => abus,
         checkalarm => checkalarm,
         clk        => clk,
         din        => din,
         hours      => hours,
         minutes    => minutes,
         resetn     => resetn,
         seconds    => seconds,
         wr_time    => wr_time,
         hour_alarm => hour_alarm,
         min_alarm  => min_alarm,
         sec_alarm  => sec_alarm,
         setaf      => setaf
      );
   U_6 : bcd_2_bin
      port map (
         din  => dbus_in,
         dout => dbus_in3
      );
   U_9 : bcdpm_2_bin
      port map (
         din  => dbus_in,
         dout => dbus_in4
      );
   U_0 : bin_2_bcd
      port map (
         din  => dout,
         dout => dbus_out3
      );
   U_1 : bin_2_bcdpm
      port map (
         din  => dout,
         dout => dbus_out4
      );
   U_5 : bin_2_pmbin
      port map (
         din  => dout,
         dout => dbus_out2
      );
   U_10 : binpm_2_bin
      port map (
         din  => dbus_in,
         dout => dbus_in2
      );
   U_3 : clock_gen
      port map (
         clk          => clk,
         dv           => dv,
         osc1         => osc1,
         resetn       => resetn,
         rs           => rs,
         sqwe         => sqwe,
         sqw          => sqw,
         uip          => uip,
         setpf        => setpf,
         onehzpulse   => onehzpulse,
         en_pulse_1hz => en_pulse_1hz,
         pulse_1hz    => pulse_1hz
      );
   U_2 : mem_block
      port map (
         abus     => abus,
         cen      => cen,
         din      => din,
         rw       => rw,
         dout_mem => dout_mem,
         clk      => clk
      );
   U_7 : redge
      port map (
         clk   => clk,
         stbin => set,
         redge => set_redge
      );
   U_11 : redge
      port map (
         clk   => clk,
         stbin => rd_regcn,
         redge => clr_regc
      );
   U_4 : timefsm
      port map (
         abus       => abus,
         clk        => clk,
         din        => din,
         leap_year  => leap_year,
         onehzpulse => onehzpulse,
         resetn     => resetn,
         set        => set,
         wr_time    => wr_time,
         checkalarm => checkalarm,
         hours      => hours,
         minutes    => minutes,
         monthday   => monthday,
         months     => months,
         seconds    => seconds,
         setuf      => setuf,
         weekday    => weekday,
         years      => years
      );

end struct;
