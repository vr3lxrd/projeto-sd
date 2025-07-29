library ieee;
use ieee.std_logic_1164.all;

entity ReconhecedorSequencia is
    port(
        SW: in std_logic_vector(0 downto 0); 
        KEY: in std_logic_vector(1 downto 0);
        LEDR: out std_logic_vector(9 downto 0);
        HEX0: out std_logic_vector(6 downto 0)
    );
end ReconhecedorSequencia;

architecture arch of ReconhecedorSequencia is
    type state_type is (A, B, C, D, E); -- Adicionando novo estado E, que representa o sucesso da sequencia
    signal state, next_state : state_type; -- Essa e a diferenca da maquina de Moore, saidas sao funcoes apenas dos estados
begin
    -- Processo 1 - Alterando logica para adicionar o switch na posicao 0 como reset 
	 process (KEY)
		 begin
			  if (KEY(1)='0') then
				   state <= A;
			  elsif (rising_edge(KEY(0))) then
					state <= next_state;
			  end if;
    end process;

    -- Processo 2 - Adicionando estado E como final
    next_state_func: process (SW(0), state)
    begin
        case state is
            when A => -- Estado inicial
					case SW(0) is
						when '1' =>
							next_state <= B;
						when '0' =>
							next_state <= A;
					end case;
            when B =>
					 case SW(0) is
						when '1' =>
							next_state <= C;
						when '0' =>
							next_state <= A;
					 end case;
            when C =>
					 case SW(0) is
						when '1' =>
							next_state <= C;
						when '0' =>
							next_state <= D;
					 end case;
            when D =>
				    case SW(0) is
						when '1' =>
							next_state <= E;
						when '0' =>
							next_state <= A;
					 end case;
            when E =>
                -- A partir daqui, verifica se a entrada pode iniciar uma nova sequência (overlapping)
                case SW(0) is
						when '1' =>
							next_state <= B;
						when '0' =>
							next_state <= A;
					 end case;
        end case;
    end process;

    -- Processo 3 - Saida do Moore
    output_func: process (state) -- A saida agora depende APENAS do estado
    begin
        case state is
            when A =>
                LEDR <= "1111111111"; -- Progresso 0%
                HEX0 <= "1111111";    -- Display apagado
            when B =>
                LEDR <= "1111111100"; -- Progresso 25%
                HEX0 <= "1111111";    -- Display apagado
            when C =>
                LEDR <= "1111110000"; -- Progresso 50%
                HEX0 <= "1111111";    -- Display apagado
            when D =>
                LEDR <= "1110000000"; -- Progresso 75%
                HEX0 <= "1111111";    -- Display apagado
            when E =>
                LEDR <= "0000000000"; -- Sucesso! Todos os LEDs acessos
                HEX0 <= "0010010";    -- Mostra um "S" de Sucesso no display
            when others =>
                LEDR <= "1111111111";
                HEX0 <= "1111111";
        end case;
    end process;

end arch;
