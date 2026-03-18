/* ================================================
                Package boilerplate
   ============================================== */ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

-- NOTE(acol): ugly boilerplate so I can pass generics on instantiation
package Memories is 
  type reg_arr is array (natural range <>) of std_logic_vector; 

  -- NOTE(acol): just log2 followed by a ceiling op
  function Clog2(Val : positive) return natural;
end package Memories;

package body Memories is 
  function Clog2(Val : positive) return natural is
  begin
    -- anti retard shielding
    if Val <= 1 then
      return 1;
    else
      return integer(ceil(log2(real(Val))));
    end if;
  end function;
end package body Memories;

/* ================================================
                  Rom implementation
   ============================================== */ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Memories.all;

entity Rom is 
  generic(
    BIT_COUNT : integer;
    REG_COUNT : integer;
    COEFFS    : reg_arr
  );
  Port(
    Clk, Enable : in std_logic;
    Address     : in std_logic_vector(Clog2(REG_COUNT) - 1 downto 0);
    RomOut      : out std_logic_vector(BIT_COUNT-1 downto 0)
  );
end entity;

architecture Behavioral of Rom is 
begin
  process(Clk) begin
    if rising_edge(Clk) then
      if (Enable = '1') then
        RomOut <= COEFFS(to_integer(unsigned(Address)));
      end if;
    end if;
  end process;
end architecture;

/* ================================================
                  Ram implementation
   ============================================== */ 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Memories.all;

entity Ram is 
  generic(
    BIT_COUNT : integer;
    REG_COUNT : integer
  );
  Port(
    Clk, Enable, WEnable, Reset : in std_logic;
    Address                     : in std_logic_vector(Clog2(REG_COUNT) - 1 downto 0);
    DataIn                      : in std_logic_vector(BIT_COUNT - 1 downto 0);
    DataOut                     : out std_logic_vector(BIT_COUNT - 1 downto 0)
  );
end entity;

architecture Behavioral of Ram is 
  type ram_type is array (0 to REG_COUNT-1) of std_logic_vector(BIT_COUNT-1 downto 0);

  signal RamEntries : ram_type := (others => (others => '0'));
begin
  process(Clk, Reset) begin
    if Reset = '1' then
      RamEntries <= (others => (others => '0'));
      DataOut    <= (others => '0');

    elsif rising_edge(Clk) then

      if Enable = '1' then
        if WEnable = '1' then
          for i in 0 to REG_COUNT - 2 loop
            RamEntries(i + 1) <= RamEntries(i);
          end loop;
          RamEntries(0) <= DataIn;

          DataOut <= DataIn;
        else
          DataOut <= RamEntries(to_integer(unsigned(Address)));
        end if;
      end if;

    end if;
  end process;
end architecture;
