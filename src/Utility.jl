function find_index_of_species(list_of_species, species_symbol)
    return findfirst(x->x=="$(species_symbol)", list_of_species)
end

function find_index_of_reaction(list_of_reactions, reaction_symbol)
    return findfirst(x->x=="$(reaction_symbol)", list_of_reactions)
end

function calculate_default_vmax(biophysical_dictionary::Dict{String,Any})

    # ok, so we need to get some stuff from the dictionary -
    # TODO: Check these keys are contained in the dictionary
    default_turnover_number = parse(Float64,biophysical_dictionary["biophysical_constants"]["default_turnover_number"]["value"])              # convert to h^-1
    default_enzyme_concentration = parse(Float64,biophysical_dictionary["biophysical_constants"]["default_enzyme_concentation"]["value"])     # mumol/gDW

    # calculate the default VMax -
    default_vmax = (default_turnover_number)*(default_enzyme_concentration)*(3600)

    return (default_vmax, default_enzyme_concentration)
end

