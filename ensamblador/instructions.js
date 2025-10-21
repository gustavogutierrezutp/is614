// ========== instrucciones basicas =========== 

const BII = {
    // instrucciones tipo R
    add: {type: "R", opcode: "0110011", funct3: "000", funct7: "0000000"},
    sub: {type: "R", opcode: "0110011", funct3: "000", funct7: "0100000"},
    xor: {type: "R", opcode: "0110011", funct3: "100", funct7: "0000000"},
    or:  {type: "R", opcode: "0110011", funct3: "110", funct7: "0000000"},
    and: {type: "R", opcode: "0110011", funct3: "111", funct7: "0000000"},
    sll: {type: "R", opcode: "0110011", funct3: "001", funct7: "0000000"},
    srl: {type: "R", opcode: "0110011", funct3: "101", funct7: "0000000"},
    sra: {type: "R", opcode: "0110011", funct3: "101", funct7: "0100000"},
    slt: {type: "R", opcode: "0110011", funct3: "010", funct7: "0000000"},
    sltu:{type: "R", opcode: "0110011", funct3: "011", funct7: "0000000"},

    // instrucciones tipo I
    addi: {type: "I", opcode: "0010011", funct3: "000"},
    xori: {type: "I", opcode: "0010011", funct3: "100"},
    ori:  {type: "I", opcode: "0010011", funct3: "110"},
    andi: {type: "I", opcode: "0010011", funct3: "111"},
    slli: {type: "I", opcode: "0010011", funct3: "001"},
    srli: {type: "I", opcode: "0010011", funct3: "101"},
    srai: {type: "I", opcode: "0010011", funct3: "101"},
    slti: {type: "I", opcode: "0010011", funct3: "010"},
    sltiu:{type: "I", opcode: "0010011", funct3: "011"},
    
    lw:  {type: "I", opcode: "0000011", funct3: "010"},
    lh:  {type: "I", opcode: "0000011", funct3: "001"},
    lb:  {type: "I", opcode: "0000011", funct3: "000"},
    lbu: {type: "I", opcode: "0000011", funct3: "100"},
    lhu: {type: "I", opcode: "0000011", funct3: "101"},

    jalr: {type: "I", opcode: "1100111", funct3: "000"},

    // instrucciones tipo S
    sb: {type: "S", opcode: "0100011", funct3: "000"},
    sh: {type: "S", opcode: "0100011", funct3: "001"},
    sw: {type: "S", opcode: "0100011", funct3: "010"},
    
    // instrucciones tipo B
    beq: {type: "B", opcode: "1100011", funct3: "000"},
    bne: {type: "B", opcode: "1100011", funct3: "001"},
    blt: {type: "B", opcode: "1100011", funct3: "100"},
    bge: {type: "B", opcode: "1100011", funct3: "101"},
    bltu:{type: "B", opcode: "1100011", funct3: "110"},
    bgeu:{type: "B", opcode: "1100011", funct3: "111"},
    
    // instrucciones tipo J
    jal: {type: "J", opcode: "1101111"},
    
    // instrucciones tipo U
    lui:   {type: "U", opcode: "0110111"},
    auipc: {type: "U", opcode: "0010111"},
};
module.exports = BII;
