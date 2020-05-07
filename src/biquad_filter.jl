# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    BiquadFilter <: RDSPFilterDefinition

Defines a biquad filter.
"""
struct BiquadFilterDef <: RDSPFilterDefinition
    b::NTuple{3,Float64}
    a::NTuple{2,Float64}
end

export BiquadFilterDef


struct BiquadCoeffs{T<:Real}
    b::NTuple{3,T}
    a::NTuple{2,T}
end

const BQState{T<:Real} = NTuple{2,T}


struct BiquadFilterInst{T<:Real} <: RDSPFilterInstance
    coeffs::BiquadCoeffs{T}
    state0::BQState{T}
end


function filterinst(fd::BiquadFilterDef, ::Type{T}) where {T<:Real}
    BiquadFilterInst(
        BiquadCoeffs{T}(fd.b, fd.a),
        BQState{U}(0, 0)
    )
end

filterdef(fi::BiquadFilterInst) = BiquadFilterDef(fi.coeffs.b, fi.coeffs.a)


@inline function fastbqfilt2!(
    Y::Vector{<:Real},
    coeffs::BiquadCoeffs{T},
    X::Vector{<:Real},
    s_init::BQState{T} = (zero(T), zero(T))
) where {T<:Real}
    U = promote_type(promote_type(eltype(X), eltype(Y)), T)
    a1, a2 = map(U, coeffs.a)
    neg_a1, neg_a2 = -a1, -a2
    b0, b1, b2 = map(U, coeffs.b)
    s1::U = s_init[1]
    s2::U = s_init[2]
    s3::U = 0

    @assert eachindex(X) == eachindex(Y)

    @inbounds @simd for i in eachindex(X)
        x = U(X[i])

        z1 = fma(b0, x, s1)
        z2 = fma(b1, x, s2)
        z3 = fma(b2, x, s3)

        y = z1
        Y[i] = y

        s1 = fma(neg_a1, y, z2)
        s2 = fma(neg_a2, y, z3)
    end
    Y
end
