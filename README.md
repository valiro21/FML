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

### Control statements
if - else
for in
while

### Indentation
The indentation is similat to python, with spaces and tabs

## Code Sample
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

### Primality test

## Versioning
We use git as versioning system and GitHub for releases, if any.

# Thanks for reading! Enjoy
