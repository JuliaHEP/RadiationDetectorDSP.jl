# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    abstract type AbstractRadFilter

Abstract type for linear filters.
"""
abstract type AbstractRadFilter
export AbstractRadFilter


"""
   output_time_axis(flt::AbstractRadFilter) 
"""
function output_time_axis(flt::AbstractRadFilter) end
