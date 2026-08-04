package s.decl;

import s.decl.parser.Token;
import s.decl.parser.Lexer;

class Parser {
	final lexer:Lexer;

	public function new(source:String, ?path:String = "source")
		lexer = new Lexer(source, path);

	public function parse(?type:String, ?name:String):Node {
		var node = new Node(type, name);
		parseNode(node);
		return node;
	}

	function parseNode(node:Node)
		switch lexer.token() {
			case THash:
				switch lexer.token() {
					case TIdent(name): // node name
						switch lexer.token() {
							case TBrOpen: parseNodeChild(node, null, name);
							case TIdent(type):
								switch lexer.token() {
									case TBrOpen: parseNodeChild(node, type, name);
									case x: lexer.error('{ expected. Got: ${toString(x)}');
								}
							case x: lexer.error('{ or identifier expected. Got: ${toString(x)}');
						}
					case x: lexer.error('identifier expected. Got: ${toString(x)}');
				}
				parseNode(node);
			case TIdent(value): // node type or attribute name
				switch lexer.token() {
					case THash:
						switch lexer.token() {
							case TIdent(name): // node name
								switch lexer.token() {
									case TBrOpen: parseNodeChild(node, value, name);
									case x: lexer.error('{ expected. Got: ${toString(x)}');
								}
							case x: lexer.error('identifier expected. Got: ${toString(x)}');
						}
					case TBrOpen: parseNodeChild(node, value, null);
					case TDbDot: parseNodeAttr(node, value);
					case x: lexer.error('{, # or : expected. Got: ${toString(x)}');
				}
				parseNode(node);
			case TLineBreak:
				parseNode(node);
			case TBrClose, TEof:
				return;
			case x:
				lexer.error('} or [#]identifier expected. Got: ${toString(x)}');
		}

	function parseNodeChild(node, ?type:String, ?name:String)
		node.addChild(parse(type, name));

	function parseNodeAttr(node:Node, name:String)
		switch lexer.token() {
			// TODO: divide values
			case TIdent(value), TNumber(value), TString(value):
				node.set(name, value);
			case x:
				lexer.error('Number, string or identifier expected. Got: ${toString(x)}');
		}
}
