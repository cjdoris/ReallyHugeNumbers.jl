module ReallyHugeNumbers

import HugeNumbers: Huge, hugen, invhugen

export ReallyHuge, hugen, invhugen

struct ReallyHuge{T<:Real,D<:Integer} <: Real
    val::T
    depth::D
    ReallyHuge{T,D}(x::T, d::D) where {T<:Real,D<:Integer} = new{T,D}(x, d)
end

ReallyHuge{T,D}(x::Real, d::Integer=zero(Int8)) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(convert(T, x), convert(D, d))
ReallyHuge{T}(x::Real, d::D=zero(Int8)) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(x, d)
ReallyHuge(x::T, d::D=zero(Int8)) where {T<:Real, D<:Integer} = ReallyHuge{T,D}(x, d)

ReallyHuge{T,D}(x::ReallyHuge, d::Integer) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(x.val, x.depth + d)
ReallyHuge{T}(x::ReallyHuge, d::Integer) where {T<:Real} = ReallyHuge{T}(x.val, x.depth + d)
ReallyHuge(x::ReallyHuge, d::Integer) = ReallyHuge(x.val, x.depth + d)

ReallyHuge{T,D}(x::ReallyHuge) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(x.val, x.depth)
ReallyHuge{T}(x::ReallyHuge) where {T<:Real} = ReallyHuge{T}(x.val, x.depth)
ReallyHuge(x::ReallyHuge) = x

ReallyHuge{T,D}(x::Huge, d::Integer) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(invhugen(x), d + one(d))
ReallyHuge{T}(x::Huge, d::D) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(x, d)
ReallyHuge(x::Huge{T}, d::D) where {T<:Real,D<:Integer} = ReallyHuge{T,D}(x, d)

hugen(x::ReallyHuge) = ReallyHuge(x.val, x.depth + one(x.depth))

invhugen(x::ReallyHuge) = ReallyHuge(x.val, x.depth - one(x.depth))

deeper(x::ReallyHuge) = ReallyHuge(invhugen(x.val), x.depth + one(x.depth))

shallower(x::ReallyHuge) = ReallyHuge(hugen(x.val), x.depth - one(x.depth))

function atdepth(x::ReallyHuge, d::Integer)
    d = oftype(x.depth, d)
    while x.depth > d
        x = shallower(x)
    end
    while x.depth < d
        x = deeper(x)
    end
    return x
end

shallow(x::ReallyHuge) = atdepth(x, 0)

function atmaxdepth(xs::ReallyHuge...)
    d = maximum(map(x->x.depth, xs))
    return map(x->atdepth(x, d), xs)
end

Base.AbstractFloat(x::ReallyHuge) = AbstractFloat(shallow(x).val)

Base.:(-)(x::ReallyHuge) = ReallyHuge(-x.val, x.depth)

Base.inv(x::ReallyHuge) = ReallyHuge(inv(x.val), x.depth)

for op in [:(+), :(-), :(*), :(/)]
    @eval function Base.$op(x::ReallyHuge, y::ReallyHuge)
        d = max(x.depth, y.depth, false)
        x = atdepth(x, d)
        y = atdepth(y, d)
        if iszero(d)
            return ReallyHuge($op(x.val, y.val), d)
        else
            x2 = hugen(Huge, invhugen(x))
            y2 = hugen(Huge, invhugen(y))
            return hugen(ReallyHuge(invhugen($op(x2, y2))))
        end
    end
end

for op in [:isinf, :isfinite, :iszero, :isone, :signbit]
    @eval Base.$op(x::ReallyHuge) = $op(x.val)
end

for op in [:isless, :(<), :isequal, :(==), :cmp]
    @eval function Base.$op(x::ReallyHuge, y::ReallyHuge)
        x, y = atmaxdepth(x, y)
        return $op(x.val, y.val)
    end
end

for op in [:log, :log2, :log10]
    @eval function Base.$op(x::ReallyHuge)
        if x.depth < 1
            x = atdepth(x, one(x.depth))
        end
        x2 = hugen(Huge, invhugen(x))
        return hugen(ReallyHuge(invhugen($op(x2))))
    end
end

function Base.exp(x::ReallyHuge)
    x2 = exp(Huge, x)
    return hugen(ReallyHuge(invhugen(x2)))
end

Base.promote_rule(::Type{ReallyHuge{T1,D1}}, ::Type{ReallyHuge{T2,D2}}) where {T1<:Real,D1<:Integer,T2<:Real,D2<:Integer}= ReallyHuge{promote_type(T1,T2),promote_type(D1,D2)}
Base.promote_rule(::Type{ReallyHuge{T1,D}}, ::Type{Huge{T2}}) where {T1<:Real,D<:Integer,T2<:Real} = ReallyHuge{promote_type(T1,T2),D}
Base.promote_rule(::Type{ReallyHuge{T1,D}}, ::Type{T2}) where {T1<:Real,D<:Integer,T2<:Real} = ReallyHuge{promote_type(T1,T2),D}

end # module
