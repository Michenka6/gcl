package main

import "core:fmt"
import "core:os"
import "src/AST"
import "src/Lexer"
import "src/Parser"
import "src/Transpiler"

main :: proc() {
    filepath := "input.txt"
    source, have_read_file := os.read_entire_file_from_filename(filepath)
    if !have_read_file {
        fmt.eprintf("ERROR: Failed to read file %s\n", filepath)
        os.exit(69420)
    }

    lexer := Lexer.lexer_make(&source, len(source))
    defer Lexer.lexer_delete(lexer)

    tokens := Lexer.lexer_tokenize(lexer)
    // fmt.println(tokens)

    parser := Parser.parser_make(tokens)
    defer Parser.parser_delete(parser)

    command, _ := Parser.parse_command(parser)
    fmt.println(AST.command_to_string(command))

    Transpiler.transpile_gcl_to_program_graph_and_print_to_file(command, true)

}
