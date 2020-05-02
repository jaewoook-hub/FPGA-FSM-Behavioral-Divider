library IEEE;
library STD; 

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all; 
use std.textio.all;
use work.divider_const.all;


entity divider_tb is
end entity divider_tb;


architecture behavioral of divider_tb is

	component divider is
		port(
			start			:	in std_logic;
			dividend		: 	in std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
			divisor 		:	in std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
			clk			: 	in std_logic;
			rst			:  in std_logic;	
			quotient 	:	out std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
			remainder 	:	out std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
			overflow		: 	out std_logic
		);
	end component divider;
	
	for all : divider use entity work.divider (fsm_behavior);
	
	signal start			:	 std_logic;
	signal rst				: 	 std_logic;
	signal clk				:	 std_logic;
	signal dividend		: 	 std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
	signal divisor			:	 std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
	signal quotient		:	 std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
	signal remainder		:	 std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
	signal overflow		: 	 std_logic;
	signal period			: 	 time := 10 ns;
	
begin
	
	divider_inst : divider 
		port map(
			clk			=> clk,
			rst			=> rst,
			start			=> start,
			dividend		=> dividend,
			divisor 		=> divisor,
			quotient		=> quotient,
			remainder 	=> remainder,
			overflow		=> overflow
		);
		
	clock_process: process is
   begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
   end process clock_process;
	
	reset_process: process is
	begin
		rst <= '1';
		wait for period;
		rst <= '0';
		wait for period;
		rst <= '1';
		wait;
	end process reset_process;
	
	file_process : process is 
	
		--file infile   : text open read_mode is "divider16.in";
		--file outfile  : text open write_mode is "divider16.out";
		file infile    : text open read_mode is "divider32.in";
		file outfile   : text open write_mode is "divider32.out";
		
		variable num1  : integer; 
		variable num2  : integer; 
		variable ln    : line;

	begin
	
		wait for period;
	
		while not(endfile(infile)) loop
			
			readline(infile, ln);
			read(ln, num1);
			readline(infile, ln);
			read(ln, num2);

			dividend <= std_logic_vector(to_signed(num1, DIVIDEND_WIDTH));
			divisor <= std_logic_vector(to_signed(num2, DIVISOR_WIDTH));

			start <= '1';
			wait for 10 ns;
			start <= '0';
			wait for 10 ns;
			start <= '1';

			wait for 100 ns;

			write(ln, num1); 
			write(ln, string'(" / "));
			write(ln, num2);
			write(ln, string'(" = ")); 
			write(ln, to_integer(signed(quotient)));
			write(ln, string'(" -- "));
			write(ln, to_integer(signed(remainder)));
			writeline(outfile, ln);
		
		end loop;
      wait;
	end process;
end architecture behavioral;