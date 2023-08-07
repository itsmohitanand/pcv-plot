using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using ColorSchemes
using GLM
using Random
using EvalMetrics

include("core.jl")
p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology

list_region = [k for (k,v) in sort(index_significant)]

regions = ipcc_region()

sort(index_significant)

region = list_region[1]

function vegetation_cor(region, xtreme)
    df = read_ori_data("crop", xtreme, region)
    year = df[df[!, "lai_su"] .== 1, "# year"]
    crop_freq = fit(Histogram, year, 1982:2021).weights

    df = read_ori_data("forest", xtreme, region)
    year = df[df[!, "lai_su"] .== 1, "# year"]
    forest_freq = fit(Histogram, year, 1982:2021).weights
    return Statistics.cor(crop_freq, forest_freq)
end


for region in [list_region[10]]
    print(region)
    print(round(vegetation_cor(region, "high"), digits = 2))    
end

