# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).

"""
    abstract type RDSPFilter

An abstract DSP filter. May be a [`RDSPFilterDefinition`](@ref) or a
[`RDSPFilterInstance`](@ref).
"""
abstract type RDSPFilter end
export RDSPFilter


"""
    abstract type RDSPFilterDefinition <: RDSPFilter

Abstract type for DSP filter definitions. A filter definition can not be
applied to data directly, a [`RDSPFilterInstance`](@ref) must be
created first. When a filter definition is applied to data, a temporary filter
instance will be created automatically.

Subtypes of `RDSPFilterDefinition` must provide implementations of
[`filterinst`](@ref).

See [`RDSPFilter`](@ref).
"""
abstract type RDSPFilterDefinition <: RDSPFilter end
export RDSPFilterDefinition


"""
    filterinst(fd::RDSPFilterDefinition, ::Type{T}):RDSPFilterInstance

Get a [`RDSPFilterInstance`](@ref) based on filter definition `fd` and a
sample value type `T<:Real`. ``T` will typically be the result of
type promotion on input and output data data types.

Subtypes of `RDSPFilterDefinition` must provide at least an implementation
of `filterdef`.
"""
function filterinst end

function filterinst(
    fd::RDSPFilterDefinition,
    input::AbstractVector{Tin},
    output::AbstractVector{Tout}
)
    U = promote_type(dspfloattype(Tin), dspfloattype(Tout))
    filterinst(fd, U)
end


"""
    createoutput(fd::RDSPFilterDefinition, input)

Create suitable uninitialized output data for filter definition `fd` and input
data `input`.

Subtypes of `RDSPFilterDefinition` may provide custom implementations of
`createoutput`, but the default implementation should typically be
sufficient.
"""
function createoutput end

function createoutput(fd::RDSPFilterDefinition, input::AbstractVector{Tin}) where {Tin<:Real}
    Tout = outputsampletype(Tin)
    similar(input, Tout)
end


"""
    outputsampletype(fd::RDSPFilterDefinition, ::Type{Tin})::Tout

Get a suitable output sample value type for filter definition `fd` and
input sample type `Tin<:Real`.

Subtypes of `RDSPFilterDefinition` may provide custom implementations of
`outputsampletype`, but the default implementation should typically be
sufficient.
"""
function outputsampletype end

outputsampletype(fd::RDSPFilterDefinition, ::Type{Tin}) where {Tin<:Real} =
    dspfloattype(Tin)


"""
    abstract type RDSPFilterInstance <: RDSPFilter

Abstract type for DSP filter instances. A filter instance is created based
on  a filter definitions ([`RDSPFilterDefinition`](@ref)) and concrete input
and output data types. Filter instances typically carry additional
information, and use input-specific typing of parameters (e.g. filter
coefficients).

Subtypes of `RDSPFilterDefinition` must at least provide implementations of
[`filterdef`](@ref), !!!!!!.

Depending on the filter, custom implementations of !!!!! may be beneficial
for performance or required under special circumstances.

See also [`RDSPFilter`](@ref).
"""
abstract type RDSPFilterInstance <: RDSPFilter end
export RDSPFilterInstance


"""
    filterdef(fi::RDSPFilterInstance):RDSPFilterDefinition

Get the [`RDSPFilterDefinition`](@ref) for `fi`.

Subtypes of `RDSPFilterDefinition` must provide an implementation
of `filterdef`.
"""
function filterdef end



struct GenericRDSPFilterInstance{F<:RDSPFilterDefinition}
    filterdef::F
end

filterdef(fi::GenericRDSPFilterInstance) = fi.filterdef
