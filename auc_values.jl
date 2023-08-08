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

# list_region = [k for (k,v) in sort(index_significant)]

regions = ipcc_region()

vegetation_type = "forest"
xtreme = "low"

println(vegetation_type)
println(xtreme)
for region in regions
    df, df_w = read_logreg_df(vegetation_type, xtreme, region)

    if !ismissing(df)
        println(region)
        println(round(mean(df[!,"AUC"]), digits=2))
        println(round(mean(df_w[!,"AUC"]), digits=2))

    end
end