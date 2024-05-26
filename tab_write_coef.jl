using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using ColorSchemes

palette = ColorSchemes.colorschemes[:mk_12]

include("core.jl")

path = "/Users/anand/Documents/data/pcv/IPCC-WGI-reference-regions-v4_shapefile/IPCC-WGI-reference-regions-v4.shp"

region_list = ipcc_regions()

ipcc_acronym

palette

vegetation_type = "crop"
xtreme = "high"

log_reg = read_log_df(vegetation_type, xtreme)
for (i, regions) in enumerate(region_list)
    col_name = "$(vegetation_type)_$(xtreme)_" * regions *"_v3"
    if col_name in names(log_reg)
        if (log_reg[!, col_name][3]>100*38)
            print(col_name*"\n")
            print(string(round.(exp.(log_reg[!, col_name][4:end]), digits=3))*"\n")
        end
    end
end