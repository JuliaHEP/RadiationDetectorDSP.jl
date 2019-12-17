# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).

__precompile__(true)

module RadiationDetectorDSP

using ArgCheck
using ArraysOfArrays
using Distributions
using DSP
using ElasticArrays
using LinearAlgebra
using ParallelProcessingTools
using Parameters
using RadiationDetectorSignals
using Random
using RecipesBase
using StaticArrays
using Statistics
using StatsBase
using TypedTables
using UnsafeArrays

include("samples.jl")
include("rdspfilter.jl")
include("iir_filter.jl")
include("fir_filter.jl")
include("biquad_filter.jl")
include("trapezoidal_filter.jl")
include("dspjl_filters.jl")
include("generators.jl")

end # module
