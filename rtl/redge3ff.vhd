-------------------------------------------------------------------------------
--  HTL146818 - RTC                                                          --
--                                                                           --
--  https://github.com/htminuslab                                            --  
--                                                                           --
-------------------------------------------------------------------------------
-- Project       : RTC                                                       --
-- Unit          : redge3ff                                                  --
-- Library       : I146818                                                   --
--                                                                           --
-- Version       : 0.1  08/12/2009   Created HT-LAB                          --
--               : 1.1  07/05/2023   Uploaded to github under MIT license.   --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity redge3ff is
   port( 
      clk    : in     std_logic;
      ena    : in     std_logic;
      stbin  : in     std_logic;
      redge  : out    std_logic;
      stbout : out    std_logic);
end redge3ff ;

LIBRARY ieee;
USE ieee.std_logic_1164.all;


architecture struct of redge3ff is

   -- Architecture declarations

   -- Internal signal declarations
   signal Q  : std_logic;
   signal Qb : std_logic;
   signal q1 : std_logic;

   -- Implicit buffer signal declarations
   signal stbout_internal : std_logic;


   -- ModuleWare signal declarations(v1.9) for instance 'I3' of 'adff'
   signal mw_I3reg_cval : std_logic;

   -- ModuleWare signal declarations(v1.9) for instance 'I5' of 'adff'
   signal mw_I5reg_cval : std_logic;

   -- ModuleWare signal declarations(v1.9) for instance 'I7' of 'adff'
   signal mw_I7reg_cval : std_logic;


begin

   -- ModuleWare code(v1.9) for instance 'I3' of 'adff'
   stbout_internal <= mw_I3reg_cval;
   Qb <= not(mw_I3reg_cval);
   i3seq_proc: process (clk)begin
      if (clk'event and clk='1') then
         if (ena = '1') then
            mw_I3reg_cval <= q1;
         end if;
      end if;
   end process i3seq_proc;

   -- ModuleWare code(v1.9) for instance 'I5' of 'adff'
   Q <= mw_I5reg_cval;
   i5seq_proc: process (clk)begin
      if (clk'event and clk='1') then
         mw_I5reg_cval <= stbout_internal;
      end if;
   end process i5seq_proc;

   -- ModuleWare code(v1.9) for instance 'I7' of 'adff'
   q1 <= mw_I7reg_cval;
   i7seq_proc: process (clk)begin
      if (clk'event and clk='1') then
         mw_I7reg_cval <= stbin;
      end if;
   end process i7seq_proc;

   -- ModuleWare code(v1.9) for instance 'I6' of 'and1'
   redge <= Qb and Q;

   -- Instance port mappings.

   -- Implicit buffered output assignments
   stbout <= stbout_internal;

end struct;
