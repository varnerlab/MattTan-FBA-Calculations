"""
    flux(model::MyCoreCancerModel, data::NamedTuple) -> Dict{String,Float64}
"""
function flux(model::MyCoreCancerModel, data::NamedTuple)::Tuple{Bool, Dict{String, Float64}}

    # initialize -
    S = model.S;
    B = model.bounds;
    list_of_reactions = model.list_of_reactions;
    (number_of_metabolites, number_of_reactions) = size(S)
    c = zeros(number_of_reactions);     # default c vector 
    b = zeros(number_of_metabolites);   # default b vector
    fluxes = Dict{String,Float64}()     # dictionary stores tge flux, keys are the ids

    # Step 1: update the objective vector 
    objective_rate_ids = data[:objective]
    for id ∈ objective_rate_ids
        
        # find the index of this rate -
        rate_index_array = find_index_of_reaction(list_of_reactions, id);
        for index ∈ rate_index_array
            c[index] = 1.0;
        end
    end

    # Step 2: update the bounds (these are being sampled)
    bounds_dictionary = data[:measurements]
    for (key, value) ∈ bounds_dictionary

        # find index of the key -
        reaction_index = find_index_of_reaction(list_of_reactions, key);
        if (isnothing(reaction_index) == false)
            
            # bounds samples are stored in a tuple
            B[reaction_index,1] = value[1];
            B[reaction_index,2] = value[2];
        end
    end

    # update bounds manually -
    manual_bounds_dictionary = data[:manual]
    if (isnothing(manual_bounds_dictionary) == false)
        for (key,value) ∈ manual_bounds_dictionary
            reaction_index = find_index_of_reaction(list_of_reactions, key);
            B[reaction_index,1] = value[1]
            B[reaction_index,2] = value[2]
        end
    end

    # Step 3: Solve the model and report the flux
    # BELOW HERE IS JuMP CONFIGURATION. DO NOT EDIT Dave! =================================================== %
    # Build JuMP model 
   lpmodel = Model(GLPK.Optimizer)

    # add decision variables to the model -
    @variable(lpmodel, B[i,1] <= v[i=1:number_of_reactions] <= B[i,2]) # this sets up the upper bound

    # Set the objective => maximize the profit -
    @objective(lpmodel, Max, transpose(c)*v);

    # Setup the capacity constraints - add them to the model 
    @constraints(lpmodel, 
        begin
            S*v .== b
        end
    );

    # add a crowding constraint -
    crowding_constraint = 0.0054;
    @constraints(lpmodel, 
        begin
            sum(v) <= (1/crowding_constraint)
        end
    );
   
    optimize!(lpmodel)
    optimal_flag = (termination_status(lpmodel) == MathOptInterface.OPTIMAL);

    # build the flux dictionary -
    list_reaction_id = model.list_of_reactions;
    for i ∈ 1:number_of_reactions
        id = list_reaction_id[i]
        fluxes[id] = value(v[i])
    end

    # return -
    return (optimal_flag,fluxes)
    # ABOVE HERE IS JuMP CONFIGURATION. DO NOT EDIT Dave! =================================================== %
end

"""
    sample(model::MyCoreCancerModel, measurements::Dict{String,Normal}, objective::Array{String,1}; 
        N::Int64 = 100) -> Array{Float64,2}
"""
function sample(model::MyCoreCancerModel, measurements::Dict{String,Normal}, objective::Array{String,1}; 
    N::Int64 = 100, constrained::Union{Nothing,Dict{String,Tuple}} = nothing)::Array{Float64,2}

    # initialize -
    list_of_reactions = model.list_of_reactions;
    number_of_reactions = length(list_of_reactions);
    flux_array = Array{Float64, 2}(undef, number_of_reactions, N);

    # compute a sample -
    local_counter = 1;
    should_loop = true
    while (should_loop == true)
        
        # initialize -
        sample_dictionary = Dict{String,Vector{Float64}}();
        for (key,d) ∈ measurements
            
            # draw 10 samples -
            tmp = rand(d);
            values = sort([0.9*tmp,1.1*tmp]);
            sample_dictionary[key] = values;
        end

        # compute the flux -
        (flag, flux_dictionary) = flux(model, (
            objective = objective,
            measurements = sample_dictionary,
            manual = constrained
        ));
    
        if (flag == true)
            
            # ok, iterate through the flux dictionary, and package in the array -
            for (key, value) ∈ flux_dictionary
                reaction_index = find_index_of_reaction(list_of_reactions, key);
                flux_array[reaction_index,local_counter] = value;
            end

            if (local_counter == N)
                should_loop = false
            end

            # update the local counter -
            local_counter += 1;
        end
    end

    # return -
    return flux_array;
end