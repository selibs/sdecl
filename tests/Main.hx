package;

import s.decl.Node;

class Main {
	public static function main() {
		var sdecl = Node.parseFile("example.sdecl");
		var c = sdecl.children[0];
		
		trace(c.type);
		trace(c.name);
		trace(c.children.length);
		trace(sdecl.children[0].get("attr"));

		trace(sdecl.toString());
		trace(sdecl.toJson());
		trace(sdecl.toXml());
	}
}
