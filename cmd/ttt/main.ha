use fmt;
use bufio;
use os;
use io;
use time;
use strings;
use math::random;
use encoding::utf8;
use ttt = games::ttt;


export fn main() void = {
	let state: ttt::state = ttt::state_new();
	const winner: rune = ' ';
	const human: rune = 'O';
	const seed = 1; //time::unix(time::now(time::clock::REALTIME));
	const rand = math::random::init(seed : u64);
	
	for (true) {
		ttt::state_print(state)!;
		winner = ttt::state_winner(state);
		if (winner != ' ') {
			fmt::printfln("The winner is '{}'.", winner)!;
			break;
		};
		if (state.turn == human) {
			let moves = ttt::state_moves(state);
			let move = ttt::move_readline(state, moves)!;
			if (!move.has_move) {
				fmt::printfln("No winner.")!;
				break;
			};
			state = ttt::state_apply(state, move);
		} else {
			let move = ttt::minimax(state, state.turn, &rand);
			if (!move.has_move) {
				fmt::printfln("No winner.")!;
				break;
			};
			state = ttt::state_apply(state, move);
		};
	};
};
