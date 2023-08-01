using CairoMakie
using Colors
using ColorSchemes
using CSV
using DataFrames
using Statistics
using StatsBase
using GLM
using EvalMetrics


include("core.jl")

palette = ColorSchemes.viridis.colors

function winter_coefficient(data)
    x = data
    data = DataFrame(y = Int64.(x[end,:]), x1 = x[1,:], x2 = x[2,:], x3 = x[3,:], x4 = x[4,:], x5 = x[5,:], x6 = x[6,:], x7 = x[7,:], x8 = x[8,:], x9=x[9,:], x10=x[10,:] );
    linreg = glm(@formula(y ~ x1+x2+x3+x4+x5+x6+x7+x8+x9+x10), data, Binomial(), LogitLink())
    
    y_pred = predict(linreg)
    y_pred
    roc = binary_eval_report( Int64.(x[end,:]), y_pred)

    return coef(linreg)[2:3], roc
end

vegetation_type = "forest"
xtreme = "low"

file_list = [file for file in readdir("/Users/anand/Documents/data/pcv/attention") if (occursin(vegetation_type, file) & occursin(xtreme, file) ) ]
file_list = [file for file in readdir("/Users/anand/Documents/data/pcv/attention")  ]

file_list
## Viridis Color


a_t2m_sm = []
y1 = []
c1 = []

a_tp_sm = []
y2 = []
c2 = []

marker_size = []

for fname in file_list
    # print(fname*"\n")
    a_others, year, y_true, y_pred, data, ei_others = read_data("/Users/anand/Documents/data/pcv/attention/"*fname)

    append!(a_t2m_sm, mean(a_others[1, :]))
    append!(a_tp_sm, mean(a_others[2,:]))        

    c, d = winter_coefficient(data)
    print(d)
    append!(c1, c[1])
    append!(c2, c[2])

    break


end

f = Figure(resolution=(500,500))
ax1 = Axis(f[1,1])

# hexbin!(ax1, Float64.(a_t2m_sm), Float64.(c1), bins=5, colormap="jet")
# hexbin!(ax1,Float64.(a_tp_sm), Float64.(c2), bins=5)

scatter!(ax1, Float64.(a_t2m_sm), Float64.(c1),  markersize = 8, color = "green", colormap=:viridis, label="temp")
scatter!(ax1, Float64.(a_tp_sm), Float64.(c2),  markersize = 8, color="blue", colormap=:viridis, label="precip")

axislegend(ax1)

f