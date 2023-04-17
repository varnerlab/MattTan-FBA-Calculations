# setup parent types -
abstract type AbstractModel end


mutable struct MyCoreCancerModel <: AbstractModel

    # data -
    S::Array{Float64,2}
    bounds::Array{Float64,2}
    list_of_reactions::Array{String,1}
    list_of_metabolites::Array{String,1}

    # constructor -
    MyCoreCancerModel() = new();
end
