# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


"""
    abstract type AbstractRadNonlinearFilter <: AbstractRadSigFilter

Abstract type for non-linear signal filters.
"""
abstract type AbstractRadNonlinearFilter <: AbstractRadSigFilter end
export AbstractRadNonlinearFilter


# ToDo:
#
# Dither(...)
# FFTDenoise(...)
# WaveletDenoise(...)
# ...
