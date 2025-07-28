library ieee;
use ieee.std_logic_1164.all;

entity ReconhecedorSequencia is
    port(
        CLK: in std_logic;
        SW: in std_logic_vector(0 downto 0); 
        KEY: in std_logic_vector(1 downto 0);
        LEDR: out std_logic_vector(9 downto 0);
        HEX0: out std_logic_vector(6 downto 0)
    );
end ReconhecedorSequencia;

architecture arch of ReconhecedorSequencia is
    type state_type is (A, B, C, D, E); -- Adicionando novo estado E, que representa o sucesso da sequencia
    signal state, next_state : state_type; -- Essa e a diferenca da maquina de Moore, saidas sao funcoes apenas dos estados
    signal X: std_logic;
begin

   X <= '1' when KEY(1) = '0' else
        '0' when KEY(0) = '0' else
         X;

    -- Processo 1 - Alterando logica para adicionar o switch na posicao 0 como reset 
    state_register: process (CLK, SW)
    begin
        if (SW(0) = '1') then -- SW é o reset
            state <= A;
        elsif (rising_edge(CLK)) then -- rising_edge e a mesma coisa que <CLK'event and CLK = '1'>
            state <= next_state;
        end if;
    end process;

    -- Processo 2 - Adicionando estado E como final
    next_state_func: process (X, state)
    begin
        case state is
            when A => -- Estado inicial
                if X = '1' then
                    next_state <= B; -- 1
                else
                    next_state <= A;
                end if;
            when B =>
                if X = '1' then
                    next_state <= C; -- 1
                else
                    next_state <= A;
                end if;
            when C =>
                if X = '1' then
                    next_state <= C; -- Se receber 111, continua esperando um 0
                else
                    next_state <= D; -- 110
                end if;
            when D => 
                if X = '1' then
                    next_state <= E; -- 1101, Sequencia completa
                else
                    next_state <= A; -- Quebrou a sequencia
                end if;
            when E =>
                -- A partir daqui, verifica se a entrada pode iniciar uma nova sequência (overlapping)
                if X = '1' then
                    next_state <= B; -- Se for 1, completou a sequencia e ja comeca uma nova com 1
                else
                    next_state <= A; -- Se for 0, comeca uma nova sequencia com 0
                end if;
        end case;
    end process;

    -- Processo 3 - Saida do Moore
    output_func: process (state) -- A saida agora depende APENAS do estado
    begin
        case state is
            when A =>
                LEDR <= "1111111110"; -- Progresso 0%
                HEX0 <= "1111111";    -- Display apagado
            when B =>
                LEDR <= "1111111000"; -- Progresso 25%
                HEX0 <= "1111111";    -- Display apagado
            when C =>
                LEDR <= "1111110000"; -- Progresso 50%
                HEX0 <= "1111111";    -- Display apagado
            when D =>
                LEDR <= "1111000000"; -- Progresso 75%
                HEX0 <= "1111111";    -- Display apagado
            when E =>
                LEDR <= "0000000000"; -- Sucesso! Todos os LEDs acessos
                HEX0 <= "0100100";    -- Mostra um S de Sucesso no display
            when others =>
                LEDR <= "1111111111";
                HEX0 <= "1111111";
        end case;
    end process;

end arch;