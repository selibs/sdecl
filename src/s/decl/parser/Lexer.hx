package s.decl.parser;

using StringTools;

function isDigit(char:String) {
	final c = char.fastCodeAt(0);
	return c >= "0".code && c <= "9".code;
}

function isAlpha(char:String) {
	final c = char.fastCodeAt(0);
	return c >= "A".code && c <= "Z".code || c >= "a".code && c <= "z".code;
}

class Lexer {
	var i:Int = -1;
	var buf:StringBuf;

	public var line(default, null):Int = 1;
	public var lineChar(default, null):Int = 1;

	final source:String;
	final path:String;

	public function new(source:String, ?path:String = "source") {
		this.source = source;
		this.path = path;
	}

	public function token():Token
		return switch advance() {
			case "@": TAt;
			case "%": TMod;
			case "#": THash;
			case "$": TDollar;
			case "=": TEquals;
			case "<": TLower;
			case ">": TGreater;
			case "+": TPlus;
			case "-": TMinus;
			case "*": TAsterisk;
			case "/": next() == "/" ? tokenLineBreak() : TSlash;
			case ".": TDot;
			case ":": TDbDot;
			case ",": TComma;
			case ";": TSemicolon;
			case "{": TBrOpen;
			case "}": TBrClose;
			case "(": TParenOpen;
			case ")": TParenClose;
			case "\"":
				buf = new StringBuf();
				tokenString();
			case "\n":
				line++;
				lineChar = 1;
				TLineBreak;
			case x if (isAlpha(x)):
				buf = new StringBuf();
				buf.add(x);
				tokenIdent();
			case x if (isDigit(x)):
				buf = new StringBuf();
				buf.add(x);
				tokenNumber();
			case "\t", "\r", " ": token();
			case x if (StringTools.isEof(x.fastCodeAt(0))): TEof;
			case x:
				error("Unexpected " + x);
		}

	public function error(message:String) {
		Sys.println('$path:$line: character $lineChar : $message');
		Sys.exit(1);
		return null;
	}

	function tokenString():Token
		return switch advance() {
			case "\"": TString(buf.toString());
			case c:
				buf.add(c);
				tokenString();
		}

	function tokenLineBreak():Token
		return switch advance() {
			case "\n":
				line++;
				lineChar = 1;
				TLineBreak;
			default: tokenLineBreak();
		}

	function tokenIdent():Token
		return switch next() {
			case x if (isAlpha(x) || isDigit(x)):
				buf.add(x);
				junk();
				tokenIdent();
			default:
				TIdent(buf.toString());
		}

	function tokenNumber():Token
		return switch next() {
			case x if (isDigit(x)):
				buf.add(x);
				junk();
				tokenNumber();
			default: TNumber(buf.toString());
		}

	function junk():Void {
		lineChar++;
		i++;
	}

	function advance():String {
		lineChar++;
		return source.charAt(++i);
	}

	function next():String
		return source.charAt(i + 1);
}
