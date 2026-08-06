package s.decl;

/** A parsed sdecl node. */
class Node {
	/** Parses sdecl source text into a root node. */
	public static function parse(source:String, ?path:String = "source")
		return new s.decl.Parser(source, path).parse();

	/** Parses an sdecl file into a root node. */
	public static function parseFile(path:String)
		return parse(sys.io.File.getContent(path), path);

	/** Node type. Defaults to `Node` when omitted. */
	public final type:String;

	/** Optional node name written as `@name`. */
	public final name:String;

	/** Child nodes in source order. */
	public final children:Array<Node> = [];

	/** Raw attribute values keyed by attribute name. */
	public final attributes:Map<String, String> = [];

	/** Creates a node with an optional type and name. */
	public function new(type:String = "Node", ?name:String) {
		this.type = type;
		this.name = name;
	}

	/** Adds a child node. */
	public inline function addChild(child:Node)
		children.push(child);

	/** Removes a child node. */
	public inline function removeChild(child:Node)
		children.remove(child);

	/** Returns a raw attribute value by name. */
	public inline function get(attr:String)
		return this.attributes.get(attr);

	/** Sets a raw attribute value. */
	public inline function set(attr:String, value:String)
		this.attributes.set(attr, value);

	/** Converts the node tree to XML. */
	public function toXml():Xml {
		var el = Xml.createElement(type);
		el.set("name", name ?? "");
		for (attr in attributes.keyValueIterator())
			el.set(attr.key, Std.string(attr.value));
		for (c in children)
			el.addChild(c.toXml());
		return el;
	}

	/** Converts the node tree to a dynamic JSON-like object. */
	public function toJson():Dynamic {
		var el = {type: type, name: name, children: [for (c in children) c.toJson()]};
		for (attr in attributes.keyValueIterator())
			Reflect.setField(el, attr.key, attr.value);
		return el;
	}

	/** Serializes the node tree back to sdecl text. */
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
