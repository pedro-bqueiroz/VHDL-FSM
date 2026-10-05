library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  port (
    clk                 : in  std_logic;
    Reset               : in  std_logic;
    Alterna_display     : in  std_logic;
    Seleciona_moeda     : in  std_logic;
    Seleciona_produto   : in  std_logic;
    Vp                  : in  unsigned(2 downto 0);
    Total               : in  unsigned(2 downto 0);
    Timeout             : in  unsigned(2 downto 0);
    Valida_moeda        : in  boolean;
    ini                 : out std_logic;
    prod                : out std_logic;
    moeda               : out std_logic;
    espera              : out std_logic;
    valida              : out std_logic;
    entrega             : out std_logic
  );
end fsm;

architecture my_fsm of fsm is

  type state_type is (
    Inicio,
    Espera_produto,
    Espera_moeda,
    Espera_outra,
    Moeda_valida,
    Entrega_produto
  );

  signal ps, ns : state_type;

  constant clock5seg : unsigned(2 downto 0) := "101";

begin

  state_register : process(clk)
  begin
    if rising_edge(clk) then
      ps <= ns;
    end if;
  end process;

  comb_proc : process(
    ps,
    reset,
    Seleciona_moeda,
    Seleciona_produto,
    Alterna_display,
    Valida_moeda,
    Vp,
    Total,
    Timeout
  )
  begin

    ns <= ps;

    ini     <= '0';
    prod    <= '0';
    moeda   <= '0';
    espera  <= '0';
    valida  <= '0';
    entrega <= '0';

    case ps is

      when Inicio =>
        ini <= '1';

        if reset = '1' then
          ns <= Espera_produto;
        else
          ns <= Inicio;
        end if;

      when Espera_produto =>
        prod <= '1';

        if Seleciona_produto = '1' then
          ns <= Espera_moeda;
        else
          ns <= Espera_produto;
        end if;

      when Espera_moeda =>
        moeda <= '1';

        if Seleciona_moeda = '1' then
          ns <= Espera_outra;
        elsif Alterna_display = '0' then
          ns <= Espera_moeda;
        else
          ns <= Espera_moeda;
        end if;

      when Espera_outra =>
        espera <= '1';

        if Valida_moeda = true then
          ns <= Moeda_valida;
        else
          ns <= Espera_moeda;
        end if;

      when Moeda_valida =>
        valida <= '1';

        if (Seleciona_moeda = '1') and (Total < Vp) then
          ns <= Moeda_valida;
        elsif (Seleciona_moeda = '0') and (Total < Vp) then
          ns <= Espera_moeda;
        elsif Total >= Vp then
          ns <= Entrega_produto;
        else
          ns <= Moeda_valida;
        end if;

      when Entrega_produto =>
        entrega <= '1';

        if Timeout < clock5seg then
          ns <= Entrega_produto;
        else
          ns <= Inicio;
        end if;

    end case;

  end process;

end my_fsm;
