use fmt;
use io;
use bufio;
use os;
use math::random;

export type state = struct {
	turn: rune,
	table: [3][3]rune
};

export type move = struct {
	value: int,
	has_move: bool,
	x: u8,
	y: u8
};

export fn state_new() state = {
	return struct {
		turn: rune = 'X',
		table: [3][3]rune = [
			[' ',' ',' '],
			[' ',' ',' '],
			[' ',' ',' ']
		]
	};
};

export fn move_new(x: u8, y: u8, has_move: bool) move = {
	return struct {
		value: int = 0,
		has_move: bool = has_move,
		x: u8 = x,
		y: u8 = y
	};
};

export fn state_print(s: state) (void | io::error) = {
	fmt::printf(" ")?;
	for (let j= 0z; j<len(s.table[0]); j+=1) {
		fmt::printf(" {}", j+1)?;
	};
	fmt::printfln("")?;
	for (let i = 0z; i<len(s.table); i+=1) {
		fmt::printf("{}", ('a' + i) : rune)?;
		for (let j= 0z; j<len(s.table[j]); j+=1) {
			fmt::printf("|{}", s.table[i][j])?;
		};
		fmt::printfln("|")?;
	};
};

export fn move_found(m: move, l: []move) bool = {
	for (let i=0z; i<len(l); i+=1) {
		if (m.x == l[i].x && m.y == l[i].y) {
			return true;
		};
	};
	return false;
};

export fn move_readline(s: state, l: []move) (move | io::error) = {
	if (len(l)==0) {
		return move_new(0, 0, false);
	};
	for (true) {
		fmt::printf("Moves {}> ", s.turn)?;
		bufio::flush(os::stdout)?;
		match (bufio::read_line(os::stdin)?) {
		case let line : io::EOF =>
			return move_new(0, 0, false);
		case let line : []u8 =>
			if (len(line) == 0) {
				continue;
			};
			if (len(line) != 2) {
				fmt::printfln("Invalid coordinates (1).")?;
				continue;
			};
			let x = line[0] - 'a';
			let y = line[1] - '1';
			if (x < 0 || x >= 3 || y < 0 || y >= 3) {
				fmt::printfln("Invalid coordinates (2).")?;
				continue;
			};
			let m = move_new(x, y, true);
			if (!move_found(m, l)) {
				fmt::printfln("Invalid movement.")?;
				continue;
			};
			return m;
		};
	};
};

export fn state_moves(s: state) []move = {
	let a : []move = [];
	for (let x = 0u8; x<3; x += 1) {
		for (let y = 0u8; y<3; y+=1) {
			if (s.table[x][y]==' ') {
				append(a, move_new(x, y, true));
			};
		};
	};
	return a;
};

export fn state_apply(s: state, m: move) state = {
	if (s.table[m.x][m.y] == ' ') {
		s.table[m.x][m.y] = s.turn;
		if (s.turn == 'X') {
			s.turn = 'O';
		} else {
			s.turn = 'X';
		};
	};
	return s;
};

export fn state_winner(s: state) rune = {
	let l: [][3][2]u8 = [
		[ [0,0], [0,1], [0,2] ],
		[ [1,0], [1,1], [1,2] ],
		[ [2,0], [2,1], [2,2] ],
		
		[ [0,0], [1,0], [2,0] ],
		[ [0,1], [1,1], [2,1] ],
		[ [0,2], [1,2], [2,2] ],
		
		[ [0,0], [1,1], [2,2] ],
		[ [0,2], [1,1], [2,0] ]
	];
	for (let i=0z; i<len(l); i+=1) {
		let p0x = l[i][0][0]; let p0y = l[i][0][1];
		let p1x = l[i][1][0]; let p1y = l[i][1][1];
		let p2x = l[i][2][0]; let p2y = l[i][2][1];
		let x = s.table[p0x][p0y];
		let y = s.table[p1x][p1y];
		let z = s.table[p2x][p2y];
		if (x != ' ' && x == y && y == z) {
			return x;
		};
	};
	return ' ';
};

export fn state_value(s: state, p: rune) int = {
	let r = state_winner(s);
	if (r == p) {
		return 1;
	} else if (r == ' ') {
		return 0;
	} else {
		return -1;
	};
};

export fn minimax(s: state, p: rune, r: *math::random::random) move = {
	let maximizer: bool = (s.turn == p);
	let winner: rune = state_winner(s);
	let ret: move = move_new(0, 0, false);
	
	if (winner != ' ') {
		if (winner == p) {
			ret.value = 2;
			return ret;
		} else {
			ret.value = -2;
			return ret;
		};
	};
	
	if (maximizer) {
		ret.value = 1;
	} else {
		ret.value = -1;
	};
	
	let moves = moves_shuffle(state_moves(s), r);
	for (let i=0z; i<len(moves); i+=1) {
		let ns = state_apply(s, moves[i]);
		let nv = minimax(ns, p, r);
		if (maximizer && nv.value > ret.value) {
			ret = moves[i];
			ret.value = nv.value;
		} else if (!maximizer && nv.value < ret.value) {
			ret = moves[i];
			ret.value = nv.value;
		} else if (!ret.has_move) {
			ret = moves[i];
			ret.value = nv.value;
		};
	};
	
	return ret;
};

export fn moves_shuffle(ml: []move, r: *math::random::random) []move = {
	for (let i=0z; i<len(ml); i+=1) {
		let j = math::random::u64n(r,  len(ml));
		let mi = ml[i];
		let mj = ml[j];
		ml[j] = mi;
		ml[i] = mj;
	};
	return ml;
};
