library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_fsm is
  port (
    Clk, Timeout, Reset, Alterna_display, Seleciona_moeda, Seleciona_produto : in std_logic;
    Vp, Total                                                                : in std_logic_vector(2 downto 0);
    clock5seg                                                                : in std_logic;
    Valida_moeda                                                             : in boolean
  );
end my_fsm;

architecture fsm of my_fsm is

  type state_type is (Inicio, Espera_produto,
    Espera_moeda, Espera_outra, Moeda_valida,
    Entrega_produto);

  signal ps, ns : state_type;
  signal x      : std_logic;

  signal b : std_logic := '0';

begin

  sync_proc : process (CLK) -- note: no NS here!
  begin -- state reset and transition
    if (rising_edge(CLK)) then
      PS <= NS;
    end if;
  end process sync_proc;

  comb_proc : process (PS)
  begin
    case PS is
      when Inicio =>
        if (Reset = '1') then
          Ns <= Espera_produto;
        else
          Ns <= Inicio;
        end if;

      when Espera_produto =>
        if (Seleciona_produto = '1') then
          ns <= Espera_moeda;
        else
          ns <= Espera_produto;
        end if;

      when Espera_moeda =>
        if (Seleciona_moeda = '1') then
          NS <= Espera_outra;
        elsif (not Seleciona_moeda = '1' and not Alterna_display = '1') then
          NS <= Espera_moeda;
        elsif (not Seleciona_moeda = '1' and Alterna_display = '1') then
          NS <= Espera_moeda;
        end if;

      when Espera_outra =>
        if not Valida_moeda then
          NS <= Espera_moeda;
        else
          NS <= Moeda_valida;
        end if;

      when Moeda_valida =>
        if (Seleciona_moeda = '1' and Total < Vp) then
          NS <= Moeda_valida;
        elsif (Total >= Vp) then
          NS <= Entrega_produto;
        end if;

      when Entrega_produto =>
        if (Timeout < clock5seg) then
          NS <= Entrega_produto;
        elsif (Timeout = clock5seg) then
          NS <= Inicio;
        end if;

    end case;
  end process comb_proc;
end fsm;
