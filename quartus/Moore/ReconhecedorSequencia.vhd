library ieee;
use ieee.std_logic_1164.all;

entity ReconhecedorSequencia is
    port(CLK, RESET, X: in std_logic;
         Z: out std_logic);
end ReconhecedorSequencia;

architecture moore_arch of ReconhecedorSequencia is
    type state_type is (A, B, C, D, E); -- Adicionando novo estado E, que representa o sucesso da sequencia
    signal state, next_state : state_type; -- Essa e a diferenca da maquina de Moore, saidas sao funcoes apenas dos estados

begin

    -- Processo 1 - Sem Alteracoes
    state_register: process (CLK, RESET)
    begin
        if (RESET = '1') then
            state <= A;
        elsif (CLK'event and CLK = '1') then
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
        if state = E then
            Z <= '1';
        else
            Z <= '0';
        end if;
    end process;

end moore_arch;