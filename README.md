# SI Units in Lua 5.1 / LuaJIT

A system for using SI units in Lua by keeping track of the dimensions throughout
a calculation and upon conversion to a string converts to a quantity and unit.
An example in a Lua 5.1 interactive interpreter is given below.

```
> si = require("si")
> const = require("constant")
> numberOfMoles = 5 * si.Unit("mol")
> temperature = 300 * si.Unit("K")
> pressure = const.unit.atm
> volume = numberOfMoles * const.unit.R * temperature / pressure
> print(volume)
1263694387.1533  m^3
```

As you can see, this uses operator overloading with metatables to propagate the
dimensions. Additionally some physical constants are provided by `constant.lua`
which includes the units for each of the constants.

## Operators Which Units can Propagate Through

Units can propagate through addition, subtraction, negation, multiplication,
division, and exponents. Addition and subtraction require the two units to have
the same dimensions, and exponents require the exponent to be dimensionless.


## Known Faults

* No tests
* Poor documentation
* Floating point numbers used for dimensions, could cause loss of information.
  Possibly should use rational numbers to store the exponents.

## Documentation

The si file should first be loaded using `require("si")`. Then the main way of
using the package is with `si.Unit()`. `si.Unit()` accepts a string of the unit,
the supported units are the base units: s, m, kg, A, K, mol and cd; the derived
units: Ω, V, H, W, C, F, T, N, J, W and Pa; and also the string "ohm" as an
easier way of using a symbol that is quite hard to type.

Units are automatically propagated and can be converted to a string using the
lua `tostring` function. Additionally all of the unit types have the following
functions built in:

* Unit:unit()
    * returns a unit with the same dimensions but with a quantity of 1. Useful
      for checking if a value has the same units as anticipated, eg 
      `(5 * si.Unit("s")):unit() == si.Unit("s")`.
* Unit:num()
    * returns the quantity of the value if the unit is dimensionless, otherwise
      errors. Useful for inputs to `math.sin`, for example. In the future I will
      have functions that wrap these functions to work for both numbers and
      units.
* Unit:numUnchecked()
    * just returns the quantity of the value with no checks for dimensions. Not
      often useful.