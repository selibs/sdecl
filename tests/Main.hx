package;

import s.decl.Node;

function assert(condition:Bool, message:String)
	if (!condition)
		throw message;

function assertEq(expected:Dynamic, actual:Dynamic, message:String)
	if (expected != actual)
		throw '$message. expected=$expected actual=$actual';

function expectError(source:String, contains:String)
	try {
		Node.parse(source);
		throw 'Expected error containing "$contains"';
	} catch (e:Dynamic) {
		var message = Std.string(e);
		assert(message.indexOf(contains) != -1, 'Unexpected error: $message');
	}

class Main {
	public static function main() {
		var sdecl = Node.parseFile("example.sdecl");
		var c = sdecl.children[0];

		assertEq("Node", c.type, "implicit node type");
		assertEq("node1", c.name, "named node");
		assertEq(4, c.children.length, "child count");
		assertEq("[0]", c.get("arr"), "array-like value");

		var buttonNode = Node.parse('Button @ok { text: "OK"; width: 100 }').children[0];
		assertEq("Button", buttonNode.type, "explicit type");
		assertEq("ok", buttonNode.name, "explicit name");
		assertEq('"OK"', buttonNode.get("text"), "quoted string");
		assertEq("100", buttonNode.get("width"), "number-like string");

		var anonymous = Node.parse('{ enabled: true }').children[0];
		assertEq("Node", anonymous.type, "anonymous default type");
		assertEq(null, anonymous.name, "anonymous default name");
		assertEq("true", anonymous.get("enabled"), "anonymous attribute");

		expectError('Node { type: value }', 'cannot be used as an attribute name');

		trace("All tests passed");
	}
}
