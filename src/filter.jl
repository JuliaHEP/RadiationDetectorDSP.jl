# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    abstract type AbstractRadSigFilter

Abstract type for signal filters.

Subtypes of `AbstractRadSigFilter` must implement

* `Base.mul!(output, flt::SomeFilter, input)`

* `RadiationDetectorDSP.output_type(flt::SomeFilter, input_type::Type{<:RealQuantity})`

* `RadiationDetectorDSP.output_length(flt::SomeFilter, input_length::Integer)`

Invertible filters must implement

* `Base.inv(flt::SomeFilter)`

If a filter's output time axis can be computed from the input time axis, it
must implement

* `RadiationDetectorDSP.output_time_axis(flt::SomeFilter, time::Range)`

Default methods are implemented for

* `Base.mul(flt::AbstractRadSigFilter, x::AbstractSamples)`
* `Base.mul(flt::AbstractRadSigFilter, wf::RDWaveform)`
* `Base.mul!(wf_out, flt::AbstractRadSigFilter, wf_in::RDWaveform)`

The default methods that operate on `RDWaveform`s require
[`RadiationDetectorDSP.output_time_axis`](@ref).
"""
abstract type AbstractRadSigFilter end
export AbstractRadSigFilter



"""
   output_type(flt::AbstractRadSigFilter, input_type::Type{<:RealQuantity})::RealQuantity

Get the output sample type of filter `flt`, given an input sample type `input_type`.

Must be implemented for all subtypes of [`AbstractRadSigFilter`](@ref).
"""
function output_type end


"""
   output_length(flt::AbstractRadSigFilter, input_length::Integer)::Integer

Get the output signal length of filter `flt`, given an input of length `input_length`.

Must be implemented for all subtypes of [`AbstractRadSigFilter`](@ref).
"""
function output_length end


"""
   output_time_axis(flt::AbstractRadSigFilter, time::Range)::Range

Get the output time axis of filter `flt`, given an input time axis `time`.

Must be implemented for subtypes of [`AbstractRadSigFilter`](@ref) only if the
filter's output time axis can be computed directly from the input time axis.
"""
function output_time_axis end



function Base.mul(flt::AbstractRadSigFilter, x::AbstractSamples)
    U = output_type(flt, eltype(x))
    n_out = output_length(flt, length(eachindex(x)))
    y = similar(x, U, n_out)
    mul!(y, flt, x)
end

# ToDo: Custom broadcasting over ArrayOfSimilarSamples


function Base.mul(flt::AbstractRadSigFilter, wf::RDWaveform)
    x = wf.value
    y = mul(flt, x)
    t = output_time(flt, x.time)
    RDWaveform(y, t)
end


function Base.mul!(wf_out, flt::AbstractRadSigFilter, wf_in::RDWaveform)
    @require wf_out.time == output_time(flt, x.time)
    x = wf_in.value
    y = wf_out.value
    y = mul!(y, flt, x)
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


Base.mul!(output, flt::GenericRadSigFilter, input) = flt.f_apply!(output, input)

output_type(flt::GenericRadSigFilter, input_type::Type{<:RealQuantity}) = flt.f_output_type(input_type)

output_length(flt::GenericRadSigFilter, input_length::Integer) = flt.f_output_length(input_length)

output_time_axis(flt::GenericRadSigFilter, time::Range) = flt.f_output_time_axis(time)
