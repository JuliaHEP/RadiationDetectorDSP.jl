# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).

"""
    abstract type RDSPFilter

An abstract DSP filter. May be a [`RDSPFilterDefinition`](@ref) or a
[`RDSPFilterInstance`](@ref).
"""
abstract type RDSPFilter end



"""
    abstract type RDSPFilterDefinition <: RDSPFilter

Abstract type for DSP filter definitions. A filter definition can not be
applied to data directly, a [`RDSPFilterInstance`](@ref) must be
created first. When a filter definition is applied to data, a temporary filter
instance will be created automatically.

See [`RDSPFilter`](@ref).
"""
abstract type RDSPFilterDefinition <: RDSPFilter end


"""
    abstract type RDSPFilterInstance <: RDSPFilter

Abstract type for DSP filter instances. A filter instance is created based
on  a filter definitions ([`RDSPFilterDefinition`](@ref)) and a concrete input
data type. Filter instances typically carry additional information, and use
input-specific typing of parameters (e.g. filter coefficients).

See also [`RDSPFilter`](@ref).
"""
abstract type RDSPFilterInstance <: RDSPFilter end



"""
    filterdef(filterinst::RDSPFilterInstance):RDSPFilterDefinition

Get the [`RDSPFilterInstance`](@ref) for `filterinst`.
"""
function filterdef end

struct GenericRDSPFilterInstance{F<:RDSPFilterDefinition}
    filterdef::F
end
