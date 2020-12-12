LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity mac_unit_tb is
end mac_unit_tb;


architecture behav of mac_unit_tb is

    component mac_unit is
      generic(
        NUM_ADDITIONS : integer := 5;
        DATA_WIDTH : integer := 32;
        --NUM_PIPELINE_STAGES: integer := 3; -- Configure number of pipeline stages
        NUM_SIGN_BITS: integer := 0 -- Set to '1' to enable signed operations
      );
      port ( 
        clk         : in std_logic;
        rst         : in std_logic;
        
        x           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        y           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        enable      : in std_logic;
    
        acc           : out std_logic_vector(2*DATA_WIDTH + NUM_ADDITIONS -1 downto 0);
        valid       : out std_logic
      );
    end component;

    constant TEST_WIDTH : integer := 10;
    constant NUM_ADDITIONS : integer := 8;
    constant OUT_WIDTH : integer := 2*TEST_WIDTH;

    -- Input signals
    signal clk : std_logic := '0';
    signal enable : std_logic;
    signal rst : std_logic;

    signal input_x  : std_logic_vector(TEST_WIDTH-1 downto 0);
    signal input_y  : std_logic_vector(TEST_WIDTH-1 downto 0);

    signal output_valid : std_logic;
    signal output_z : std_logic_vector(OUT_WIDTH-1+NUM_ADDITIONS downto 0);

    signal cnt : integer := 0;

    signal cnt_capture : integer := 0;

    type input_arr_type is array (natural range <>) of std_logic_vector(TEST_WIDTH-1 downto 0);
    type output_arr_type is array (natural range <>)of std_logic_vector(OUT_WIDTH-1 downto 0);

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

    constant output_z_arr : std_logic_vector(OUT_WIDTH-1+NUM_ADDITIONS downto 0) := std_logic_vector(to_signed(2383, OUT_WIDTH+NUM_ADDITIONS));

    
    
begin
    uut: mac_unit
    generic map(
        NUM_SIGN_BITS => 1,
        NUM_ADDITIONS => 8,
        DATA_WIDTH => TEST_WIDTH
    )
    port map(
        clk     => clk,
        rst     => rst,    

        x       => input_x,
        y       => input_y,
        enable   => enable,

        acc       => output_z,
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



end behav;

