addi x10, x0, 10 
addi x11, x0, 20  

add  x12, x10, x11   
addi x11, x11, -1     
add  x13, x10, x11    

addi x14, x0, 0       
sub  x14, x12, x13    
and  x15, x10, x14   

sw   x10, 0(x0)      
sw   x12, 4(x0)     

lw   x16, 4(x0)      
lh   x17, 0(x14)     


