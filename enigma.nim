# =======
# Imports
# =======

import strutils
import tables

# =====
# Types
# =====

type
  Rotor = object
    str: string

  StepDirection {.pure.} = enum
    Down,
    Up
  

# ====
# Data
# ====

let forwardA = Rotor(str: "EKMFLGDQVZNTOWYHXUSPAIBRCJ")
let reverseA = Rotor(str: "UWYGADFPVZBECKMTHXSLRINQOJ")

let forwardB = Rotor(str: "AJDKSIRUXBLHWTMCQGZNPYFVOE")
let reverseB = Rotor(str: "AJPCZWRLFBDKOTYUQGENHXMIVS")

let forwardC = Rotor(str: "BDFHJLCPRTXVZNYEIWGAKMUSQO")
let reverseC = Rotor(str: "TAGBPCSDQEUFVNZHYIXJWLRKOM")

let reflect = Rotor(str: "YRUHQSLDPXNGOKMIEBFZCWVJAT")

var plug = Rotor(str: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")

var stepA = 0
var stepB = 0
var stepC = 0

var shiftA = 1
var shiftB = 1
var shiftC = 1


# =========
# Functions
# =========

proc RequestUserInput(): string =
  echo("Enter message to cypher: ")
  var input_string = ""
  let input = readline(stdin).toUpperAscii()
  for letter in input:
    if letter.isAlphaAscii():
      input_string &= letter
    else:
      input_string &= " "
  return input_string

proc UpdateStringWithRotor(input: char, rotor: Rotor, step: int): char =
  let index = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".find(input)
  let rotor_index = index + step
  if rotor_index >= 26:
    rotor_index -= 26
  return rotor.str[rotor_index]

proc ApplyStep(step: var int, shift: int, direction: StepDirection): int =
  case direction
  of StepDirection.Down:
    step -= shift
  of StepDirection.Up:
    step += shift
  if step >= 26:
    step -= 26
  if step < 0:
    step += 26
  return step

# ===========
# Entry Point
# ===========

let input_string = RequestUserInput()
var cyphered_string = ""

for letter in input_string:
  if letter.isAlphaAscii():
    stepC = ApplyStep(stepC, shiftC, StepDirection.Up)
    stepB = ApplyStep(stepB, shiftB, StepDirection.Down)
    stepA = ApplyStep(stepA, shiftA, StepDirection.Up)
    let passForwardPlug = UpdateStringWithRotor(letter, plug, 0)
    let passForwardC = UpdateStringWithRotor(passForwardPlug, forwardC, stepC)
    let passForwardB = UpdateStringWithRotor(passForwardC, forwardB, stepB)
    let passForwardA = UpdateStringWithRotor(passForwardB, forwardA, stepA)
    let passReflect = UpdateStringWithRotor(passForwardA, reflect, 0)
    let passReverseA = UpdateStringWithRotor(passReflect, reverseA, stepA)
    let passReverseB = UpdateStringWithRotor(passReverseA, reverseB, stepB)
    let passReverseC = UpdateStringWithRotor(passReverseB, reverseC, stepC)
    let passReversePlug = UpdateStringWithRotor(passReverseC, plug, 0)
    cyphered_string &= passReversePlug
  else:
    cyphered_string &= letter

echo(cyphered_string)

