from random import choices, randint, random
from string import ascii_lowercase

def gen(n):
    s = ''
    for i in range(n):
        if(random()< 0.5):
            s += '\t'*randint(0, 3)
            s += " "*randint(0, 3)
        else:
            s += "".join(choices(ascii_lowercase, k=randint(0, 8)))
    return s

def get_ans(l):
    r = []
    for i in l:
        z = i.split()
        z = [x[0:len(x):2] for x in z]
        z = " ".join(z)
        r.append(z)
    return r

l = [gen(randint(0, 8)) for i in range(10)]
z = get_ans(l)
with open("test", "wt") as f:
    f.write('\n'.join(l))

with open("ans", "wt") as f:
    f.write('\n'.join(z))

