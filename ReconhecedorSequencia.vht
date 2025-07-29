-- Copyright (C) 2025  Altera Corporation. All rights reserved.
-- Seu uso das ferramentas de design, funções lógicas da Altera
-- e outros softwares e ferramentas está sujeito aos termos e condições
-- do Contrato de Licença do Programa Altera.
--
-- Vhdl Test Bench gerado para o design: ReconhecedorSequencia
-- Ferramenta de Simulação: Questa Intel FPGA (VHDL)

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ReconhecedorSequencia_vhd_tst IS
END ReconhecedorSequencia_vhd_tst;

ARCHITECTURE ReconhecedorSequencia_arch OF ReconhecedorSequencia_vhd_tst IS
    -- =========================================================================
    -- ==                         CONSTANTES DE TESTE                         ==
    -- =========================================================================
    -- Define o tempo para simular um "click" no botão KEY(0)
    constant KEY_PRESS_TIME : time := 20 ns;

    -- =========================================================================
    -- ==                               SINAIS                              ==
    -- =========================================================================
    -- Sinais de entrada para o nosso componente (DUT - Device Under Test)
    SIGNAL KEY : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '1'); -- Inicia com reset inativo
    SIGNAL SW  : STD_LOGIC_VECTOR(0 DOWNTO 0) := (others => '0'); -- Inicia com entrada 0

    -- Sinais de saída do nosso componente (DUT)
    SIGNAL HEX0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL HEX2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL LEDR : STD_LOGIC_VECTOR(9 DOWNTO 0);

    -- =========================================================================
    -- ==                         DECLARAÇÃO DO COMPONENTE                    ==
    -- =========================================================================
    -- Declaração da entidade que vamos testar
    COMPONENT ReconhecedorSequencia
        PORT (
            SW   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            KEY  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            LEDR : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
            HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

BEGIN
    -- =========================================================================
    -- ==                       INSTANCIAÇÃO DO COMPONENTE                    ==
    -- =========================================================================
    -- Conecta os sinais do testbench às portas do componente
    i1 : ReconhecedorSequencia
        PORT MAP (
            SW   => SW,
            KEY  => KEY,
            LEDR => LEDR,
            HEX0 => HEX0,
            HEX2 => HEX2
        );

    -- =========================================================================
    -- ==                        PROCESSO DE ESTÍMULOS                        ==
    -- =========================================================================
    -- Este processo gera os sinais de entrada (estímulos) para testar o DUT.
    stim_proc : PROCESS

        -- Procedure para simular um click no botão (borda de subida)
        procedure pressionar_tecla is
        begin
            KEY(0) <= '0';
            wait for KEY_PRESS_TIME / 2;
            KEY(0) <= '1'; -- Borda de subida
            wait for KEY_PRESS_TIME / 2;
            KEY(0) <= '0';
        end procedure pressionar_tecla;

    BEGIN
        -- -----------------------------------------------------------------
        -- TESTE 1: Reset do sistema
        -- -----------------------------------------------------------------
        report "INICIANDO SIMULACAO: Testando o reset...";
        KEY(1) <= '0'; -- Ativa o reset (ativo em baixo)
        wait for 50 ns;
        KEY(1) <= '1'; -- Desativa o reset
        wait for KEY_PRESS_TIME;

        -- -----------------------------------------------------------------
        -- TESTE 2: Sequência CORRETA (1101)
        -- -----------------------------------------------------------------
        report "TESTE 2: Enviando a sequencia correta 1101...";
        
        -- Enviando '1'
        SW(0) <= '1';
        pressionar_tecla; -- Deverá ir para o estado B
        
        -- Enviando '1'
        SW(0) <= '1';
        pressionar_tecla; -- Deverá ir para o estado C
        
        -- Enviando '0'
        SW(0) <= '0';
        pressionar_tecla; -- Deverá ir para o estado D
        
        -- Enviando '1'
        SW(0) <= '1';
        pressionar_tecla; -- Deverá ir para o estado E (SUCESSO!)
        
        wait for 50 ns; -- Pausa para observar a saída de sucesso

        -- -----------------------------------------------------------------
        -- TESTE 3: Sequência INCORRETA (111...)
        -- -----------------------------------------------------------------
        report "TESTE 3: Enviando uma sequencia incorreta 111...";
        KEY(1) <= '0'; wait for 20 ns; KEY(1) <= '1'; -- Reseta novamente
        
        -- Enviando '1'
        SW(0) <= '1';
        pressionar_tecla; -- Vai para B
        
        -- Enviando '1'
        SW(0) <= '1';
        pressionar_tecla; -- Vai para C

        -- Enviando '1' (quebra a sequência)
        SW(0) <= '1';
        pressionar_tecla; -- Fica em C (conforme a lógica do seu código)

        wait for 50 ns;

        -- -----------------------------------------------------------------
        -- TESTE 4: Sequência com Sobreposição (Overlapping)
        -- A sequência é 1101. A entrada 1101101 deve ser reconhecida uma vez
        -- e preparar o início da segunda.
        -- -----------------------------------------------------------------
        report "TESTE 4: Enviando sequencia com sobreposicao 11011...";
        KEY(1) <= '0'; wait for 20 ns; KEY(1) <= '1'; -- Reseta novamente

        -- Enviando a primeira sequência correta: 1101
        SW(0) <= '1'; pressionar_tecla; -- A -> B
        SW(0) <= '1'; pressionar_tecla; -- B -> C
        SW(0) <= '0'; pressionar_tecla; -- C -> D
        SW(0) <= '1'; pressionar_tecla; -- D -> E (SUCESSO 1)

        -- Agora, o último '1' da sequência pode ser o primeiro '1' de uma nova.
        -- A sua FSM vai de E para B com entrada '1'
        report "TESTE 4: Verificando a sobreposicao...";
        SW(0) <= '1';
        pressionar_tecla; -- E -> B (Início da próxima sequência)
        
        -- A máquina está agora no estado B, pronta para receber "101".

        report "SIMULACAO CONCLUIDA.";
        WAIT; -- Fim do processo de estímulos, para a simulação.
    END PROCESS stim_proc;

END ReconhecedorSequencia_arch;