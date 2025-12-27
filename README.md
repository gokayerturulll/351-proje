# CSE351 Dead Code Elimination

Lex ve Yacc kullanarak Dead Code Elimination algoritması implementasyonu.

## Derleme

```bash
make
```

## Kullanım

```bash
./dce < input.il
```

## Test

```bash
make test
```

## Dosyalar

- `lexer.l` - Lexer (token tanımları)
- `parser.y` - Parser ve DCE algoritması
- `test1.il`, `test2.il` - Test dosyaları
- `report.txt` - Proje raporu
