using CairoMakie
using Statistics
using ColorSchemes
using EvalMetrics
using StatsBase

include("core.jl")
p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology



regions = ipcc_region()

function vegetation_cor(region, xtreme)
    df = read_ori_data("crop", xtreme, region)
    if !ismissing(df)
        year = df[df[!, "lai_su"] .== 1, "# year"]
        crop_freq = fit(Histogram, year, 1982:2021).weights

        df = read_ori_data("forest", xtreme, region)
        if !ismissing(df)
            year = df[df[!, "lai_su"] .== 1, "# year"]
            forest_freq = fit(Histogram, year, 1982:2021).weights
            return Statistics.cor(crop_freq, forest_freq)
        end
    end
    return missing
end


for region in regions
    println(region)
    println(round(vegetation_cor(region, "high"), digits = 2))    
end

