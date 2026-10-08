library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm2 is
  port (
    clk               : in std_logic;
    Reset             : in std_logic;
    SEL_D   : in std_logic;
    SEL_M   : in std_logic;
    SEL_P : in std_logic;
    LD_S : in std_logic;
    Vp                : in unsigned(2 downto 0);
    Total             : in unsigned(2 downto 0);
    Timeout           : in std_logic;
    Valida_moeda      : in boolean;
    ini               : out std_logic;
    prod              : out std_logic;
    moeda             : out std_logic;
    espera            : out std_logic;
    valida            : out std_logic;
    entrega           : out std_logic
  );
end fsm2;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador is
  port (
    a, b : in std_logic_vector(7 downto 0);
    s    : out std_logic_vector(7 downto 0));
end somador;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coin_detector is
  port (
    moeda : in std_logic_vector(2 downto 0);
    moe : out std_logic_vector(7 downto 0));
end coin_detector;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity product_detector_ROM is
  port (
    SW      : in std_logic;
    produto : in std_logic_vector(2 downto 0);
    LED     : out std_logic_vector(7 downto 0);
    HEX0    : out std_logic_vector(7 downto 0);
    HEX1    : out std_logic_vector(7 downto 0);
    HEX2    : out std_logic_vector(7 downto 0);
    HEX3    : out std_logic_vector(7 downto 0);
    HEX4    : out std_logic_vector(7 downto 0);
    HEX5    : out std_logic_vector(7 downto 0)
  );
end entity;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
  port (
    Total                   : in std_logic_vector(2 downto 0); -- apenas para esse arquivo
    Vp                      : in std_logic_vector(2 downto 0);
    Total_maior_ou_igual_Vp : out std_logic;
    Total_menor_que_Vp      : out std_logic
  );
end comparador;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registrador is
  generic (
    N : integer := 8
  );

  port (
    Reset : in std_logic;
    Load  : in std_logic;
    Clock : in std_logic;
    Ent   : in std_logic_vector(N - 1 downto 0);

    Sai : out std_logic_vector(N - 1 downto 0)
  );

end entity;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer5seg is
  port (
    Clock         : in std_logic;
    Clear         : in std_logic;
    Dispara_timer : in std_logic;
    Timeout       : out std_logic
  );
end timer5seg;

-- Divisor de clock com entrada de 50MHz e saída de 1Hz
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisorClock is
  port (
    clk50MHz : in std_logic;
    reset    : in std_logic;
    clk1Hz   : out std_logic
  );
end DivisorClock;

architecture fsm of fsm2 is

  type state_type is (Inicio, Espera_produto,
    Espera_moeda, Espera_outra, Moeda_valida,
    Entrega_produto);

  signal ps, ns : state_type;

  signal moereg : STD_LOGIC_VECTOR(7 downto 0);
  signal SOMADOR_A, SOMADOR_B, SOMADOR_C : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal s, ent, LED : STD_LOGIC_VECTOR(7 downto 0);

begin

  CP : entity work.comparador
  port map (
    Vp => SOMADOR_C,
    Total => SOMADOR_B,
    Total_maior_ou_igual_Vp => entrega
  );

  REG_P : entity work.registrador
  port map (
    Reset => Reset,
    Load => SEL_P,
    Clock => clk,
    Ent => LED,
    Sai => SOMADOR_C
  );

  REG_M : entity work.registrador
  port map (
    Reset => Reset,
    Load => SEL_M,
    Clock => clk,
    Ent => moereg,
    Sai => SOMADOR_A
  );

  REG_S : entity work.registrador
  port map (
    Reset => Reset,
    Load => LD_S,
    Clock => clk,
    Ent => s,
    Sai => SOMADOR_B
  );

  SOMADOR : entity work.somador
  port map(
    a => SOMADOR_A,
    b => SOMADOR_B,
    s => Ent
  );

  sync_proc : process (CLK) -- note: no NS here!
  begin -- state reset and transition
    if (rising_edge(CLK)) then
      PS <= NS;
    end if;
  end process sync_proc;

  comb_proc : process (Reset, SEL_P, SEL_M, SEL_D, Valida_moeda, Total, Vp, Timeout)
  begin
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Espera_produto;
        else
          Ns <= Inicio;
        end if;

      when Espera_produto =>
        if (SEL_P = '1') then
          ns <= Espera_moeda;
        else
          ns <= Espera_produto;
        end if;

      when Espera_moeda =>
        if (SEL_M = '1') then
          NS <= Espera_outra;
        elsif (not SEL_M = '1' and not SEL_D = '1') then
          NS <= Espera_moeda;
        elsif (not SEL_M = '1' and SEL_D = '1') then
          NS <= Espera_moeda;
        end if;

      when Espera_outra =>
        if not Valida_moeda then
          NS <= Espera_moeda;
        else
          NS <= Moeda_valida;
        end if;

      when Moeda_valida =>
        if (SEL_M = '1' and Total < Vp) then
          NS <= Moeda_valida;
        elsif (SEL_M = '0' and Total < Vp) then
          NS <= Espera_moeda;
        elsif (Total >= Vp) then
          NS <= Entrega_produto;
        end if;

      when Entrega_produto =>
        if (Timeout = '0') then
          NS <= Entrega_produto;
        else
          NS <= Inicio;
        end if;

    end case;
  end process comb_proc;
end fsm;

architecture comportamental of somador is
begin
  s <= std_logic_vector(unsigned(a) + unsigned(b));
end comportamental;

architecture comportamental of coin_detector is
begin

  moe(7) <= '1' when (moeda(2) = '0' and moeda(1) = '0' and moeda(0) = '0') else
  '0';
  moe(6) <= '1' when (moeda(2) = '1' and moeda(1) = '0' and moeda(0) = '0') else
  '0';
  moe(5) <= '1' when (moeda(2) = '1' and moeda(1) = '0' and moeda(0) = '0') else
  '1' when (moeda(2) = '0' and moeda(1) = '1' and moeda(0) = '0') else
  '0';
  moe(4) <= '1' when (moeda(2) = '0' and moeda(1) = '1' and moeda(0) = '0') else
  '1' when (moeda(2) = '0' and moeda(1) = '0' and moeda(0) = '1') else
  '0';
  moe(3) <= '1' when (moeda(2) = '0' and moeda(1) = '0' and moeda(0) = '1') else
  '0';
  moe(2) <= '1' when (moeda(2) = '1' and moeda(1) = '0' and moeda(0) = '0') else
  '0';
  moe(1) <= '1' when (moeda(2) = '0' and moeda(1) = '1' and moeda(0) = '0') else
  '0';
  moe(0) <= '1' when (moeda(2) = '0' and moeda(1) = '0' and moeda(0) = '1') else
  '0';
end comportamental;

architecture rtl of product_detector_ROM is

  constant NADA : std_logic_vector(7 downto 0) := x"FF";

  constant D0 : std_logic_vector(7 downto 0) := x"C0";
  constant D1 : std_logic_vector(7 downto 0) := x"F9";
  constant D2 : std_logic_vector(7 downto 0) := x"A4";
  constant D5 : std_logic_vector(7 downto 0) := x"92";
  constant D7 : std_logic_vector(7 downto 0) := x"F8";

  constant A : std_logic_vector(7 downto 0) := x"88";
  constant C : std_logic_vector(7 downto 0) := x"C6";
  constant D : std_logic_vector(7 downto 0) := x"A1";
  constant E : std_logic_vector(7 downto 0) := x"86";
  constant F : std_logic_vector(7 downto 0) := x"8E";
  constant H : std_logic_vector(7 downto 0) := x"89";
  constant I : std_logic_vector(7 downto 0) := x"CF";
  constant L : std_logic_vector(7 downto 0) := x"C7";
  constant N : std_logic_vector(7 downto 0) := x"AB";
  constant O : std_logic_vector(7 downto 0) := x"C0";
  constant P : std_logic_vector(7 downto 0) := x"8C";
  constant R : std_logic_vector(7 downto 0) := x"AF";
  constant S : std_logic_vector(7 downto 0) := x"92";
  constant T : std_logic_vector(7 downto 0) := x"87";
  constant U : std_logic_vector(7 downto 0) := x"C1";

  type memory is array (0 to 7) of std_logic_vector(95 downto 0);

  constant ROM : memory := (
  0 =>
  N & O & NADA & NADA & NADA & NADA &
  NADA & NADA & NADA & NADA & NADA & D0,

  1 =>
  C & R & I & S & P & S &
  NADA & NADA & NADA & NADA & D7 & D5,

  2 =>
  P & E & A & N & U & T &
  NADA & NADA & NADA & NADA & D5 & D0,

  3 =>
  C & O & F & F & E & E &
  NADA & NADA & NADA & D1 & D0 & D0,

  4 =>
  A & P & P & L & E & S &
  NADA & NADA & NADA & D1 & D7 & D5,

  5 =>
  S & O & D & A & NADA & NADA &
  NADA & NADA & NADA & D1 & D5 & D0,

  6 =>
  C & H & I & P & S & NADA &
  NADA & NADA & NADA & D1 & D2 & D5,

  7 =>
  NADA & NADA & NADA & NADA & NADA & NADA &
  NADA & NADA & NADA & NADA & NADA & NADA
  );

  signal product       : std_logic_vector(2 downto 0);
  signal saida_produto : std_logic_vector(95 downto 0);
  signal SEL_D         : std_logic := '0';
  signal address       : integer range 0 to 7;
begin

  product <= produto;

  address <= to_integer(unsigned(produto));

  saida_produto <= ROM(address);

  SEL_D <= SW;

  process (SEL_D, saida_produto)

  begin
    if SEL_D = '0' then
      HEX5 <= saida_produto(95 downto 88);
      HEX4 <= saida_produto(87 downto 80);
      HEX3 <= saida_produto(79 downto 72);
      HEX2 <= saida_produto(71 downto 64);
      HEX1 <= saida_produto(63 downto 56);
      HEX0 <= saida_produto(55 downto 48);
    else
      HEX5 <= saida_produto(47 downto 40);
      HEX4 <= saida_produto(39 downto 32);
      HEX3 <= saida_produto(31 downto 24);
      HEX2 <= saida_produto(23 downto 16);
      HEX1 <= saida_produto(15 downto 8);
      HEX0 <= saida_produto(7 downto 0);

    end if;
  end process;
end architecture;

architecture padrao of comparador is
begin
  k : process (Total, Vp) is
  begin
    if (unsigned(Vp)        <= unsigned(Total)) then
      Total_maior_ou_igual_Vp <= '1';
      Total_menor_que_Vp      <= '0';
    else
      Total_menor_que_Vp      <= '1';
      Total_maior_ou_igual_Vp <= '0';
    end if;
  end process;
end architecture padrao;

architecture registra of registrador is

begin
  reg : process (Clock, Reset)

  begin
    if (Reset = '1') then
      Sai <= (others => '0');
    elsif (rising_edge(Clock)) then
      if (Load = '1') then
        Sai <= Ent;
      end if;
    end if;

  end process;
end architecture;
architecture Behavioral of DivisorClock is

  --signal count : integer := 0;
  signal b : std_logic := '0';
begin

  -- Geração do Clock. Para um clock de 50MHz esse process gera um sinal de clock de 1Hz.
  process (clk50MHz, b)
    variable cnt : integer range 0 to 2 ** 26 - 1;
  begin
    if (rising_edge(clk50MHz)) then
      if (reset = '1') then
        cnt := 0;
      else
        cnt := cnt + 1;
      end if;
      if (cnt = 24999999) then
        b <= not b;
        cnt := 0;
      end if;
      clk1Hz <= b;
    end if;
  end process;
end;

architecture Behavioral of timer5seg is
  signal clk_1Hz  : std_logic;
  signal contador : integer range 0 to 4 := 0;
begin

  U_DIVISOR : entity work.DivisorClock
    port map
    (
      clk50MHz => Clock,
      reset    => Clear,
      clk1Hz   => clk_1Hz
    );

  process (clk_1Hz, Clear)
  begin
    if Clear = '1' then
      contador <= 0;
      Timeout  <= '0';

    elsif rising_edge(clk_1Hz) then
      Timeout <= '0';

      if Dispara_timer = '1' then
        if contador = 4 then
          contador <= 0;
          Timeout  <= '1';
        else
          contador <= contador + 1;
        end if;
      else
        contador <= 0;
      end if;
    end if;
  end process;

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;

entity clock5seg is
  port (
    Clock         : in std_logic;
    Clear         : in std_logic;
    Dispara_timer : in std_logic;
    Timeout       : out std_logic
  );
end clock5seg;

architecture Behavioral of clock5seg is

  component timer5seg is
    port (
      Clock         : in std_logic;
      Clear         : in std_logic;
      Dispara_timer : in std_logic;
      Timeout       : out std_logic
    );
  end component;

begin

  U1 : timer5seg
  port map
  (
    Clock         => Clock,
    Clear         => Clear,
    Dispara_timer => Dispara_timer,
    Timeout       => Timeout
  );

end Behavioral;
