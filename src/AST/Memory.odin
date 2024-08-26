package AST

import "core:fmt"

Memory :: struct {
    values: map[string]int,
}

memory_make :: proc() -> (mem: ^Memory) {
    mem = new(Memory)
    mem.values = make(map[string]int)
    return
}

memory_add :: proc(mem: ^Memory, k: string, v: int) {
    mem.values[k] = v
}

memory_get :: proc(mem: ^Memory, k: string) -> (v: int, ok: bool) {
    v, ok = mem.values[k]
    return
}

memory_to_string :: proc(mem: ^Memory) -> (s: string) {
    s = "Memory { "
    flag := false
    for k, v in mem.values {
        if flag {
            s = fmt.aprintf("%s; ", s)
        }

        s = fmt.aprintf("%s%s : %v", k, v)

        flag = true
    }
    s = fmt.aprintf("%s}", s)
    return
}
