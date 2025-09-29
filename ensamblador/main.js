const ABI = require('./abi');
const BII = require('./instructions');
const { assembleTypeR, assembleTypeI, assembleTypeS, assembleTypeB, assembleTypeJ, assembleTypeU,
    assembleLB, assembleLH, assembleLW, assembleLBU, assembleLHU
 } = require('./assemblerUtils');
const Pseudoinst = require('./pseudoinst');

// ===== Funcion principal =====
function main(linea, tabla, pcActual, skipPseudo = false) {
    let [inst, ...args] = linea.replace(/,/g, "").trim().split(/\s+/);
    inst = inst.toLowerCase();

    if (!skipPseudo) {
        let pseudo = Pseudoinst(inst, args, tabla, pcActual, main);
        if (pseudo) return pseudo;
    }

    if (!BII[inst]) {
        throw new Error(`Instruccion no soportada: ${inst}`);
    }
    const def = BII[inst];

    // === Validación de argumentos (excepto etiquetas en saltos) ===
    args.forEach((a, i) => {
        if ((def.type === "B" && i === 2) || (def.type === "J" && i === 1)) {
            // último argumento puede ser etiqueta o número
            return;
        }
        if (ABI[a] === undefined && isNaN(parseInt(a))) {
            throw new Error(`Registro desconocido o argumento inválido: "${a}" en instrucción ${inst}`);
        }
    });

    switch (def.type) {
        case "R":
            return assembleTypeR(def.opcode, def.funct3, def.funct7,
                ABI[args[0]], ABI[args[1]], ABI[args[2]]);

        case "I":
            // distinguir loads
            if (inst === "lb") return assembleLB(ABI[args[0]], ABI[args[1]], parseInt(args[2]));
            if (inst === "lh") return assembleLH(ABI[args[0]], ABI[args[1]], parseInt(args[2]));
            if (inst === "lw") return assembleLW(ABI[args[0]], ABI[args[1]], parseInt(args[2]));
            if (inst === "lbu") return assembleLBU(ABI[args[0]], ABI[args[1]], parseInt(args[2]));
            if (inst === "lhu") return assembleLHU(ABI[args[0]], ABI[args[1]], parseInt(args[2]));
            if (inst == "jalr") {
                let rd = ABI[args[0]];
                let match = args[1].match(/(-?\d+)\((\w+)\)/);
                if (!match) throw new Error("Formato inválido para jalr: " + args[1]);
                let imm = parseInt(match[1]);
                let rs1 = ABI[match[2]];
                return assembleTypeI(def.opcode, def.funct3, rd, rs1, imm);
            }
            // resto de tipo I normal
            return assembleTypeI(def.opcode, def.funct3,
                ABI[args[0]], ABI[args[1]], parseInt(args[2]));

        case "S":
            return assembleTypeS(def.opcode, def.funct3,
                ABI[args[1]], ABI[args[0]], parseInt(args[2]));

        case "B": {
            let target = args[2];
            let offset;
            if (isNaN(target)) {
                // etiqueta
                let direccion = tabla[target];
                if (direccion == undefined) throw new Error(`Etiqueta no encontrada: ${target}`);
                offset = direccion - pcActual;
            } else {
                offset = parseInt(target);
            }
            return assembleTypeB(def.opcode, def.funct3, offset,
                ABI[args[0]], ABI[args[1]]);
        }

        case "J": {
            let target = args[1];
            let offset;
            if (isNaN(target)) {
                let direccion = tabla[target];
                if (direccion == undefined) throw new Error(`Etiqueta no encontrada: ${target}`);
                offset = direccion - pcActual;
            } else {
                offset = parseInt(target);
            }
            return assembleTypeJ(def.opcode, offset, ABI[args[0]]);
        }

        case "U": {
            let imm = parseInt(args[1]);
            return assembleTypeU(def.opcode, imm, ABI[args[0]]);
        }
    }
}

module.exports = main;
