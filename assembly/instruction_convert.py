with open('instruction.txt', 'r') as instruction:
	a = instruction.readlines()
	with open('instruction_memory.txt', 'w') as mem:
		cnt = 0
		for line in a:
			mem.write('8\'d%d: Instruction <= 32\'h%s;\n' % (cnt, line[:-1]))
			cnt = cnt + 1
