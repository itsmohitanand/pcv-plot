using CairoMakie
using Colors
using ColorSchemes

palette = ColorSchemes.viridis.colors



include("core.jl")

fname = "/Users/anand/Documents/data/pcv/attention/high_crop_C.North-America_n_1724_399_v2.h5"

a_others, year, y_true, data, ei_others = read_data(fname)

# Create a contour plot



a_t2m_sm = a_others[1, :]
a_tp_sm = a_others[2,:]
t2m = data[1,:]
tp = data[2,:]
sm = data[3,:]

f = Figure(resolution=(1400,800))
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

joint_limits = (0, 0.7)

sc11 = scatter!(ax11, t2m, tp, markersize = 4, color = a_t2m_sm, colorrange = joint_limits)
sc12 = scatter!(ax12, t2m, sm, markersize = 4, color = a_t2m_sm, colorrange = joint_limits)
sc13 = scatter!(ax13, sm, tp, markersize = 4, color = a_t2m_sm, colorrange = joint_limits)
Colorbar(f[1,4], sc11)
sc21 = scatter!(ax21, t2m, tp, markersize = 4, color = a_tp_sm, colorrange = joint_limits)
sc22 = scatter!(ax22, t2m, sm, markersize = 4, color = a_tp_sm, colorrange = joint_limits)
sc23 = scatter!(ax23, sm, tp, markersize = 4, color = a_tp_sm, colorrange = joint_limits)
Colorbar(f[2,4], sc11)
f

ax31= Axis(f[3,1:2])

year_min = minimum(year)
year_max = maximum(year)

for i=year_min:year_max
    index = i .== year 
    year_attn = a_t2m_sm[index]
    
    x = ones(Int8, size(year_attn)) .+ i .- year_min

    boxplot!(ax31, x, year_attn, color = palette[end-5] )
end

f