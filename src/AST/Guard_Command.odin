package AST

import "core:fmt"

Guard_Command :: union {
    Then,
    Else,
}

Then :: struct {
    condition: ^Boolean,
    body:      ^Command,
}

@(private = "file")
then_make :: proc(
    condition: ^Boolean,
    body: ^Command,
) -> (
    gc: ^Guard_Command,
) {
    gc = new(Guard_Command)
    gc^ = Then{condition, body}
    return
}

Else :: struct {
    left:  ^Guard_Command,
    right: ^Guard_Command,
}

@(private = "file")
else_make :: proc(
    left: ^Guard_Command,
    right: ^Guard_Command,
) -> (
    gc: ^Guard_Command,
) {
    gc = new(Guard_Command)
    gc^ = Else{left, right}
    return
}

guard_command_make :: proc {
    then_make,
    else_make,
}

guard_command_to_string :: proc(gc: ^Guard_Command) -> (s: string) {
    switch gc in gc {
    case Then:
        s = fmt.aprintf(
            "%s -> %s",
            boolean_to_string(gc.condition),
            command_to_string(gc.body),
        )
    case Else:
        s = fmt.aprintf(
            "%s [] %s",
            guard_command_to_string(gc.left),
            guard_command_to_string(gc.right),
        )
    }
    return
}
