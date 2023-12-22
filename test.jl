using CairoMakie
using NCDatasets
ds = Dataset("/Users/anand/Documents/data/pcv/plot_data/crop_data/low/crop_N.Europe_v0.nc")

ds

var = ds["lai_su_crop"][:,:,:]
var = replace(var, missing=>NaN)
var[var .!= 1] .=0

f = Figure()
ax1 = Axis(f[1,1])
ax2 = Axis(f[1,2])
ax3 = Axis(f[2,1])
ax4 = Axis(f[2,2])

heatmap!(ax1,var[:,:,1])
heatmap!(ax2,var[:,:,2])
heatmap!(ax3,var[:,:,3])
heatmap!(ax4,var[:,:,4])

f

for i=1:38
    println(sum(var[:,:,i])/sum(var)*100)
end


var[var.<1].=0

for i=1:38
    heatmap!(ax,ds["lai_su_crop"][:,:,1])
end

