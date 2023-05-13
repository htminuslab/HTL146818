-------------------------------------------------------------------------------
--  HTL146818 - RTC                                                          --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : RTC                                                       --
-- Unit          : redge                                                     --
-- Library       : I146818                                                   --
--                                                                           --
-- Version       : 0.1  08/12/2009   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity redge is
   port( 
      clk   : in     std_logic;
      stbin : in     std_logic;
      redge : out    std_logic
   );
end redge ;


architecture struct of redge is

   -- Internal signal declarations
   signal q1 : std_logic;
   signal qb : std_logic;

   signal mw_I3reg_cval : std_logic;
   signal mw_I5reg_cval : std_logic;


begin

   -- ModuleWare code(v1.9) for instance 'I3' of 'adff'
   q1 <= mw_I3reg_cval;
   i3seq_proc: process (clk)begin
      if (clk'event and clk='1') then
         mw_I3reg_cval <= stbin;
      end if;
   end process i3seq_proc;

   -- ModuleWare code(v1.9) for instance 'I5' of 'adff'
   qb <= not(mw_I5reg_cval);
   i5seq_proc: process (clk)begin
      if (clk'event and clk='1') then
         mw_I5reg_cval <= q1;
      end if;
   end process i5seq_proc;

   -- ModuleWare code(v1.9) for instance 'I6' of 'and1'
   redge <= q1 and qb;

end struct;
