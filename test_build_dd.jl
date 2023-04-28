# include 
include("Include.jl")

# initialize -
distribution_dict_control = Dict{String,Normal}()

# load the measurements file -
path_to_measurements_file = joinpath(_PATH_TO_DATA, "FluxData-24-48-hr.csv")
df = measurements(path_to_measurements_file)

# build the distributions for CTRL -
number_of_metabolites = nrow(df);
for i ∈ 1:number_of_metabolites
    
    # get data 
    flux_id = df[i,:FLUX];
    μ = abs(df[i,:AVG_CTRL]);
    σ = df[i,:SD_CTRL];
    
    # build and store the distributions -
    distribution_dict_control[flux_id] = Normal(μ,σ);
end
