using Plots

include("references.jl")
include("production.jl")
include("signal.jl")
include("const.jl")
include("simulation.jl")

const time_frame = collect(1:tps_simul)

function stock_simulation_array(stocks_simul::Vector{Stocks})::Matrix{Int}
    """ Make an array ou of the stocks Vector. """
    acc = zeros(Int, (R, tps_simul))
    for i in 1:tps_simul
        acc[:,i] = stocks_simul[i].stocks
    end
    return acc
end

function plot_stocks(stocks_simul::Vector{Stocks}, depth::Int = R)
    """ Plots stock evolution through simulation time. """
    depth = min(depth, R)
    stock_matrix = stock_simulation_array(stocks_simul)
    p = plot(time_frame, stock_matrix[1, :], xlabel= "time", label = "Stock of ref 1")
    for ref_ind in  2:depth
        plot!(p, time_frame, stock_matrix[ref_ind, :], label = "Stock of ref $ref_ind")
    end
    if depth==R
        title!(p, "Stock evolution through time")
    elseif depth==1
        title!(p, "Stock evolution through time of first reference")
    else
        title!(p, "Stock evolution through time among $depth first references")
    end
    return p
end

function plot_staffing(staffing_simul::Vector{Int})
    """ Plots staffing evolution through simulation. """
    p = plot(time_frame, staffing_simul, xlabel= "time t", ylabel= "mobilised staff at t")
    title!(p, "Staffing requirements through time")
    return p
end
