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
		var buf = new StringBuf();

		// type
		if (type != null)
			buf.add(type);

		// name
		if (name != null) {
			buf.add(" @");
			buf.add(name);
		}

		// {
		buf.add(" {\n");

		// attributes
		for (attr in attributes.keyValueIterator()) {
			buf.add("    ");
			buf.add(attr.key);
			buf.add(": ");
			buf.add(attr.value);
			buf.add("\n");
		}

		// children
		for (child in children) {
			buf.add("\n");
			for (line in child.toString().split("\n")) {
				buf.add("    ");
				buf.add(line);
				buf.add("\n");
			}
		}

		// }
		buf.add("}");

		return buf.toString();
	}
}
