using CairoMakie
using Colors
using ColorSchemes
using CSV
using DataFrames
using Statistics
using StatsBase
using GLM


function pred_atttention(year, attn)
    data = DataFrame(y = Float64.(attn), x = year);
    linreg = lm(@formula(y ~ x), data)
    data = DataFrame(x = [1983:2020;])
    return predict(linreg, data)
    
end

file_list = readdir("/Users/anand/Documents/data/pcv/attention")

## Viridis Color



palette = ColorSchemes.viridis.colors

include("core.jl")

oni_data = Matrix(CSV.read("/Users/anand/Documents/data/pcv/oni.csv", DataFrame, delim = "\t"))
year_oni = oni_data[:, 1]
oni = mean(oni_data[:, 2:end], dims=2)[:,1]

for fname in file_list
    print(fname*"\n")
    a_others, year, y_true, data, ei_others = read_data("/Users/anand/Documents/data/pcv/attention/"*fname)

    a_t2m_sm = a_others[1, :]
    a_tp_sm = a_others[2,:]
    t2m = data[1,:]
    tp = data[2,:]
    sm = data[3,:]

    ## Start plot

    n = [35, 36, 37, 38, 37, 36, 35]
    ci = 2 ./ sqrt.(n)

    f = Figure(resolution=(1400,1000))
    ax11 = Axis(f[1,1], xlabel = "Temperature Anomalies", ylabel = "Precipitation Anomalies", xgridvisible = false, ygridvisible = false)
    ax12 = Axis(f[1,2], xlabel = "Temperature Anomalies", ylabel = "Soil Moisture Anomalies", xgridvisible = false, ygridvisible = false)
    ax13 = Axis(f[1,3], xlabel = "Soil Moisture Anomalies", ylabel = "Precipitation Anomalies", xgridvisible = false, ygridvisible = false)

    ax21 = Axis(f[2,1], xlabel = "Temperature Anomalies", ylabel = "Precipitation Anomalies", xgridvisible = false, ygridvisible = false)
    ax22 = Axis(f[2,2], xlabel = "Temperature Anomalies", ylabel = "Soil Moisture Anomalies", xgridvisible = false, ygridvisible = false)
    ax23 = Axis(f[2,3], xlabel = "Soil Moisture Anomalies", ylabel = "Precipitation Anomalies", xgridvisible = false, ygridvisible = false)

    hidespines!(ax11, :r, :t)
    hidespines!(ax12, :r, :t)
    hidespines!(ax13, :r, :t)

    hidespines!(ax21, :r, :t)
    hidespines!(ax22, :r, :t)
    hidespines!(ax23, :r, :t)

    joint_limits = (0, maximum([maximum(a_t2m_sm), maximum(a_tp_sm)]))

    ms = 2
    sc11 = scatter!(ax11, t2m, tp, markersize = ms, color = a_t2m_sm, colorrange = joint_limits)
    sc12 = scatter!(ax12, t2m, sm, markersize = ms, color = a_t2m_sm, colorrange = joint_limits)
    sc13 = scatter!(ax13, sm, tp, markersize = ms, color = a_t2m_sm, colorrange = joint_limits)
    Colorbar(f[1,4], sc11, label="Attention | t2m > sm")
    sc21 = scatter!(ax21, t2m, tp, markersize = ms, color = a_tp_sm, colorrange = joint_limits)
    sc22 = scatter!(ax22, t2m, sm, markersize = ms, color = a_tp_sm, colorrange = joint_limits)
    sc23 = scatter!(ax23, sm, tp, markersize = ms, color = a_tp_sm, colorrange = joint_limits)
    Colorbar(f[2,4], sc11, label="Attention | tp > sm")
    f
    year_min = minimum(year)
    year_max = maximum(year)

    lags=[-3:3;]


    ax31= Axis(f[3,1:2], xgridvisible = false, ygridvisible = false, xlabel = "Attention | t2m > sm")

    yearly_attn_t2m_sm = []
    for i=year_min:year_max
        index = i .== year 
        year_attn = a_t2m_sm[index]
        
        x = ones(Int8, size(year_attn)) .+ i
        boxplot!(ax31, x, year_attn, color = palette[end-15], show_outliers = false )

        append!(yearly_attn_t2m_sm, mean(year_attn))
    end
    a_t2m_pred = pred_atttention(year, a_t2m_sm)
    lines!(ax31, [1983:2020;], a_t2m_pred , color = "red", linestyle="--", label = "trend")
    axislegend(ax31)

    ax31x = Axis(f[3, 1:2], yaxisposition = :right, xgridvisible = false, ygridvisible = false, ylabel = "ONI-3.4")
    index = year_max .>= year_oni .>= year_min

    lines!(ax31x, year_oni[index], oni[index] , color = palette[20])
    hidespines!(ax31, :r, :t)
    hidespines!(ax31x, :l, :t)
    xlims!(ax31, (year_min , year_max))
    xlims!(ax31x, (year_min , year_max))

    
    f

    r = crosscor(Float64.(yearly_attn_t2m_sm), oni[index], lags; demean=true)
    ax32 = Axis(f[3,3:4], xlabel = "Correlation | t2m > sm", xgridvisible = false, ygridvisible = false)
    stem!(ax32, lags, r )
    lines!(ax32, lags, ci, color = "red", linestyle = "--")
    lines!(ax32, lags, -ci, color = "red", linestyle = "--")
    xlims!(ax32, (-3.2, 3.2))
    ylims!(ax32, (-0.6, 0.6))
    f

    ax41= Axis(f[4,1:2], xgridvisible = false, ygridvisible = false, xlabel = "Attention | tp > sm")

    yearly_attn_tp_sm = []
    for i=year_min:year_max
        index = i .== year 
        year_attn = a_tp_sm[index]
        
        x = ones(Int8, size(year_attn)) .+ i
        boxplot!(ax41, x, year_attn, color = palette[end-15], show_outliers = false )
        append!(yearly_attn_tp_sm, mean(year_attn))
    end
    a_tp_pred = pred_atttention(year, a_tp_sm)
    lines!(ax41, [1983:2020;], a_tp_pred , color = "red", linestyle="--", label = "trend")
    axislegend(ax41)
    f

    ax41x = Axis(f[4, 1:2], yaxisposition = :right, xgridvisible = false, ygridvisible = false, ylabel = "ONI-3.4")
    index = year_max .>= year_oni .>= year_min
    year_oni[index]

    lines!(ax41x, year_oni[index], oni[index] , color = palette[20])
    hidespines!(ax41, :r, :t)
    hidespines!(ax41x, :l, :t)

    xlims!(ax41, (year_min , year_max))
    xlims!(ax41x, (year_min , year_max))

    r = crosscor(Float64.(yearly_attn_tp_sm), oni[index], lags; demean=true)
    ax42 = Axis(f[4,3:4], xlabel = "Correlation | tp > sm", xgridvisible = false, ygridvisible = false)
    stem!(ax42, lags, r)
    lines!(ax42, lags, ci, color = "red", linestyle = "--")
    lines!(ax42, lags, -ci, color = "red", linestyle = "--")
    xlims!(ax42, (-3.2, 3.2))
    ylims!(ax42, (-0.6, 0.6))
    save_path = collect(eachsplit(fname, "/"))[end][1:end-10]
    save("/Users/anand/Documents/data/pcv/images/"*save_path*".png", f)
end

f
