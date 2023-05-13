-------------------------------------------------------------------------------
--  HTL146818 - 146818 compatible Real Time Clock IP core                    --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : HTL146818                                                 --
-- Unit          : Tester File                                               --
-- Library       : I146818                                                   --
--                                                                           --
-- Version       : 1.0  27/07/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
--                 Note requires Modelsim SignalSpy Library                  --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY std;
USE std.TEXTIO.all;

library modelsim_lib;
use modelsim_lib.util.all;



entity top_rtc_tester is
   port( 
      clk      : in     std_logic;
      dbus_out : in     std_logic_vector (7 downto 0);
      irq      : in     std_logic;
      rflag    : in     std_logic;
      sqw      : in     std_logic;
      abus     : out    std_logic_vector (5 downto 0);
      cen      : out    std_logic;
      clredge  : out    std_logic;
      dbus_in  : out    std_logic_vector (7 downto 0);
      mux      : out    std_logic_vector (1 downto 0);
      resetn   : out    std_logic;
      rw       : out    std_logic
   );
end top_rtc_tester ;

--
architecture behaviour of top_rtc_tester is

signal data_s : std_logic_vector(7 downto 0);
signal abus_s : std_logic_vector(5 downto 0);
signal regb_s : std_logic_vector(7 downto 0);
signal time_s : std_logic_vector(23 downto 0);
signal date_s : std_logic_vector(23 downto 0);

signal min_alarm_s  : std_logic_vector(7 downto 0);
signal minutes_s    : std_logic_vector(5 downto 0);
signal monthday_s   : std_logic_vector(5 downto 0);
signal months_s     : std_logic_vector(3 downto 0);
signal hour_alarm_s : std_logic_vector(7 downto 0);
signal hours_s      : std_logic_vector(4 downto 0);
signal sec_alarm_s  : std_logic_vector(7 downto 0);
signal seconds_s    : std_logic_vector(5 downto 0);
signal weekday_s    : std_logic_vector(2 downto 0);
signal years_s      : std_logic_vector(6 downto 0);

signal onehzpulse_s : std_logic;
signal errorflag    : std_logic:='0';

begin
    
    process                                             -- Modelsim's Signal Spy
        begin
            init_signal_spy("/htl146818_tb/u_0/min_alarm","/htl146818_tb/u_1/min_alarm_s",0,1); 
            init_signal_spy("/htl146818_tb/u_0/minutes","/htl146818_tb/u_1/minutes_s",0,1); 
            init_signal_spy("/htl146818_tb/u_0/monthday","/htl146818_tb/u_1/monthday_s",0,1);   
            init_signal_spy("/htl146818_tb/u_0/months","/htl146818_tb/u_1/months_s",0,1);    
            init_signal_spy("/htl146818_tb/u_0/hour_alarm","/htl146818_tb/u_1/hour_alarm_s",0,1);
            init_signal_spy("/htl146818_tb/u_0/hours","/htl146818_tb/u_1/hours_s",0,1);     
            init_signal_spy("/htl146818_tb/u_0/sec_alarm","/htl146818_tb/u_1/sec_alarm_s",0,1); 
            init_signal_spy("/htl146818_tb/u_0/seconds","/htl146818_tb/u_1/seconds_s",0,1);   
            init_signal_spy("/htl146818_tb/u_0/weekday","/htl146818_tb/u_1/weekday_s",0,1);   
            init_signal_spy("/htl146818_tb/u_0/years","/htl146818_tb/u_1/years_s",0,1);    

            init_signal_spy("/htl146818_tb/u_0/onehzpulse","/htl146818_tb/u_1/onehzpulse_s",0,1);     
            wait;
    end process;

    
    process
        variable l        : line;
        variable t1,t2,td : time;

        procedure writemem(                             -- write byte to memory   
            signal addr_p : in std_logic_vector(5 downto 0);-- Address
            signal dbus_p : in std_logic_vector(7 downto 0)) is 
            begin 
                wait until rising_edge(clk);
                abus <= addr_p;
                cen  <= '0';
                wait for 5 ns;
                wait until rising_edge(clk);
                wait for 3 ns;
                dbus_in <= dbus_p;
                wait for 10 ns;
                rw  <= '0';
                wait until rising_edge(clk);
                wait until rising_edge(clk);
                wait for 130 ns;
                abus  <= (others => '1');
                rw  <= '1';
                cen  <= '1';
                dbus_in <= (others=>'1');
                wait for 1 ns;
        end writemem;

        procedure readmem(                              -- Read from memory   
            signal addr_p : in std_logic_vector(5 downto 0);-- Address
            signal dbus_p : out std_logic_vector(7 downto 0)) is 
            begin 
                wait until rising_edge(clk);
                abus <= addr_p;
                cen  <= '0';
                wait for 5 ns;
                wait until rising_edge(clk);
                wait for 3 ns;
                rw  <= '1';
                wait for 2 ns;
                wait until rising_edge(clk);                
                wait until rising_edge(clk);
                dbus_p<= dbus_out;
                wait for 130 ns;
                abus <= (others => '1');
                cen  <= '1';
                wait for 1 ns;
        end readmem;

        -- Set regb_s value before calling this routine
        procedure writetime(                            -- write HOURS:MIN:SECONDS to memory   
            signal time_p : in std_logic_vector(23 downto 0)) is -- HOURS:MIN:SECONDS
            begin 
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='1';
                writemem(abus_s,regb_s);                -- Disable Updates
                 
                abus_s <= "000000";                     -- Write Seconds
                writemem(abus_s,time_p(7 downto 0));            
                abus_s <= "000010";                     -- Write minutes
                writemem(abus_s,time_p(15 downto 8));            
                abus_s <= "000100";                     -- Write hours
                writemem(abus_s,time_p(23 downto 16));       
                
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='0';
                writemem(abus_s,regb_s);                -- Renable Updates
        end writetime;

        procedure writealarm(                           -- write HOURS:MIN:SECONDS to memory   
            signal time_p : in std_logic_vector(23 downto 0)) is -- HOURS:MIN:SECONDS
            begin 
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='1';
                writemem(abus_s,regb_s);                -- Disable Updates
                 
                abus_s <= "000001";                     -- Write Alarm Seconds
                writemem(abus_s,time_p(7 downto 0));            
                abus_s <= "000011";                     -- Write Alarm minutes
                writemem(abus_s,time_p(15 downto 8));            
                abus_s <= "000101";                     -- Write Alarm hours
                writemem(abus_s,time_p(23 downto 16));       
                
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='0';
                writemem(abus_s,regb_s);                -- Renable Updates
        end writealarm;


        procedure readtime(                             -- return HOURS:MIN:SECONDS   
            signal time_p : out std_logic_vector(23 downto 0)) is -- HOURS:MIN:SECONDS
            begin 
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='1';
                writemem(abus_s,regb_s);                -- Disable Updates
                 
                abus_s <= "000000";                     -- Read Seconds
                readmem(abus_s,time_p(7 downto 0));            
                abus_s <= "000010";                     -- Read minutes
                readmem(abus_s,time_p(15 downto 8));            
                abus_s <= "000100";                     -- Read hours
                readmem(abus_s,time_p(23 downto 16));       
                
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='0';
                writemem(abus_s,regb_s);                -- Renable Updates
        end readtime;

        -- Set regb_s value before calling this routine
        procedure writedate(                            -- write YEAR:MONTH:DAY to memory   
            signal date_p : in std_logic_vector(23 downto 0)) is -- HOURS:MIN:SECONDS
            begin 
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='1';
                writemem(abus_s,regb_s);                -- Disable Updates
                 
                abus_s <= "000111";                     -- Write Day og Month
                writemem(abus_s,date_p(7 downto 0));            
                abus_s <= "001000";                     -- Write Month
                writemem(abus_s,date_p(15 downto 8));            
                abus_s <= "001001";                     -- Write Year
                writemem(abus_s,date_p(23 downto 16));       
                
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='0';
                writemem(abus_s,regb_s);                -- Renable Updates
        end writedate;

        procedure readdate(                             -- return YEAR:MONTH:DAY   
            signal date_p : out std_logic_vector(23 downto 0)) is -- HOURS:MIN:SECONDS
            begin 
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='1';
                writemem(abus_s,regb_s);                -- Disable Updates
                 
                abus_s <= "000111";                     -- Read Day
                readmem(abus_s,date_p(7 downto 0));            
                abus_s <= "001000";                     -- Read Month
                readmem(abus_s,date_p(15 downto 8));            
                abus_s <= "001001";                     -- Read Year
                readmem(abus_s,date_p(23 downto 16));       
                
                abus_s <= "001011";                     -- Write to RegisterB
                regb_s(7)<='0';
                writemem(abus_s,regb_s);                -- Renable Updates
        end readdate;

        procedure wait_n_rising_edge_clk(               -- wait for n clk edges   
            constant n : in integer) is 
            begin 
                for i in 1 to n loop
                    wait until rising_edge(clk);
                end loop;
        end wait_n_rising_edge_clk;


        begin

            dbus_in  <= (others => '1');
            abus     <= (others => '1');
            cen      <= '1';
            rw       <= '1';
            resetn   <= '0';
            mux      <= (others => '0');
            clredge  <= '0';
 

            wait for 100 ns;
            resetn   <= '1';
            wait for 1 ms;
            
            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00100001";                       -- DV2:0=010 enable OSC1, RS3:0=0001=256Hz 
            writemem(abus_s,data_s);            
            
            abus_s <= "001011";                         -- Write to RegisterB
            data_s <= "00000110";                       -- Select BIN format, sqw disabled
            writemem(abus_s,data_s);


            --------------------------------------------------------------------
            -- Check worst update cycle duration
            --------------------------------------------------------------------
            regb_s <= "00000110";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"173B3B";                        -- 23:59:59
            writetime(time_s);

            date_s <= X"080C1F";                        -- Dec31
            writedate(date_s);
            
            wait until rising_edge(oneHzpulse_s);



            wait for 40 ms;

            -- *****************************************************************
            -- * Check a few values
            -- *****************************************************************
            write(L,string'("1) Checking Square Wave Output"));
            writeline(output,L);
            errorflag<='0';                             -- Clear flag

            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00100001";                       -- DV2:0=010 enable OSC1, RS3:0=0001=256Hz 
            writemem(abus_s,data_s);            

            abus_s <= "001011";                         -- Write to RegisterB
            data_s <= "00001110";                       -- sqw enabled
            writemem(abus_s,data_s);

            wait until rising_edge(sqw);
            wait until rising_edge(sqw);
            t1:=now;                                    -- start time
            wait until rising_edge(sqw);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("Divider set to 256Hz(3.9ms) Time="));
            write(L,td);
--            if (td=3906090 ns) then write(L,string'(" *** PASS ***"));
--                               else write(L,string'(" *** FAIL ***")); 
--                                    errorflag<='1';
--            end if;
            writeline(output,L);

            -- -----------------------------------------------------------------

            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00100011";                       -- DV2:0=010 enable OSC1, RS3:08KHz 
            writemem(abus_s,data_s);            

            wait for 10 ms;

            wait until rising_edge(sqw);
            wait until rising_edge(sqw);
            t1:=now;                                    -- start time
            wait until rising_edge(sqw);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("Divider set to 8192Hz(122us) Time="));
            write(L,td);
--            if (td=119880 ns) then write(L,string'(" *** PASS ***"));
--                              else write(L,string'(" *** FAIL ***"));
--                                   errorflag<='1';
--            end if;
            writeline(output,L);
            
            -- -----------------------------------------------------------------
            
            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00101001";                       -- DV2:0=010 enable OSC1, RS3:0=128Hz 
            writemem(abus_s,data_s);            
        
            wait for 10 ms;

            wait until rising_edge(sqw);
            wait until rising_edge(sqw);
            t1:=now;                                    -- start time
            wait until rising_edge(sqw);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("Divider set to 128Hz(7.8ms) Time="));
            write(L,td);
--            if (td=7812180 ns) then write(L,string'(" *** PASS ***"));
--                               else write(L,string'(" *** FAIL ***"));
--                                    errorflag<='1';
--            end if;
            writeline(output,L);


            -- -----------------------------------------------------------------
            -- Check no output
            -- Select sqw output, clear edge, wait and check flag
            -- -----------------------------------------------------------------
            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00100000";                       -- DV2:0=010 enable OSC1, RS3:0=disabled 
            writemem(abus_s,data_s);            
        
            mux    <= "00";                             -- select sqw input to edge detector
            clredge<= '1';                              -- clear flag
            wait for 100 ns;
            clredge<= '0';

            wait for 500 ms;

            write(L,string'("Divider set to no output"));
            if (rflag='0') then write(L,string'(" *** PASS ***"));
                           else write(L,string'(" *** FAIL ***"));
                                errorflag<='1';
            end if;
            writeline(output,L);

            wait until rising_edge(onehzpulse_s);

            -- -----------------------------------------------------------------
            -- Check first update (oneHzpulse_s) after DV2:0=RESET should
            -- be 0.5 seconds (note 146818=1sec)
            -- -----------------------------------------------------------------
            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "01100000";                       -- UIP-DV2:0=110=RESET, enable OSC1, RS3:0=disabled 
            writemem(abus_s,data_s);            
            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00100000";                       -- UIP-DV2:0=010=run, enable OSC1, RS3:0=disabled 
            writemem(abus_s,data_s);            
            
            t1:=now;                                    -- start time
            wait until rising_edge(onehzpulse_s);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("First update after DV2:0=110 is = "));
            write(L,td);
            writeline(output,L);


            assert errorflag='0' report "Error Detected, test failed" severity failure;
            
            -- *****************************************************************
            -- * Set the Time in BIN, wait then check the time
            -- *****************************************************************
            write(L,string'("2) Checking Time/Clock Output in BIN mode"));
            writeline(output,L);

            regb_s <= "00001110";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"173B3A";                        -- 23:59:58
            writetime(time_s);
            
            wait until rising_edge(oneHzpulse_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait 2 seconds, then check time

            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 23:59:58 + 2 seconds = "));       
            if (time_s=X"000000") then write(L,string'("00:00:00 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); 
                                       errorflag<='1';
            end if;
            writeline(output,L);

            -- *****************************************************************
            -- * Set the Time in BCD, wait then check the time
            -- *****************************************************************
            write(L,string'("3) Checking Time/Clock Output in BCD mode"));
            writeline(output,L);

            regb_s <= "10001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"235958";                        -- 23:59:58  BCD mode!
            writetime(time_s);
            
            wait until rising_edge(oneHzpulse_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait 2 seconds, then check time

            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 23:59:58 + 2 seconds = "));       
            if (time_s=X"000000") then write(L,string'("00:00:00 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); 
                                       errorflag<='1';
            end if;
            writeline(output,L);

            assert errorflag='0' report "Error Detected, test failed" severity failure;


            -- *****************************************************************
            -- * Check 24hour to AM/PM conversion 
            -- *****************************************************************
            write(L,string'("4) Checking 24hour to AM/PM conversion"));
            writeline(output,L);
            
            wait until rising_edge(oneHzpulse_s);       -- just for syncing

            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"001030";                        -- 24HOUR 0:10 -> 0:10AM BCD mode
            writetime(time_s);

            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 00:10:30 = "));       
            if (time_s=X"121030") then write(L,string'("12:10:30 AM *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ----------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"101030";                        -- 24HOUR 10:10 -> 10:10AM BCD mode
            writetime(time_s);

            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 10:10:30 = "));       
            if (time_s=X"101030") then write(L,string'("10:10:30 AM *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            -- ----------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"121030";                        -- 24HOUR 12:10 -> 12:10PM BCD mode
            writetime(time_s);

            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 12:10:30 = "));       
            if (time_s=X"921030") then write(L,string'("12:10:30 PM *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ----------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"131030";                        -- 24HOUR 13:10 -> 1:10PM BCD mode
            writetime(time_s);

            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 13:10:30 = "));       
            if (time_s=X"811030") then write(L,string'("01:10:30 PM *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ----------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"231030";                        -- 24HOUR 23:10 -> 11:10PM BCD mode
            writetime(time_s);

            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 23:10:30 = "));       
            if (time_s=X"911030") then write(L,string'("11:10:30 PM *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);



            -- *****************************************************************
            -- * Check AM/PM to 24 hour conversion 
            -- *****************************************************************
            write(L,string'("5) Checking AM/PM to 24hour conversion"));
            writeline(output,L);
            
            wait until rising_edge(oneHzpulse_s);       -- just for syncing

            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"121030";                        -- 12:10AM -> 0:10 BCD mode
            writetime(time_s);

            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 12:10:30AM = "));       
            if (time_s=X"001030") then write(L,string'("00:10:30 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ----------------------------------------------------------------
            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"101030";                        -- 10:10AM -> 10:10 BCD mode
            writetime(time_s);

            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 10:10:30AM = "));       
            if (time_s=X"101030") then write(L,string'("10:10:30 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            -- ----------------------------------------------------------------
            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"921030";                        -- 12:10PM -> 12:10 BCD mode
            writetime(time_s);

            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 12:10:30PM = "));       
            if (time_s=X"121030") then write(L,string'("12:10:30 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ----------------------------------------------------------------
            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"831030";                        -- 03:10PM -> 15:10 BCD mode
            writetime(time_s);

            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 03:10:30PM = "));       
            if (time_s=X"151030") then write(L,string'("15:10:30 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ----------------------------------------------------------------
            regb_s <= "00001000";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"901030";                        -- 10:10:30 -> 22:10:30PM BCD mode
            writetime(time_s);

            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            write(L,string'("Checking Time 10:10:30PM = "));       
            if (time_s=X"221030") then write(L,string'("22:10:30 *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            -- *****************************************************************
            -- * Check for leap years 
            -- *****************************************************************
            write(L,string'("6) Check for leap year"));
            writeline(output,L);
            
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);

            date_s <= X"080228";                        -- Feb28 2008, leapyear, next date is Feb29
            writedate(date_s);

            wait until rising_edge(oneHzpulse_s);       -- Wait one second

            readdate(date_s);                           -- Check the date

            write(L,string'("Checking Leap Year 28-Feb-2007 -> 29-Feb-2008  "));       
            if (date_s=X"080229") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- ------------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);

            date_s <= X"070228";                        -- Feb28 2007, not a leapyear, next date is Feb29
            writedate(date_s);

            wait until rising_edge(oneHzpulse_s);       -- Wait one second

            readdate(date_s);                           -- Check the date

            write(L,string'("Checking None Leap Year 28-Feb-2007 -> 01-March-2007  "));       
            if (date_s=X"070301") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            -- *****************************************************************
            -- * Check dates 
            -- *****************************************************************
            write(L,string'("7) Checking calender month"));
            writeline(output,L);
            
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);

            date_s <= X"080130";                        -- Jan30 -> Jan31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date

            write(L,string'("Checking Jan30 -> Jan31  "));       
            if (date_s=X"080131") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080330";                        -- March30 -> March31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Mar30 -> Mar31  "));       
            if (date_s=X"080331") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080430";                        -- April30 -> June01
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Apr30 -> Jun01  "));       
            if (date_s=X"080501") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080530";                        -- April30 -> June01
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking May30 -> May31  "));       
            if (date_s=X"080531") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080630";                        -- June30 -> July01
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Jun30 -> Jul01  "));       
            if (date_s=X"080701") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080730";                        -- July30 -> July31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Jul30 -> Jul31  "));       
            if (date_s=X"080731") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080830";                        -- Aug30 -> Aug31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Aug30 -> Aug31  "));       
            if (date_s=X"080831") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"080930";                        -- Sept30 -> Oct01
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Sep30 -> Oct01  "));       
            if (date_s=X"081001") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"081030";                        -- Oct30 -> Oct31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Oct30 -> Oct31  "));       
            if (date_s=X"081031") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);


            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"081130";                        -- Nov30 -> Dec31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Nov30 -> Dec01  "));       
            if (date_s=X"081201") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"081230";                        -- Dec30 -> Dec31
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Dec30 -> Dec31  "));       
            if (date_s=X"081231") then write(L,string'(" *** PASS ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            time_s <= X"235959";                        -- BCD mode, 24 hour
            writetime(time_s);
            date_s <= X"081231";                        -- Dec31 -> Jan01
            writedate(date_s);
            wait until rising_edge(oneHzpulse_s);       -- Wait one second
            readdate(date_s);                           -- Check the date
            write(L,string'("Checking Dec31 -> Jan01  "));       
            if (date_s=X"090101") then write(L,string'(" *** PASS, HAPPY NEW YEAR ***"));
                                  else write(L,string'(" *** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);

            -- *****************************************************************
            -- * Check Alarm function 
            -- *****************************************************************
            write(L,string'("8) Checking Alarm function"));
            writeline(output,L);
            
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"010203";                        -- BCD mode, 24 hour
            writetime(time_s);

            time_s <= X"010205";                        -- set Alarm 2 seconds later
            writealarm(time_s);

            abus_s <= "001100";                         -- Read Status regC to clear any previous AF's
            readmem(abus_s,data_s);            

            write(L,string'("Waiting for Alarm "));       

            wait until rising_edge(oneHzpulse_s);       -- Wait one second, 010204
            wait_n_rising_edge_clk(7);                  -- Delay required for AF flag to propagate
                                                        -- Worst case is 7 clk cycles.

            abus_s <= "001100";                         -- Read Status regC, check b5=AF
            readmem(abus_s,data_s);            
            if (data_s(5)='1') then 
                write(L,string'(" *** FAIL, AF set to early ***"));
                errorflag<='1';                         -- AF prematurely set
            else 
                wait until rising_edge(oneHzpulse_s);   -- Wait one second, 010205
                wait_n_rising_edge_clk(7);              -- Delay required for AF flag to propagate

                abus_s <= "001100";                     -- Read Status regC, check b5=AF
                readmem(abus_s,data_s);            
                if (data_s(5)='1') then 
                    write(L,string'(" *** PASS ***"));
                else 
                    write(L,string'(" *** FAIL, AF not set ***"));
                    errorflag<='1';                      -- AF prematurely set
                end if;
            end if;
            writeline(output,L);


            -- -----------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"010258";                        -- BCD mode, 24 hour
            writetime(time_s);

            time_s <= X"010300";                        -- set Alarm 2 seconds later
            writealarm(time_s);

            abus_s <= "001100";                         -- Read Status regC to clear any previous AF's
            readmem(abus_s,data_s);            

            write(L,string'("Waiting for Alarm "));       

            wait until rising_edge(oneHzpulse_s);       -- Wait one second, 010204
            wait_n_rising_edge_clk(7);                  -- Delay required for AF flag to propagate
            
            abus_s <= "001100";                         -- Read Status regC, check b5=AF
            readmem(abus_s,data_s);            
            if (data_s(5)='1') then 
                write(L,string'(" *** FAIL, AF set to early ***"));
                errorflag<='1';                         -- AF prematurely set
            else 
                wait until rising_edge(oneHzpulse_s); -- Wait one second, 010205
                wait_n_rising_edge_clk(7);              -- Delay required for AF flag to propagate

                abus_s <= "001100";                     -- Read Status regC, check b5=AF
                readmem(abus_s,data_s);            
                if (data_s(5)='1') then 
                    write(L,string'(" *** PASS ***"));
                else 
                    write(L,string'(" *** FAIL, AF not set ***"));
                    errorflag<='1';                     -- AF prematurely set
                end if;
            end if;
            writeline(output,L);

            -- -----------------------------------------------------------------
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"235958";                        -- BCD mode, 24 hour
            writetime(time_s);

            time_s <= X"000000";                        -- set Alarm 2 seconds later
            writealarm(time_s);

            abus_s <= "001100";                         -- Read Status regC to clear any previous AF's
            readmem(abus_s,data_s);            

            write(L,string'("Waiting for Alarm "));       

            wait until rising_edge(oneHzpulse_s);       -- Wait one second, 010204
            wait_n_rising_edge_clk(7);                  -- Delay required for AF flag to propagate

            abus_s <= "001100";                         -- Read Status regC, check b5=AF
            readmem(abus_s,data_s);            
            if (data_s(5)='1') then 
                write(L,string'(" *** FAIL, AF set to early ***"));
                errorflag<='1';                         -- AF prematurely set
            else 
                wait until rising_edge(oneHzpulse_s); -- Wait one second, 010205
                wait_n_rising_edge_clk(7);              -- Delay required for AF flag to propagate
                abus_s <= "001100";                     -- Read Status regC, check b5=AF
                readmem(abus_s,data_s);            
                if (data_s(5)='1') then 
                    write(L,string'(" *** PASS ***"));
                else 
                    write(L,string'(" *** FAIL, AF not set ***"));
                    errorflag<='1';                     -- AF prematurely set
                end if;
            end if;
            writeline(output,L);

            -- *****************************************************************
            -- * Test Periodic Interrupts 
            -- *****************************************************************
            write(L,string'("9) Checking Periodic Interrupts"));
            writeline(output,L);

            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00101101";                       -- DV2:0=010 enable OSC1, RS3:0=0001=8Hz, 125ms 
            writemem(abus_s,data_s);            
            
            abus_s <= "001011";                         -- Write to RegisterB
            data_s <= "01000110";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            writemem(abus_s,data_s);                    -- Disable SQW, enable PIE 

            abus_s <= "001100";                         -- Read Register C to clear any previous flags
            readmem(abus_s,data_s);

            write(L,string'("Enable PIE, period=125ms, "));
            writeline(output,L);

            wait until falling_edge(irq);               -- Interrupt Request Asserted
            t1:=now;                                    -- start time
            
            abus_s <= "001100";                         -- Read Register C to clear PF flag
            readmem(abus_s,data_s);
            if (data_s(6)='0' OR data_s(7)='0') then write(L,string'("PF not set *** FAIL ***"));
                                    errorflag<='1';
            end if;
            
            wait until falling_edge(irq);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("*** IRQ *** time between IRQ="));
            write(L,td);
            writeline(output,L);

            abus_s <= "001100";                         -- Read Register C to clear PF flag
            readmem(abus_s,data_s);

            
            wait until falling_edge(irq);               -- Interrupt Request Asserted

            t1:=now;                                    -- end time
            td:=t1-t2;
            write(L,string'("*** IRQ *** time between IRQ="));
            write(L,td);
            writeline(output,L);

            abus_s <= "001100";                         -- Read Register C to clear PF flag
            readmem(abus_s,data_s);

            -- ------------------------------------------------------------------------
            -- Change frequency and test again
            -- ------------------------------------------------------------------------
            abus_s <= "001010";                         -- Write to RegisterA 
            data_s <= "00100011";                       -- DV2:0=010 enable OSC1, RS3:0=0001=8KHz, 125ms 
            writemem(abus_s,data_s);            
            
            write(L,string'("Enable PIE, period=122us, "));
            writeline(output,L);

            wait until falling_edge(irq);               -- Interrupt Request Asserted
            t1:=now;                                    -- start time
            
            abus_s <= "001100";                         -- Read Register C to clear PF flag
            readmem(abus_s,data_s);
            if (data_s(6)='0' OR data_s(7)='0') then write(L,string'("PF not set *** FAIL ***"));
                                    errorflag<='1';
            end if;
            
            wait until falling_edge(irq);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("*** IRQ *** time between IRQ="));
            write(L,td);
            writeline(output,L);

            abus_s <= "001100";                         -- Read Register C to clear PF flag
            readmem(abus_s,data_s);

            
            wait until falling_edge(irq);               -- Interrupt Request Asserted

            t1:=now;                                    -- end time
            td:=t1-t2;
            write(L,string'("*** IRQ *** time between IRQ="));
            write(L,td);
            writeline(output,L);

            abus_s <= "001100";                         -- Read Register C to clear PF flag
            readmem(abus_s,data_s);


            -- *****************************************************************
            -- * Test Update Interrupts 
            -- *****************************************************************
            write(L,string'("10) Checking Update Ended Interrupts"));
            writeline(output,L);
            
            abus_s <= "001011";                         -- Write to RegisterB
            data_s <= "00010110";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            writemem(abus_s,data_s);                    -- Disable SQW, enable UIE 

            abus_s <= "001100";                         -- Read Register C to clear any previous flags
            readmem(abus_s,data_s);

            write(L,string'("Enable UIE, period=1sec, "));
            writeline(output,L);

            wait until falling_edge(irq);               -- Interrupt Request Asserted
            t1:=now;                                    -- start time
            
            abus_s <= "001100";                         -- Read Register C to clear UF flag
            readmem(abus_s,data_s);
            if (data_s(4)='0' OR data_s(7)='0') then write(L,string'("UF not set *** FAIL ***"));
                                    errorflag<='1';
            end if;
            
            wait until falling_edge(irq);
            t2:=now;                                    -- end time
            td:=t2-t1;
            write(L,string'("*** IRQ *** time between IRQ="));
            write(L,td);
            writeline(output,L);

            abus_s <= "001100";                         -- Read Register C to clear UF flag
            readmem(abus_s,data_s);

            
            wait until falling_edge(irq);               -- Interrupt Request Asserted

            t1:=now;                                    -- end time
            td:=t1-t2;
            write(L,string'("*** IRQ *** time between IRQ="));
            write(L,td);
            writeline(output,L);

            abus_s <= "001100";                         -- Read Register C to clear UF flag
            readmem(abus_s,data_s);


            -- *****************************************************************
            -- * Check Alarm Interrupts
            -- *****************************************************************
            write(L,string'("11) Checking Alarm Interrupts"));
            writeline(output,L);
            
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            time_s <= X"010859";                        -- BCD mode, 24 hour
            writetime(time_s);

            time_s <= X"010901";                        -- set Alarm 2 seconds later
            writealarm(time_s);

            abus_s <= "001011";                         -- Write to RegisterB
            data_s <= "00100110";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE
            writemem(abus_s,data_s);                    -- Disable SQW, enable AIE 

            write(L,string'("Set Alarm for 01:09:01, Waiting for IRQ....."));       
            writeline(output,L);

            wait until falling_edge(irq);               -- Interrupt Request Asserted

            abus_s <= "001100";                         -- Read Register C 
            readmem(abus_s,data_s);
            if (data_s(5)='0' OR data_s(7)='0') then write(L,string'("AF not set *** FAIL ***"));
                                    errorflag<='1';
            end if;
            
            regb_s <= "00001010";                       -- SET:PIE:AIE:UIE - SQWE:DM:2412:DSE            
            readtime(time_s);                           -- Check the time

            if (time_s=X"010901") then write(L,string'("*** IRQ *** Time = 01:09:01 *** PASS ***"));
                                  else write(L,string'("*** FAIL ***")); errorflag<='1';
            end if;
            writeline(output,L);
            

            assert errorflag='0' report "Error Detected, test failed" severity failure;
            assert errorflag='1' report "*** All tests passed ***" severity failure;

            wait;
    end process; 


end architecture behaviour;

