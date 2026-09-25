-- Divisor de clock com entrada de 50MHz e saída de 1Hz
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisorClock is
port ( clk50MHz : in std_logic;
       reset : in std_logic;
       clk0d2Hz : out std_logic
     );
end DivisorClock;

architecture Behavioral of DivisorClock is

--signal count : integer := 0;
signal b : std_logic := '0';
begin

-- Geração do Clock. Para um clock de 50MHz esse process gera um sinal de clock de 0.2Hz.
process(clk50MHz, b)
	variable cnt : integer range 0 to 2**27-1;
	begin
		if(rising_edge(clk50MHz)) then
		   if(reset = '1') then
			   cnt := 0;
			else
			   cnt := cnt + 1;
         end if;
			if(cnt = 124999999) then
				b <= not b;
				cnt := 0;
			end if;
		end if;
		clk0d2Hz <= b;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_fsm is
  port (
    Clk, Reset, Timeout, Alterna_display, Seleciona_moeda, Seleciona_produto : in std_logic;
    Vp, Total, Display                                                       : in std_logic_vector(2 downto 0);
    Valida_moeda                                                             : in boolean;
    HEX0                                                                     : out std_logic_vector(7 downto 0);
    HEX1                                                                     : out std_logic_vector(7 downto 0);
    HEX2                                                                     : out std_logic_vector(7 downto 0);
    HEX3                                                                     : out std_logic_vector(7 downto 0);
    HEX4                                                                     : out std_logic_vector(7 downto 0);
    HEX5                                                                     : out std_logic_vector(7 downto 0)
  );
end my_fsm;

architecture fsm of my_fsm is
  constant NADA : std_logic_vector(7 downto 0) := x"FF";

  constant D0 : std_logic_vector(7 downto 0) := x"C0";
  constant D1 : std_logic_vector(7 downto 0) := x"F9";
  constant D2 : std_logic_vector(7 downto 0) := x"A4";
  constant D5 : std_logic_vector(7 downto 0) := x"92";
  constant D7 : std_logic_vector(7 downto 0) := x"F8";

  constant CHR_A : std_logic_vector(7 downto 0) := x"88";
  constant CHR_C : std_logic_vector(7 downto 0) := x"C6";
  constant CHR_D : std_logic_vector(7 downto 0) := x"A1";
  constant CHR_E : std_logic_vector(7 downto 0) := x"86";
  constant CHR_F : std_logic_vector(7 downto 0) := x"8E";
  constant CHR_H : std_logic_vector(7 downto 0) := x"89";
  constant CHR_I : std_logic_vector(7 downto 0) := x"CF";
  constant CHR_L : std_logic_vector(7 downto 0) := x"47";
  constant CHR_N : std_logic_vector(7 downto 0) := x"AB";
  constant CHR_O : std_logic_vector(7 downto 0) := x"C0";
  constant CHR_P : std_logic_vector(7 downto 0) := x"8C";
  constant CHR_R : std_logic_vector(7 downto 0) := x"AF";
  constant CHR_S : std_logic_vector(7 downto 0) := x"92";
  constant CHR_T : std_logic_vector(7 downto 0) := x"87";
  constant CHR_U : std_logic_vector(7 downto 0) := x"C1";

  type state_type is (Inicio, Espera_produto,
    Espera_moeda, Espera_outra, Moeda_valida,
    Entrega_produto);

  signal ps, ns : state_type;
  signal x : STD_LOGIC;
  
begin

  DIV : entity work.DivisorClock
    port map (
      clk50MHz => Clk,
      reset => Reset,
      clk0d2Hz => x 
  );

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
        end if;

      when Moeda_valida =>
        if (Seleciona_moeda = '1' AND Total < Vp) then 
          NS <= Moeda_valida;
          --Displays = Total;
        elsif (Total >= Vp) then 
          NS <= Entrega_produto;
          -- Led_entrega_produto 
          -- Dispara timer

        end if;
      
      when Entrega_produto =>
        if (true) then NS <= Entrega_produto;
        end if;
        /*if (Timeout <= x) then 
          NS <= Entrega_produto;
          -- Led_entrega_produto;
        elsif (Timeout = x) then
          NS <= Inicio;
          -- NOT Led_entrega_produto
          -- NOT dispara_timer

        end if;
        */
    end case;
  end process comb_proc;
end fsm;
