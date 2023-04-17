function find_index_of_species(list_of_species, species_symbol)
    return findfirst(x->x=="$(species_symbol)", list_of_species)
end