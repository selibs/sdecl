package s.decl;

using StringTools;

function isDigit(c:Int)
	return c >= "0".code && c <= "9".code;

function isAlpha(c:Int)
	return c >= "A".code && c <= "Z".code || c >= "a".code && c <= "z".code;

function isEof(c:Int)
	return StringTools.isEof(c);

function isSpace(c:Int)
	return c == "\t".code || c == "\r".code || c == " ".code;

function isBreak(c:Int)
	return c == "\n".code;

/** Thrown when sdecl parsing fails. */
class ParserError extends haxe.Exception {}

/** Parses sdecl source into a `Node` tree. */
class Parser {
	var i:Int = -1;

	final source:String;
	final path:String;

	/** Creates a parser for sdecl source text. */
	public function new(source:String, ?path:String = "source") {
		this.source = source;
		this.path = path;
	}

	/** Parses the source text into a root node. */
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
			switch skipSpaces() {
				case "{".code:
					parseNodeChild(type, name);
				case x:
					error('{ or identifier expected. Got: ${String.fromCharCode(x)}');
			}

		function parseNodeWithValue(value:String)
			switch skipSpaces() {
				case "@".code:
					junk();
					parseNodeWithName(value, parseIdent());
				case "{".code:
					parseNodeChild(value, null);
				case ":".code:
					switch value {
						case "name", "type", "children": // reserved attribute names
							error('"$value" cannot be used as an attribute name');
						default:
							node.set(value, parseValue());
					}
				case x:
					error('{, @ or : expected. Got: ${String.fromCharCode(x)}');
			}

		while (true)
			switch char() {
				case "@".code:
					junk();
					parseNodeWithName(null, parseIdent());
				case x if (isAlpha(x)): // node type or node attr name
					parseNodeWithValue(parseIdent());
				case "{".code: // node with no type and name
					parseNodeChild(null, null);
				case "}".code:
					break;
				case x if (isEof(x) && finishOnEof):
					break;
				case x if (isSpace(x) || isBreak(x)): // skip spaces
				case x:
					error('} or [@]identifier expected. Got: ${String.fromCharCode(x)}');
			}
	}

	function parseValue() {
		var buf = new StringBuf();

		while (true)
			switch char() {
				case "\n".code, ";".code:
					break;
				case "}".code:
					revert();
					break;
				case "\"".code:
					junk();
					buf.add('"${parseString()}"');
				case x if (isSpace(x)): // skip spaces
				case x if (isEof(x)):
					error("Unexpected End of file");
				case x:
					buf.addChar(x);
			}

		return buf.toString();
	}

	function parseIdent():String {
		var x = skipSpaces();
		var start = i;

		while (isAlpha(x) || isDigit(x))
			x = advance();

		return source.substring(start - 1, i--);
	}

	function parseString():String {
		var start = i;
		var x = advance();

		while (true) {
			if (x == "\\".code) // escape character
				junk();
			else if (x == "\"".code)
				break;
			else if (isEof(x))
				error("Unexpected End of file");
			x = advance();
		}

		return source.substring(start, i);
	}

	function skipSpaces() {
		var x = char();
		while (isSpace(x))
			x = char();
		return x;
	}

	function junk():Void
		i++;

	function revert():Void
		i--;

	function char():Int
		switch advance() {
			case "/".code if (next() == "/".code):
				var x = advance();
				while (x != "\n".code && !isEof(x))
					x = advance();
				return x;
			case x:
				return x;
		}

	function advance():Int
		return source.fastCodeAt(++i);

	function next():Int
		return source.fastCodeAt(i + 1);

	function error(message:String)
		return throw new ParserError('$path: $message');
}
