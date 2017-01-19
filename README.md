# FML
"Fun" Micro Language

## Language definition

### Primitives
bool - 8bit data

char - 8bit data

int - 32bit data

float - 32bit floating point

longlong - 64bit data

double - 64bit floating point

### Basic operations
operators: 
 * + 
 * -
 * *
 * / 
 * % 
 * & 
 * |


comparison operators:
 * ==
 * !=
 * <
 * < =
 * >
 * > =


declarations:
 * int a
 * int a = 3
 * int a = function ()
 * auto x

assignemnts:
 * a = b

### Control statements
if - else

for in

while

### Indentation
The indentation is similar to python, with spaces and tabs

## Code Sample

### Control statements - Primality test
```python
def isprime (int i):
 bool prime = true
 int x
 auto j = 2
 while j * j <= i:
  if i % j == 0:
   prime = false
  j = j + 1
 prime = prime

int i
char c = 10
for i in range (2,101,1):
 if isprime(i):
  print (i)
  print (c)
```

### Recursion - Logarithmic pow
```python
def lgpow (int base, int pw):
 int r
 if pw == 0:
  r = 1
 else:
  int res = lgpow(base, pw/2)
  r = res * res
  if pw % 2 == 1:
   r = r * base
 r = r


int a = lgpow (2,3)
print(a)

```

## Versioning
We use git as versioning system and GitHub for releases, if any.

# Thanks for reading! Enjoy
