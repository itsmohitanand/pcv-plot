using CairoMakie
using StatsBase

include("core.jl")

auc_ch = read_auc("crop", "high")
auc_cl = read_auc("crop", "low")
auc_fh = read_auc("forest", "high")
auc_fl = read_auc("forest", "low")


function remove_col_with_missing(df)
    return df[!, map(x->!all(ismissing, x), eachcol(df))]
end


function rank_auc_diff(f, ax_loc, df, color, title )
    df = remove_col_with_missing(df)
    x_names = names(df)
    diff = Matrix(df)[2,:] - Matrix(df)[1,:]
    sorted_index = sortperm(diff, rev=true)
    x = [1:length(sorted_index);]

    xticklabels = [ipcc_acronym[split(x_names[i], "_")[3]] for i in sorted_index]
    ax =Axis(f[ax_loc[1], ax_loc[2]], xticks = (x, xticklabels), xticklabelrotation = π/2, title=title)
    
    for (i , sort_index) in enumerate(sorted_index)
        barplot!(ax, x[i], diff[sort_index], color = color)
    end

end

f = Figure()

rank_auc_diff(f, [1,1], auc_cl, palette["orange"], "CROP LOW")
rank_auc_diff(f, [2,1], auc_fl, palette["mint"], "FOREST LOW")
rank_auc_diff(f, [1,2], auc_ch, palette["orange"], "CROP HIGH")
rank_auc_diff(f, [2,2], auc_fh, palette["mint"], "FOREST HIGH")

f



