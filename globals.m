classdef globals
    %GLOBALS Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)        
        APP_NAME = 'rats';
        DATA_DIRECTORY = iff(isunix(), [home_directory() '/.' globals.APP_NAME], [home_directory() '_' globals.APP_NAME]);
        CACHE_DIRECTORY = [globals.DATA_DIRECTORY '/cache'];
    end     
end