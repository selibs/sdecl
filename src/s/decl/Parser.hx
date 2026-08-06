package s.decl;

using StringTools;

function isDigit(char:String) {
	final c = char.fastCodeAt(0);
	return c >= "0".code && c <= "9".code;
}

function isAlpha(char:String) {
	final c = char.fastCodeAt(0);
	return c >= "A".code && c <= "Z".code || c >= "a".code && c <= "z".code;
}

class ParserError extends haxe.Exception {}
final ATTR_NAMES_RESERVED = ["name", "type", "children"];
final DIRECTIVE_NAMES = ["define", "undef", "ifdef", "if", "elif", "else", "endif"];

class Parser {
	var i:Int = -1;

	final source:String;
	final path:String;

	public function new(source:String, ?path:String = "source") {
		this.source = source;
		this.path = path;
	}

	public function parse(?type:String, ?name:String):Node {
		var node = new Node(type, name);
		parseNode(node, true);
		return node;
	}

	function parseNode(node:Node, ?finishOnEof:Bool = false) {
		function parseNodeChild(type:String, name:String) {
			var d = new Node(type, name);
			parseNode(d);
			node.addChild(d);
		}

		function parseNodeWithName(type:String, name:String)
			switch char() {
				case "{":
					parseNodeChild(type, name);
				case "\n", "\t", "\r", " ": // skip spaces
					parseNodeWithName(type, name);
				case x:
					error('{ or identifier expected. Got: $x');
			}

		function parseNodeWithValue(value:String)
			switch char() {
				case "@":
					parseNodeWithName(value, expectIdent());
				case "{":
					parseNodeChild(value, null);
				case ":":
					if (ATTR_NAMES_RESERVED.contains(value))
						error('"$value" cannot be used as an attribute name');
					node.set(value, expectValue());
				case "\n", "\t", "\r", " ": // skip spaces
					parseNodeWithValue(value);
				case x:
					error('{, @ or : expected. Got: $x');
			}

		switch char() {
			case "@":
				parseNodeWithName(null, expectIdent());
				parseNode(node, finishOnEof);
			case x if (isAlpha(x)): // node type or node attr name
				var buf = new StringBuf();
				buf.add(x);
				parseNodeWithValue(parseIdent(buf));
				parseNode(node, finishOnEof);
			case "{": // node with no type and name
				parseNodeChild(null, null);
			case "\n", "\t", "\r", " ": // skip spaces
				parseNode(node, finishOnEof);
			case "}":
				return;
			case x if (StringTools.isEof(x.fastCodeAt(0)) && finishOnEof):
				return;
			case x:
				error('} or [@]identifier expected. Got: $x');
		}
	}

	function parseValue(buf:StringBuf)
		return switch char() {
			case "\t", "\r", " ": // skip spaces
				parseValue(buf);
			case "\n", ";":
				buf.toString();
			case "}":
				revert();
				buf.toString();
			case "\"":
				buf.add('"${expectString()}"');
				parseValue(buf);
			case x if (StringTools.isEof(x.fastCodeAt(0))):
				error("Unexpected End of file");
			case x:
				buf.add(x);
				parseValue(buf);
		}

	function expectValue():String
		return parseValue(new StringBuf());

	function parseIdent(buf:StringBuf):String
		return switch next() {
			case x if (isAlpha(x) || isDigit(x)):
				buf.add(x);
				junk();
				parseIdent(buf);
			default:
				buf.toString();
		}

	function expectIdent():String
		return switch char() {
			case "\t", "\r", " ": // skip spaces
				expectIdent();
			case x if (isAlpha(x)):
				var buf = new StringBuf();
				buf.add(x);
				parseIdent(buf);
			case x:
				error('Identifier expected. Got: "$x"');
		}

	function parseString(buf:StringBuf):String
		return switch char(false) {
			case "\"":
				buf.toString();
			case "\\": // escape character
				buf.add("\\");
				buf.add(next());
				junk();
				parseString(buf);
			case x if (StringTools.isEof(x.fastCodeAt(0))):
				error("Unexpected End of file");
			case x:
				buf.add(x);
				parseString(buf);
		}

	function expectString():String
		return parseString(new StringBuf());

	function junk():Void
		i++;

	function revert():Void
		i--;

	function char(skipComments:Bool = true):String {
		var c = advance();

		if (!skipComments)
			return c;

		switch c {
			case "/" if (next() == "/"):
				var x = char();
				while (x != "\n" && !StringTools.isEof(x.fastCodeAt(0)))
					x = char();
				return x;
			default:
				return c;
		}
	}

	function advance():String
		return source.charAt(++i);

	function next():String
		return source.charAt(i + 1);

	function error(message:String)
		return throw new ParserError('$path: $message');
}
