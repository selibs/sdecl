# sdecl

`sdecl` is a small declarative language for tree-shaped data.

It is designed to be:
- compact
- fast
- easy to parse
- convenient for UI markup, config files, and build descriptions

The core of the language only provides an AST. Attribute values are stored as `String`, and their meaning is defined by the code that consumes the parsed tree.

## Syntax

```sdecl
App @root {
    title: "Hello"
    width: 800

    Button @ok {
        text: "OK"
    }

    {
        visible: true
    }
}
```

Rules:
- `Type { ... }` creates a node with explicit type
- `@name { ... }` creates a node with implicit `Node` type
- `{ ... }` creates a node with implicit type and no name
- `attr: value` defines an attribute
- quoted strings keep spaces
- unquoted values are parsed as raw strings without spaces

Reserved attribute names:
- `type`
- `name`
- `children`

## Haxe API

```haxe
import s.decl.Node;

var root = Node.parse(source);
var fileRoot = Node.parseFile("example.sdecl");
```

Each parsed node contains:
- `type:String`
- `name:String`
- `attributes:Map<String, String>`
- `children:Array<Node>`

## Development

Run tests:

```bash
haxe build_tests.hxml
```
