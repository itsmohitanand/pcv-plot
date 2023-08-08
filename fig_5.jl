using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using ColorSchemes
using GLM
using Random
using EvalMetrics
using StatsBase

include("core.jl")

p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology

xtreme = "high"
vegetation_type = "crop"

regions = ipcc_region()

for region in regions
    print(region)
    df = read_ori_data(vegetation_type, xtreme, region)
    if !ismissing(df)
        df = df[df[!, "lai_su"].==1, :]

        t2m = zeros(3,size(df)[1])
        tp = zeros(3,size(df)[1])

        t2m[1, :] = df[!, "t2m_winter"]
        t2m[2, :] = df[!, "t2m_spring"]
        t2m[3, :] = df[!, "t2m_summer"]

        tp[1, :] = df[!, "tp_winter"]
        tp[2, :] = df[!, "tp_spring"]
        tp[3, :] = df[!, "tp_summer"]

        f = Figure(resolution=(1200,600))
        ax1 = Axis(f[1,1], xticks= (1:1:3, ["winter", "spring", "summer"]), title= "Temp anomaly $(xtreme)_$(vegetation_type)_$(region)", ylabel="Temp [Celsius]")
        ax2 = Axis(f[1,2], xticks= (1:1:3, ["winter", "spring", "summer"]), title= "Precip anomaly $(xtreme)_$(vegetation_type)_$(region)", ylabel="Precip")


        for i=1:size(t2m)[2]
            lines!(ax1, t2m[:,i], color = (palette["pale_grey"], 0.1))
        end

        for i=1:size(tp)[2]
            lines!(ax2, tp[:,i], color = (palette["pale_grey"], 0.1))
        end

        lines!(ax1, mean(t2m, dims=2)[:,1], color = (palette["light_blue"]))
        lines!(ax2, mean(tp, dims=2)[:,1], color = (palette["light_blue"]))

        save("images/scratch/$(xtreme)_$(vegetation_type)_$(region)_v1.png", f)

    end
end