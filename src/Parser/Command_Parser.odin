package Parser

import "../AST"
import "core:fmt"

/*
    Command     :=
                | Component (; Command)?

    Component   :=
                | "skip"
                | "if" Guard_Command "fi"
                | "do" Guard_Command "od"
                | IDENT ":" "=" Arithmetic
                | IDENT "[" Arithmetic "]" ":" "=" Arithmetic
*/

parse_command :: proc(parser: ^Parser) -> (c: ^AST.Command, ok: bool) {
    // | Component (; Command)?
    c = parse_component(parser) or_return

    if eat_tk(parser, .SEMI_COLON) {
        second := parse_command(parser) or_return
        c = AST.command_make(c, second)
        return c, true
    }

    return c, true
}

@(private = "file")
parse_component :: proc(parser: ^Parser) -> (c: ^AST.Command, ok: bool) {
    // | "skip"
    if eat_tk(parser, .SKIP) {
        c = AST.command_make()
        return c, true
    }

    // | "if" Guard_Command "fi"
    if eat_tk(parser, .IF) {
        gc := parse_guard_command(parser) or_return
        eat_tk(parser, .FI) or_return
        c = AST.command_make(gc, true)
        return c, true
    }

    // | "do" Guard_Command "od"
    if eat_tk(parser, .DO) {
        gc := parse_guard_command(parser) or_return
        eat_tk(parser, .OD) or_return
        c = AST.command_make(gc, false)
        return c, true
    }

    tk := get_tk(parser) or_return
    if eat_tk(parser, .IDENT) {
        // | IDENT ":" "=" Arithmetic
        if eat_tk(parser, .COLON) && eat_tk(parser, .EQ) {
            x := tk.payload.(string)
            a := parse_arithmetic(parser) or_return
            c = AST.command_make(x, a)
            return c, true
        }

        // | IDENT "[" Arithmetic "]" ":" "=" Arithmetic
        name := tk.payload.(string)
        eat_tk(parser, .LEFT_SQ) or_return

        if eat_tk(parser, .RIGHT_SQ) {
            parser.cursor -= 2
        } else {
            index := parse_arithmetic(parser) or_return

            eat_tk(parser, .RIGHT_SQ) or_return
            eat_tk(parser, .COLON) or_return
            eat_tk(parser, .EQ) or_return

            value := parse_arithmetic(parser) or_return

            c = AST.command_make(name, index, value)
            return c, true
        }
    }

    return
}
