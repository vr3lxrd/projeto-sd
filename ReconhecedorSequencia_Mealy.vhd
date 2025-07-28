-- Sequence Recognizer: VHDL Process Description
-- (See Figure 4-21 for state diagram)
library ieee;
use ieee.std_logic_1164.all;
entity ReconhecedorSequencia is
   port(CLK, RESET, X: in std_logic; -- Clock, Reset e Input X, talvez vai ser o caso adicionar os switchs como input
        Z: out std_logic); -- Saida Z, mesma coisa que talvez vai ser o caso trocar para os displays como saida
end ReconhecedorSequencia;

architecture process_3 of ReconhecedorSequencia is
   type state_type is (A, B, C, D); -- Define um enum para os dois signals abaixo usarem no case #32, #64
   signal state, next_state : state_type; -- https://www.vhdl-online.de/courses/system_design/synthesis/finite_state_machines_and_vhdl/state_coding
begin

-- Process 1 - state_register: implements positive edge-triggered
-- state storage with asynchronous reset. 
   state_register: process (CLK, RESET)
   begin
     if (RESET = '1') then -- Reset selecionado
        state <= A; -- Processo volta para o começo
     else
        if (CLK'event and CLK = '1') then -- Verifica se houve um evento de clock e se o clock esta no 1
           state <= next_state; 
        end if;
     end if;
end process;

-- Process 2 - next_state_function: implements next state as function
-- of input X and state. 
-- Processo que vai ser responsavel por identificar a sequencia, a ideia e chegar ao estado D que representa o final da sequencia
-- Quando <letra> valida se o valor de X e o proximo da sequencia, se sim state = <letra + 1>, se nao state = <letra - 1>
   next_state_func: process (X, state)
   begin
      case state is
			when A =>
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
					next_state <= C;
				else
					next_state <= D; -- 0
				end if;
			when D => -- Chegou no estado D, o final da sequencia reconhecido na saida fica no processo 3
				if X = '1' then
					next_state <= B; -- Se for 1, completou a sequencia e ja comeca uma nova com 1
				else
					next_state <= A; -- Se for 0, comeca uma nova sequencia com 0
				end if;
		end case;
   end process;

-- Process 3 - output_function: implements output as function
-- of input X and state.
-- Validaçao do valor de saida dependendo do input X e do estado, caracteristico de Mealy
   output_func: process (X, state)
   begin
      case state is -- Todos os casos diferente de D sao irrelevantes
			when A =>
				Z <= '0';
			when B =>
				Z <= '0';
			when C =>
				Z <= '0';
			when D =>
				if X = '1' then -- Quer dizer que a sequencia foi 1101, saida Z recebe o valor 1 - Esse e o ponto que define a maquina de Mealy, depender de state e X
					Z <= '1';
				else
					Z <= '0';
				end if;
      end case;
   end process;
end;