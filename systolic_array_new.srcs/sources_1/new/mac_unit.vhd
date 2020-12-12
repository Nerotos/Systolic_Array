----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.12.2020 22:29:18
-- Design Name: 
-- Module Name: mac_unit - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.systolic_array_lib.ALL;

entity mac_unit is
  generic(
    NUM_ADDITIOns : integer := 5;
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
end mac_unit;

architecture Behavioral of mac_unit is

    signal accumulator : std_logic_vector(2*DATA_WIDTH + NUM_ADDITIONS -1 downto 0);
    signal acc_valid : std_logic;
    signal z_local : std_logic_vector(2*DATA_WIDTH-1 downto 0);
    signal valid_local : std_logic;

begin

    multiply_unit : shift_multiplier 
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        --NUM_PIPELINE_STAGES => 3,
        NUM_SIGN_BITS => NUM_SIGN_BITS
        
    )
    port map(
        clk         => clk,
        rst         => rst,

        x           => x,
        y           => y,
        enable      => enable,

        z           => z_local,
        valid       => valid_local
        );
        
    mac_process: process(clk, rst) 
    
    begin
        if rst = '1' then
            accumulator <= (others => '0');
        else
            if rising_edge(clk) then
            
                -- Accumulate results, respect sign of results
                if valid_local = '1' then
                    
                    if NUM_SIGN_BITS = 1 then
                        accumulator <= std_logic_vector( signed(accumulator) + signed(z_local) );
                    else
                        accumulator <= std_logic_vector( unsigned(accumulator) + unsigned(z_local) );
                    end if;
                    
                    acc_valid <= '1';
                end if;
                
            end if;
        end if;
    end process;
    
    valid <= acc_valid;
    acc <= accumulator;

end Behavioral;
