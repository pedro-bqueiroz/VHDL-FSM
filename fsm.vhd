

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_fsm is
    port (
        Clk, Reset, Timeout, Alterna_display, Seleciona_moeda : in STD_LOGIC;
        Seleciona_produto, Vp, Total, Display : in STD_LOGIC_VECTOR(2 downto 0);
        Valida_moeda : in BOOLEAN;
        HEX0     : out std_logic_vector(7 downto 0);
        HEX1     : out std_logic_vector(7 downto 0);
        HEX2     : out std_logic_vector(7 downto 0);
        HEX3     : out std_logic_vector(7 downto 0);
        HEX4     : out std_logic_vector(7 downto 0);
        HEX5     : out std_logic_vector(7 downto 0)
    );
end my_fsm;


architecture fsm of my_fsm is
    type state_type is (Inicio, Espera_produto,
        Espera_moeda, Espera_outra, Moeda_valida,
        Entrega_produto);

        signal ps, ns : state_type;
        begin
            sync_proc: process(CLK) -- note: no NS here!
            begin -- state reset and transition
                if (rising_edge(CLK)) then PS <= NS;
                end if;
                end process sync_proc;

            comb_proc: process(PS)
            begin
            case PS is
                when Inicio => 
                if (Reset = '1') then 
                    Ns <= Espera_produto;
                else 
                    Ns <= Inicio;
                end if;-- items regarding state ST0
                
                when Espera_produto => 
                if (Seleciona_produto = '1') then
                    ns <= Espera_moeda;
                else ns <= Espera_produto;
                end if;

                when Espera_moeda => -- items regarding state ST1
                if (Seleciona_moeda) then NS <= Espera_outra;
                elsif (not Seleciona_moeda = '1' and not Alterna_display = '1') then 
                Display <= Seleciona_produto;
                end if;
                when others => -- the catch-all condition
                NS <= ST0; -- make it to these two statements
            end case;
 end process comb_proc;
end fsm;