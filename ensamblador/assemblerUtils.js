// ===== Funciones de ensamblado =====
function assembleTypeR(opcode,funct3,funct7, rd, rs1, rs2) {
    return  funct7.padStart(7, "0") + " " +
            rs2.toString(2).padStart(5, "0") + " " +
            rs1.toString(2).padStart(5, "0") + " " +
            funct3.padStart(3, "0") + " " +
            rd.toString(2).padStart(5, "0") + " " +
            opcode.padStart(7, "0");
}

function assembleTypeI(opcode,funct3, rd, rs1, imm) {
    let immBin = (imm & 0xFFF).toString(2).padStart(12, "0");
    return  immBin + " " +
            rs1.toString(2).padStart(5, "0") + " " +
            funct3.padStart(3, "0") + " " +
            rd.toString(2).padStart(5, "0") + " " +
            opcode.padStart(7, "0");
}

function assembleTypeS(opcode, funct3, rs1, rs2, imm) {
    let immBin = (imm & 0xFFF).toString(2).padStart(12, "0");
    let immHi = immBin.substring(0, 7);
    let immLo = immBin.substring(7);
    return  immHi + " " +
            rs2.toString(2).padStart(5, "0") + " " +
            rs1.toString(2).padStart(5, "0") + " " +
            funct3.padStart(3, "0") + " " +
            immLo + " " +
            opcode.padStart(7, "0");
}

function assembleTypeB(opcode,funct3,offset, rs1, rs2) {
    let imm = offset >> 1;
    let immBin = (imm & 0xFFF).toString(2).padStart(12, "0");
    let imm12 = immBin[0];
    let imm10_5 = immBin.slice(1, 7); 
    let imm4_1 = immBin.slice(7,11);
    let imm11 = immBin[11];
    return  (imm12+ " " + imm10_5 + " " +
            rs2.toString(2).padStart(5, "0") + " " +
            rs1.toString(2).padStart(5, "0") + " " +
            funct3.padStart(3, "0") + " " + imm4_1 + " " + imm11 + " " +
            opcode.padStart(7, "0"));
}

function assembleTypeJ(opcode,offset, rd) {
    let imm = offset >> 1;
    let immBin = (imm & 0xFFF).toString(2).padStart(12, "0");
    let imm20 = immBin[0];
    let imm10_1 = immBin.slice(10, 20);
    let imm11 = immBin[9];
    let imm19_12 = immBin.slice(1, 9);
    return  (imm20 + " " + imm10_1 + " " + imm11 + " " + imm19_12 + " " +
            rd.toString(2).padStart(5, "0") +
            opcode.padStart(7, "0")
    );
}

function assembleTypeU(opcode, imm, rd) {
    // Formato U: imm[31:12] | rd | opcode
    let immBin = (imm >>> 12).toString(2).padStart(20, "0");
    return  immBin + " " +
            rd.toString(2).padStart(5, "0") + " " +
            opcode.padStart(7, "0");
}

// ===== Funciones específicas para loads =====
function assembleLB(rd, rs1, imm) {
    return assembleTypeI("0000011", "000", rd, rs1, imm);
}
function assembleLH(rd, rs1, imm) {
    return assembleTypeI("0000011", "001", rd, rs1, imm);
}
function assembleLW(rd, rs1, imm) {
    return assembleTypeI("0000011", "010", rd, rs1, imm);
}
function assembleLBU(rd, rs1, imm) {
    return assembleTypeI("0000011", "100", rd, rs1, imm);
}
function assembleLHU(rd, rs1, imm) {
    return assembleTypeI("0000011", "101", rd, rs1, imm);
}

module.exports = { assembleTypeR, assembleTypeI, assembleTypeS, assembleTypeB, assembleTypeJ, assembleTypeU, assembleLB,
    assembleLH, assembleLW, assembleLBU, assembleLHU
 };