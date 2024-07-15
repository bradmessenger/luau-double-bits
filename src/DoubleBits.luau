local doubleBuffer = buffer.create(8)

local DoubleBits = {}

function DoubleBits.lo(n: number): number
	buffer.writef64(doubleBuffer, 0, n)
	return buffer.readu32(doubleBuffer, 0)
end

function DoubleBits.hi(n: number): number
	buffer.writef64(doubleBuffer, 0, n)
	return buffer.readu32(doubleBuffer, 4)
end

function DoubleBits.unpack(n: number): (number, number)
	buffer.writef64(doubleBuffer, 0, n)
	return buffer.readu32(doubleBuffer, 0), buffer.readu32(doubleBuffer, 4)
end

function DoubleBits.pack(lo: number, hi: number): number
	buffer.writeu32(doubleBuffer, 0, lo)
	buffer.writeu32(doubleBuffer, 4, hi)
	return buffer.readf64(doubleBuffer, 0)
end

function DoubleBits.sign(n: number): boolean
	return bit32.rshift(DoubleBits.hi(n), 31) ~= 0
end

function DoubleBits.exponent(n: number): number
	local b = DoubleBits.hi(n)
	return bit32.rshift(bit32.lshift(b, 1), 21) - 1023
end

function DoubleBits.fraction(n: number): (number, number)
	local lo, hi = DoubleBits.unpack(n)
	local b = bit32.band(hi, bit32.lshift(1, 20) - 1)
	if bit32.band(hi, 0x7ff00000) ~= 0 then
		b += bit32.lshift(1, 20)
	end
	return lo, b
end

function DoubleBits.denormalized(n: number): boolean
	local value = bit32.band(DoubleBits.hi(n), 0x7ff00000) 
	return value == 0
end

return DoubleBits