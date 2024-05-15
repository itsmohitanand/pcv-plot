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
using GLM
using MannKendall_XY


include("core.jl")

p_list = [val for (k, val) in palette if k!="pale_grey"]

# Simple schematic showing the methodology

regions = ipcc_regions()

corr_data = Dict(
    "C.North-America" => Dict("high" => 0.51, "low" => 0.29),
    "E.Asia" => Dict("high" => 0.65, "low" => 0.79),
    "E.C.Asia" => Dict("high" => missing, "low" => missing),
    "E.Europe" => Dict("high" => 0.47, "low" => 0.32),
    "E.North-America" => Dict("high" => 0.41, "low" => 0.26),
    "E.Siberia" => Dict("high" => 0.56, "low" => 0.69),
    "Mediterranean" => Dict("high" => 0.84, "low" => 0.94),
    "N.Central-America" => Dict("high" => 0.72, "low" => 0.47),
    "N.E.North-America" => Dict("high" => 0.44, "low" => 0.15),
    "N.Europe" => Dict("high" => 0.44, "low" => 0.25),
    "N.W.North-America" => Dict("high" => 0.39, "low" => 0.24),
    "Russian-Arctic" => Dict("high" => missing, "low" => missing),
    "Russian-Far-East" => Dict("high" => 0.58, "low" => 0.62),
    "S.Asia" => Dict("high" => 0.45, "low" => 0.44),
    "Tibetan-Plateau" => Dict("high" => 0.45, "low" => 0.71),
    "W.C.Asia" => Dict("high" => 0.47, "low" => 0.79),
    "W.North-America" => Dict("high" => 0.37, "low" => 0.29),
    "W.Siberia" => Dict("high" => 0.57, "low" => 0.6),
    "West&Central-Europe" => Dict("high" => 0.61, "low" => 0.78)
)

function plot_hist(ax, vegetation_type, xtreme )
    i=1
    for region in regions    
        df = read_ori_data(vegetation_type, xtreme, region)
        if vegetation_type == "crop"
            color = palette["orange"]
            sign= 1
        else
            color = palette["mint"]
            sign= -1
        end

        if !ismissing(df)
            print(size(df))
            if size(df)[1]> 100
                year = Int16.(df[!,  "# year"][df[!,"lai_su"].==1])
                freq = fit(Histogram, year, 1983:2021).weights
                freq = freq ./ sum(freq)   
                time_x = [1983:2020;]
                # print(coeftable(lm(reshape(time_x, :,1), freq)))
                println(region)
                freq = sign*2*freq  
                barplot!(ax, time_x , freq, offset = 1*i , color = color )
                
                c = corr_data[region][xtreme]
                if !ismissing(c)
                    text!(ax, time_x[end-2], 1*i+0.25, text=string(round(c, digits=2)), color=:grey20)
                end
            end
            # h = hist!(ax, year, scale_to=2, offset = 3*i, color = color, bins=37, flip=true)        
        end
        i+=1

    end
end


regions_acronym = [ipcc_acronym[region] for region in regions]

with_theme(theme_latexfonts()) do

    f = Figure(resolution=(1200, 1400), fontsize=18)

    ax1 = Axis(f[2,1], title = L"LAI_{low}", xgridvisible = false, ygridvisible=false, yticks= (1:1:19*1, regions_acronym))
    ax2 = Axis(f[2,2], title = L"LAI_{high}", xgridvisible = false, ygridvisible=false)
    # ax3 = Axis(f[2,1], title = "High crop activity", xgridvisible = false, ygridvisible=false, yticks= (1:1:19*1, regions))
    # ax4 = Axis(f[2,2], title = "High forest activity", xgridvisible = false, ygridvisible=false)

    ylims!(ax1, (0.5,19.5))
    ylims!(ax2, (0.5,19.5))
    # ylims!(ax3, (1,20))
    # ylims!(ax4, (1,20))

    plot_hist(ax1, "crop", "low")
    plot_hist(ax1, "forest", "low")

    plot_hist(ax2, "crop", "high")
    plot_hist(ax2, "forest", "high")
    hidespines!(ax1, :r, :t)
    hidespines!(ax2, :r, :t, :l)

    # hidespines!(ax3, :r, :t)
    # hidespines!(ax4, :r, :t, :l)
    # hideydecorations!(ax1)
    hideydecorations!(ax2)
    # hideydecorations!(ax3)
    # hideydecorations!(ax4)

    elem_1 = MarkerElement(color = palette["orange"], marker = :rect, markersize = 15, points=Point2f[(0.5,0.5) ])
    elem_2 = MarkerElement(color = palette["mint"], marker = :rect, markersize = 15, points=Point2f[(0.5,0.5)])

    Legend(f[1,1:end], [elem_1, elem_2], ["Crop", "Forest"], orientation= :horizontal, framevisible=false)
    f
    save("images/year_of_extreme_v3.pdf", f)

end



x = [0.02694610778443114, 0.005239520958083832, 0.005389221556886228, 0.0007485029940119761, 0.003143712574850299, 0.06377245508982037, 0.047005988023952096, 0.007634730538922155, 0.004640718562874252, 0.003143712574850299]

mk_original_test(x)

unique_x = unique(x)
g = length(unique_x)

n = length(x)
tp = zeros(length(unique_x))
demo = ones(n)

for i in 1:g
    tp[i] = sum(demo[x == unique_x[i]])
end

unique_x

sum(x .== unique_x[5])

var_s = (n*(n-1)*(2*n+5) - sum(tp*(tp-1)*(2*tp+5)))/18