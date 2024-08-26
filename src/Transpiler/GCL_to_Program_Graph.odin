package Transpiler

import "../AST"
import "core:fmt"
import "core:os"

transpile_gcl_to_program_graph_and_print_to_file :: proc(
    command: ^AST.Command,
    is_deterministic: bool = false,
    filepath: string = "graph.gv",
) {
    source := AST.node_make(0)
    target := AST.node_make(-1)
    acc := make([dynamic]AST.Edge)
    index := 1

    if is_deterministic {
        edges_deterministic(source, target, command, &acc, &index)
    } else {
        edges(source, target, command, &acc, &index)
    }

    pg := AST.program_graph_make(acc[:])
    dot := AST.program_graph_to_string(pg)
    os.write_entire_file(filepath, transmute([]u8)dot)
}

@(private = "file")
edges :: proc(
    source: AST.Node,
    target: AST.Node,
    command: ^AST.Command,
    acc: ^[dynamic]AST.Edge,
    index: ^int,
) {
    switch c in command {
    case AST.Assignment:
        action := AST.action_make(c.x, c.a)
        edge := AST.edge_make(source, target, action)
        append_elem(acc, edge)

    case AST.Array_Assignment:
        action := AST.action_make(c.name, c.index, c.value)
        edge := AST.edge_make(source, target, action)
        append_elem(acc, edge)

    case AST.Skip:
        action := AST.action_make()
        edge := AST.edge_make(source, target, action)
        append_elem(acc, edge)

    case AST.Chain:
        fresh_node := AST.node_make(index^)
        index^ += 1

        edges(source, fresh_node, c.first, acc, index)
        edges(fresh_node, target, c.second, acc, index)

    case AST.If:
        edges_guard_command(source, target, c.gc, acc, index)

    case AST.Do:
        b := done(c.gc)

        edges_guard_command(source, source, c.gc, acc, index)

        cond_action := AST.action_make(b)
        edge := AST.edge_make(source, target, cond_action)
        append_elem(acc, edge)
    }
}

@(private = "file")
edges_guard_command :: proc(
    source: AST.Node,
    target: AST.Node,
    gc: ^AST.Guard_Command,
    acc: ^[dynamic]AST.Edge,
    index: ^int,
) {
    switch gc in gc {
    case AST.Then:
        fresh_node := AST.node_make(index^)
        index^ += 1

        edges(fresh_node, target, gc.body, acc, index)

        cond_action := AST.action_make(gc.condition)
        edge := AST.edge_make(source, fresh_node, cond_action)
        append_elem(acc, edge)

    case AST.Else:
        edges_guard_command(source, source, gc.left, acc, index)
        edges_guard_command(source, source, gc.right, acc, index)
    }
}

@(private = "file")
done :: proc(gc: ^AST.Guard_Command) -> (b: ^AST.Boolean) {
    switch gc in gc {
    case AST.Then:
        b = AST.boolean_make(gc.condition, AST.Unary_B_Op.NOT)
    case AST.Else:
        lhs := done(gc.left)
        rhs := done(gc.right)
        b = AST.boolean_make(lhs, rhs, AST.Binary_B_Op.AND)
    }
    return
}

@(private = "file")
edges_deterministic :: proc(
    source: AST.Node,
    target: AST.Node,
    command: ^AST.Command,
    acc: ^[dynamic]AST.Edge,
    index: ^int,
) {
    switch c in command {
    case AST.Assignment:
        action := AST.action_make(c.x, c.a)
        edge := AST.edge_make(source, target, action)
        append_elem(acc, edge)

    case AST.Array_Assignment:
        action := AST.action_make(c.name, c.index, c.value)
        edge := AST.edge_make(source, target, action)
        append_elem(acc, edge)

    case AST.Skip:
        action := AST.action_make()
        edge := AST.edge_make(source, target, action)
        append_elem(acc, edge)

    case AST.Chain:
        fresh_node := AST.node_make(index^)
        index^ += 1

        edges_deterministic(source, fresh_node, c.first, acc, index)
        edges_deterministic(fresh_node, target, c.second, acc, index)

    case AST.If:
        f := AST.boolean_make(false)
        _ = edges_guard_command_deterministic(
            source,
            target,
            c.gc,
            acc,
            index,
            f,
        )

    case AST.Do:
        f := AST.boolean_make(false)
        d := edges_guard_command_deterministic(
            source,
            source,
            c.gc,
            acc,
            index,
            f,
        )

        cond := AST.boolean_make(d, AST.Unary_B_Op.NOT)
        cond_action := AST.action_make(cond)
        edge := AST.edge_make(source, target, cond_action)
        append_elem(acc, edge)
    }
}

@(private = "file")
edges_guard_command_deterministic :: proc(
    source: AST.Node,
    target: AST.Node,
    gc: ^AST.Guard_Command,
    acc: ^[dynamic]AST.Edge,
    index: ^int,
    d: ^AST.Boolean,
) -> (
    new_d: ^AST.Boolean,
) {
    switch gc in gc {
    case AST.Then:
        fresh_node := AST.node_make(index^)
        index^ += 1

        edges_deterministic(fresh_node, target, gc.body, acc, index)

        cond := AST.boolean_make(
            gc.condition,
            AST.boolean_make(d, AST.Unary_B_Op.NOT),
            AST.Binary_B_Op.AND,
        )
        cond_action := AST.action_make(cond)
        edge := AST.edge_make(source, fresh_node, cond_action)
        append_elem(acc, edge)

        new_d = AST.boolean_make(gc.condition, d, AST.Binary_B_Op.OR)

    case AST.Else:
        temp_d := edges_guard_command_deterministic(
            source,
            target,
            gc.left,
            acc,
            index,
            d,
        )
        new_d := edges_guard_command_deterministic(
            source,
            target,
            gc.left,
            acc,
            index,
            temp_d,
        )
    }
    return
}
