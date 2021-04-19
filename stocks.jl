include("references.jl")
include("signal.jl")
include("production.jl")

struct Stocks
    stocks::Array{Int64,1}
    date::Int64

    Stocks(stocks, date)=new(stocks,date)
end


function Compute_Stocks_at_T_plus_1(signal::Signal, production::Production, stocks_T::Stocks, nbr_references::Int)
    new_stocks::Array{Int64,1}(undef,nbr_references)
    cum_prods = countmap(production.planning)
    cum_demand = countmap(signal.planning)
    for i in 1:nbr_references
        new_stocks[i] = stocks_T.planning[i] + cum_prods[i] - cum_demand[i]
        if new_stocks[i] < 0
            println("Error: negative stocks for reference ", i, " !")
        end
    end
    return Stocks(new_stocks,stocks_T.date+1)
end


function Compute_Stocks_for_12_hours(signaux::Vect{Signal}, productions::Vect{Production}, stocks_initiaux::Stocks, nbr_references::Int)
    Stocks_planning::Vect{Stocks}
    push!(Stocks_planning, Compute_stocks_at_T_plus_1(signaux[i], productions[i], stocks_initiaux, nbr_references))
    for i in 2:12
        push!(Stocks_planning, Compute_stocks_at_T_plus_1(signaux[i], productions[i], Stocks_planning[i-1]), nbr_references)
    end
    return Stocks_planning
end
