# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    abstract type AbstractRadFilter

Abstract type for signal filters.

Subtypes of `AbstractRadFilter` must implement

* `Base.mul!(output, flt::SomeFilter, input)`

* `RadiationDetectorDSP.output_type(flt::SomeFilter, input_type::Type{<:RealQuantity})`

* `RadiationDetectorDSP.output_length(flt::SomeFilter, input_length::Integer)`

Invertible filters must implement

* `Base.inv(flt::SomeFilter)`

If a filter's output time axis can be computed from the input time axis, it
must implement

* `RadiationDetectorDSP.output_time_axis(flt::SomeFilter, time::Range)`

Default methods are implemented for

* `Base.mul(flt::AbstractRadFilter, x::AbstractSamples)`
* `Base.mul(flt::AbstractRadFilter, wf::RDWaveform)`
* `Base.mul!(wf_out, flt::AbstractRadFilter, wf_in::RDWaveform)`

The default methods that operate on `RDWaveform`s require
[`RadiationDetectorDSP.output_time_axis`](@ref).
"""
abstract type AbstractRadFilter
export AbstractRadFilter



"""
   output_type(flt::AbstractRadFilter, input_type::Type{<:RealQuantity})::RealQuantity

Get the output sample type of filter `flt`, given an input sample type `input_type`.

Must be implemented for all subtypes of [`AbstractRadFilter`](@ref).
"""
function output_type end


"""
   output_length(flt::AbstractRadFilter, input_length::Integer)::Integer

Get the output signal length of filter `flt`, given an input of length `input_length`.

Must be implemented for all subtypes of [`AbstractRadFilter`](@ref).
"""
function output_length end


"""
   output_time_axis(flt::AbstractRadFilter, time::Range)::Range

Get the output time axis of filter `flt`, given an input time axis `time`.

Must be implemented for subtypes of [`AbstractRadFilter`](@ref) only if the
filter's output time axis can be computed directly from the input time axis.
"""
function output_time_axis end



function Base.mul(flt::AbstractRadFilter, x::AbstractSamples)
    U = output_type(flt, eltype(x))
    n_out = output_length(flt, length(eachindex(x)))
    y = similar(x, U, n_out)
    mul!(y, flt, x)
end

# ToDo: Custom broadcasting over ArrayOfSimilarSamples


function Base.mul(flt::AbstractRadFilter, wf::RDWaveform)
    x = wf.value
    y = mul(flt, x)
    t = output_time(flt, x.time)
    RDWaveform(y, t)
end


function Base.mul!(wf_out, flt::AbstractRadFilter, wf_in::RDWaveform)
    @require wf_out.time == output_time(flt, x.time)
    x = wf_in.value
    y = wf_out.value
    y = mul!(y, flt, x)
    wf_out
end


# ToDo: Custom broadcasting over ArrayOfRDWaveforms
