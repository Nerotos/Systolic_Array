----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2020 23:24:44
-- Design Name: 
-- Module Name: shift_register_lut_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_register_lut_tb is
--  Port ( );
end shift_register_lut_tb;

architecture Behavioral of shift_register_lut_tb is

    constant WIDTH : integer := 8;
    constant DEPTH : integer := 8;
    
    type input_array_type is array (natural range <>) of std_logic_vector(WIDTH-1 downto 0);

    component shift_register_lut is
      generic(
        WIDTH : integer := 32;
        DEPTH : integer := 8
      );
      Port (
        clk         : in std_logic;
        rst         : in std_logic;
        
        wr_en       : in std_logic;
        data_in     : in std_logic_vector(WIDTH-1 downto 0);
        rd_en       : in std_logic;
        data_out    : out std_logic_vector(WIDTH-1 downto 0);
        
        full        : out std_logic;
        empty       : out std_logic
      );
    end component;
    
    constant input_array : input_array_type(0 to 15)  := (
             x"FF",  --0
             x"11",
             x"22",
             x"33",
             x"44",
             x"55",  -- 5
             x"66",
             x"77",
             x"88",
             x"99",
             x"00",  -- 10
             x"AA",
             x"BB",
             x"CC",
             x"DD",
             x"EE"   -- 15
        );
    
    signal clk : std_logic := '0';
    signal rst : std_logic;
    signal wr_en:std_logic;
    signal rd_en:std_logic;
    signal data_in : std_logic_vector(WIDTH-1 downto 0);
    
    signal data_out : std_logic_vector(WIDTH-1 downto 0);
    signal empty : std_logic;
    signal full  : std_logic;
    
    signal cnt : integer := 0;
    signal cycle_cnt : integer := 0;
    
begin

    uut: shift_register_lut
        generic map(
            WIDTH => WIDTH,
            DEPTH => DEPTH
        )
        port map(
        
            clk => clk,
            rst => rst,
            
            wr_en => wr_en,
            rd_en => rd_en,
            data_in => data_in,
            
            data_out => data_out,
            full => full,
            empty=> empty
        
        );
        
    -- Generate clock
    clk_gen: process(clk)
    begin
        clk <= not clk after 5 ns;
    end process;
    
    -- generate stimuli
    stimuli: process
    begin
        wait until rising_edge(clk);
        rst <= '1';
        
        cnt <= 0;
        
        wait for 100 ns;
        rst <= '0';
        
        while cnt < input_array'length loop
            data_in <= input_array(cnt);
            
            rd_en <= '0';
            wr_en <= '0';
            
            cycle_cnt <= cycle_cnt + 1;
            if empty = '0' then
                rd_en <= '1';
            end if;
            
            if full = '0' then
                wr_en <= '1';
                cnt <= cnt + 1;
            end if;
            
            wait until rising_edge(clk);
        end loop;
        
        wr_en <= '0';
        
        wait until rising_edge(clk);
        rd_en <= '1';
    
        wait;
    end process;
    


end Behavioral;
