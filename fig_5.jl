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
            df[!, i] .= (df[!, i] .- mean(df[!, i]))  #./ std(df[!, i]) 
        end
    end
    return df    
end

vegetation_type = "crop"
xtreme = "high"

function concatenate_season(df, var_name)
    var = zeros(3,size(df)[1])

    if var_name == "lai"
        var[2, :] = df[!, var_name*"_spring"]
        var[3, :] = df[!, var_name*"_summer"]
    
    else
        var[1, :] = df[!, var_name*"_winter"]
        var[2, :] = df[!, var_name*"_spring"]
        var[3, :] = df[!, var_name*"_summer"]
    
    end

    return var
end

region  = regions[1]

df = read_ori_data(vegetation_type, xtreme, region)
df_linreg = select(df, Not([:sd_winter, :sd_spring, :sd_summer, ]))
df = filter(row -> all(!isnan, row), df)
df_linreg = filter(row -> all(!isnan, row), df_linreg)
df = standard_norm(df)
df_linreg = standard_norm(df_linreg)

t2m = concatenate_season(df_linreg,"t2m")
tp = concatenate_season(df_linreg,"tp")
sm = concatenate_season(df_linreg,"sm")
lai = concatenate_season(df_linreg,"lai")
sd = concatenate_season(df, "sd")


function plot_anomaly!(vegetation_type, xtreme, region, ax1, ax2, ax3, ax4, ax5)
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
        df_linreg = select(df, Not([:sd_winter, :sd_spring, :sd_summer]))

        df = filter(row -> all(!isnan, row), df)
        df_linreg = filter(row -> all(!isnan, row), df_linreg)
        
        df = df[df[!, "lai_summer"].==1, :]
        df_linreg = df_linreg[df_linreg[!, "lai_summer"].==1, :]
        
        # df = standard_norm(df)
        # df_linreg = standard_norm(df_linreg)

        
        t2m = concatenate_season(df_linreg,"t2m")
        tp = concatenate_season(df_linreg,"tp")
        sm = concatenate_season(df_linreg,"sm")
        lai = concatenate_season(df_linreg,"lai")
        sd = concatenate_season(df, "sd")

        boxplot!(ax1, val[1] .+ zeros(size(t2m)[2]),  t2m[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax1, val[2] .+ zeros(size(t2m)[2]),  t2m[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax1, val[3] .+ zeros(size(t2m)[2]),  t2m[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax1, 0, linestyle = "--", color = "black")
        
        boxplot!(ax2, val[1] .+ zeros(size(tp)[2]),  tp[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax2, val[2] .+ zeros(size(tp)[2]),  tp[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax2, val[3] .+ zeros(size(tp)[2]),  tp[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax2, 0, linestyle = "--", color = "black")
        
        index = sd[1,:].!=0
        boxplot!(ax3, val[1] .+ zeros(sum(index)),  sd[1,index], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax3, val[2] .+ zeros(sum(index)),  sd[2, index], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax3, val[3] .+ zeros(sum(index)),  sd[3, index], show_outliers=false, color = color, show_notch=true)
        hlines!(ax3, 0, linestyle = "--", color = "black")


        percent_loss = round((size(index)[1] - sum(index))*100/size(index)[1], digits=2)
        
        if xtreme =="low"
            text!(ax3, 20, 0.1, text = "Data Lost: $(size(index)[1] - sum(index))", align = (:center, :center))
            text!(ax3, 20, 0.08, text = "Percent Loss: $(percent_loss)", align = (:center, :center))
        end

        boxplot!(ax4, val[1] .+ zeros(size(sm)[2]),  sm[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax4, val[2] .+ zeros(size(sm)[2]),  sm[2, :], show_outliers=false, color = color, show_notch=true)
        boxplot!(ax4, val[3] .+ zeros(size(sm)[2]),  sm[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax4, 0, linestyle = "--", color = "black")

        boxplot!(ax5, val[1] .+ zeros(size(lai)[2]),  lai[1, :], show_outliers=false, color = color, show_notch=true, label=xtreme)
        boxplot!(ax5, val[2] .+ zeros(size(lai)[2]),  lai[2, :], show_outliers=false, color = color, show_notch=true)
        # boxplot!(ax5, val[3] .+ zeros(size(lai)[2]),  lai[3, :], show_outliers=false, color = color, show_notch=true)
        hlines!(ax5, 0, linestyle = "--", color = "black")
        
    end
    return ax1, ax2, ax3, ax4, ax5
end

for region in regions
    vegetation_type = "crop"
    f = Figure(resolution=(1200,800))
    ax1 = Axis(f[1,1], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Temp anomaly $(vegetation_type)_$(region)", ylabel="Temp [Celsius]", xgridvisible = false, ygridvisible = false)
    ax2 = Axis(f[1,2], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Precip anomaly $(vegetation_type)_$(region)", ylabel="Precip [mm]", xgridvisible = false, ygridvisible = false)
    ax3 = Axis(f[2,1], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Snow Depth $(vegetation_type)_$(region)", ylabel="SD [m Water eq]", xgridvisible = false, ygridvisible = false)
    ax4 = Axis(f[2,2], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "Soil moisture anomaly $(vegetation_type)_$(region)", ylabel="SM [m3/m3]", xgridvisible = false, ygridvisible = false)
    ax5 = Axis(f[3,1], xticks= (11:10:31, ["winter", "spring", "summer"]), title= "LAI anomaly $(vegetation_type)_$(region)", ylabel="LAI [m2/m2]", xgridvisible = false, ygridvisible = false)

    ax1, ax2, ax3, ax4, ax5 = plot_anomaly!(vegetation_type, "low", region, ax1, ax2, ax3, ax4, ax5)
    ax1, ax2, ax3, ax4, ax5 = plot_anomaly!(vegetation_type, "high", region, ax1, ax2, ax3, ax4, ax5)
    
    try 
        axislegend(ax1)
        axislegend(ax2)
        axislegend(ax3)
        axislegend(ax4)
        axislegend(ax5)

    catch e 
        print("Exception: ", e)
    end
    save("/Users/anand/Documents/data/pcv/images/anomaly_dynamics/$(vegetation_type)_$(region)_v5.pdf", f)
end