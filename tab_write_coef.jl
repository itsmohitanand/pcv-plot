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

vegetation_type = "forest"
xtreme = "high"

log_reg = read_log_df(vegetation_type, xtreme)
for (i, regions) in enumerate(region_list)
    col_name = "$(vegetation_type)_$(xtreme)_" * regions *"_v3"
    if col_name in names(log_reg)
        if (log_reg[!, col_name][3]>100*38)
            print(col_name*"\n")
            # print(string(round.(exp.(log_reg[!, col_name][4:end]), digits=3))*"\n")
            print(string(abs.(100 .-round.(exp.(log_reg[!, col_name][4:end])[1:2]*100, digits=3)))*"\n")

        end
    end
end

# Crop High
[28.108000000000004, 24.497]
[39.286, 31.784999999999997]
[58.40700000000001, 25.986000000000004]
[27.093999999999994, 5.257000000000005]
[43.05, 24.647999999999996]

# Crop Low
[44.196, 10.959999999999994]
[9.855999999999995, 43.391]
[36.935, 27.53]
[7.572999999999993, 46.206]
[23.662000000000006, 28.608999999999995]

# Forest High
[13.997, 26.870999999999995]
[16.054000000000002, 11.040999999999997]
[29.305000000000007, 8.653999999999996]
[21.046000000000006, 31.127999999999986]
[13.087999999999994, 38.542]

# Forest Low
