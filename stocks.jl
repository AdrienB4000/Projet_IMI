include("references.jl")
include("signal.jl")
include("production.jl")

struct Stocks
    stocks::Array{Int64,1}
    date::Int64

    Stocks(stocks, date)=new(stocks,date)
end


function Compute_Stocks_at_T_plus_1(signal::Signal, production::Production, stocks_T::Stocks, nbr_references::Int)
    new_stocks = stocks_T.stocks
    cum_prods = countmap(production.planning)
    cum_demand = countmap(signal.planning)
    println(cum_prods, " prod reelle ", production.planning)
    println(cum_demand, " signal reel ", signal.planning)


    for i in 1:nbr_references
        if i in keys(cum_prods)
            new_stocks[i] += cum_prods[i]
        end
        if i in keys(cum_demand)
            new_stocks[i] -= cum_demand[i]
        end
        if new_stocks[i] < 0
            println("Error: negative stocks for reference ", i, " !")
        end
    end
    s = Stocks(new_stocks,stocks_T.date+1)
    println("stock ", s.date, " : ", s.stocks)
    return s
end


function Compute_Stocks_for_12_hours(signaux::Array{Signal}, productions::Array{Production}, stocks_initiaux::Stocks, nbr_references::Int)
    Stocks_planning = Array{Stocks}(undef,12)
    Stocks_planning[1] = Compute_Stocks_at_T_plus_1(signaux[1], productions[1], stocks_initiaux, nbr_references)
    for i in 2:12
        Stocks_planning[i] = Compute_Stocks_at_T_plus_1(signaux[i], productions[i], Stocks_planning[i-1], nbr_references)
    end
    return Stocks_planning
end
