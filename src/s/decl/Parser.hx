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
final RESERVED = ["name", "type", "children"];

class Parser {
	var i:Int = -1;

	final source:String;
	final path:String;

	public function new(source:String, ?path:String = "source") {
		this.source = source;
		this.path = path;
	}

	public function parse(?type:String, ?name:String):Node {
		var decl = new Node(type, name);
		parseDecl(decl, true);
		return decl;
	}

	function parseDecl(decl:Node, ?finishOnEof:Bool = false) {
		function parseDeclWithName(type:String, name:String)
			switch advance() {
				case "{":
					var d = new Node(type, name);
					parseDecl(d);
					decl.addChild(d);
				case "\n", "\t", "\r", " ": // skip spaces
					parseDeclWithName(type, name);
				case x:
					error('{ or identifier expected. Got: $x');
			}

		function parseDeclName(type:String)
			switch advance() {
				case x if (isAlpha(x)):
					var buf = new StringBuf();
					buf.add(x);
					parseDeclWithName(type, parseIdent(buf));
				case x:
					error('identifier expected. Got: $x');
			}

		function parseDeclWithValue(value:String)
			switch advance() {
				case "#":
					parseDeclName(value);
				case "{":
					var d = new Node(value, null);
					parseDecl(d);
					decl.addChild(d);
				case ":":
					if (RESERVED.contains(value))
						error('"$value" cannot be used as an attribute name');
					decl.set(value, parseDeclAttr(new StringBuf()));
				case "\n", "\t", "\r", " ": // skip spaces
					parseDeclWithValue(value);
				case x:
					error('{, # or : expected. Got: $x');
			}

		switch advance() {
			case "#":
				parseDeclName(null);
				parseDecl(decl, finishOnEof);
			case x if (isAlpha(x)): // decl type or decl attr name
				var buf = new StringBuf();
				buf.add(x);
				parseDeclWithValue(parseIdent(buf));
				parseDecl(decl, finishOnEof);
			case "\n", "\t", "\r", " ": // skip spaces
				parseDecl(decl, finishOnEof);
			case "}":
				return;
			case x if (StringTools.isEof(x.fastCodeAt(0)) && finishOnEof):
				return;
			case x:
				error('} or [#]identifier expected. Got: $x');
		}
	}

	function parseDeclAttr(buf:StringBuf)
		return switch advance() {
			case "\t", "\r", " ": // skip spaces
				parseDeclAttr(buf);
			case "\n", ";":
				buf.toString();
			case "}":
				revert();
				buf.toString();
			case "\"":
				buf.add('"${parseString(new StringBuf())}"');
				parseDeclAttr(buf);
			case x if (StringTools.isEof(x.fastCodeAt(0))):
				error("Unexpected End of file");
			case x:
				buf.add(x);
				parseDeclAttr(buf);
		}

	function parseIdent(buf:StringBuf):String
		return switch next() {
			case x if (isAlpha(x) || isDigit(x)):
				buf.add(x);
				junk();
				parseIdent(buf);
			default:
				buf.toString();
		}

	function parseString(buf:StringBuf):String
		return switch advance(false) {
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

	function junk():Void
		i++;

	function revert():Void
		i--;

	function advance(skipComments:Bool = true):String {
		var c = source.charAt(++i);
		if (skipComments)
			return switch c {
				case "/" if (next() == "/"):
					var x = advance();
					while (x != "\n" && !StringTools.isEof(x.fastCodeAt(0)))
						x = advance();
					x;
				case x: x;
			}
		else
			return c;
	}

	function next():String
		return source.charAt(i + 1);

	function error(message:String)
		return throw new ParserError('$path: $message');
}
