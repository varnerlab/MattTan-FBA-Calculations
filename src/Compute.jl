"""
    flux(model::MyCoreCancerModel, data::NamedTuple) -> Dict{String,Float64}
"""
function flux(model::MyCoreCancerModel, data::NamedTuple)::Dict{String,Float64}

    # initialize -
    S = problem.S;
    B = problem.bounds;
    list_of_reactions = model.list_of_reactions;
    (number_of_metabolites, number_of_reactions) = size(S)
    c = zeros(number_of_reactions);     # default c vector 
    b = zeros(number_of_metabolites);   # default b vector
    fluxes = Dict{String,Float64}()     # dictionary stores tge flux, keys are the ids

    # Step 1: update the objective vector 
    objective_rate_ids = data[:objective]
    for id ∈ objective_rate_ids
        
        # find the index of this rate -
        rate_index_array = find_index_of_reactions(list_of_reactions, id);
        for index ∈ rate_index_array
            c[index] = 1.0;
        end
    end

    # Step 2: update the bounds (these are being sampled)
    bounds_dictionary = data[:measurements]
    for (key, value) ∈ bounds_dictionary
        
        # bounds samples are stored in a tuple
        lb = value[1];
        ub = value[2];

        # find index of the key -
        reaction_index = find_index_of_reactions(list_of_reactions, key);
        B[reaction_index,1] = lb;
        B[reaction_index,2] = ub;
    end

    # Step 3: Solve the model and report the flux
    # BELOW HERE IS JuMP CONFIGURATION. DO NOT EDIT Dave! =================================================== %
    # Build JuMP model 
    model = Model(GLPK.Optimizer)

    # add decision variables to the model -
    @variable(model, B[i,1] <= v[i=1:number_of_reactions] <= B[i,2]) # this sets up the upper bound

    # Set the objective => maximize the profit -
    @objective(model, Max, transpose(c)*v);

    # Setup the capacity constraints - add them to the model 
    @constraints(model, 
        begin
            S*v .== b
        end
    );
   
    optimize!(model)
    solution_summary(model)

    # build the flux dictionary -
    list_reaction_id = problem.reactions;
    for i ∈ 1:number_of_reactions
        id = list_reaction_id[i]
        fluxes[id] = value(v[i])
    end

    # return -
    return fluxes
    # ABOVE HERE IS JuMP CONFIGURATION. DO NOT EDIT Dave! =================================================== %
end

"""
    sample(model::MyCoreCancerModel, measurements::Dict{String,Normal}, objective::Array{String,1}; 
        N::Int64 = 100) -> Array{Float64,2}
"""
function sample(model::MyCoreCancerModel, measurements::Dict{String,Normal}, objective::Array{String,1}; 
    N::Int64 = 100)::Array{Float64,2}

    # initialize -
    list_of_reactions = model.list_of_reactions;
    number_of_reactions = length(list_of_reactions);
    flux_array = Array{Float64, 2}(undef, number_of_reactions, N);

    # compute a sample -
    for i ∈ 1:N
        
        # initialize -
        sample_dictionary = Dict{String,Tuple}();
        for (key,d) ∈ measurements
            
            # draw 10 samples -
            tmp = rand(d,10);
            values = (minimum(tmp),maximum(tmp));
            sample_dictionary[key] = values;
        end

        # compute the flux -
        flux_dictionary = flux(model,(
            objective = objective,
            measurements = sample_dictionary
        ));
    
        # ok, iterate through the flux dictionary, and package in the array -
        for (key, value) ∈ flux_dictionary
            reaction_index = find_index_of_reactions(list_of_reactions, key);
            flux_array[reaction_index,i] = value;
        end
    end

    # return -
    return flux_array;
end