package Parser

import "../AST"
import "core:fmt"

@(private = "file")
parse_then :: proc(parser: ^Parser) -> (gc: ^AST.Guard_Command, ok: bool) {
    b := parse_boolean(parser) or_return

    eat_tk(parser, .MINUS) or_return
    eat_tk(parser, .GREATER) or_return

    c := parse_command(parser) or_return

    gc = AST.guard_command_make(b, c)
    return gc, true
}

@(private = "file")
parse_else :: proc(parser: ^Parser) -> (gc: ^AST.Guard_Command, ok: bool) {
    gc = parse_then(parser) or_return

    if eat_tk(parser, .LEFT_SQ) && eat_tk(parser, .RIGHT_SQ) {
        right := parse_else(parser) or_return
        gc = AST.guard_command_make(gc, right)
        return gc, true
    }

    return gc, true
}

parse_guard_command :: proc {
    parse_else,
}
