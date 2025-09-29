// ============= pseudoinstrucciones ====================

const ABI = require('./abi');
const BII = require('./instructions');
const { assembleTypeR, assembleTypeI, assembleTypeS, assembleTypeB, assembleTypeJ, assembleTypeU,
    assembleLB, assembleLH, assembleLW, assembleLBU, assembleLHU
 } = require('./assemblerUtils');

function Pseudoinst(inst, args, tabla, pcActual, mainFn) {
  function splitImm(addr) {
    const upper = ((addr + 0x800) >> 12) | 0;
    const lower = (addr - (upper << 12)) | 0;
    return {upper, lower};
  }

  switch (inst) {
    // ---------- CARGAS DE INMEDIATOS Y DIRECCIONES ----------
    case "la": {
      const rd = ABI[args[0]];
      const sym = args[1];
      if (!(sym in tabla)) throw new Error(`Símbolo no definido: ${sym}`);
      const {upper, lower} = splitImm(tabla[sym]);
      const defLui = BII["lui"];
      const defAddi = BII["addi"];
      return [
        assembleTypeU(defLui.opcode, upper, rd),
        assembleTypeI(defAddi.opcode, defAddi.funct3, rd, rd, lower)
      ];
    }

    case "li": {
      const rd = ABI[args[0]];
      const imm = parseInt(args[1]);
      const defAddi = BII["addi"];
      const defLui = BII["lui"];
      if (imm >= -2048 && imm <= 2047) {
        return [assembleTypeI(defAddi.opcode, defAddi.funct3, rd, ABI["x0"], imm)];
      } else {
        const {upper, lower} = splitImm(imm);
        return [
          assembleTypeU(defLui.opcode, upper, rd),
          assembleTypeI(defAddi.opcode, defAddi.funct3, rd, rd, lower)
        ];
      }
    }

    case "mv": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defAddi = BII["addi"];
      return [assembleTypeI(defAddi.opcode, defAddi.funct3, rd, rs, 0)];
    }

    case "nop": {
      const defAddi = BII["addi"];
      return [assembleTypeI(defAddi.opcode, defAddi.funct3, ABI["x0"], ABI["x0"], 0)];
    }

    case "not": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defXori = BII["xori"];
      return [assembleTypeI(defXori.opcode, defXori.funct3, rd, rs, -1)];
    }

    case "neg": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defSub = BII["sub"];
      return [assembleTypeR(defSub.opcode, defSub.funct3, defSub.funct7, rd, ABI["x0"], rs)];
    }

    // ---------- CONDICIONALES ----------
    case "seqz": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defSltiu = BII["sltiu"];
      return [assembleTypeI(defSltiu.opcode, defSltiu.funct3, rd, rs, 1)];
    }

    case "snez": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defSltu = BII["sltu"];
      return [assembleTypeR(defSltu.opcode, defSltu.funct3, defSltu.funct7, rd, ABI["x0"], rs)];
    }

    case "sltz": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defSlt = BII["slt"];
      return [assembleTypeR(defSlt.opcode, defSlt.funct3, defSlt.funct7, rd, rs, ABI["x0"])];
    }

    case "sgtz": {
      const rd = ABI[args[0]];
      const rs = ABI[args[1]];
      const defSlt = BII["slt"];
      return [assembleTypeR(defSlt.opcode, defSlt.funct3, defSlt.funct7, rd, ABI["x0"], rs)];
    }

    case "beqz": {
      return [mainFn(`beq ${args[0]}, x0, ${args[1]}`, tabla, pcActual, true)];
    }

    case "bnez": {
      return [mainFn(`bne ${args[0]}, x0, ${args[1]}`, tabla, pcActual, true)];
    }

    case "blez": {
      return [mainFn(`bge x0, ${args[0]}, ${args[1]}`, tabla, pcActual, true)];
    }

    case "bgez": {
      return [mainFn(`bge ${args[0]}, x0, ${args[1]}`, tabla, pcActual, true)];
    }

    case "bltz": {
      return [mainFn(`blt ${args[0]}, x0, ${args[1]}`, tabla, pcActual, true)];
    }

    case "bgtz": {
      return [mainFn(`blt x0, ${args[0]}, ${args[1]}`, tabla, pcActual, true)];
    }

    case "bgt": {
      return [mainFn(`blt ${args[1]}, ${args[0]}, ${args[2]}`, tabla, pcActual, true)];
    }

    case "ble": {
      return [mainFn(`bge ${args[1]}, ${args[0]}, ${args[2]}`, tabla, pcActual, true)];
    }

    case "bgtu": {
      return [mainFn(`bltu ${args[1]}, ${args[0]}, ${args[2]}`, tabla, pcActual, true)];
    }

    case "bleu": {
      return [mainFn(`bgeu ${args[1]}, ${args[0]}, ${args[2]}`, tabla, pcActual, true)];
    }

    // ---------- SALTOS Y LLAMADAS ----------
    case "j": {
      return [mainFn(`jal x0, ${args[0]}`, tabla, pcActual, true)];
    }

    case "jal": {
      return [mainFn(`jal x1, ${args[0]}`, tabla, pcActual, true)];
    }

    case "jr": {
      return [mainFn(`jalr x0, 0(${args[0]})`, tabla, pcActual, true)];
    }

    case "jalr": {
      return [mainFn(`jalr x1, 0(${args[0]})`, tabla, pcActual, true)];
    }

    case "ret": {
      return [mainFn(`jalr x0, 0(x1)`, tabla, pcActual, true)];
    }

    case "call": {
      const off = parseInt(args[0]);
      const {upper, lower} = splitImm(off);
      return [
        mainFn(`auipc x1, ${upper}`, tabla, pcActual, true),
        mainFn(`jalr x1, x1, ${lower}`, tabla, pcActual + 4, true)
      ];
    }

    case "tail": {
      const off = parseInt(args[0]);
      const {upper, lower} = splitImm(off);
      return [
        mainFn(`auipc x6, ${upper}`, tabla, pcActual, true),
        mainFn(`jalr x0, x6, ${lower}`, tabla, pcActual + 4, true)
      ];
    }

    default:
      return null;
  }
}

module.exports = Pseudoinst;
