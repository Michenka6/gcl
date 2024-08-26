package AST

import "core:fmt"

Boolean :: union {
    True,
    False,
    Binary_B,
    Unary_B,
    Binary_B_A,
}

True :: struct {}
False :: struct {}

@(private = "file")
prop_make :: proc(flag: bool) -> (b: ^Boolean) {
    b = new(Boolean)
    if flag {
        b^ = True{}
    } else {
        b^ = False{}
    }
    return
}

Binary_B :: struct {
    lhs: ^Boolean,
    rhs: ^Boolean,
    op:  Binary_B_Op,
}

Binary_B_Op :: enum {
    AND,
    OR,
}

@(private = "file")
binary_b_make :: proc(
    lhs: ^Boolean,
    rhs: ^Boolean,
    op: Binary_B_Op,
) -> (
    b: ^Boolean,
) {
    b = new(Boolean)
    b^ = Binary_B{lhs, rhs, op}
    return
}

Unary_B :: struct {
    arg: ^Boolean,
    op:  Unary_B_Op,
}

Unary_B_Op :: enum {
    NOT,
}

@(private = "file")
unary_b_make :: proc(arg: ^Boolean, op: Unary_B_Op) -> (b: ^Boolean) {
    b = new(Boolean)
    b^ = Unary_B{arg, op}
    return
}

Binary_B_A :: struct {
    lhs: ^Arithmetic,
    rhs: ^Arithmetic,
    op:  Binary_B_A_Op,
}

Binary_B_A_Op :: enum {
    EQUALS,
    LESS,
    GREATER,
    NOT_EQUALS,
    LESS_EQUALS,
    GREATER_EQUALS,
}

@(private = "file")
binary_b_a_make :: proc(
    lhs: ^Arithmetic,
    rhs: ^Arithmetic,
    op: Binary_B_A_Op,
) -> (
    b: ^Boolean,
) {
    b = new(Boolean)
    b^ = Binary_B_A{lhs, rhs, op}
    return
}

boolean_make :: proc {
    prop_make,
    binary_b_make,
    unary_b_make,
    binary_b_a_make,
}

@(private = "file")
binary_b_op_to_string :: proc(op: Binary_B_Op) -> string {
    switch op {
    case .OR:
        return "||"
    case .AND:
        return "&&"
    }
    err_msg := fmt.aprintf("ERROR: look at the %s", #procedure)
    return err_msg
}

@(private = "file")
binary_b_a_op_to_string :: proc(op: Binary_B_A_Op) -> string {
    switch op {
    case .EQUALS:
        return "="
    case .LESS:
        return "<"
    case .GREATER:
        return ">"
    case .NOT_EQUALS:
        return "!="
    case .LESS_EQUALS:
        return "<="
    case .GREATER_EQUALS:
        return ">="
    }
    err_msg := fmt.aprintf("ERROR: look at the %s", #procedure)
    return err_msg
}

@(private = "file")
unary_b_op_to_string :: proc(op: Unary_B_Op) -> string {
    switch op {
    case .NOT:
        return "!"
    }
    err_msg := fmt.aprintf("ERROR: look at the %s", #procedure)
    return err_msg
}

boolean_to_string :: proc(b: ^Boolean) -> (s: string) {
    switch b in b {
    case True:
        s = "true"
    case False:
        s = "false"
    case Binary_B:
        s = fmt.aprintf(
            "%s %s %s",
            boolean_to_string(b.lhs),
            binary_b_op_to_string(b.op),
            boolean_to_string(b.rhs),
        )
    case Unary_B:
        s = fmt.aprintf(
            "%s(%s)",
            unary_b_op_to_string(b.op),
            boolean_to_string(b.arg),
        )
    case Binary_B_A:
        s = fmt.aprintf(
            "%s %s %s",
            arithmetic_to_string(b.lhs),
            binary_b_a_op_to_string(b.op),
            arithmetic_to_string(b.rhs),
        )}
    return s
}
