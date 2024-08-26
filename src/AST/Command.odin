package AST

import "core:fmt"

Command :: union {
    Assignment,
    Array_Assignment,
    Skip,
    Chain,
    If,
    Do,
}

Assignment :: struct {
    x: string,
    a: ^Arithmetic,
}

@(private = "file")
assignment_make :: proc(x: string, a: ^Arithmetic) -> (c: ^Command) {
    c = new(Command)
    c^ = Assignment{x, a}
    return
}

Array_Assignment :: struct {
    name:  string,
    index: ^Arithmetic,
    value: ^Arithmetic,
}

@(private = "file")
array_assignment_make :: proc(
    x: string,
    index: ^Arithmetic,
    value: ^Arithmetic,
) -> (
    c: ^Command,
) {
    c = new(Command)
    c^ = Array_Assignment{x, index, value}
    return
}

Skip :: struct {}

@(private)
skip_make :: proc() -> (c: ^Command) {
    c = new(Command)
    c^ = Skip{}
    return
}

Chain :: struct {
    first:  ^Command,
    second: ^Command,
}

@(private = "file")
chain_make :: proc(left: ^Command, right: ^Command) -> (c: ^Command) {
    c = new(Command)
    c^ = Chain{left, right}
    return
}

If :: struct {
    gc: ^Guard_Command,
}

Do :: struct {
    gc: ^Guard_Command,
}

@(private = "file")
command_gc_make :: proc(gc: ^Guard_Command, is_if: bool) -> (c: ^Command) {
    c = new(Command)
    if is_if {
        c^ = If{gc}
    } else {
        c^ = Do{gc}
    }
    return
}

command_make :: proc {
    assignment_make,
    array_assignment_make,
    skip_make,
    chain_make,
    command_gc_make,
}

command_to_string :: proc(command: ^Command) -> (s: string) {
    switch c in command {
    case Assignment:
        s = fmt.aprintf("%s := %s", c.x, arithmetic_to_string(c.a))
    case Array_Assignment:
        s = fmt.aprintf(
            "%s[%s] := %s",
            c.name,
            arithmetic_to_string(c.index),
            arithmetic_to_string(c.value),
        )
    case Skip:
        s = "skip"
    case Chain:
        s = fmt.aprintf(
            "%s; %s",
            command_to_string(c.first),
            command_to_string(c.second),
        )
    case If:
        s = fmt.aprintf("if %s fi", guard_command_to_string(c.gc))
    case Do:
        s = fmt.aprintf("do %s od", guard_command_to_string(c.gc))
    }
    return
}
