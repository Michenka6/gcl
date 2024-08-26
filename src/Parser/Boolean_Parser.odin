package Parser

import "../AST"
import "core:fmt"

/*
        Boolean :=
                | BOR ( "&&" Boolean )*
        BOR     :=
                | BNT ( "||" BOR)*
        BNT     :=
                | ( "!" )? ARL
        ARL     :=
                | "(" Boolean ")"
                | Arithmetic ( ( "<=" + "<" + "=" + ">=" + ">") Arithmetic )?
                | TRUE
                | FALSE
*/

@(private)
parse_boolean :: proc(parser: ^Parser) -> (b: ^AST.Boolean, ok: bool) {
    // | BOR ( "&&" Boolean )*
    b = parse_BOR(parser) or_return

    tk, got_tk := get_tk(parser)
    if eat_tk(parser, .AMPERSAND) && eat_tk(parser, .AMPERSAND) {
        rhs := parse_boolean(parser) or_return
        b = AST.boolean_make(b, rhs, AST.Binary_B_Op.AND)
        tk, got_tk = get_tk(parser)
    }

    return b, true
}

@(private = "file")
parse_BOR :: proc(parser: ^Parser) -> (b: ^AST.Boolean, ok: bool) {
    // | BNT ( "||" BOR)*
    b = parse_BNT(parser) or_return

    tk, got_tk := get_tk(parser)
    if eat_tk(parser, .BAR) && eat_tk(parser, .BAR) {
        rhs := parse_BOR(parser) or_return
        b = AST.boolean_make(b, rhs, AST.Binary_B_Op.OR)
        tk, got_tk = get_tk(parser)
    }

    return b, true
}

@(private = "file")
parse_BNT :: proc(parser: ^Parser) -> (b: ^AST.Boolean, ok: bool) {
    // | ( "!" )? ARL
    tk := get_tk(parser) or_return

    if eat_tk(parser, .BANG) {
        arg := parse_ARL(parser) or_return
        b = AST.boolean_make(arg, AST.Unary_B_Op.NOT)
        return b, true
    }

    b = parse_ARL(parser) or_return
    return b, true
}

@(private = "file")
parse_ARL :: proc(parser: ^Parser) -> (b: ^AST.Boolean, ok: bool) {
    // | "(" Boolean ")"
    if eat_tk(parser, .LEFT_PAR) {
        b = parse_boolean(parser) or_return
        eat_tk(parser, .RIGHT_PAR) or_return
        return b, true
    }

    // | TRUE
    if eat_tk(parser, .TRUE) {
        b = AST.boolean_make(true)
        return b, true
    }

    // | FALSE
    if eat_tk(parser, .FALSE) {
        b = AST.boolean_make(false)
        return b, true
    }

    // | Arithmetic ( ( "<=" + "<" + "=" + ">=" + ">") Arithmetic )?
    lhs := parse_arithmetic(parser) or_return
    if eat_tk(parser, .EQ) {
        rhs := parse_arithmetic(parser) or_return
        b = AST.boolean_make(lhs, rhs, AST.Binary_B_A_Op.EQUALS)
        return b, true
    }

    if eat_tk(parser, .LESS) {
        if eat_tk(parser, .EQ) {
            rhs := parse_arithmetic(parser) or_return
            b = AST.boolean_make(lhs, rhs, AST.Binary_B_A_Op.LESS_EQUALS)
            return b, true
        }

        rhs := parse_arithmetic(parser) or_return
        b = AST.boolean_make(lhs, rhs, AST.Binary_B_A_Op.LESS)
        return b, true
    }

    if eat_tk(parser, .GREATER) {
        if eat_tk(parser, .EQ) {
            rhs := parse_arithmetic(parser) or_return
            b = AST.boolean_make(lhs, rhs, AST.Binary_B_A_Op.GREATER_EQUALS)
            return b, true
        }

        rhs := parse_arithmetic(parser) or_return
        b = AST.boolean_make(lhs, rhs, AST.Binary_B_A_Op.GREATER)
        return b, true
    }

    return
}
