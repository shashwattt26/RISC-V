.text
  lui x3, 0x80000       # 0x00: Load LED address (0x80000000) into x3
  addi x1, x0, 0        # 0x04: x1 (counter) = 0
  addi x4, x0, 1000     # 0x08: x4 (delay loop max) = 1000

OUTER_LOOP:             # (Address 0x0C)
  sw  x1, 0(x3)         # 0x0C: Write counter (x1) to LED address (x3)
  addi x1, x1, 1        # 0x10: counter++
  addi x2, x0, 0        # 0x14: x2 (delay_counter) = 0

DELAY_LOOP:             # (Address 0x18)
  addi x2, x2, 1        # 0x18: delay_counter++
  bne x2, x4, DELAY_LOOP # 0x1C: Loop if (x2 != x4)

  jal x0, OUTER_LOOP    # 0x20: Jump back to OUTER_LOOP