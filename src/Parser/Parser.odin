package Parser

import "../AST"
import "../Lexer"

Parser :: struct {
    tokens: []Lexer.Token,
    cursor: u64,
}

parser_make :: proc(tokens: []Lexer.Token) -> (parser: ^Parser) {
    parser = new(Parser)
    parser^ = Parser{tokens, 0}
    return
}

parser_delete :: proc(parser: ^Parser) {
    free(parser)
}

eat_tk :: proc(parser: ^Parser, kind: Lexer.Token_Kind) -> bool {
    tk := get_tk(parser) or_return
    if tk.kind == kind {
        parser.cursor += 1
        return true
    }
    return false
}

get_tk :: proc(parser: ^Parser) -> (tk: Lexer.Token, ok: bool) {
    if parser.cursor < 0 || parser.cursor >= cast(u64)len(parser.tokens) {
        return
    }
    return parser.tokens[parser.cursor], true
}
