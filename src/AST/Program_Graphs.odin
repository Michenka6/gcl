package AST

import "core:fmt"

Node :: struct {
    payload: int,
    kind:    enum {
        INITIAL,
        FINAL,
        INTERMIDEATE,
    },
}

Program_Graph :: struct {
    edges: []Edge,
}

Edge :: struct {
    source: Node,
    target: Node,
    action: ^Action,
}

Action :: union {
    Skip,
    Assignment,
    Array_Assignment,
    Conditional,
}

Conditional :: struct {
    b: ^Boolean,
}

program_graph_make :: proc(edges: []Edge) -> (pg: ^Program_Graph) {
    pg = new(Program_Graph)
    pg^ = Program_Graph{edges}
    return
}

node_make :: proc(payload: int) -> Node {
    switch payload {
    case -1:
        return Node{-1, .FINAL}
    case 0:
        return Node{0, .INITIAL}
    case:
        return Node{payload, .INTERMIDEATE}
    }
    return Node{69420, .FINAL}
}

edge_make :: proc(source: Node, target: Node, action: ^Action) -> Edge {
    return Edge{source, target, action}
}

@(private = "file")
skip_make :: proc() -> (act: ^Action) {
    act = new(Action)
    act^ = Skip{}
    return
}

@(private = "file")
assignment_make :: proc(x: string, a: ^Arithmetic) -> (act: ^Action) {
    act = new(Action)
    act^ = Assignment{x, a}
    return
}

@(private = "file")
array_assignment_make :: proc(
    x: string,
    index: ^Arithmetic,
    value: ^Arithmetic,
) -> (
    act: ^Action,
) {
    act = new(Action)
    act^ = Array_Assignment{x, index, value}
    return
}

@(private = "file")
conditional_make :: proc(b: ^Boolean) -> (act: ^Action) {
    act = new(Action)
    act^ = Conditional{b}
    return
}

action_make :: proc {
    skip_make,
    assignment_make,
    array_assignment_make,
    conditional_make,
}

action_to_string :: proc(act: ^Action) -> (s: string) {
    switch act in act {
    case Skip:
        s = "skip"
    case Assignment:
        s = fmt.aprintf("%s := %s", act.x, arithmetic_to_string(act.a))
    case Array_Assignment:
        s = fmt.aprintf(
            "%s[%s] := %s",
            act.name,
            arithmetic_to_string(act.index),
            arithmetic_to_string(act.value),
        )
    case Conditional:
        s = boolean_to_string(act.b)
    }
    return
}

node_to_string :: proc(node: Node) -> (s: string) {
    switch node.kind {
    case .INITIAL:
        s = "▷"
    case .INTERMIDEATE:
        s = fmt.aprintf("%v", node.payload)
    case .FINAL:
        s = "◀"
    }
    return
}

edge_to_string :: proc(edge: Edge) -> (s: string) {
    return fmt.aprintf(
        "q%s -> q%s [ label = \"%s\"];",
        node_to_string(edge.source),
        node_to_string(edge.target),
        action_to_string(edge.action),
    )
}

program_graph_to_string :: proc(pg: ^Program_Graph) -> (s: string) {
    s = "digraph {\n"
    for edge in pg.edges {
        s = fmt.aprintf("%s%s\n", s, edge_to_string(edge))
    }
    s = fmt.aprintf("%s}", s)
    return
}
