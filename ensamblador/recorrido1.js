const fs = require('fs');

// ===== Primer recorrido para recolectar etiquetas (.text y .data) =====
function recorrido1(archivo) {
  const contenido = fs.readFileSync(archivo, "utf-8");
  const lineas = contenido.split("\n");

  let section = ".text";
  let PCtext = 0x00000000;  // direcciones para .text
  let PCdata = 0x10000000;  // direcciones para .data
  let tabla = {};

  // === PRIMERA PASADA: solo registrar etiquetas con sus direcciones ===
  for (let raw of lineas) {
    let linea = raw.trim();
    if (linea === "" || linea.startsWith("#")) continue;

    if (linea === ".text") { section = ".text"; continue; }
    if (linea === ".data") { section = ".data"; continue; }

    // directivas que no generan código
    if (linea.startsWith(".globl")) continue;

    // detectar etiqueta
    let labelMatch = linea.match(/^([A-Za-z_]\w*):/);
    if (labelMatch) {
      let etiqueta = labelMatch[1];
      if (section === ".text") {
        tabla[etiqueta] = PCtext;
      } else {
        tabla[etiqueta] = PCdata;
      }
    }

    // avanzar PC en la primera pasada
    if (section === ".text") {
      // cada instrucción (o pseudo) cuenta como 4 bytes por ahora
      PCtext += 4;
    } else if (section === ".data") {
      if (linea.includes(".word")) {
        PCdata += 4;
      }
    }
  }

  // === SEGUNDA PASADA: ajustar tamaños de pseudoinstrucciones ===
  section = ".text";
  PCtext = 0x00000000;
  PCdata = 0x10000000;

  for (let raw of lineas) {
    let linea = raw.trim();
    if (linea === "" || linea.startsWith("#")) continue;

    if (linea === ".text") { section = ".text"; continue; }
    if (linea === ".data") { section = ".data"; continue; }
    if (linea.startsWith(".globl")) continue;

    // si hay etiqueta al inicio, quitarla para no confundir
    let labelMatch = linea.match(/^([A-Za-z_]\w*):\s*(.*)$/);
    if (labelMatch) {
      linea = labelMatch[2]; // resto de la línea
    }

    if (linea === "") continue;

    if (section === ".text") {
      let tokens = linea.replace(/,/g,"").trim().split(/\s+/);
      let inst = tokens[0].toLowerCase();

      // pseudoinstrucciones que expanden a más de 4 bytes
      if (inst === "la") {
        PCtext += 8;
      } else if (inst === "li") {
        let imm = parseInt(tokens[1]);
        if (!isNaN(imm) && imm >= -2048 && imm <= 2047) {
          PCtext += 4;
        } else {
          PCtext += 8;
        }
      } else {
        PCtext += 4;
      }
    } else if (section === ".data") {
      if (linea.startsWith(".word")) {
        PCdata += 4;
      }
    }
  }

  return tabla;
}

module.exports = recorrido1;
