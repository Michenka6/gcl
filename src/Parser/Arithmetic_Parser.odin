package Parser

import "../AST"
import "../Lexer"
import "core:fmt"

/*
    Arithmetic  :=
                | MDTP ( ( "+" + "-" ) Arithmetic )*
    MDTP        :=
                | A_Basic ( ( "%" + "*" + "/" + "^" ) MDTP )*
    A_Basic     :=
                | "(" Arithmetic ")"
                | "-" Arithmetic
                | INT
                | IDENT "[" Arithmetic "]"
                | IDENT
*/

@(private)
parse_arithmetic :: proc(parser: ^Parser) -> (a: ^AST.Arithmetic, ok: bool) {
    // | MDTP ( ( "+" + "-" ) Arithmetic )?
    a = parse_MDTP(parser) or_return

    if eat_tk(parser, .MINUS) {
        if eat_tk(parser, .GREATER) {parser.cursor -= 2} else {
            rhs := parse_arithmetic(parser) or_return
            a = AST.arithmetic_make(a, rhs, AST.Binary_A_Op.MINUS)
            return a, true
        }
    }

    if eat_tk(parser, .PLUS) {
        rhs := parse_arithmetic(parser) or_return
        a = AST.arithmetic_make(a, rhs, AST.Binary_A_Op.PLUS)
        return a, true
    }

    return a, true
}

@(private)
parse_MDTP :: proc(parser: ^Parser) -> (a: ^AST.Arithmetic, ok: bool) {
    // | A_Basic ( ( "%" + "*" + "/" + "^" ) MDTP )*
    a, ok = parse_a_basic(parser)

    op_to_bop := map[Lexer.Token_Kind]AST.Binary_A_Op {
        .MOD   = .MODULUS,
        .DIV   = .DIVIDE,
        .TIMES = .TIMES,
    }

    tk, got_tk := get_tk(parser)
    for got_tk && (tk.kind in op_to_bop) {
        parser.cursor += 1
        rhs := parse_MDTP(parser) or_return
        a = AST.arithmetic_make(a, rhs, op_to_bop[tk.kind])
        tk, got_tk = get_tk(parser)
    }
    return a, true
}

@(private)
parse_a_basic :: proc(parser: ^Parser) -> (a: ^AST.Arithmetic, ok: bool) {
    // | "-" Arithmetic
    if eat_tk(parser, .MINUS) {
        arg := parse_a_basic(parser) or_return
        a = AST.arithmetic_make(arg, AST.Unary_A_Op.U_MINUS)
        return a, true
    }

    // | "(" Arithmetic ")"
    if eat_tk(parser, .LEFT_PAR) {
        a := parse_arithmetic(parser) or_return
        eat_tk(parser, .RIGHT_PAR) or_return
        return a, true
    }

    tk := get_tk(parser) or_return

    // | INT
    if tk.kind == .INT {
        eat_tk(parser, .INT) or_return
        a = AST.arithmetic_make(tk.payload.(int))
        return a, true
    }

    if tk.kind == .IDENT {
        eat_tk(parser, .IDENT) or_return

        // | IDENT "[" Arithmetic "]"
        if eat_tk(parser, .LEFT_SQ) {
            if eat_tk(parser, .RIGHT_SQ) {
                parser.cursor -= 2
            } else {
                name := tk.payload.(string)
                index := parse_arithmetic(parser) or_return
                eat_tk(parser, .RIGHT_SQ) or_return
                a = AST.arithmetic_make(name, index)
                return a, true
            }
        }
        // | IDENT
        x := tk.payload.(string)
        a = AST.arithmetic_make(x)
        return a, true
    }

    return nil, false
}
