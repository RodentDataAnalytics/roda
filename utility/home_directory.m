function home = home_directory()
    if ispc
        home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
    else
        home = getenv('HOME');
    end
end