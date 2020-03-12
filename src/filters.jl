# This file is a part of RadiationDetectorDSP.jl, licensed under the MIT License (MIT).


#=
// Return RC low-pass filter output samples, given input samples,
 // time interval dt, and time constant RC
 function lowpass(real[0..n] x, real dt, real RC)
   var real[0..n] y
   var real α := dt / (RC + dt)
   y[0] := α * x[0]
   for i from 1 to n
       y[i] := α * x[i] + (1-α) * y[i-1]
   return y

template<typename tp_Type> class RCFilter: public Filter<tp_Type> {
protected:
    const tp_Type alpha;
    tp_Type y_1;

public:
    inline tp_Type operator()(tp_Type x) {
        tp_Type y = alpha * x + (1 - alpha) * y_1;
        y_1 = y; return y;
    }

    RCFilter(tp_Type rc, tp_Type initWith = 0)
        : alpha(1 / (1 + rc)), y_1(initWith) {}
};


template<typename tp_Type> class CRFilter: public Filter<tp_Type> {
protected:
    const tp_Type alpha;
    tp_Type x_1, y_1;

public:
    inline tp_Type operator()(tp_Type x) {
        tp_Type y = alpha * (y_1 + x - x_1);
        x_1 = x; y_1 = y; return y;
    }

    CRFilter(tp_Type rc, tp_Type initWith = 0)
        : alpha(1 / (1 + 1/rc)), x_1(initWith), y_1(0) {}
};

=#

function biquad_rcfilter(RC::Real)
    T = typeof(RC)
    α = 1 / (1 + RC)
    Biquad(T(α), T(0), T(0), T(α - 1), T(0))
end

function biquad_crfilter(RC::Real)
    T = typeof(RC)
    α = 1 / (1 + RC)
    Biquad(T(α), T(-α), T(0), T(α - 1), T(0))
end

biquad_integrator(T::Type{<:Real} = Float64) = Biquad(T(1), T(0), T(0), T(-1), T(0))
biquad_differentiator(T::Type{<:Real} = Float64) = Biquad(T(1), T(-1), T(0), T(0), T(0))



function exp_decay_deconv(samples::AbstractSamples, τ::Real)
    T = eltype(samples)

    α = T(1 / (1 + tau))
    # α = T(1 - exp(- 1/tau))

    acc::T = zero(T);

    for i in eachindex(samples)
        x = samples[i];
        res = x + acc;
        acc += x * α;
        samples[i] = res;
    end
end
