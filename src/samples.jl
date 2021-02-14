# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


const MaybeWithUnits{T} = Union{T,Quantity{<:T}}
const RealQuantity = MaybeWithUnits{<:Real}


const AbstractSamples{T<:Real} = AbstractVector{T}


dspfloattype(::Type{T}) where {T} = float(T)
dspfloattype(::Type{T}) where {T<:Union{Int8,UInt8,Int16,UInt16,Int32,UInt32}} = Float32


const RealOrSIMD{T<:Real} = Union{T,<:Vec{N,<:T} where N}