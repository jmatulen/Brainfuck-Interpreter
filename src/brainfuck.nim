proc interpret*(code: string) =   
  #[
  #  Interprets the brainfuck 'code' string/tape,
  #  reading from stdin and writing to stdout
 ]# 
  echo code

  {.push overflowchecks: off.}
  proc xinc(c: var char) = inc c
  proc xdec(c: var char) = dec c
  {.pop.}

  var ##declare some variables
    tape: seq[char] = newSeq[char]()
    codePos: int = 0
    tapePos: int = 0
  
  #[
  # procedure, run, that takes param skip which is false. Obviously of type bool
 ]#
  proc run(skip = false): bool =
    while tapePos>=0 and codePos < code.len: 
      if tapePos >= tape.len:
        tape.add '\0'
      
      if code[codePos] == '[':
        inc codePos
        let oldPos = codePos
        while run(tape[tapePos] == '\0'):
            codePos = oldPos
      elif code[codePos] == ']':
        return tape[tapePos] != '\0'
      elif not skip:
        case code[codePos]
        of '+': xinc tape[tapePos]
        of '-': xdec tape[tapePos]
        of '>': inc tapePos
        of '<': dec tapePos
        of '.': stdout.write tape[tapePos]
        of ',': tape[tapePos] = stdin.readChar
        else:   discard
      
      inc codePos
#[call run proc]#
  discard run()

when isMainModule:
  import os

  echo "Welcome to brainfuck"
  
  let code = if paramCount() > 0: readFile paramStr(1)
             else: readAll stdin

  interpret code
