----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.12.2020 22:26:09
-- Design Name: 
-- Module Name: systolic_array_lib - 
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

package systolic_array_lib is


    ------------------------------------
    -- Type Declarations
    ------------------------------------
    type matrix_size_type is array(0 to 1) of integer range 0 to 1024;

    ------------------------------------
    -- Component Declarations
    ------------------------------------
    component shift_multiplier is
        generic(
            DATA_WIDTH : integer := 32;
            --NUM_PIPELINE_STAGES: integer := 3; -- Configure number of pipeline stages
            NUM_SIGN_BITS: integer := 0 -- Set to '1' to enable signed operations
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

    
end package systolic_array_lib;
 
-- Package Body Section
package body systolic_array_lib is
 
    ------------------------------------
    -- Function Definitions
    ------------------------------------

 
end package body systolic_array_lib;

