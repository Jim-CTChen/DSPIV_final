import math
import pandas as pd

def write_to_xlsx(name, s, t, array):
  col = [name] + s
  data = [[t[id]] + row for (id, row) in enumerate(array)]
  output = pd.DataFrame(data, columns = col)
  output.to_excel("{}.xlsx".format(name), index=False)



MISMATCH = -5
MATCH = 8
GAP_OPEN = -7
GAP_EXTENSION = -3

file_s = open('./dat/s1.dat', 'r')
file_t = open('./dat/t1.dat', 'r')
s = [int(line[:-1]) for line in file_s]
s.insert(0, '')
t = [int(line[:-1]) for line in file_t]
t.insert(0, '')

rows, cols = (len(t), len(s))

e = [[0 for x in range(cols)] for y in range(rows)]
f = [[0 for x in range(cols)] for y in range(rows)]
v = [[0 for x in range(cols)] for y in range(rows)]

delta = 0

for i in range(0, rows):
  for j in range(0, cols):
    if t[i] == s[j]:
      delta = MATCH
    else:
      delta = MISMATCH
    if i == 0:
      f[i][j] = GAP_OPEN
    else:
      f[i][j] = max((f[i-1][j] + GAP_EXTENSION), (v[i-1][j] + GAP_OPEN))
    if j == 0:
      e[i][j] = GAP_OPEN
    else:
      e[i][j] = max((e[i][j-1] + GAP_EXTENSION), (v[i][j-1] + GAP_OPEN))

    if i == 0 or j == 0:
      v[i][j] = 0
    else:
      v[i][j] = max(v[i-1][j-1] + delta, e[i][j], f[i][j], 0)

# write_to_xlsx("E", s, t, e)
# write_to_xlsx("F", s, t, f)
# write_to_xlsx("V", s, t, v)

max = 0;

for i in range(0, rows):
  for j in range(0, cols):
    if v[i][j] > max:
      max = v[i][j]

print('max', max)

