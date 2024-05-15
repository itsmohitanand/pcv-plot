using CairoMakie
using Statistics
using ColorSchemes
using EvalMetrics
using StatsBase

include("core.jl")
p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology



regions = ipcc_regions()

function vegetation_cor(region, xtreme)
    df = read_ori_data("crop", xtreme, region)
    if !ismissing(df)
        year = df[df[!, "lai_su"] .== 1, "# year"]
        crop_freq = fit(Histogram, year, 1982:2021).weights

        df = read_ori_data("forest", xtreme, region)
        if !ismissing(df)
            year = df[df[!, "lai_su"] .== 1, "# year"]
            forest_freq = fit(Histogram, year, 1982:2021).weights
            print(size(crop_freq), size(forest_freq))
            return Statistics.cor(crop_freq, forest_freq)
        end
    end
    return missing
end


for region in regions
    println(region)
    println(round(vegetation_cor(region, "high"), digits = 2))
    println(round(vegetation_cor(region, "low"), digits = 2))    
end

data = Dict(
    "C.North-America" => Dict("high" => 0.51, "low" => 0.29),
    "E.Asia" => Dict("high" => 0.65, "low" => 0.79),
    # "E.C.Asia" => Dict("high" => 0.42, "low" => 0.63),
    "E.Europe" => Dict("high" => 0.47, "low" => 0.32),
    "E.North-America" => Dict("high" => 0.41, "low" => 0.26),
    "E.Siberia" => Dict("high" => 0.56, "low" => 0.69),
    "Mediterranean" => Dict("high" => 0.84, "low" => 0.94),
    "N.Central-America" => Dict("high" => 0.72, "low" => 0.47),
    "N.E.North-America" => Dict("high" => 0.44, "low" => 0.15),
    "N.Europe" => Dict("high" => 0.44, "low" => 0.25),
    "N.W.North-Americ" => Dict("high" => 0.39, "low" => 0.24),
    "Russian-Arctic" => Dict("high" => "missing", "low" => "missing"),
    "Russian-Far-East" => Dict("high" => 0.58, "low" => 0.62),
    "S.Asia" => Dict("high" => 0.45, "low" => 0.44),
    "Tibetan-Plateau" => Dict("high" => 0.45, "low" => 0.71),
    "W.C.Asia" => Dict("high" => 0.47, "low" => 0.79),
    "W.North-America" => Dict("high" => 0.37, "low" => 0.29),
    "W.Siberia" => Dict("high" => 0.57, "low" => 0.6),
    "West&Central-Europe" => Dict("high" => 0.61, "low" => 0.78)
)