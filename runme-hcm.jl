# include 
include("Include.jl")

# initialize -
distribution_dict = Dict{String,Normal}()

# load the measurements file -
path_to_measurements_file = joinpath(_PATH_TO_DATA, "FluxData-0-48-hr-v3-HCM.csv")
df = measurements(path_to_measurements_file)

# build the distributions for CTRL -
number_of_metabolites = nrow(df);
for i ∈ 1:number_of_metabolites
    
    # get data 
    flux_id = df[i,:FLUX];
    μ = df[i,:AVG_HCM];
    σ = df[i,:SD_HCM];
    
    # build and store the distributions -
    distribution_dict[flux_id] = Normal(μ,σ);
end

# setup path to model file -
path_to_model_file = joinpath(_PATH_TO_MODEL, "CoreCancerModel_v1.mat");
model = build(MyCoreCancerModel,path_to_model_file);

# sample -
# obj = ["growth"];
# obj = ["EX_ha(e)"];
obj = ["EX_ha(e)"]
flux_array = sample(model,distribution_dict,obj; N = 1000, constrained = nothing);

# build output -
df_output = output(model,flux_array)

# write -
CSV.write(joinpath(_PATH_TO_SIMS, "HCM-fluxes-0-48-HA-v4.csv"), df_output)