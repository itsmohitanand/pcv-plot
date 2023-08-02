
function ipcc_region()
    data_path = "/Users/anand/Documents/data/pcv/crop_data/high/"
    region_1 = Set([split(path, "_")[2] for path in readdir(data_path) if !occursin("logreg",path)])
    data_path = "/Users/anand/Documents/data/pcv/forest_data/high/"
    region_2 = Set([split(path, "_")[2] for path in readdir(data_path) if !occursin("logreg",path)])
    regions = union(region_1, region_2)
    return sort(collect(regions))
end 

function crop_forest_location()

    crop_mask = transpose(npzread("/Users/anand/Documents/data/pcv/crop_data/crop_mask.npy"))
    forest_mask = transpose(npzread("/Users/anand/Documents/data/pcv/forest_data/forest_mask.npy"))

    lon = [-179.75:0.25:180;]
    lat = [25:0.25:74.25;]

    c = Point2f[]
    f = Point2f[]

    for i=1:1440
        for j=1:200
            
            if crop_mask[i, j] == true
                push!(c, Point2f(lon[i], lat[j]))  
            end

            if forest_mask[i, j] == true
                push!(f, Point2f(lon[i], lat[j]))                
            end

        end
    end
    return c, f
end

function read_logreg_df(vegetation_type, xtreme, region_name)

    ds_path = "/Users/anand/Documents/data/pcv/$(vegetation_type)_data/$(xtreme)"
    fname = [path for path in readdir(ds_path) if occursin("logreg_$(xtreme)_$(vegetation_type)_$(region_name)",path)]
    fname_w = [path for path in readdir(ds_path) if occursin("logreg_winter_$(xtreme)_$(vegetation_type)_$(region_name)",path)]

    if !isempty(fname)
        df = DataFrame(CSV.File(joinpath(ds_path, fname[1]), header=1, delim="\t"))
        df_w = DataFrame(CSV.File(joinpath(ds_path, fname_w[1]), header=1, delim="\t"))

        return df, df_w
    else
        return missing, missing
    end
end

function read_ori_data(vegetation_type, xtreme, region_name)
    ds_path = "/Users/anand/Documents/data/pcv/$(vegetation_type)_data/$(xtreme)"
    fname = [path for path in readdir(ds_path) if startswith(path, "$(vegetation_type)_$(region_name)")]
    
    if !isempty(fname)
        df = DataFrame(CSV.File(joinpath(ds_path, fname[1]), header=1, delim="\t"))
    
        return df
    else
        return missing
    end
end


function winter_significance(df, df_w)
    diff = max(mean(df_w[!,"AUC"]) - quantile(df[!,"AUC"], 0.9),0)

    return diff>0
end

function anomaly(df, var_name)
    return df[!, var_name][df[!, "lai_su"] .== 1] .- mean(df[!, var_name])
end

function winter_climate_anomaly(df)
    return anomaly(df, "t2m_winter"), anomaly(df, "tp_winter")
end