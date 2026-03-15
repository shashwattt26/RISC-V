# RISC-V Processor Implementation

![RISC-V](https://img.shields.io/badge/Architecture-RISC--V-blue)
![Language](https://img.shields.io/badge/Language-C%2FC%2B%2B-green)
![License](https://img.shields.io/badge/License-MIT-orange)

A simplified implementation of a **RISC-V processor architecture** designed to demonstrate how a CPU executes instructions at a low level.

This project explores the fundamentals of **instruction decoding, register operations, ALU execution, and memory access** using the RISC-V instruction set architecture.

---

## Overview

RISC-V is an **open-source Instruction Set Architecture (ISA)** that follows the **Reduced Instruction Set Computer (RISC)** design philosophy.

This project demonstrates how a processor:

- Fetches instructions
- Decodes them
- Executes arithmetic/logic operations
- Accesses memory
- Updates registers

The goal is to **build a conceptual model of a CPU** and understand the **instruction execution pipeline**.

---

## Architecture

The processor is composed of several key components:

            +----------------------+
            |   Instruction Memory |
            +----------+-----------+
                       |
                       v
                 +-----------+
                 |  Decoder  |
                 +-----+-----+
                       |
      +----------------+----------------+
      |                                 |
      v                                 v
+-----------+                    +--------------+
| Register  |                    | Control Unit |
|   File    |                    +--------------+
+-----+-----+
      |
      v
   +------+
   | ALU  |
   +--+---+
      |
      v
 +---------+
 |  Memory |
 +---------+

 
---

## Features

- RISC-V instruction decoding
- Register file implementation
- Arithmetic Logic Unit (ALU)
- Load / Store memory instructions
- Control flow instructions
- Modular processor design

---

## Instruction Categories

### Arithmetic Operations
- ADD
- SUB
- AND
- OR
- XOR


### Immediate Instructions
- ADDI
- ANDI
- ORI


### Memory Operations
- LW
- SW


### Control Flow
- BEQ
- BNE
- JAL


---

## Example Program

Example RISC-V assembly:

```assembly
addi x1, x0, 10
addi x2, x0, 20
add x3, x1, x2
```
Result:
```
x3 = 30
```

---

## Learning Objectives

This project helps in understanding:
- Instruction Set Architecture (ISA)
- CPU datapath design
- Instruction execution cycle
- Register-transfer operations
- Low level processor architecture

---

## References

- RISC-V ISA Specification
- Computer Organization and Design — Patterson & Hennessy
- RISC-V Official Documentation

---

## Licence

This project is licensed under the MIT License.

---

✅ To use it:

1. Open your repo  
2. Create or edit **README.md**  
3. Paste this code  
4. Commit

---

If you want, I can also help you add **GitHub features that make the repo look much more impressive**, like:

- architecture **diagram image**
- **instruction table**
- **demo GIF**
- **build badge + stars badge**

These things make the project look **much stronger when recruiters open it**.
