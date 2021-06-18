##Use metaprogramming from nim to generate Nim code AST at compile time,
##rather than interpreting it.

import macros

proc compile(code: string): PNimrodNode {.compiletime.} = 
  var stmts = @[newStmtList()]
  template addStmt(text): typed =
    stmts[stmts.high].add parseStmt(text)

  addStmt "var tape: array[1_000_000, char]"
  addStmt "var tapePos = 0"

  for c in code:
    case c
    of '+': addStmt "xinc tape[tapePos]"
    of '-': addStmt "xdec tape[tapePos]"
    of '>': addStmt "inc tapePos"
    of '<': addStmt "dec tapePos"
    of '.': addStmt "stdout.write tape[tapePos]"
    of ',': addStmt "tape[tapePos] = stdin.readChar"
    of '[': stmts.add newStmtList()
    of ']':
      var loop = newNimNode(nnkWhileStmt)
      loop.add parseExpr("tape[tapepos] != '\\0'")
      loop.add stmts.pop
      stmts[stmts.high].add loop
    else:	discard

  result = stmts[0]
  echo result.repr

macro compileString*(code: string): typed =
	compile code.strval

macro compileFile*(filename: string): typed =
	compile staticRead(filename.strval)

proc mandelbrot = compileFile "mandelbrot.b"

mandelbrot()
