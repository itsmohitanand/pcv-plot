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
            
            year = Int16.(df[!,  "# year"][df[!,"lai_su"].==1])
            freq = fit(Histogram, year, 1983:2021).weights
            freq = freq ./ sum(freq)   
            time_x = [1983:2020;]
            # print(coeftable(lm(reshape(time_x, :,1), freq)))
            println(region)
            println(freq)            
            freq = sign*2*freq  
            barplot!(ax, time_x , freq, offset = 1*i , color = color )
            # h = hist!(ax, year, scale_to=2, offset = 3*i, color = color, bins=37, flip=true)        
        end
        i+=1

    end
end


regions_acronym = [ipcc_acronym[region] for region in regions]

f = Figure(resolution=(1200, 1400))

ax1 = Axis(f[2,1], title = "Low vegetation activity", xgridvisible = false, ygridvisible=false, yticks= (1:1:19*1, regions_acronym))
ax2 = Axis(f[2,2], title = "High vegetation activity", xgridvisible = false, ygridvisible=false)
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

Legend(f[1,1:end], [elem_1, elem_2], ["Crop", "Forest"], orientation= :horizontal)
f

save("images/year_of_extreme_v3.pdf", f)

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