    .data
val1:   .word 3      
val2:   .word 4       
limite: .word 10      

    .text

main:
    la a4, val1        
    lw a4, 0(a4)       

    la a5, val2        
    lw a5, 0(a5)       

    add a5, a4, a5     

    la t0, limite      
    lw a4, 0(t0)       

    ble a5, a4, else   
    li a0, 1           
    ret

else:
    li a0, 0           
    ret
