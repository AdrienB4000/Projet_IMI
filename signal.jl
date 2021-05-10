#=
signal:
- Julia version: 1.6.0
- Author: cgris
- Date: 2021-04-12
=#
#include("const.jl")

struct Signal
    planning::Vector{Int}
    T::Int #en unite de temps

    Signal(planning, T)=new(planning, T)
    Signal(T)=new(rand(1:R, nb_ref_unite_tps), T) #references a produire en une unité de temps dans T unité de temps
end
