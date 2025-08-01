library ieee;
use ieee.std_logic_1164.all;

entity ReconhecedorSequencia is
    port(
        MAX10_CLK1_50: in std_logic; -- << ADICIONAR ESTA LINHA
        SW: in std_logic_vector(0 downto 0);  
        KEY: in std_logic_vector(1 downto 0);
        LEDR: out std_logic_vector(9 downto 0);
        HEX0: out std_logic_vector(6 downto 0);
        HEX2: out std_logic_vector(6 downto 0)
    );
end ReconhecedorSequencia;

architecture arch of ReconhecedorSequencia is
    type state_type is (A, B, C, D, E);
    signal state : state_type;

    -- Sinais para o Debouncer de KEY(0)
    signal key0_reg1, key0_reg2, key0_reg3 : std_logic;
    signal key0_pulse : std_logic;

begin
    -- ===================================================================
    -- Processo de Debounce para KEY(0)
    -- Este processo "limpa" o sinal do botão usando o clock principal.
    -- Ele gera um pulso único 'key0_pulse' para cada aperto.
    -- ===================================================================
    debounce_proc: process(MAX10_CLK1_50, KEY(1), KEY(0))
    begin
        if (KEY(1) = '0') then -- Reset
            key0_reg1 <= '1';
            key0_reg2 <= '1';
            key0_reg3 <= '1';
            key0_pulse <= '0';
        elsif (rising_edge(MAX10_CLK1_50)) then
            -- Pipeline de 3 registradores para sincronizar e filtrar o botão
            -- A entrada KEY é ativa em nível baixo, então procuramos por '0'
            key0_reg1 <= KEY(0); 
            key0_reg2 <= key0_reg1;
            key0_reg3 <= key0_reg2;

            -- Gera um pulso de um ciclo de clock quando o botão é pressionado
            -- (transição de não-pressionado '1' para pressionado '0')
            if (key0_reg3 = '1' and key0_reg2 = '0') then
                key0_pulse <= '1';
            else
                key0_pulse <= '0';
            end if;
        end if;
    end process;

    -- ===================================================================
    -- Processo da Máquina de Estados - AGORA USANDO O SINAL LIMPO
    -- ===================================================================
    fsm_proc: process (MAX10_CLK1_50, KEY(1))
    begin
        if (KEY(1) = '0') then -- Reset assíncrono
            state <= A;
        elsif (rising_edge(MAX10_CLK1_50)) then
            -- A máquina de estados só avança quando o pulso limpo do debouncer é '1'
            if (key0_pulse = '1') then 
                case state is
                    when A =>
                        if SW(0) = '1' then
                            state <= B;
                        else
                            state <= A;
                        end if;
                    when B =>
                        if SW(0) = '1' then
                            state <= C;
                        else
                            state <= A;
                        end if;
                    when C =>
                        if SW(0) = '0' then
                            state <= D;
                        else
                            state <= C;
                        end if;
                    when D =>
                        if SW(0) = '1' then
                            state <= E;
                        else
                            state <= A;
                        end if;
                    when E =>
                        if SW(0) = '1' then
                            state <= B; -- Overlapping
                        else
                            state <= A;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- Processo 3 - Saida do Moore
    output_func: process (state) -- A saida agora depende APENAS do estado
    begin
        case state is
            when A =>
                LEDR <= "1111111111"; -- Progresso 0%
                HEX0 <= "1000000";    -- Display 0
                HEX2 <= "0001000";
            when B =>
                LEDR <= "1111111100"; -- Progresso 25%
                HEX0 <= "1000000";    -- Display 0
                HEX2 <= "0000011";
            when C =>
                LEDR <= "1111110000"; -- Progresso 50%
                HEX0 <= "1000000";    -- Display 0
                HEX2 <= "1000110";
            when D =>
                LEDR <= "1110000000"; -- Progresso 75%
                HEX0 <= "1000000";    -- Display 0
                HEX2 <= "0100001";
            when E =>
                LEDR <= "0000000000"; -- Sucesso! Todos os LEDs acessos
                HEX0 <= "1111001";    -- Mostra um "1" de Sucesso no display
                HEX2 <= "0000110";
            when others =>
                LEDR <= "1111111111";
                HEX0 <= "0000000";
                HEX2 <= "0000000";
        end case;
    end process;

end arch;
