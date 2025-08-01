-- Generated on "08/01/2025 16:19:50"
-- Vhdl Test Bench template for design : seq_rec
--
-- Simulation tool : Questa Intel FPGA (VHDL)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY seq_rec_vhd_tst IS
END seq_rec_vhd_tst;

ARCHITECTURE seq_rec_arch OF seq_rec_vhd_tst IS

-- constants
constant CLK_period : time := 10 ns;

-- signals
SIGNAL CLK : STD_LOGIC;
SIGNAL RESET : STD_LOGIC;
SIGNAL X : STD_LOGIC;
SIGNAL Z : STD_LOGIC;

COMPONENT seq_rec
    PORT (
    CLK : IN STD_LOGIC;
    RESET : IN STD_LOGIC;
    X : IN STD_LOGIC;
    Z : OUT STD_LOGIC
    );
END COMPONENT;

BEGIN

    i1 : seq_rec
    PORT MAP (
    CLK => CLK,
    RESET => RESET,
    X => X,
    Z => Z
    );

    -- Clock process definitions
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;


    stimulus_process : PROCESS
    BEGIN

        -- Reset do circuito
        RESET <= '1';
        wait for CLK_period * 2;
        RESET <= '0';
        wait for CLK_period;

        -- Aplica a sequência "011"
        -- Ciclo 1: X = '0'
        X <= '1';
        wait for CLK_period;
        
        -- Ciclo 2: X = '1'
        X <= '1';
        wait for CLK_period;

        -- Ciclo 3: X = '1' (aqui Z deve ir para '1')
        X <= '0';
        wait for CLK_period;
        
        -- Aplica um "0" para verificar que Z volta para '0'
        X <= '1';
        wait for CLK_period;
        
        WAIT; -- Termina a simulação
    END PROCESS stimulus_process;

END seq_rec_arch;
