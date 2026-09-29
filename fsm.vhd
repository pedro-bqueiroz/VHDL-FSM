library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_fsm is
  port (
    Clk, Clk1, Reset, Alterna_display, Seleciona_moeda, Seleciona_produto : in std_logic;
    Vp, Total, Display                                                       : in std_logic_vector(2 downto 0);
    Valida_moeda                                                             : in boolean;
    HEX0                                                                     : out std_logic_vector(7 downto 0);
    HEX1                                                                     : out std_logic_vector(7 downto 0);
    HEX2                                                                     : out std_logic_vector(7 downto 0);
    HEX3                                                                     : out std_logic_vector(7 downto 0);
    HEX4                                                                     : out std_logic_vector(7 downto 0);
    HEX5                                                                     : out std_logic_vector(7 downto 0);
  
    clk50MHz : in std_logic;
    clk1Hz   : out std_logic
    );
end my_fsm;

architecture fsm of my_fsm is
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
  constant L : std_logic_vector(7 downto 0) := x"47";
  constant N : std_logic_vector(7 downto 0) := x"AB";
  constant O : std_logic_vector(7 downto 0) := x"C0";
  constant P : std_logic_vector(7 downto 0) := x"8C";
  constant R : std_logic_vector(7 downto 0) := x"AF";
  constant S : std_logic_vector(7 downto 0) := x"92";
  constant T : std_logic_vector(7 downto 0) := x"87";
  constant U : std_logic_vector(7 downto 0) := x"C1";

  type state_type is (Inicio, Espera_produto,
    Espera_moeda, Espera_outra, Moeda_valida,
    Entrega_produto);

  signal ps, ns : state_type;
  signal x      : std_logic;

  type memory is array (0 to 7) of std_logic_vector(103 downto 0);

  constant ROM : memory := (
        0 =>
            N & O & NADA & NADA & NADA & NADA &
            NADA & NADA & NADA & NADA & NADA & D0 &
            "00000000",

        1 =>
            C & R & I & S & P & S &
            NADA & NADA & NADA & NADA & D7 & D5 &
            "01001011",

        2 =>
            P & E & A & N & U & T &
            NADA & NADA & NADA & NADA & D5 & D0 &
            "00110010",

        3 =>
            C & O & F & F & E & E &
            NADA & NADA & NADA & D1 & D0 & D0 &
            "01100100",

        4 =>
            A & P & P & L & E & S &
            NADA & NADA & NADA & D1 & D7 & D5 &
            "10101111",

        5 =>
            S & O & D & A & NADA & NADA &
            NADA & NADA & NADA & D1 & D5 & D0 &
            "10010110",

        6 =>
            C & H & I & P & S & NADA &
            NADA & NADA & NADA & D1 & D2 & D5 &
            "01111101",

        7 =>
            NADA & NADA & NADA & NADA & NADA & NADA &
            NADA & NADA & NADA & NADA & NADA & NADA &
            "00000000"
    );

    signal saida_produto : std_logic_vector (103 downto 0);
    signal seletor_produto : std_logic_vector (2 downto 0);
    signal modo : std_logic;
    signal contador : integer range 0 to 4 := 0;
    signal Timeout : std_logic;

    signal b : std_logic := '0';

begin
  -- Geração do Clock. Para um clock de 50MHz esse process gera um sinal de clock de 1Hz.
  process (clk50MHz, b)
    variable cnt : integer range 0 to 2 ** 27 - 1;
  begin
    if (rising_edge(clk50MHz)) then
      if (reset = '1') then
        cnt := 0;
      else
        cnt := cnt + 1;
      end if;
      if (cnt = 124999999) then
        b <= not b;
        cnt := 0;
      end if;
    end if;
    clk1Hz <= b;
  end process;

  sync_proc : process (CLK) -- note: no NS here!
  begin -- state reset and transition
    if (rising_edge(CLK)) then
      PS <= NS;
    end if;
  end process sync_proc;

  comb_proc : process (PS)
  begin

    HEX0 <= NADA;
    HEX1 <= NADA;
    HEX2 <= NADA;
    HEX3 <= NADA;
    HEX4 <= NADA;
    HEX5 <= NADA;
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Espera_produto;
        else
          Ns <= Inicio;

          HEX0 <= (others => '0');
          HEX1 <= (others => '0');
          HEX2 <= (others => '0');
          HEX3 <= (others => '0');
          HEX4 <= (others => '0');
          HEX5 <= (others => '0');

        end if;

      when Espera_produto =>
        if (Seleciona_produto = '1') then
          ns <= Espera_moeda;

          -- CARREGA PRODUTO, CARREGA VP.
        else
          ns <= Espera_produto;
        end if;

      when Espera_moeda =>
        if (Seleciona_moeda) then
          NS <= Espera_outra;
        elsif (not Seleciona_moeda = '1' and not Alterna_display = '1') then
          --DISPLAYS = PRODUTO
          NS <= Espera_moeda;
        elsif (not Seleciona_moeda = '1' and Alterna_display = '1') then
          --Displays = Vp 
          NS <= Espera_moeda;
        end if;

      when Espera_outra =>
        if not Valida_moeda then
          --LED_MOEDA_INVALIDA;     

          NS <= Espera_moeda;

        else
          NS <= Moeda_valida;
        end if;

      when Moeda_valida =>
        if (Seleciona_moeda = '1' and Total < Vp) then
          NS <= Moeda_valida;
          --Displays = Total;
        elsif (Total >= Vp) then
          NS <= Entrega_produto;
          -- Led_entrega_produto 
          -- Dispara timer

        end if;

      when Entrega_produto =>
        if (true) then
          NS             <= Entrega_produto;
          /* if (Timeout <= x) then
          NS             <= Entrega_produto;
          -- Led_entrega_produto;
        elsif (Timeout = x) then
          NS <= Inicio;
          -- NOT Led_entrega_produto
          -- NOT dispara_timer

        end if;
        */

      else
        NS <= Inicio;
    end if;

  end case;
end process comb_proc;
end fsm;
