# general array for testing input to SpecialFunctions.jl
x = 0.01:0.01:100.0

### Tests for besselj0
j0_SpecialFunctions = SpecialFunctions.besselj0.(big.(x)) # array to be tested against computed in BigFloats
@assert j0_SpecialFunctions[1] isa BigFloat               # just double check the higher precision

j0_64 = besselj0.(Float64.(x))
j0_32 = besselj0.(Float32.(x))
j0_big = besselj0.(big.(x))

# make sure output types match input types
@test j0_64[1] isa Float64
@test j0_32[1] isa Float32
@test j0_big[1] isa BigFloat

# test against SpecialFunctions.jl
@test j0_64 ≈ j0_SpecialFunctions
@test j0_32 ≈ j0_SpecialFunctions

# BigFloat precision only computed to 128 bits
@test isapprox(j0_big, j0_SpecialFunctions, atol=1.5e-34)

# NaN should return NaN
@test isnan(besselj0(NaN))

# zero should return one
@test isone(besselj0(zero(Float32)))
@test isone(besselj0(zero(Float64)))
@test isone(besselj0(zero(BigFloat)))

# test that Inf inputs go to zero
@test besselj0(Inf32) == zero(Float32)
@test besselj0(Inf64) == zero(Float64)

### Tests for besselj1
j1_SpecialFunctions = SpecialFunctions.besselj1.(big.(x)) # array to be tested against computed in BigFloats
@assert j1_SpecialFunctions[1] isa BigFloat               # just double check the higher precision

j1_64 = besselj1.(Float64.(x))
j1_32 = besselj1.(Float32.(x))

# make sure output types match input types
@test j1_64[1] isa Float64
@test j1_32[1] isa Float32

# test against SpecialFunctions.jl
@test j1_64 ≈ j1_SpecialFunctions
@test j1_32 ≈ j1_SpecialFunctions

# NaN should return NaN
@test isnan(besselj1(NaN))

# zero should return zero
@test iszero(besselj1(zero(Float32)))
@test iszero(besselj1(zero(Float64)))

# test that Inf inputs go to zero
@test besselj1(Inf32) == zero(Float32)
@test besselj1(Inf64) == zero(Float64)
