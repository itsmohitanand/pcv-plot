using HDF5

function read_data(fname)

    # t2m_winter 0	tp_winter 1	sm_winter 2	
    # t2m_spring 3 tp_spring 4 sm_spring 5 lai_spring 6	
    # t2m_summer 7	tp_summer 8	sm_summer 9	lai_su 10

    fid = h5open(fname, "r")
    a_others = fid["a_others"][:,:]
    a_self = fid["a_self"][:,:]
    ei_others = fid["ei_others"][:,:,:]
    ei_self = fid["ei_self"][:,:,:]
    y_true = fid["y_true"][:]
    year = fid["year"][1,:]
    data = fid["data"][1,:,:]
    y_pred = fid["y_pred"][:]
    return a_others, year, y_true, y_pred, data, ei_others
end

# readdir("/Users/anand/Documents/data/pcv/attention/")
# file_list = []

# function get_file_paths(xtreme, vegetation_type):
    
#     file_list = []
#     for files in readdir("/Users/anand/Documents/data/pcv/attention/")
#         if 
#     end
# end

pallete_climai_d = [
    colorant"#E8549D", 
    colorant"#DA56A9", 
    colorant"#A565D7", 
    colorant"#629FE8", 
    colorant"#60A8E5", 
    colorant"#64D6DC", 
    colorant"#60A8E5",
    colorant"#629FE8",
    colorant"#A565D7",
    colorant"#DA56A9",
    colorant"#E8549D"
    ]

pallete_climai = [
    colorant"#E8549D", 
    colorant"#DA56A9", 
    colorant"#A565D7", 
    colorant"#629FE8", 
    colorant"#60A8E5", 
    colorant"#64D6DC", 
    ]

climai_scheme_d = ColorScheme(pallete_climai_d)
climai_d = cgrad(climai_scheme_d, categorical=false)
    
climai_scheme = ColorScheme(pallete_climai)
climai = cgrad(climai_scheme, categorical=false)