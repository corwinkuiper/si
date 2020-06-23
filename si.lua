local si = {}

local baseUnits = {"s", "m", "kg", "A", "K", "mol", "cd"}
local baseUnitNumbering = {}
local derivedUnits = {}
local unitTypingAlias = {}
for index, value in ipairs(baseUnits) do baseUnitNumbering[value] = index end

local unitMetaTable = {}

local function initialiseUnit()
    local newUnit = {}
    newUnit.baseUnits = {0, 0, 0, 0, 0, 0, 0}
    newUnit.quantity = 1
    setmetatable(newUnit, unitMetaTable)
    return newUnit
end

local function numberSign(x)
    local sign = 0
    if x > 0 then
        sign = sign + 1
    elseif x < 0 then
        sign = sign - 1
    end
    return sign
end

local function truncate(n)
    if n > 0 then
        return math.floor(n)
    elseif n < 0 then
        return math.ceil(n)
    else
        return 0
    end
end

-- this function is based off that found in
-- https://www.nuget.org/packages/Metric, which is MIT licensed by Ivan
-- Milutinović
local function factor(unitTable, factorTable)

    local power
    for index, value in ipairs(factorTable) do
        if value ~= 0 then
            local thisFactor = truncate(unitTable[index] / value)
            if thisFactor == 0 or
                (power ~= nil and numberSign(power * thisFactor) == -1) then -- test if power and thisFactor have opposite signs
                return 0
            elseif (power == nil or math.abs(thisFactor) < math.abs(power)) then
                power = thisFactor
            end
        end
    end

    return power or 0
end

-- this function is based off that found in
-- https://www.nuget.org/packages/Metric, which is MIT licensed by Ivan
-- Milutinović I think there is a better algorithm out there that better matches
-- what a human would write. This function also has no context. This function
-- cannot find the combination "N s" as is used for impulse. This is because
-- this algorithm never takes powers in the "wrong direction", which would be
-- required for "N s" to arise. The better algorithm may be combining this
-- algorithm with a list of exceptions.
local function findDerivedUnits(baseUnitTable)

    local derivedUnitReturn = {}

    while true do
        local optimalUnit
        local optimalBaseUnitPowerSum = 0
        for unit, u in pairs(derivedUnits) do
            local power = factor(baseUnitTable, u.baseUnits)
            if power ~= 0 then
                local baseUnitPowerSum = 0
                for _, v in ipairs(u.baseUnits) do
                    baseUnitPowerSum = baseUnitPowerSum + math.abs(v)
                end
                baseUnitPowerSum = baseUnitPowerSum * math.abs(power)
                if baseUnitPowerSum > optimalBaseUnitPowerSum then
                    optimalUnit = {unit = unit, power = power}
                    optimalBaseUnitPowerSum = baseUnitPowerSum
                end
            end
        end

        if optimalUnit ~= nil then
            table.insert(derivedUnitReturn, optimalUnit)
            local derivedUnitBaseUnitTable =
                derivedUnits[optimalUnit.unit].baseUnits
            for i, value in ipairs(baseUnitTable) do
                baseUnitTable[i] = value - optimalUnit.power *
                                       derivedUnitBaseUnitTable[i]
            end
        else
            return derivedUnitReturn
        end
    end

end

unitMetaTable = {
    __add = function(u1, u2)
        local newUnit = initialiseUnit()

        if type(u1) == "number" then
            local n = u1
            u1 = initialiseUnit()
            u1.quantity = n
        end
        if type(u2) == "number" then
            local n = u2
            u2 = initialiseUnit()
            u2.quantity = n
        end

        for i in ipairs(u1.baseUnits) do
            assert(u1.baseUnits[i] == u2.baseUnits[i],
                   "Cannot add incompatible units, units have different dimensions")
            newUnit.baseUnits[i] = u1.baseUnits[i]
        end

        newUnit.quantity = u1.quantity + u2.quantity

        return newUnit
    end,
    __sub = function(u1, u2)
        local newUnit = initialiseUnit()

        if type(u1) == "number" then
            local n = u1
            u1 = initialiseUnit()
            u1.quantity = n
        end
        if type(u2) == "number" then
            local n = u2
            u2 = initialiseUnit()
            u2.quantity = n
        end

        for i in ipairs(u1.baseUnits) do
            assert(u1.baseUnits[i] == u2.baseUnits[i],
                   "Cannot add incompatible units, units have different dimensions")
            newUnit.baseUnits[i] = u1.baseUnits[i]
        end

        newUnit.quantity = u1.quantity - u2.quantity

        return newUnit
    end,
    __mul = function(u1, u2)
        local newUnit = initialiseUnit()

        if type(u1) == "number" then
            newUnit.quantity = u1 * u2.quantity
            for index, value in ipairs(u2.baseUnits) do
                newUnit.baseUnits[index] = value
            end
        elseif type(u2) == "number" then
            newUnit.quantity = u2 * u1.quantity
            for index, value in ipairs(u1.baseUnits) do
                newUnit.baseUnits[index] = value
            end
        else
            newUnit.quantity = u1.quantity * u2.quantity
            for index in ipairs(newUnit.baseUnits) do
                newUnit.baseUnits[index] =
                    u1.baseUnits[index] + u2.baseUnits[index]
            end
        end

        return newUnit
    end,
    __div = function(u1, u2)
        local newUnit = initialiseUnit()

        if type(u1) == "number" then
            newUnit.quantity = u1 / u2.quantity
            for index, value in ipairs(u2.baseUnits) do
                newUnit.baseUnits[index] = value
            end
        elseif type(u2) == "number" then
            newUnit.quantity = u1.quantity / u2
            for index, value in ipairs(u1.baseUnits) do
                newUnit.baseUnits[index] = value
            end
        else
            newUnit.quantity = u1.quantity * u2.quantity
            for index in ipairs(newUnit.baseUnits) do
                newUnit.baseUnits[index] =
                    u1.baseUnits[index] - u2.baseUnits[index]
            end
        end

        return newUnit
    end,
    __unm = function(u1)
        local newUnit = initialiseUnit()
        newUnit.quantity = -u1.quantity
        for i in ipairs(u1.baseUnits) do
            newUnit.baseUnits[i] = u1.baseUnits[i]
        end

        return newUnit
    end,
    __pow = function(u1, u2)

        local power
        if type(u2) == "number" then
            power = u2
        else
            for _, value in ipairs(u2.baseUnits) do
                assert(value == 0, "Power must be dimensionless")
            end
            power = u2.quantity
        end

        local newUnit = initialiseUnit()

        if type(u1) == "number" then
            newUnit.quantity = u1 ^ power
        else
            newUnit.quantity = u1.quantity ^ power
            for index, value in ipairs(u1.baseUnits) do
                -- do not check for non integer powers, these are allowed to be
                -- introduced. For example specific detectivity contains a
                -- Hz^-1/2 unit.
                newUnit.baseUnits[index] = value * power
            end
        end

        return newUnit
    end,
    __tostring = function(u1)

        local baseUnitTable = {}
        for index, value in ipairs(u1.baseUnits) do
            baseUnitTable[index] = value
        end

        local unitTable = findDerivedUnits(baseUnitTable)

        for index, value in ipairs(baseUnitTable) do
            if value ~= 0 then
                table.insert(unitTable, {unit = baseUnits[index], power = value})
            end
        end

        table.sort(unitTable, function(e1, e2) return e1.power > e2.power end)

        for index, value in ipairs(unitTable) do
            if value.power == 1 then
                unitTable[index] = value.unit
            else
                unitTable[index] = value.unit .. "^" .. tostring(value.power)
            end
        end

        return u1.quantity .. "  " .. table.concat(unitTable, " ")
    end,
    __eq = function(u1, u2)

        if type(u1) == "number" then
            local newUnit = initialiseUnit()
            newUnit.quantity = u1
            u1 = newUnit
        end
        if type(u2) == "number" then
            local newUnit = initialiseUnit()
            newUnit.quantity = u2
            u2 = newUnit
        end

        if u1.quantity ~= u2.quantity then return false end

        for index, value in ipairs(u1.baseUnits) do
            if value ~= u2.baseUnits[index] then return false end
        end
        return true
    end,
    __index = {
        unit = function(self)
            local newUnit = initialiseUnit()
            for index, value in ipairs(self.baseUnits) do
                newUnit.baseUnits[index] = value
            end
            return newUnit
        end,
        num = function(self)
            for _, value in ipairs(self.baseUnits) do
                assert(value == 0,
                       "Unit must be dimensionless to convert to number")
            end
            return self.quantity
        end,
        numUnchecked = function(self) return self.quantity end
    }
}

function si.Unit(singleUnit)
    local newUnit = initialiseUnit()
    if not singleUnit then return newUnit end
    local baseUnitIndex = baseUnitNumbering[singleUnit]
    if baseUnitIndex ~= nil then
        newUnit.baseUnits[baseUnitIndex] = 1
    else
        local derivedUnit = derivedUnits[singleUnit] or
                                unitTypingAlias[singleUnit]
        assert(derivedUnit, "Cannot determine unit")
        for index, value in ipairs(derivedUnit.baseUnits) do
            newUnit.baseUnits[index] = value
        end
    end

    return newUnit
end

do -- initialise the derived units
    local kg = si.Unit("kg")
    local m = si.Unit("m")
    local s = si.Unit("s")
    local A = si.Unit("A")
    local K = si.Unit("K")
    local mol = si.Unit("mol")
    local cd = si.Unit("cd")

    derivedUnits = {
        ["Ω"] = kg * m ^ 2 * s ^ -3 * A ^ -2,
        ["V"] = kg * m ^ 2 * s * -3 * A ^ -1,
        ["H"] = kg * m ^ 2 * s ^ -2 * A ^ -2,
        ["Wb"] = kg * m ^ 2 * s ^ -2 * A ^ -1,
        ["C"] = A * s ^ -1,
        ["F"] = kg ^ -1 * m ^ -2 * s ^ 4 * A ^ 2,
        ["T"] = kg * s ^ -2 * A ^ -1,

        ["N"] = kg * m * s ^ -2,
        ["J"] = kg * m ^ 2 * s ^ -2,
        ["W"] = kg * m ^ 2 * s ^ -3,

        ["Pa"] = kg * m ^ -1 * s ^ -2
    }

    unitTypingAlias = {["ohm"] = derivedUnits["Ω"]}
end

return si
