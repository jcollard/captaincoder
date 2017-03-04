package application;

public class GameBoard {

	/* Array that will contain the complete solution to the board */
	private int[][] solution;
	/* Array that will contain ONLY the numbers initially drawn on the board and that the player can't change */
	private int[][] initial;
	/* Array that will contain player's numbers */
	private int[][] player;

	public GameBoard() {
		solution = new int[][]
		{
			{5,3,8,4,6,1,7,9,2},
			{6,9,7,3,2,5,8,1,4},
			{2,1,4,7,8,9,5,6,3},
			{9,4,1,2,7,8,6,3,5},
			{7,6,2,1,5,3,9,4,8},
			{8,5,3,9,4,6,1,2,7},
			{3,8,9,5,1,2,4,7,6},
			{4,2,6,8,9,7,3,5,1},
			{1,7,5,6,3,4,2,8,9}
		};

		// 0's will be rendered as empty space and will be editable by player
		initial = new int[][]
		{
			{0,0,0,4,0,0,0,9,0},
			{6,0,7,0,0,0,8,0,4},
			{0,1,0,7,0,9,0,0,3},
			{9,0,1,0,7,0,0,3,0},
			{0,0,2,0,0,0,9,0,0},
			{0,5,0,0,4,0,1,0,7},
			{3,0,0,5,0,2,0,7,0},
			{4,0,6,0,0,0,3,0,1},
			{0,7,0,0,0,4,0,0,0}
		};

		// player's array is initialized as a 9x9 full of zeroes
		player = new int[9][9];
	}

	// returns the solution array
	public int[][] getSolution() {
		return solution;
	}

	// returns the initial filled-in numbers array
	public int[][] getInitial() {
		return initial;
	}

	// returns the player array
	public int[][] getPlayer() {
		return player;
	}

	// modifies a value in the player array
	public void modifyPlayer(int val, int row, int col) {
		if(val >=0 && val <= 9) // only values from 0 to 9 inclusive are permitted
			player[row][col] = val;
		else // print out an error message
			System.out.println("Value passed to player falls out of range");
	}

}
