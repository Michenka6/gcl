package Lexer

import "core:bytes"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strings"

Lexer :: struct {
    source_data: ^[]u8,
    source_len:  u64,
    cursor:      u64,
}

Token :: struct {
    kind:    Token_Kind,
    payload: Token_Payload,
}

Token_Payload :: union {
    int,
    string,
}

Token_Kind :: enum {
    INVALID,
    INT,
    BOOLEAN,
    IDENT,
    COLON,
    SEMI_COLON,
    LEFT_PAR,
    RIGHT_PAR,
    LEFT_SQ,
    RIGHT_SQ,
    // ARITHMETIC
    PLUS,
    MINUS,
    TIMES,
    DIV,
    MOD,
    CARROT,
    // BOOLEAN
    EQ,
    LESS,
    GREATER,
    BANG,
    AMPERSAND,
    BAR,
    // KEYWORDS
    TRUE,
    FALSE,
    IF,
    FI,
    DO,
    OD,
    SKIP,
    CONTINUE,
    BREAK,
    TRY,
    CATCH,
    YRT,
    THROW,
}

lexer_make :: proc(data: ^[]u8, data_len: int) -> (lexer: ^Lexer) {
    lexer = new(Lexer)
    lexer^ = Lexer{data, cast(u64)data_len, 0}
    return
}

lexer_delete :: proc(lexer: ^Lexer) {
    free(lexer)
}

lexer_tokenize :: proc(lexer: ^Lexer) -> []Token {
    tokens := make([dynamic]Token)
    tk, ok := next_token(lexer)
    for ok {
        append_elem(&tokens, tk)
        tk, ok = next_token(lexer)
    }
    return tokens[:]
}

@(private = "file")
RESERVED_CHARS := map[u8]Token_Kind {
    ':' = .COLON,
    ';' = .SEMI_COLON,
    '(' = .LEFT_PAR,
    ')' = .RIGHT_PAR,
    '[' = .LEFT_SQ,
    ']' = .RIGHT_SQ,
    '+' = .PLUS,
    '-' = .MINUS,
    '*' = .TIMES,
    '/' = .DIV,
    '%' = .MOD,
    '^' = .CARROT,
    '=' = .EQ,
    '<' = .LESS,
    '>' = .GREATER,
    '!' = .BANG,
    '&' = .AMPERSAND,
    '|' = .BAR,
}

@(private = "file")
RESERVED_IDENTS := map[string]Token_Kind {
    "true"     = .TRUE,
    "false"    = .FALSE,
    "if"       = .IF,
    "fi"       = .FI,
    "do"       = .DO,
    "od"       = .OD,
    "skip"     = .SKIP,
    "continue" = .CONTINUE,
    "break"    = .BREAK,
    "try"      = .TRY,
    "catch"    = .CATCH,
    "yrt"      = .YRT,
    "throw"    = .THROW,
}

@(private = "file")
next_token :: proc(lexer: ^Lexer) -> (tk: Token, ok: bool) {
    skip_whitespace(lexer)

    c := peek(lexer) or_return


    if c in RESERVED_CHARS {
        tk.kind = RESERVED_CHARS[c]
        lexer.cursor += 1
        return tk, true
    }

    if is_digit(c) {
        value: int = eat_int(lexer) or_return
        tk.kind = .INT
        tk.payload = value
        return tk, true
    }

    ident := eat_ident(lexer) or_return
    if ident in RESERVED_IDENTS {
        tk.kind = RESERVED_IDENTS[ident]
        return tk, true
    }

    tk.kind = .IDENT
    tk.payload = ident
    return tk, true
}

@(private = "file")
skip_whitespace :: proc(lexer: ^Lexer) {
    c, ok := peek(lexer)

    whitespace := []u8{'\r', '\n', '\t', ' '}

    for ok {
        if !slice.contains(whitespace, c) {break}
        lexer.cursor += 1
        c, ok = peek(lexer)
    }
}

@(private = "file")
eat_ident :: proc(lexer: ^Lexer) -> (ident: string, ok: bool) {
    c: u8
    c, ok = peek(lexer)
    if !ok || !is_alphanum(c) {return}

    start := lexer.cursor

    for ok && is_alphanum(c) {
        lexer.cursor += 1
        c, ok = peek(lexer)
    }
    ident = string(lexer.source_data[start:lexer.cursor])
    return ident, true
}

@(private = "file")
is_alphanum :: proc(c: u8) -> bool {
    switch c {
    case 'a' ..= 'z':
        fallthrough
    case 'A' ..= 'Z':
        fallthrough
    case '0' ..= '9':
        fallthrough
    case '_':
        return true
    }
    return false
}

@(private = "file")
is_digit :: proc(c: u8) -> bool {
    switch c {
    case '0' ..= '9':
        return true
    }
    return false
}

@(private = "file")
eat_int :: proc(lexer: ^Lexer) -> (value: int, ok: bool) {
    c := peek(lexer) or_return
    if is_digit(c) {
        value = int(c - '0')
        lexer.cursor += 1

        c, ok = peek(lexer)
        for ok && is_digit(c) {
            lexer.cursor += 1
            value = value * 10 + int(c - '0')
            c, ok = peek(lexer)
        }
        return value, true
    }
    return
}

@(private = "file")
peek :: proc(lexer: ^Lexer) -> (u8, bool) {
    if lexer.cursor <
       u64(lexer.source_len) {return lexer.source_data[lexer.cursor], true}
    return 0x69, false
}
