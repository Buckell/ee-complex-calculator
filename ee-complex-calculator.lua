local sin, cos = math.sin, math.cos

local deg = math.rad
local rad = function (rad) return rad end

local c

POLAR_METATABLE = {
    __index = {
        a = function (self)
            return self.amplitude
        end,
        p = function (self)
            return self.phase
        end,
        c = function (self)
            return c(self.amplitude * math.cos(self.phase), self.amplitude * math.sin(self.phase))
        end,
    },
    __tostring = function (self)
        return tostring(self.amplitude) .. "<" .. tostring(math.deg(self.phase)) .. "*" 
    end,
}

local create_polar = function (amplitude, phase)
    local polar = { amplitude = amplitude, phase = phase }
    
    setmetatable(polar, POLAR_METATABLE)
    
    return polar
end

COMPLEX_METATABLE = {
    __index = {
        re = function (self)
            return self.real
        end,
        im = function (self)
            return self.imaginary 
        end,
        p = function (self)
            local amplitude = math.sqrt(self.real ^ 2 + self.imaginary ^ 2)
            local phase = self.real ~= 0 and math.atan(self.imaginary / self.real) or (math.pi / 2)
            
            return create_polar(amplitude, phase)
        end,
        conj = function (self)
            return c(self.real, -self.imaginary) 
        end,
        rms = function (self)
            return self / math.sqrt(2)
        end
    },
    __tostring = function (self)
        return tostring(self.real) .. " + " .. tostring(self.imaginary) .. "i"
    end,
    __unm = function (self)
        return c(-self.real, -self.imaginary)
    end,
    __add = function (self, rhs)
        local rhs_type = type(rhs)
        
        if rhs_type == "number" then
            return c(self.real + rhs, self.imaginary)
        elseif rhs_type == "table" and rhs.COMPLEX then
            return c(self.real + rhs.real, self.imaginary + rhs.imaginary)
        end
        
        return self
    end,
    __sub = function (self, rhs)
         local rhs_type = type(rhs)
        
        if rhs_type == "number" then
            return c(self.real - rhs, self.imaginary)
        elseif rhs_type == "table" and rhs.COMPLEX then
            return c(self.real - rhs.real, self.imaginary - rhs.imaginary)
        end
        
        return self
    end,
    __mul = function (self, rhs)
        local rhs_type = type(rhs)
        
        if rhs_type == "number" then
            return c(self.real * rhs, self.imaginary * rhs)
        elseif rhs_type == "table" and rhs.COMPLEX then
            return c(self.real * rhs.real - self.imaginary * rhs.imaginary, self.real * rhs.imaginary + self.imaginary * rhs.real)
        end
        
        return self
    end,
    __div = function (self, rhs)
        local rhs_type = type(rhs)
        
        if rhs_type == "number" then
            return c(self.real / rhs, self.imaginary / rhs)
        elseif rhs_type == "table" and rhs.COMPLEX then
            return (self * rhs:conj()) / (rhs * rhs:conj()):re()
        end
        
        return self
    end,
    __bor = function (self, rhs)
        return (self * rhs) / (self + rhs)
    end
}


c = function (real, imaginary)
    local complex = { COMPLEX = true, real = real, imaginary = imaginary or 0 } 
    setmetatable(complex, COMPLEX_METATABLE)
    return complex
end

p = function (amplitude, phase)
    return create_polar(amplitude, phase or 0):c()
end

-- V = p(45, 30)

-- ZL = c(0, 0.3 * 1000)
-- ZR = c(1500)
-- ZC = c(0, 1/(1000 * 0.000005))

-- V1 = V * ((ZC | (ZR + ZC))/((ZC | (ZR + ZC)) + ZL + ZR))
-- V2 = V1 * (ZC / (ZC + ZR))

-- print(V1:p())
-- print(V2:p())

-- print(ZC | (ZR + ZC | (ZL + ZR)))


-- Vout = p(10, 45)

-- ZC = c(0, -1/(200*0.000010))
-- ZR = c(1000)

-- I2 = Vout / (ZR | ZC)

-- print("I2 =", I2:p())

-- V2 = I2 * (ZR + ZR | ZC)

-- print("V2 =", V2:p())


V = p(8, 90)

ZR = c(10000)
ZL = c(0, 60 * math.pi * 0.005)
ZC = c(0, -1/(60 * math.pi * 0.000009))


I = V / (ZR + ZL + ZC)
Theta = V:p():p() - I:p():p()

print(I:p())
print(math.cos(Theta))
print((V:rms() * I:rms() * math.cos(Theta)):p():a())
print((V:rms() * I:rms() * math.sin(Theta)):p():a())


