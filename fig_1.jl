using CairoMakie
using Colors
using ColorSchemes
using CSV
using DataFrames
using Statistics
using StatsBase


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

    sc11 = scatter!(ax11, t2m, tp, markersize = 4, color = a_t2m_sm, colorrange = joint_limits)
    sc12 = scatter!(ax12, t2m, sm, markersize = 4, color = a_t2m_sm, colorrange = joint_limits)
    sc13 = scatter!(ax13, sm, tp, markersize = 4, color = a_t2m_sm, colorrange = joint_limits)
    Colorbar(f[1,4], sc11)
    sc21 = scatter!(ax21, t2m, tp, markersize = 4, color = a_tp_sm, colorrange = joint_limits)
    sc22 = scatter!(ax22, t2m, sm, markersize = 4, color = a_tp_sm, colorrange = joint_limits)
    sc23 = scatter!(ax23, sm, tp, markersize = 4, color = a_tp_sm, colorrange = joint_limits)
    Colorbar(f[2,4], sc11)
    f
    year_min = minimum(year)
    year_max = maximum(year)

    lags=[-5:5;]


    ax31= Axis(f[3,1:2], xgridvisible = false, ygridvisible = false, xlabel = "Attention | t2m > sm")

    yearly_attn_t2m_sm = []
    for i=year_min:year_max
        index = i .== year 
        year_attn = a_t2m_sm[index]
        
        x = ones(Int8, size(year_attn)) .+ i
        boxplot!(ax31, x, year_attn, color = palette[end-15], show_outliers = false )

        append!(yearly_attn_t2m_sm, mean(year_attn))
    end

    ax31x = Axis(f[3, 1:2], yaxisposition = :right, xgridvisible = false, ygridvisible = false)
    index = year_max .>= year_oni .>= year_min

    lines!(ax31x, year_oni[index], oni[index])
    hidespines!(ax31, :r, :t)
    hidespines!(ax31x, :l, :t)
    xlims!(ax31, (year_min , year_max))
    xlims!(ax31x, (year_min , year_max))



    r = crosscor(Float64.(yearly_attn_t2m_sm), oni[index], lags; demean=true)
    ax32 = Axis(f[3,3:4], xlabel = "Correlation | t2m > sm", xgridvisible = false, ygridvisible = false)
    stem!(ax32, lags, r )
    ylims!(ax32, (-0.5, 0.5))
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
    f

    ax41x = Axis(f[4, 1:2], yaxisposition = :right, xgridvisible = false, ygridvisible = false)
    index = year_max .>= year_oni .>= year_min
    year_oni[index]

    lines!(ax41x, year_oni[index], oni[index])
    hidespines!(ax41, :r, :t)
    hidespines!(ax41x, :l, :t)

    xlims!(ax41, (year_min , year_max))
    xlims!(ax41x, (year_min , year_max))


    r = crosscor(Float64.(yearly_attn_tp_sm), oni[index], lags; demean=true)
    ax42 = Axis(f[4,3:4], xlabel = "Correlation | tp > sm", xgridvisible = false, ygridvisible = false)
    stem!(ax42, lags, r)
    ylims!(ax42, (-0.5, 0.5))

    save_path = collect(eachsplit(fname, "/"))[end][1:end-10]
    save("/Users/anand/Documents/data/pcv/images/"*save_path*".pdf", f)
end
