package s.decl.parser;

function toString(token:Token)
	return switch token {
		case TAt: "@";
		case TMod: "%";
		case THash: "#";
		case TDollar: "$";
		case TEquals: "=";
		case TLower: "<";
		case TGreater: ">";
		case TPlus: "+";
		case TMinus: "-";
		case TAsterisk: "*";
		case TSlash: "/";
		case TDot: ".";
		case TDbDot: ":";
		case TComma: ",";
		case TSemicolon: ";";
		case TBrOpen: "{";
		case TBrClose: "}";
		case TBkOpen: "[";
		case TBkClose: "]";
		case TParenOpen: "(";
		case TParenClose: ")";
		case TIdent(value), TNumber(value), TString(value): value;
		case TLineBreak: "\\n";
		case TEof: "End Of File";
	}

enum Token {
	/** @ **/ TAt;

	/** % **/ TMod;

	/** # **/ THash;

	/** $ **/ TDollar;

	/** = **/ TEquals;

	/** < **/ TLower;

	/** > **/ TGreater;

	/** + **/ TPlus;

	/** - **/ TMinus;

	/** * **/ TAsterisk;

	/** / **/ TSlash;

	/** . **/ TDot;

	/** : **/ TDbDot;

	/** , **/ TComma;

	/** ; **/ TSemicolon;

	/** { **/ TBrOpen;

	/** } **/ TBrClose;

	/** [ **/ TBkOpen;

	/** ] **/ TBkClose;

	/** ( **/ TParenOpen;

	/** ) **/ TParenClose;

	/** Identifier **/ TIdent(value:String);

	/** Number **/ TNumber(value:String);

	/** String **/ TString(value:String);

	/** \n **/ TLineBreak;

	/** \0 **/ TEof;
}
