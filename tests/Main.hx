package;

import s.decl.Node;

class Main {
	public static function main() {
		var sdecl = Node.parseFile("example.sdecl");

		trace(sdecl.children[0].children.length);
		trace(sdecl.children[0].get("attr"));

		trace(sdecl);
	}
}
