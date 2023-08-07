using CairoMakie
using DataFrames
using CSV
using Statistics
using NPZ
using ColorSchemes
using GLM
using Random
using EvalMetrics


include("core.jl")

# Simple schematic showing the methodology

regions = ipcc_region()

r = regions[2]

vegetation_type = "crop"
xtreme = "low"

df = read_ori_data(vegetation_type, xtreme,r)

function splitdf(df, pct)
    @assert 0 <= pct <= 1
    ids = collect(axes(df, 1))
    shuffle!(ids)
    sel = ids .<= nrow(df) .* pct
    return copy(view(df, sel, :)), copy(view(df, .!sel, :))
end


f = Figure(resolution=(1200,600))
ax1 = Axis(f[1,1], limits = (0,1,0,1), xgridvisible = false, ygridvisible = false, xlabel="False Positive Rate", ylabel="True Positive Rate")
ax2 = Axis(f[1,2], limits = (0.64,.74,0,20), xgridvisible = false, ygridvisible = false, xlabel="Area Under ROC", ylabel="Frequency")

auc_w_list = []
auc_list = []
for i=1:100
    train, test = splitdf(df, .85);

    fm = @formula(lai_su ~ t2m_winter + tp_winter + t2m_spring + tp_spring  + t2m_summer + tp_summer )
    l1 = glm(fm, train, Binomial(), ProbitLink())

    scores = Float64.(predict(l1, test))
    target = test[!, "lai_su"]

    roc = roccurve(target, scores)
    lines!(ax1, roc[1], roc[2], color=palette["light_cyan"])

    push!(auc_w_list, auc_trapezoidal(roccurve(target, scores)...))

    fm = @formula(lai_su ~ t2m_spring + tp_spring  + t2m_summer + tp_summer )
    l1 = glm(fm, train, Binomial(), ProbitLink())

    scores = Float64.(predict(l1, test))
    target = test[!, "lai_su"]

    roc = roccurve(target, scores)
    push!(auc_list, auc_trapezoidal(roc...))

    lines!(ax1, roc[1], roc[2], color=palette["pale_grey"])

end
f

hist!(ax2, auc_list, color = palette["pale_grey"])
hist!(ax2, auc_w_list, color = palette["light_cyan"])

vlines!(ax2, quantile(auc_list, 0.9), color = :black, linestyle = "--" )
vlines!(ax2, mean(auc_w_list), color = :black )
f
save("images/method.pdf", f)

