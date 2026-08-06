package s.decl;

class Node {
	public static function parse(source:String, ?path:String = "source")
		return new s.decl.Parser(source, path).parse();

	public static function parseFile(path:String)
		return parse(sys.io.File.getContent(path), path);

	public final type:String;
	public final name:String;
	public final children:Array<Node> = [];
	public final attributes:Map<String, String> = [];

	public function new(type:String = "Node", ?name:String) {
		this.type = type;
		this.name = name;
	}

	public inline function addChild(child:Node)
		children.push(child);

	public inline function removeChild(child:Node)
		children.remove(child);

	public inline function get(attr:String)
		return this.attributes.get(attr);

	public inline function set(attr:String, value:String)
		this.attributes.set(attr, value);

	public function toXml():Xml {
		var el = Xml.createElement(type);
		el.set("name", name ?? "");
		for (attr in attributes.keyValueIterator())
			el.set(attr.key, Std.string(attr.value));
		for (c in children)
			el.addChild(c.toXml());
		return el;
	}

	public function toJson():Dynamic {
		var el = {type: type, name: name, children: [for (c in children) c.toJson()]};
		for (attr in attributes.keyValueIterator())
			Reflect.setField(el, attr.key, attr.value);
		return el;
	}

	public function toString():String {
		var at = [for (k in attributes.keys()) '    $k: ${attributes.get(k)}'];
		var ch = [for (c in children) c.toString().split("\n").map(s -> "    " + s).join("\n")];

		var s = type != null ? type : "";
		if (name != null)
			s += " @" + name;
		s += " {\n";

		if (at.length > 0) {
			s += at.join("\n");
			if (ch.length > 0)
				s += "\n\n";
		}

		if (ch.length > 0)
			s += ch.join("\n\n");

		s += "\n}";

		return s;
	}
}
