package AST

import "core:fmt"

Arithmetic :: union {
    Number,
    Variable,
    Unary_A,
    Binary_A,
    Array_Access,
}

Number :: struct {
    n: int,
}

@(private = "file")
number_make :: proc(n: int) -> (a: ^Arithmetic) {
    a = new(Arithmetic)
    a^ = Number{n}
    return
}

Variable :: struct {
    x: string,
}

@(private = "file")
variable_make :: proc(x: string) -> (a: ^Arithmetic) {
    a = new(Arithmetic)
    a^ = Variable{x}
    return
}

Unary_A :: struct {
    arg: ^Arithmetic,
    op:  Unary_A_Op,
}

@(private = "file")
unary_a_make :: proc(arg: ^Arithmetic, op: Unary_A_Op) -> (a: ^Arithmetic) {
    a = new(Arithmetic)
    a^ = Unary_A{arg, op}
    return
}

Unary_A_Op :: enum {
    U_MINUS,
}

Binary_A :: struct {
    lhs: ^Arithmetic,
    rhs: ^Arithmetic,
    op:  Binary_A_Op,
}

@(private = "file")
binary_a_make :: proc(
    lhs: ^Arithmetic,
    rhs: ^Arithmetic,
    op: Binary_A_Op,
) -> (
    a: ^Arithmetic,
) {
    a = new(Arithmetic)
    a^ = Binary_A{lhs, rhs, op}
    return
}

Binary_A_Op :: enum {
    PLUS,
    MINUS,
    TIMES,
    MODULUS,
    DIVIDE,
    POWER,
}

Array_Access :: struct {
    name:  string,
    index: ^Arithmetic,
}

@(private = "file")
array_access_make :: proc(
    name: string,
    index: ^Arithmetic,
) -> (
    a: ^Arithmetic,
) {
    a = new(Arithmetic)
    a^ = Array_Access{name, index}
    return
}

arithmetic_make :: proc {
    number_make,
    variable_make,
    unary_a_make,
    binary_a_make,
    array_access_make,
}

@(private = "file")
unary_a_op_to_string :: proc(op: Unary_A_Op) -> string {
    switch op {
    case .U_MINUS:
        return "-"
    }

    err_msg := fmt.aprintf("ERROR: look at the %s", #procedure)
    return err_msg
}

@(private = "file")
binary_a_op_to_string :: proc(op: Binary_A_Op) -> string {
    switch op {
    case .PLUS:
        return "+"
    case .MINUS:
        return "-"
    case .TIMES:
        return "*"
    case .POWER:
        return "^"
    case .DIVIDE:
        return "/"
    case .MODULUS:
        return "%"
    }

    err_msg := fmt.aprintf("ERROR: look at the %s", #procedure)
    return err_msg
}

arithmetic_to_string :: proc(a: ^Arithmetic) -> (s: string) {
    switch a in a {
    case Number:
        s = fmt.aprintf("%i", a.n)
    case Variable:
        s = a.x
    case Unary_A:
        s = fmt.aprintf(
            "%s%s",
            unary_a_op_to_string(a.op),
            arithmetic_to_string(a.arg),
        )
    case Binary_A:
        s = fmt.aprintf(
            "%s %s %s",
            arithmetic_to_string(a.lhs),
            binary_a_op_to_string(a.op),
            arithmetic_to_string(a.rhs),
        )
    case Array_Access:
        s = fmt.aprintf("%s[%s]", a.name, arithmetic_to_string(a.index))
    }
    return
}
