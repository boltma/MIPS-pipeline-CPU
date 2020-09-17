import random

with open('data.txt', 'w') as out:
    with open('data_memory.txt', 'w') as mem_out:
        for i in range(128):
            num = random.getrandbits(32)
            hex_num = '{:08x}'.format(num)
            out.write(f'{hex_num}\n')
            mem_out.write('RAM_data[%d] <= 32\'h%s;\n' % (i, hex_num))
