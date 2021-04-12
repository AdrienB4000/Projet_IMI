#=
signal:
- Julia version: 1.6.0
- Author: cgris
- Date: 2021-04-12
=#

const nb_ref_unite_tps

struct Signal
    planning::Vector{Int}
    size::Int #en unite de temps

    Signal(planning, size)=new(planning, size)
    Signal(size)=new(rand(1:R, size*nb_ref_unite_tps), size)
end

