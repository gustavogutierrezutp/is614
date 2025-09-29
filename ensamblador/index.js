const fs = require('fs');
const recorrido1 = require('./recorrido1');
const main = require('./main');

// ===== Lector de archivo (segundo pase) =====
const tablaEtiquetas = recorrido1('texto.asm');

fs.readFile("texto.asm", "utf8", (err, data) => {
    if (err) {
        console.error("Error:", err);
        return;
    }

    const lineas = data.split('\n');
    
    let section = ".text";
    let pcText = 0x00000000;    // donde empieza el código
    let pcData = 0x10000000;    // donde empieza la data
    let memoryData = {};

    // buffers de salida
    let binOutput = "";
    let hexOutput = "";

    for (const raw of lineas) {
        let limpio = raw.trim();
        if (limpio === '' || limpio.startsWith('#')) continue;

        // cambio de sección
        if (limpio === ".text") { section = ".text"; continue; }
        if (limpio === ".data") { section = ".data"; continue; }

        // detectar etiqueta al inicio con resto en la misma línea
        let labelMatch = limpio.match(/^([A-Za-z_]\w*):\s*(.*)$/);
        if (labelMatch) {
            // si sólo es etiqueta (sin resto) nos saltamos — la tabla ya la llenó el primer pase
            if (labelMatch[2] === "") continue;
            // si hay resto, procesamos el resto como una línea normal
            limpio = labelMatch[2];
        }

        // directiva .globl
        if (limpio.startsWith(".globl")) {
            continue;
        }

        if (section === ".data") {
            if (limpio.startsWith(".word")) {
                let parts = limpio.split(/\s+/);
                let val = parseInt(parts[1]);
                memoryData[pcData] = (isNaN(val) ? 0 : (val >>> 0));
                binOutput += `DATA @0x${pcData.toString(16).padStart(8,"0")}: ${memoryData[pcData]}\n`;
                hexOutput += `DATA @0x${pcData.toString(16).padStart(8,"0")}: ${(memoryData[pcData]).toString(16).padStart(8,"0")}\n`;
                pcData += 4;
            }
            continue;
        }

        // === Sección de código ===
        try {
            const resultado = main(limpio, tablaEtiquetas, pcText);

            if (Array.isArray(resultado)) {
                for (let r of resultado) {
                    if (typeof r !== "string") throw new Error(`Resultado inválido al ensamblar: ${limpio}`);
                    const binStr = r.toString().replace(/\s+/g, "").padStart(32, "0");   // aseguro 32 bits
                    const hexStr = parseInt(binStr, 2).toString(16).padStart(8, "0");
                    
                    binOutput += `PC=0x${pcText.toString(16).padStart(4, "0")} | ${limpio} → ${binStr}\n`;
                    hexOutput += `PC=0x${pcText.toString(16).padStart(4, "0")} | ${limpio} → ${hexStr}\n`;

                    pcText += 4;
                }
            } else {
                if (typeof resultado !== "string") throw new Error(`Resultado inválido al ensamblar: ${limpio}`);
                const binStr = resultado.toString().replace(/\s+/g, "").padStart(32, "0");
                const hexStr = parseInt(binStr, 2).toString(16).padStart(8, "0");

                binOutput += `PC=0x${pcText.toString(16).padStart(4, "0")} | ${limpio} → ${binStr}\n`;
                hexOutput += `PC=0x${pcText.toString(16).padStart(4, "0")} | ${limpio} → ${hexStr}\n`;

                pcText += 4;
            }

        } catch (e) {
            console.error(`Error en PC=0x${pcText.toString(16)}: ${e.message}`);
        }
    }

    // escribir resultados en archivos
    fs.writeFileSync("programbin.bin", binOutput);
    fs.writeFileSync("programhex.hex", hexOutput);

    console.log("Archivos generados: programbin.bin y programhex.hex");
    fs.writeFileSync("datamemory.json", JSON.stringify(memoryData, null, 2));
});
