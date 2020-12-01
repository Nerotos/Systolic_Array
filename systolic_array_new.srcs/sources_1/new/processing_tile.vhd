----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.12.2020 22:30:57
-- Design Name: 
-- Module Name: processing_tile - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Processing Tile of the systolic Array. Implements MAC unit. Data
--   from inputs is shifted to output ports.
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

entity processing_tile is
  generic(
    DATA_WIDTH : integer := 32
  );
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    
    north   : in processing_tile_signal_type(data(DATA_WIDTH-1 downto 0));
    west    : in processing_tile_signal_type(data(DATA_WIDTH-1 downto 0));
    east    : out processing_tile_signal_type(data(DATA_WIDTH-1 downto 0));
    south   : out processing_tile_signal_type(data(DATA_WIDTH-1 downto 0));
    
    acc     : out std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end processing_tile;

architecture Behavioral of processing_tile is
    signal mult_result      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mult_valid       : std_logic;
    signal mult_enable      : std_logic;
    signal accumulator      : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

    mult_enable <= north.ready and west.ready;
    multiplier : shift_multiplier
        generic map(
            DATA_WIDTH => DATA_WIDTH
        )
        port map(
            clk     => clk,
            rst     => rst,
            x       => north.data,
            y       => west.data,
            enable  => mult_enable,
            z       => mult_result,
            valid   => mult_valid
        );
        
    main : process(clk, rst)
    
    begin
        if rst = '1' then
            accumulator <= (others => '0');
        else
            if rising_edge(clk) then
                -- Passthrough of signals
                east <= west;
                south <= north;
                
                if mult_valid = '1' then
                    accumulator <= std_logic_vector( unsigned(mult_result) + unsigned(accumulator) );
                end if;
                
                acc <= accumulator;
            end if;
        end if;
    end process;


end Behavioral;
