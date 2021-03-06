LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity shift_multiplier_tb is
end shift_multiplier_tb;


architecture behav of shift_multiplier_tb is

    component shift_multiplier is
        generic(
            NUM_SIGN_BITS : integer := 0;
            DATA_WIDTH : integer := 32
        );
    
        port(
            clk         : in std_logic;
            rst         : in std_logic;    
    
            x           : in std_logic_vector(DATA_WIDTH-1 downto 0);
            y           : in std_logic_vector(DATA_WIDTH-1 downto 0);
            enable       : in std_logic;
    
            z           : out std_logic_vector(2*DATA_WIDTH-1 downto 0);
            valid       : out std_logic
    
        );
    end component;

    constant TEST_WIDTH : integer := 10;
    constant OUT_WIDTH : integer := 2*TEST_WIDTH;

    -- Input signals
    signal clk : std_logic := '0';
    signal enable : std_logic;
    signal rst : std_logic;

    signal input_x  : std_logic_vector(TEST_WIDTH-1 downto 0);
    signal input_y  : std_logic_vector(TEST_WIDTH-1 downto 0);

    signal output_valid : std_logic;
    signal output_z : std_logic_vector(OUT_WIDTH-1 downto 0);

    signal cnt : integer := 0;

    signal cnt_capture : integer := 0;

    type input_arr_type is array (natural range <>) of std_logic_vector(TEST_WIDTH-1 downto 0);
    type output_arr_type is array (natural range <>)of std_logic_vector(OUT_WIDTH-1 downto 0);

    signal output_capture : output_arr_type (0 to 8);

    -- Define sequence of test inputs and expected outputs
    constant input_x_arr : input_arr_type (0 to 8) := ( std_logic_vector(to_signed(42,TEST_WIDTH)), --0
                                                        std_logic_vector(to_signed( -1,  TEST_WIDTH)),
                                                        std_logic_vector(to_signed( -35,  TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 35,  TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 42,  TEST_WIDTH)),

                                                        std_logic_vector(to_signed( 42,  TEST_WIDTH)), --5
                                                        std_logic_vector(to_signed( 42,  TEST_WIDTH)), 
                                                        std_logic_vector(to_signed( 255,  TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 255,  TEST_WIDTH)) --8
    );
    
    constant input_y_arr : input_arr_type (0 to 8) :=  (std_logic_vector(to_signed(7, TEST_WIDTH)), --0
                                                        std_logic_vector(to_signed( 255, TEST_WIDTH)), 
                                                        std_logic_vector(to_signed( -1, TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 25, TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 10, TEST_WIDTH)),
                                                
                                                        std_logic_vector(to_signed( 7, TEST_WIDTH)), --5
                                                        std_logic_vector(to_signed( 5, TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 1, TEST_WIDTH)),
                                                        std_logic_vector(to_signed( 0, TEST_WIDTH)) --8
	);

    constant output_z_arr: output_arr_type(0 to 8) :=  (std_logic_vector(to_signed(294, OUT_WIDTH)), --0
                                                        std_logic_vector(to_signed( -255, OUT_WIDTH)), 
                                                        std_logic_vector(to_signed( 35, OUT_WIDTH)),
                                                        std_logic_vector(to_signed( 875, OUT_WIDTH)),
                                                        std_logic_vector(to_signed( 420, OUT_WIDTH)),
                                                
                                                        std_logic_vector(to_signed( 294, OUT_WIDTH)), --5
                                                        std_logic_vector(to_signed( 210, OUT_WIDTH)),
                                                        std_logic_vector(to_signed( 255, OUT_WIDTH)),
                                                        std_logic_vector(to_signed( 0, OUT_WIDTH)) --8
    );
    
begin
    uut: shift_multiplier
    generic map(
        NUM_SIGN_BITS => 1,
        DATA_WIDTH => TEST_WIDTH
    )
    port map(
        clk     => clk,
        rst     => rst,    

        x       => input_x,
        y       => input_y,
        enable   => enable,

        z       => output_z,
        valid   => output_valid
    );

    -- Generate clock
    clk_gen: process(clk)
    begin
        clk <= not clk after 5 ns;
    end process;

    -- Generate stimuli
    stim_gen: process
    begin 
        wait until rising_edge(clk);
        rst <= '1';
        enable <= '0';

        cnt <= 0;
        
        wait for 100 ns;
        rst <= '0';

        

        while cnt < (input_x_arr'length) loop
            input_x <= input_x_arr(cnt);
            input_y <= input_y_arr(cnt);
            enable <= '1';
            
            cnt <= cnt+1;
            
            wait until rising_edge(clk);
        end loop;
        
        enable <= '0';
    
        wait;
    end process;

    -- Capture output
    cap_out : process(output_z)
    begin
        if output_valid = '1' and cnt_capture <= output_capture'length-1 then
            output_capture(cnt_capture) <= output_z;
            cnt_capture <= cnt_capture+1;
        end if;

    end process;

end behav;

