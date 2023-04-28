function _model(path::String; modelname::String="CoreCancerModel_v1")

    # load -
    file = matopen(path)
    cobra_dictionary = read(file, modelname)
    close(file);

    # return -
    return cobra_dictionary;
end

function _load_biomass_components_dict(path::String)::Dict{String,Float64}
    
    # initialize -
    compounds = Dict{String, Float64}()

    # use example pattern from: https://varnerlab.github.io/CHEME-1800-Computing-Book/unit-1-basics/data-file-io.html#program-read-a-csv-file-refactored
    open(path, "r") do io # open a stream to the file
        for line in eachline(io) # read each line from the stream
            

            # TODO: Implement the logid to process the records in the Test.data file
            # line is a line from the file  

            # A couple of things to think about: 
            # a) ignore the comments, check out the contains function: https://docs.julialang.org/en/v1/base/strings/#Base.contains
            # b) ignore the header data
            # c) records are comma delimited. Check out the split functions: https://docs.julialang.org/en/v1/base/strings/#Base.split
            # d) from the data in each reacord, we need to build a MyChemicalCompoundModel object. Each compound object should be stored in the compound dict with the name as the key
            if (contains(line,"#") == false)

                fields = split(line, ','); # splits around the ','

                # grab the fields -
                name = string(fields[1]);
                stcoeff = parse(Float64,string(fields[2]));

                # store -
                compounds[name] = stcoeff;
            end
        end
    end

    # return -
    return compounds;
end

# == PUBLIC METHODS BELOW HERE ================================================================ #
function measurements(path::String)::DataFrame
    return CSV.read(path, DataFrame);
end

function output(model::MyCoreCancerModel, flux_array::Array{Float64,2})

    # initialize -
    list_of_reactions = model.list_of_reactions
    number_of_reactions = length(list_of_reactions);
    df = DataFrame(reaction=String[],mean=Float64[],std=Float64[]);

    for i ∈ 1:number_of_reactions
        
        # get the reaction id -
        reaction_id = list_of_reactions[i];
        μ = mean(flux_array[i,:])
        σ = std(flux_array[i,:]);
        
        results_tuple = (
            reaction = reaction_id,
            mean = μ,
            std = σ
        );
        push!(df, results_tuple);
    end

    return df
end
# == PUBLIC METHODS ABOVE HERE ================================================================ #