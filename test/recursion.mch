def fact $ n
  if = int 0 n
    int 1
    * n . fact . dec n
>> . print ' Recursion:
  let answer . fact int 5
  >> . print ' Factorial_of_5_is:
  if = int 120 answer
    >> . print answer
    . print ' Correct
    >> . print answer
    . print ' Wrong
