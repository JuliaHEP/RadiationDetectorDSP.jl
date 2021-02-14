# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    abstract type AbstractRadIIRFilter

Abstract type for IIR filters.
"""
abstract type AbstractRadIIRFilter
export AbstractRadIIRFilter



"""
    abstract type AbstractBiquadCompatibleFilter{T<:RealQuantity}

Abstract type for IIR filters that can be expressed as a biquad filter.

Conversions to DSP.jl:

* `DSP.Biquad(flt::AbstractBiquadCompatibleFilter)`
"""
abstract type AbstractBiquadCompatibleFilter{T<:RealQuantity}
export AbstractBiquadCompatibleFilter

DSP.FilterCoefficients(flt::AbstractBiquadCompatibleFilter) = DSP.Biquad(flt)

function DSP.Biquad(flt::AbstractBiquadCompatibleFilter{T}) where {T<:Real}
    U = float(T)
    DSP.Biquad{U}(flt)
end


# For testing:
coeffs_b_a(f::Biquad) = (SVec(f.b0, f.b1, f.b2), SVec(one(f.a1), f.a1, f.a2))



"""
    struct RCFilter{T<:Real} <: AbstractBiquadCompatibleFilter

A simple RC-filter.

Constructors:

* ```$(FUNCTIONNAME)(fields...)```

Fields:

$(TYPEDFIELDS)
"""
struct RCFilter{T<:RealQuantity} <: AbstractBiquadCompatibleFilter{T}
    "RC time constant"
    rc::Real
end

export RCFilter

function DSP.Biquad{T}(flt::RCFilter) where {T<:Real}
    rc = T(flt.RC)
    α = 1 / (1 + RC)
    Biquad(T(α), T(0), T(0), T(α - 1), T(0))
end



"""
    struct CRFilter{T<:Real} <: AbstractBiquadCompatibleFilter

A simple CR-filter.

Constructors:

* ```$(FUNCTIONNAME)(fields...)```

Fields:

$(TYPEDFIELDS)
"""
struct CRFilter{T<:RealQuantity} <: AbstractBiquadCompatibleFilter{T}
    "CR time constant"
    cr::Real
end

export CRFilter

Base.inv(flt::CRFilter) = InvCRFilter(flt.cr)

function DSP.Biquad{T}(flt::CRFilter) where {T<:Real}
    CR = T(flt.cr)
    α = CR / (CR + 1)
    DSP.Biquad(T(α), T(-α), T(0), T(-α), T(0))
end



"""
    struct InvCRFilter{T<:Real} <: AbstractBiquadCompatibleFilter

Inverse of [`CRFilter`](@ref).

Constructors:

* ```$(FUNCTIONNAME)(fields...)```

Fields:

$(TYPEDFIELDS)
"""
struct InvCRFilter{T<:RealQuantity} <: AbstractBiquadCompatibleFilter{T}
    "CR time constant"
    cr::Real
end

export InvCRFilter

Base.inv(flt::InvCRFilter) = CRFilter(flt.cr)

function DSP.Biquad{T}(flt::InvCRFilter) where {T<:Real}
    CR = T(flt.cr)
    α = inv(1 + CR)
    k = 1 + inv(CR)
    Biquad(T(k), T(k * (α - 1)), T(0), T(-1), T(0))
end






function crmod_filter(RC::Real)
    T = float(typeof(RC))
    α = RC / (RC + 1)
    Biquad(T(1), T(-1), T(0), T(-α), T(0))
end


function inv_crmod_filter(RC::Real)
    T = float(typeof(RC))
    α = 1 / (1 + RC)
    Biquad(T(1), T(α - 1), T(0), T(-1), T(0))
end


function integrator_filter(gain::Real)
    T = float(typeof(gain))
    Biquad(T(gain), T(0), T(0), T(-1), T(0))
end


function differentiator_filter(gain::Real)
    T = float(typeof(gain))
    Biquad(T(gain), T(-gain), T(0), T(0), T(0))
end


function integrator_cr_filter(gain::Real, RC::Real)
    T = float(promote_type(typeof(gain), typeof(RC)))
    α = 1 / (1 + RC)
    Biquad(T(gain), T(-α), T(0), T(α - 1), T(0))
end


function integrator_crmod_filter(gain::Real, RC::Real)
    T = float(promote_type(typeof(gain), typeof(RC)))
    α = 1 / (1 + RC)
    Biquad(T(gain), T(0), T(0), T(α - 1), T(0))
end


function simple_csa_response_filter(τ_rise::Real, τ_decay::Real, gain::Real = one(τ_rise))
    # TODO: Use a single biquad filter

    T = float(promote_type(promote_type(typeof(τ_rise), typeof(τ_decay)), typeof(gain)))
    rc_filter(T(τ_rise)) * integrator_cr_filter(T(gain), T(τ_decay))
end
