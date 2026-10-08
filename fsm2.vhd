library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm2 is
  port (
    clk          : in std_logic;
    Reset        : in std_logic;
    SEL_D        : in std_logic;
    SEL_M        : in std_logic;
    SEL_P        : in std_logic;
    LD_S         : in std_logic;
    Vp           : in unsigned(2 downto 0);
    Total        : in unsigned(2 downto 0);
    Timeout      : in std_logic;
    Valida_moeda : in boolean;
    SW           : in std_logic_vector(9 downto 0);

    ini     : out std_logic;
    prod    : out std_logic;
    moeda   : out std_logic;
    espera  : out std_logic;
    valida  : out std_logic;
    entrega : out std_logic

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
    moe   : out std_logic_vector(7 downto 0));
end coin_detector;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity product_detector_ROM is
  port (
    SW      : in std_logic;
    produto : in std_logic_vector(2 downto 0);
    LED     : out std_logic_vector(7 downto 0);

    HEX0 : out std_logic_vector(7 downto 0);
    HEX1 : out std_logic_vector(7 downto 0);
    HEX2 : out std_logic_vector(7 downto 0);
    HEX3 : out std_logic_vector(7 downto 0);
    HEX4 : out std_logic_vector(7 downto 0);
    HEX5 : out std_logic_vector(7 downto 0)
  );
end entity;

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
  port (
    Total                   : in std_logic_vector(7 downto 0);
    Vp                      : in std_logic_vector(7 downto 0);
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

  signal moeda_sel                       : std_logic_vector(2 downto 0);
  signal produto_sel                     : std_logic_vector(2 downto 0);
  signal moereg                          : std_logic_vector(7 downto 0);
  signal SOMADOR_A, SOMADOR_B, SOMADOR_C : std_logic_vector(7 downto 0);
  signal s, ent, LED                     : std_logic_vector(7 downto 0);

  signal ok : std_logic;

  -- Sinais invertidos para adaptar o acionamento em nível baixo dos botões KEY0 e KEY1
  signal sel_p_btn : std_logic;
  signal sel_m_btn : std_logic;

  signal ld_s_int : std_logic;

begin

  -- Inversão para botões ativos em nível baixo (KEY0 e KEY1)
  sel_p_btn <= not SEL_P;
  sel_m_btn <= not SEL_M;

  -- Seleção de entradas a partir dos switches
  moeda_sel   <= SW(9 downto 7);
  produto_sel <= SW(6 downto 4);

  -- Gera o preco (LED) internamente baseado na chave de produto
  process(produto_sel)
  begin
    case produto_sel is
      when "000" => LED <= std_logic_vector(to_unsigned(0, 8));
      when "001" => LED <= std_logic_vector(to_unsigned(75, 8));
      when "010" => LED <= std_logic_vector(to_unsigned(50, 8));
      when "011" => LED <= std_logic_vector(to_unsigned(100, 8));
      when "100" => LED <= std_logic_vector(to_unsigned(175, 8));
      when "101" => LED <= std_logic_vector(to_unsigned(150, 8));
      when "110" => LED <= std_logic_vector(to_unsigned(125, 8));
      when others => LED <= std_logic_vector(to_unsigned(0, 8));
    end case;
  end process;

  ld_s_int <= '1' when (PS = Espera_outra and Valida_moeda = true) else '0';

  -- Instanciação da ROM para decodificar o produto e os Displays HEX

  CP : entity work.comparador
    port map
    (
      Vp                      => SOMADOR_C,
      Total                   => SOMADOR_B,
      Total_maior_ou_igual_Vp => ok,
      Total_menor_que_Vp      => open
    );

  REG_P : entity work.registrador
    port map
    (
      Reset => Reset,
      Load  => sel_p_btn,
      Clock => clk,
      Ent   => LED,
      Sai   => SOMADOR_C
    );

  REG_M : entity work.registrador
    port map
    (
      Reset => Reset,
      Load  => sel_m_btn,
      Clock => clk,
      Ent   => moereg,
      Sai   => SOMADOR_A
    );

  REG_S : entity work.registrador
    port map
    (
      Reset => Reset,
      Load  => ld_s_int,
      Clock => clk,
      Ent   => s,
      Sai   => SOMADOR_B
    );

  SOMADOR : entity work.somador
    port map
    (
      a => SOMADOR_A,
      b => SOMADOR_B,
      s => Ent
    );

  COIN : entity work.coin_detector
    port map
    (
      moeda => moeda_sel,
      moe   => moereg
    );

  sync_proc : process (CLK)
  begin
    if (rising_edge(CLK)) then
      PS <= NS;
    end if;
  end process sync_proc;

  saida : process (PS)
  begin
    ini     <= '0';
    prod    <= '0';
    moeda   <= '0';
    espera  <= '0';
    valida  <= '0';
    entrega <= '0';

    case (PS) is
      when Inicio          => ini              <= '1';
      when Espera_produto  => prod     <= '1';
      when Espera_moeda    => moeda      <= '1';
      when Espera_outra    => espera     <= '1';
      when Moeda_valida    => valida     <= '1';
      when Entrega_produto => entrega <= '1';
    end case;
  end process;

  comb_proc : process (PS, Reset, sel_p_btn,
    sel_m_btn, SEL_D, Valida_moeda,
    ok, Timeout)
  begin
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Espera_produto;
        else
          Ns <= Inicio;
        end if;

      when Espera_produto =>
        if (sel_p_btn = '1') then
          ns <= Espera_moeda;
        else
          ns <= Espera_produto;
        end if;

      when Espera_moeda =>
        if (sel_m_btn = '1') then
          NS <= Espera_outra;
        else
          NS <= Espera_moeda;
        end if;

      when Espera_outra =>
        if Valida_moeda = FALSE then
          NS <= Espera_moeda;
        else
          NS <= Moeda_valida;
        end if;

      when Moeda_valida =>
        if (sel_m_btn = '1' and ok = '0') then
          NS <= Moeda_valida;
        elsif (sel_m_btn = '0' and ok = '0') then
          NS <= Espera_moeda;
        elsif (ok = '1') then
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
  process(moeda)
  begin
    if moeda = "001" then
      moe <= std_logic_vector(to_unsigned(25, 8));
    elsif moeda = "010" then
      moe <= std_logic_vector(to_unsigned(50, 8));
    elsif moeda = "100" then
      moe <= std_logic_vector(to_unsigned(100, 8));
    else
      moe <= (others => '0');
    end if;
  end process;
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
  signal SEL_D_int     : std_logic := '0';
  signal address       : integer range 0 to 7;
begin

  product <= produto;

  address <= to_integer(unsigned(produto));

  saida_produto <= ROM(address);

  SEL_D_int <= SW;

  process (SEL_D_int, saida_produto)

  begin
    if SEL_D_int = '0' then
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
  signal b : std_logic := '0';
begin

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
    end if;
    clk1Hz <= b;
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm2_top is
  port (
    clk          : in std_logic;
    Reset        : in std_logic;
    SEL_D        : in std_logic;
    SEL_P        : in std_logic;
    SEL_M        : in std_logic;
    Valida_moeda : in std_logic;
    SW           : in std_logic_vector(9 downto 4);
    
    ini          : out std_logic;
    prod         : out std_logic;
    moeda        : out std_logic;
    espera       : out std_logic;
    valida       : out std_logic;
    entrega      : out std_logic;
    
    HEX0         : out std_logic_vector(7 downto 0);
    HEX1         : out std_logic_vector(7 downto 0);
    HEX2         : out std_logic_vector(7 downto 0);
    HEX3         : out std_logic_vector(7 downto 0);
    HEX4         : out std_logic_vector(7 downto 0);
    HEX5         : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of fsm2_top is
  signal timeout_sig : std_logic;
  signal is_valid_coin : boolean;
  signal fsm_valida : std_logic;
  signal fsm_entrega : std_logic;
  
  -- Para mapear o SW original do fsm2 que tinha 10 bits
  signal sw_full : std_logic_vector(9 downto 0);
begin
  -- Reconstrói SW completo para passar pro fsm2
  sw_full(9 downto 4) <= SW;
  sw_full(3) <= '0';
  sw_full(2) <= Valida_moeda;
  sw_full(1) <= SEL_D;
  sw_full(0) <= Reset;

  -- A logica de validacao de moeda (25, 50, 100)
  is_valid_coin <= true when (SW(9 downto 7) = "001" or SW(9 downto 7) = "010" or SW(9 downto 7) = "100") else false;

  FSM_INST : entity work.fsm2
    port map (
      clk          => clk,
      Reset        => Reset,
      SEL_D        => SEL_D,
      SEL_M        => SEL_M,
      SEL_P        => SEL_P,
      LD_S         => '0',
      Vp           => "000",
      Total        => "000",
      Timeout      => timeout_sig,
      Valida_moeda => is_valid_coin,
      SW           => sw_full,
      ini          => ini,
      prod         => prod,
      moeda        => moeda,
      espera       => espera,
      valida       => fsm_valida,
      entrega      => fsm_entrega
    );

  -- O led de moeda valida aceso mesmo sem apertar o botao
  valida <= '1' when is_valid_coin else fsm_valida;
  
  entrega <= fsm_entrega;

  ROM_INST : entity work.product_detector_ROM
    port map (
      SW      => SEL_D,
      produto => SW(6 downto 4),
      LED     => open,
      HEX0    => HEX0,
      HEX1    => HEX1,
      HEX2    => HEX2,
      HEX3    => HEX3,
      HEX4    => HEX4,
      HEX5    => HEX5
    );

  -- O timer precisa ser limpo quando a maquina nao estiver operando (Reset = '0' significa parada no Inicio)
  TIMER_INST : entity work.clock5seg
    port map (
      Clock         => clk,
      Clear         => not Reset,
      Dispara_timer => fsm_entrega,
      Timeout       => timeout_sig
    );

end architecture;
