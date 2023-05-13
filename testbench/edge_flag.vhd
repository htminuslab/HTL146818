-------------------------------------------------------------------------------
--  Edge Detector and Sync flag                                              --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       :                                                           --
-- Unit          : edge_flag                                                 --
-- Library       : utils                                                     --
--                                                                           --
-- Version       : 0.1  07/27/2002   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.NUMERIC_STD.all;

entity edge_flag is
   generic( 
      RESVAL : std_logic := '0'
   );
   port( 
      clk        : in     std_logic;
      clredge_in : in     std_logic;
      reset      : in     std_logic;
      strobe_in  : in     std_logic;
      fedge      : out    std_logic;
      fflag      : out    std_logic;
      redge      : out    std_logic;
      rflag      : out    std_logic
   );
end edge_flag ;


architecture struct of edge_flag is

   signal Q         : std_logic;
   signal Qb        : std_logic;
   signal dind1_s   : std_logic;
   signal dind2_s   : std_logic;
   signal falling_s : std_logic;
   signal rising_s  : std_logic;


   signal mw_I3reg_cval : std_logic;
   signal mw_I5reg_cval : std_logic;
   signal mw_I7reg_cval : std_logic;
   signal mw_I8reg_cval : std_logic;


begin
    
    process (clredge_in, reset, falling_s)        
    begin
        if (reset='1') then
           fflag <= RESVAL;                         -- Default value upon reset   
        elsif (falling_s='1') then   
           fflag <= '1';      
        elsif (rising_edge(clredge_in)) then 
           fflag <= '0';
        end if;    
    end process;

    process (clredge_in, reset, rising_s)        
    begin
      if (reset='1') then
         rflag <= RESVAL;                       -- Default value upon reset   
      elsif (rising_s='1') then   
         rflag <= '1';      
      elsif (rising_edge(clredge_in)) then 
         rflag <= '0';
      end if;    
    end process;


    dind1_s <= mw_I3reg_cval;
    Qb <= not(mw_I3reg_cval);
    i3seq_proc: process (clk, reset)
    begin
      if (reset = '1') then
         mw_I3reg_cval <= '0';
      elsif (clk'event and clk='1') then
         mw_I3reg_cval <= strobe_in;
      end if;
    end process i3seq_proc;

    Q <= mw_I5reg_cval;
    dind2_s <= not(mw_I5reg_cval);
    i5seq_proc: process (clk, reset)
    begin
      if (reset = '1') then
         mw_I5reg_cval <= '0';
      elsif (clk'event and clk='1') then
         mw_I5reg_cval <= dind1_s;
      end if;
    end process i5seq_proc;

    fedge <= mw_I7reg_cval;
    i7seq_proc: process (clk, reset)
    begin
      if (reset = '1') then
         mw_I7reg_cval <= '0';
      elsif (clk'event and clk='1') then
         mw_I7reg_cval <= falling_s;
      end if;
    end process i7seq_proc;

    redge <= mw_I8reg_cval;
    i8seq_proc: process (clk, reset)
    begin
      if (reset = '1') then
         mw_I8reg_cval <= '0';
      elsif (clk'event and clk='1') then
         mw_I8reg_cval <= rising_s;
      end if;
    end process i8seq_proc;

    rising_s <= dind2_s and dind1_s;
    falling_s <= Qb and Q;

end struct;
