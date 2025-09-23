addi x1, x0, 5
# Comentario
loop: beq x1, x0, end
      addi x1, x1, -1
      jal x0, loop
end:  addi x2, x0, 1
