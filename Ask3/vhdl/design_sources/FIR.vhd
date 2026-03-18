library ieee;
use ieee.std_logic_1164.all;
use work.Memories.all;

entity FirFilter is 
  Port(
    Clk      : in std_logic;
    Reset    : in std_logic;
    ValidIn  : in std_logic;
    X        : in std_logic_vector(7 downto 0); 
    ValidOut : out std_logic;
    Y        : out std_logic_vector(18 downto 0)
  );
end entity;

architecture Structural of FirFilter is

  signal XDelayed         : std_logic_vector(7 downto 0);
  signal MacInitDelayed   : std_logic;
  signal MacEnableDelayed : std_logic;
  signal ValidOutDelayed  : std_logic;

  signal CuValidOut, CuRomEnable, CuRamEnable, CuRamWEnable : std_logic;
  signal CuMacEnable, CuMacInit                             : std_logic;
  signal CuRamAddress, CuRomAddress                         : std_logic_vector(2 downto 0);
  
  signal RomDataOut, RamDataOut                             : std_logic_vector(7 downto 0);

begin

  U_CU: entity work.CU
    port map(
      Clk        => Clk,
      Reset      => Reset,
      ValidIn    => ValidIn,
      ValidOut   => CuValidOut,
      RomEnable  => CuRomEnable,
      RamEnable  => CuRamEnable,
      RamWEnable => CuRamWEnable,
      MacEnable  => CuMacEnable,
      MacInit    => CuMacInit,
      RamAddress => CuRamAddress,
      RomAddress => CuRomAddress
    );

  U_ROM: entity work.Rom
    generic map(
      BIT_COUNT => 8,
      REG_COUNT => 8,
      COEFFS    => ("00000001", "00000010", "00000011", "00000100",
                    "00000101", "00000110", "00000111", "00001000")
    )
    port map(
      Clk     => Clk,
      Enable  => CuRomEnable,
      Address => CuRomAddress,
      RomOut  => RomDataOut
    );

  U_RAM: entity work.Ram
    generic map(
      BIT_COUNT => 8,
      REG_COUNT => 8
    )
    port map(
      Clk     => Clk,
      Reset   => Reset,
      Enable  => CuRamEnable,
      WEnable => CuRamWEnable,
      Address => CuRamAddress,
      DataIn  => XDelayed,
      DataOut => RamDataOut
    );

  U_MAC: entity work.Mac
    port map(
      Clk     => Clk,
      Reset   => Reset,
      Enable  => MacEnableDelayed,
      Init    => MacInitDelayed,
      IRCoeff => RomDataOut,
      Sig     => RamDataOut,
      YOut    => Y
    );

  process(Clk, Reset) begin
    if Reset = '1' then
      XDelayed         <= (others => '0');
      MacInitDelayed   <= '0';
      MacEnableDelayed <= '0';
      ValidOutDelayed  <= '0';
    elsif rising_edge(Clk) then
      XDelayed         <= X;
      MacInitDelayed   <= CuMacInit;
      MacEnableDelayed <= CuMacEnable;
      ValidOutDelayed  <= CuValidOut; 
    end if;
  end process;

  ValidOut <= ValidOutDelayed;
end architecture;
