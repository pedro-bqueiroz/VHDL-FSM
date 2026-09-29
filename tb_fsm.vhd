library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fsm is
end entity;

architecture maquina of tb_fsm is
  signal Clk               : std_logic;
  signal Timeout           : std_logic;
  signal Reset             : std_logic;
  signal Alterna_display   : std_logic;
  signal Seleciona_moeda   : std_logic;
  signal Seleciona_produto : std_logic;
  signal Vp                : std_logic_vector(2 downto 0);
  signal Total             : std_logic_vector(2 downto 0);
  signal clock5seg         : std_logic;
  signal Valida_moeda      : boolean;
begin

  DUT : entity work.my_fsm
    port map
    (
      Clk               => Clk,
      Reset             => Reset,
      Alterna_display   => Alterna_display,
      Seleciona_moeda   => Seleciona_moeda,
      Seleciona_produto => Seleciona_produto,
      Timeout           => Timeout,
      Vp                => Vp,
      Total             => Total,
      clock5seg         => clock5seg,
      Valida_moeda      => Valida_moeda
    );

  pclock : process
  begin
    while true loop
      Clk <= '0';
      wait for 20 ns;

      Clk <= '1';
      wait for 20 ns;

    end loop;
  end process;
  k : process
  begin
    Reset <= '0';
    Vp    <= "010";
    Total <= "000";
    wait until rising_edge(Clk); -- TESTANDO RESET

    Reset <= '1';
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ESPERA_PRODUTO

    Seleciona_produto <= '0';
    wait until rising_edge(Clk); -- TESTANDO LOOP EM ESPERA_PRODUTO

    Seleciona_produto <= '1';
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ESPERA_MOEDA

    Seleciona_moeda <= '0';
    Alterna_display <= '0';
    wait until rising_edge(Clk); -- TESTANDO LOOP 1 EM ESPERA_MOEDA

    Seleciona_moeda <= '0';
    Alterna_display <= '1';
    wait until rising_edge(Clk); -- TESTANDO LOOP 2 EM ESPERA_MOEDA

    Seleciona_moeda <= '1';
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ESPERA_OUTRA

    Valida_moeda <= FALSE;
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ESPERA_MOEDA;

    Seleciona_moeda <= '1';
    wait until rising_edge(Clk);

    Valida_moeda <= TRUE;
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA MOEDA_VALIDA

    Seleciona_moeda <= '0';
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ESPERA_MOEDA

    Seleciona_moeda <= '1';
    wait until rising_edge(Clk);

    Valida_moeda <= TRUE;
    wait until rising_edge(Clk);

    Seleciona_moeda <= '1';
    wait until rising_edge(Clk); -- VERIFICANDO 0 < 2

    Seleciona_moeda <= '1';
    Total <= "110";
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ENTREGA_PRODUTO


    Timeout <= '1';
    clock5seg <= '0';
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA ENTREGA_PRODUTO

    Timeout <= '1';
    clock5seg <= '1';
    wait until rising_edge(Clk); -- TESTANDO TRANSIÇÃO PARA INICIO


    wait;

  end process;

end architecture;
