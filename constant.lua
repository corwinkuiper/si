-- Physical constants to go with si library
-- There is nothing stopping you from modifying the constants during run time,
--  so please don't.
local si = require("si")

local constants = {}

do

    local kg = si.Unit("kg")
    local m = si.Unit("m")
    local s = si.Unit("s")
    local A = si.Unit("A")
    local K = si.Unit("K")
    local mol = si.Unit("mol")
    local cd = si.Unit("cd")

    -- all constant values are from nist
    constants.unit = {
        -- exact defined physical constants
        c = 299792458 * m * s ^ -1,
        speedOfLight = 299792458 * m * s ^ -1,
        k = 1.380649 * 10 ^ -23 * si.Unit("J") * K ^ -1,
        boltzmannConstant = 1.380649 * 10 ^ -23 * si.Unit("J") * K ^ -1,
        e = 1.602176634 * 10 ^ -19 * si.Unit("C"),
        elementryCharge = 1.602176634 * 10 ^ -19 * si.Unit("C"),
        Na = 6.02214076 * 10 ^ 23 * mol ^ -1,
        avogadroConstant = 6.02214076 * 10 ^ 23 * mol ^ -1,
        h = 6.62607015 * 10 ^ -34 * si.Unit("J") * s,
        planckConstant = 6.62607015 * 10 ^ -34 * si.Unit("J") * s,
        hBar = 1.054571817 * 10 ^ -34 * si.Unit("J") * s,
        reducedPlanckConstant = 1.054571817 * 10 ^ -34 * si.Unit("J") * s,
        g = 9.80665 * m * s ^ -2,
        standardAcceleration = 9.80665 * m * s ^ -2,
        atm = 101325 * si.Unit("Pa"),
        R = 8.314462618 * si.Unit("J") * mol ^ -1 * K ^ -1,
        gasConstant = 8.314462618 * si.Unit("J") * mol ^ -1 * K ^ -1,
        stefanBoltzmannConstant = 5.670374419 * 10 ^ -8 * si.Unit("W") * m ^ -2 *
            K ^ -4,

        -- non exact physical constants
        G = 6.67430 * 10 ^ -11 * m ^ 3 * kg ^ -1 * s ^ -2,
        newtonianGravityConstant = 6.67430 * 10 ^ -11 * m ^ 3 * kg ^ -1 * s ^ -2,
        me = 9.1093837015 * 10 ^ -31 * kg,
        electronMass = 9.1093837015 * 10 ^ -31 * kg,
        protonMass = 1.67262192369 * 10 ^ -27 * kg,
        neutronMass = 1.67492749804 * 10 ^ -27 * kg
    }
end

constants.number = {}

for unitName, unitValue in pairs(constants.unit) do
    constants.number[unitName] = unitValue:numUnchecked()
end

return constants
