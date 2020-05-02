library IEEE;
use IEEE.std_logic_1164.all;
use work.divider_const.all;
--Additional standard or custom libraries go here


entity display_divider is
port(
	--Inputs
	signal clk 			: in std_logic;
	signal rst			: in std_logic;
	signal start 		: in std_logic;
	signal dividend 	: in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
	signal divisor 	: in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
	
	--Outputs
	signal quotient 	: out std_logic_vector (7*(DIVIDEND_WIDTH/4) - 1 downto 0);
	signal remainder 	: out std_logic_vector (7*(DIVISOR_WIDTH/4) - 1 downto 0);
	signal overflow 	: out std_logic
);
end entity display_divider;


architecture structure of display_divider is
	
	component divider is
	port(
		--Inputs
		signal clk 			: in std_logic;
		signal rst			: in std_logic;
		signal start 		: in std_logic;
		signal dividend 	: in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
		signal divisor 	: in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
		
		--Outputs
		signal quotient 	: out std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
		signal remainder 	: out std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
		signal overflow 	: out std_logic
	);
	end component divider;
	
	component leddcd is 
	port(
		signal data_in 	  : in std_logic_vector (3 downto 0);
		signal segments_out : out std_logic_vector (6 downto 0)
	);
	end component leddcd;
	
	signal quotient_buf : std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
	signal remainder_buf : std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
	
begin
	
	divider_inst : divider 
	port map (
		clk			=> clk,
		rst			=> rst,
		start 		=> start,
		dividend 	=> dividend,
		divisor 		=> divisor,
		quotient 	=> quotient_buf,
		remainder 	=> remainder_buf,
		overflow 	=> overflow
	);

	quotient_block : for i in 0 to (DIVIDEND_WIDTH/4) - 1 generate 
	begin 	
		quotient_leddcd_inst : leddcd port map ( 
			data_in 		=> quotient_buf((i+1)*4 - 1 downto i*4),
			segments_out 	=> quotient((i+1)*7 - 1 downto i*7)
		);
	end generate;
	
	remainder_block : for i in 0 to (DIVISOR_WIDTH/4) - 1 generate begin
		remainder_leddcd_inst : leddcd port map ( 
			data_in 		=> remainder_buf((i+1)*4 - 1 downto i*4),
			segments_out 	=> remainder((i+1)*7 - 1 downto i*7)
		); 
	end generate;
	
end architecture structure;
