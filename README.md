# CSE351 Dead Code Elimination

Lex ve Yacc kullanarak Dead Code Elimination algoritması implementasyonu.

## Proje Yapısı

```
├── src/
│   ├── lexer.l      # Lexer
│   └── parser.y     # Parser + DCE algoritması
├── tests/
│   ├── test1.il     # Test 1
│   └── test2.il     # Test 2
├── Makefile
├── report.txt
└── README.md
```

## Derleme

```bash
make
```

## Kullanım

```bash
./dce < tests/test1.il
```

## Test

```bash
make test
```
