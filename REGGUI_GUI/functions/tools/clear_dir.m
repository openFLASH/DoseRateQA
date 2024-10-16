function clear_dir(temp_dir)

if(exist(temp_dir,'dir'))
    try
        rmdir(temp_dir,'s')
    catch
        disp(['Could not delete ',temp_dir])
    end
end
mkdir(temp_dir)