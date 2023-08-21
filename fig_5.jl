using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using Random
using EvalMetrics
using StatsBase

include("core.jl")

palette

p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology

regions = ipcc_region()

function standard_norm(df)
    for i in names(df)
        if (i != "# year") && (i!="lai_su")
            df[!, i] .= (df[!, i] .- mean(df[!, i])) ./ std(df[!, i]) 
        end
    end
    return df    
end

function plot_anomaly!(vegetation_type, xtreme, region, ax1, ax2, ax3, ax4)
    df = read_ori_data(vegetation_type, xtreme, region)
    
    if xtreme == "high"
        val = [10,20,30]
        color = palette["light_yellow"]
    elseif xtreme == "low"
        val = [12,22,32]
        color = palette["pink"]
    end


    # if vegetation_type == "crop"
    #     val = [10,20,30]
    #     color = palette["orange"]
    # elseif vegetation_type == "forest"
    #     val = [12,22,32]
    #     color = palette["mint"]
    # end

    if !ismissing(df)
        n_init = size(df)[1]
        df = filter(row -> all(!isnan, row), df)
        n_final = size(df)[1]

        df = standard_norm(df)

        δ = (n_init-n_final)*100/n_init
        println(size(df)[1])
        println(round(δ, digits = 2))
    
        df = df[df[!, "lai_su"].==1, :]
        t2m = zeros(3,size(df)[1])
        tp = zeros(3,size(df)[1])
        sm = zeros(3,size(df)[1])
        lai = zeros(3,size(df)[1])
        
        t2m[1, :] = df[!, "t2m_winter"]
        t2m[2, :] = df[!, "t2m_spring"]
        t2m[3, :] = df[!, "t2m_summer"]

        tp[1, :] = df[!, "tp_winter"]
        tp[2, :] = df[!, "tp_spring"]
        tp[3, :] = df[!, "tp_summer"]

        sm[1, :] = df[!, "sm_winter"]
        sm[2, :] = df[!, "sm_spring"]
        sm[3, :] = df[!, "sm_summer"]

        lai[2, :] = df[!, "lai_spring"]
        lai[3, :] = df[!, "lai_su"]


        boxplot!(ax1, val[1] .+ zeros(size(t2m)[2]),  t2m[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax1, val[2] .+ zeros(size(t2m)[2]),  t2m[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax1, val[3] .+ zeros(size(t2m)[2]),  t2m[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax1, 0, linestyle = "--", color = "black")
        
        boxplot!(ax2, val[1] .+ zeros(size(tp)[2]),  tp[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax2, val[2] .+ zeros(size(tp)[2]),  tp[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax2, val[3] .+ zeros(size(tp)[2]),  tp[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax2, 0, linestyle = "--", color = "black")

        boxplot!(ax3, val[1] .+ zeros(size(sm)[2]),  sm[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax3, val[2] .+ zeros(size(sm)[2]),  sm[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax3, val[3] .+ zeros(size(sm)[2]),  sm[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax3, 0, linestyle = "--", color = "black")


        boxplot!(ax4, val[1] .+ zeros(size(lai)[2]),  lai[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax4, val[2] .+ zeros(size(lai)[2]),  lai[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax4, val[3] .+ zeros(size(lai)[2]),  lai[3, :], show_outliers=false, color = color, show_notch=true)
        
        hlines!(ax4, 0, linestyle = "--", color = "black")
        
    end
    return ax1, ax2, ax3, ax4
end

for region in regions
    vegetation_type = "crop"
    f = Figure(resolution=(1200,800))
    ax1 = Axis(f[1,1], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Temp anomaly $(vegetation_type)_$(region)", ylabel="Temp [Celsius]", xgridvisible = false, ygridvisible = false)
    ax2 = Axis(f[1,2], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Precip anomaly $(vegetation_type)_$(region)", ylabel="Precip", xgridvisible = false, ygridvisible = false)
    ax3 = Axis(f[2,1], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Soil moisture anomaly $(vegetation_type)_$(region)", ylabel="SM", xgridvisible = false, ygridvisible = false)
    ax4 = Axis(f[2,2], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "LAI anomaly $(vegetation_type)_$(region)", ylabel="LAI", xgridvisible = false, ygridvisible = false)

    ax1, ax2, ax3, ax4 = plot_anomaly!(vegetation_type, "low", region, ax1, ax2, ax3, ax4)
    ax1, ax2, ax3, ax4 = plot_anomaly!(vegetation_type, "high", region, ax1, ax2, ax3, ax4)
    
    try 
        axislegend(ax1)
        axislegend(ax2)
        axislegend(ax3)
        axislegend(ax4)
    catch e 
        print("Exception: ", e)
    end
    save("/Users/anand/Documents/data/pcv/images/anomaly_dynamics/$(vegetation_type)_$(region)_v4.pdf", f)
end