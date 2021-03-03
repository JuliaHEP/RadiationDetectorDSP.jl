# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    abstract type FilterLinearity <: FilteringType

Indended as a type parameter to designate the behavior of a filter
as linear or nonlinear.

Subtypes are [`LinearFiltering`](@ref) and [`NonlinearFiltering`](@ref).
"""
abstract type FilteringType end


"""
    abstract type LinearFiltering <: FilteringType

When used as a type parameter value, marks linear behavior of a filter.
"""
abstract type LinearFiltering <: FilteringType end
export LinearFiltering


"""
    abstract type LinearFiltering <: FilteringType

When used as a type parameter value, marks non linear behavior of a filter.
"""
abstract type NonlinearFiltering <: FilteringType end
export NonlinearFiltering



"""
    abstract type AbstractRadSigFilter{<:FilteringType}

Abstract type for signal filters.

Subtypes of `AbstractRadSigFilter` must implement

* `RadiationDetectorDSP.flt_output_smpltype(flt::SomeFilter, input_smpltype::Type{<:RealQuantity})`

* `RadiationDetectorDSP.flt_output_length(flt::SomeFilter, input_length::Integer)`

* `RadiationDetectorDSP.flt_output_dt(fi::SomeFilter, input_dt::Real)`

Invertible filters must implement

* `Base.inv(flt::SomeFilter)`

If a filter's output time axis can be computed from the input time axis, it
must implement

* `RadiationDetectorDSP.flt_output_time_axis(flt::SomeFilter, time::Range)`

The default methods for

* `RadiationDetectorDSP.rdfilt!(output, flt::AbstractRadSigFilter, input)`
* `RadiationDetectorDSP.rdfilt(flt::AbstractRadSigFilter, x::AbstractSamples)`
* `RadiationDetectorDSP.rdfilt(flt::AbstractRadSigFilter, wf::RDWaveform)`
* `RadiationDetectorDSP.rdfilt!(wf_out, flt::AbstractRadSigFilter, wf_in::RDWaveform)`

should not be overloaded.

The default methods that operate on `RDWaveform`s require
[`RadiationDetectorDSP.flt_output_time_axis`](@ref).
"""
abstract type AbstractRadSigFilter{<:FilteringType} end
export AbstractRadSigFilter


"""
    abstract type AbstractRadSigFilterInstance{<:FilteringType}

Abstract type for signal filter instances. Filter instances are specilized to
a specific length and numerical type of input and output.

Subtypes of `AbstractRadSigFilterInstance` must implement

* `RadiationDetectorDSP.rdfilt!(output, fi::SomeFilterInstance, input)`

* `RadiationDetectorDSP.flt_input_smpltype(fi::SomeFilterInstance)`

* `RadiationDetectorDSP.flt_output_smpltype(fi::SomeFilterInstance)`

* `RadiationDetectorDSP.flt_input_length(fi::SomeFilterInstance)`

* `RadiationDetectorDSP.flt_output_length(fi::SomeFilterInstance)`

* `RadiationDetectorDSP.flt_input_dt(fi::SomeFilterInstance)`

* `RadiationDetectorDSP.flt_output_dt(fi::SomeFilterInstance)`

* `RadiationDetectorDSP.filterdef(fi::SomeFilterInstance)::AbstractRadSigFilter`

Linear filters (subtypes of `AbstractRadSigFilterInstance{LinearFiltering}`) must implement

* `Base.convert(LinearMaps.LinearMap, fi::SomeFilterInstance)`

Invertible filters may implement

* `Base.inv(fi::SomeFilterInstance)`

If a filter's output time axis can be computed from the input time axis, it
must implement

* `RadiationDetectorDSP.flt_output_time_axis(fi::SomeFilterInstance, time::Range)`

Default methods are implemented for

* `RadiationDetectorDSP.rdfilt(flt::AbstractRadSigFilterInstance, x::AbstractSamples)`
* `RadiationDetectorDSP.rdfilt(flt::AbstractRadSigFilterInstance, wf::RDWaveform)`
* `RadiationDetectorDSP.rdfilt!(wf_out, flt::AbstractRadSigFilterInstance, wf_in::RDWaveform)`

The default methods that operate on `RDWaveform`s require
[`RadiationDetectorDSP.flt_output_time_axis`](@ref).
"""
abstract type AbstractRadSigFilterInstance{<:FilteringType} end
export AbstractRadSigFilter




"""
    rdfilt!(output, flt::AbstractRadSigFilter, input)
    rdfilt!(output, fi::AbstractRadSigFilterInstance, input)

Apply filter `flt` or filter instance `fi` to signal `input` and store the
filtered signal in `output`. Returns `output`.

Returns `output`.
"""
function dfilt! end
export rdfilt!

rdfilt!(output, flt::AbstractRadSigFilter, input) = rdfilt!(output, fltinstance(flt, input), input)


"""
    rdfilt(flt::AbstractRadSigFilter, input)
    rdfilt(fi::AbstractRadSigFilterInstance, input)

Apply filter `flt` or filter instance `fi` to signal `input`, returns the
filtered signal.

Returns `output`.
"""
function rdfilt end
export rdfilt

rdfilt(flt::AbstractRadSigFilter, input) = rdfilt(fltinstance(flt, input), input)


"""
    RadiationDetectorDSP.flt_output_smpltype(FT::Type{<:AbstractRadSigFilter}, input_smpltype::Type{<:RealQuantity})
    RadiationDetectorDSP.flt_output_smpltype(FT::Type{<:AbstractRadSigFilterInstance})

Get the output sample type for
    
* a filter type given an input sample type `input_smpltype`
* a filter instance

Must be implemented for all subtypes of [`AbstractRadSigFilter`](@ref).
"""
function flt_output_smpltype end


"""
    RadiationDetectorDSP.flt_input_smpltype(fi::AbstractRadSigFilterInstance)

Get the input sample type of a filter instance `fi`.
    
Must be implemented for all subtypes of [`AbstractRadSigFilterInstance`](@ref).
"""
function flt_input_smpltype end


"""
    RadiationDetectorDSP.flt_output_length(flt::AbstractRadSigFilter, input_length::Integer)::Integer

Get the output signal length of

* a filter `flt`, given an input of length `input_length`
* a filter instance `fi`

Must be implemented for all subtypes of [`AbstractRadSigFilter`](@ref) and
[`AbstractRadSigFilterInstance`](@ref).
"""
function flt_output_length end


"""
    RadiationDetectorDSP.flt_input_length(fi::AbstractRadSigFilterInstance)::Integer

Get the output signal length of a filter instance `fi`.

Must be implemented for all subtypes of [`AbstractRadSigFilterInstance`](@ref).
"""
function flt_input_length end


"""
    RadiationDetectorDSP.flt_output_dt(flt::SomeFilter, input_dt::RealQuantity)::RealQuantity
    RadiationDetectorDSP.flt_output_dt(fi::SomeFilterInstance)::RealQuantity

Get the output sampling interval of

* a filter `flt`, given an input sampling interval `input_dt`
* a filter instance `fi`

Must be implemented for all subtypes of [`AbstractRadSigFilter`](@ref) and
[`AbstractRadSigFilterInstance`](@ref).        
"""
function flt_output_dt end


"""
    RadiationDetectorDSP.flt_input_dt(fi::AbstractRadSigFilterInstance)::RealQuantity

Get the input sampling interval of a filter instance `fi`.

Must be implemented for all subtypes of [`AbstractRadSigFilterInstance`](@ref).
"""
function flt_input_dt end



"""
    RadiationDetectorDSP.flt_output_time_axis(flt::AbstractRadSigFilter, time::Range)::Range
    RadiationDetectorDSP.flt_output_time_axis(fi::AbstractRadSigFilterInstance, time::Range)::Range

Get the output time axis of filter `flt` or filter instance `fi`, given an
input time axis `time`.

Must be implemented for subtypes of [`AbstractRadSigFilter`](@ref) and
[`AbstractRadSigFilterInstance`](@ref) only if the filter's output time axis
can be computed directly from the input time axis.
"""
function flt_output_time_axis end



function rdfilt(flt::AbstractRadSigFilter, x::AbstractSamples)
    U = flt_output_smpltype(typeof(flt), eltype(x))
    n_out = flt_output_length(flt, length(eachindex(x)))
    y = similar(x, U, n_out)
    rdfilt!(y, flt, x)
end

# ToDo: Custom broadcasting over ArrayOfSimilarSamples


function rdfilt(flt::AbstractRadSigFilter, wf::RDWaveform)
    x = wf.value
    y = rdfilt(flt, x)
    t = output_time(flt, x.time)
    RDWaveform(y, t)
end


function rdfilt!(wf_out, flt::AbstractRadSigFilter, wf_in::RDWaveform)
    @require wf_out.time == output_time(flt, x.time)
    x = wf_in.value
    y = wf_out.value
    y = rdfilt!(y, flt, x)
    wf_out
end


# ToDo: Custom broadcasting over ArrayOfRDWaveforms



struct GenericRadSigFilter{
    F<:Function,
    FOT<:Function,
    FOL<:Function,
    FOA<:Function
} <: AbstractRadSigFilter
    f_apply!::F
    f_output_type::FOT
    f_output_length::FOL
    f_output_time_axis::FOA
end


GenericRadSigFilter(
    f_apply!::Function,
    f_output_type::Function = identity,
    f_output_length::Function = identity,
    f_output_time_axis::Function = identity  
) = GenericRadSigFilter{typeof(f_apply!), typeof(f_output_type), typeof(f_output_length), typeof(f_output_time_axis)}(
    f_apply!, f_output_type, f_output_length, f_output_time_axis
)


rdfilt!(output, flt::GenericRadSigFilter, input) = flt.f_apply!(output, input)

flt_output_smpltype(flt::GenericRadSigFilter, input_smpltype::Type{<:RealQuantity}) = flt.f_output_type(input_smpltype)

flt_output_length(flt::GenericRadSigFilter, input_length::Integer) = flt.f_output_length(input_length)

flt_output_time_axis(flt::GenericRadSigFilter, time::Range) = flt.f_output_time_axis(time)
