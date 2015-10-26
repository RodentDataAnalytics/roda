classdef globals
    %GLOBALS Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant)        
        APP_NAME = 'rats';
        PATH_SEPARATOR = iff(ispc, '\', '/');        
    end 
    
    methods(Static)
        function ret = DATA_DIRECTORY()           
            ret = iff(ispc, fullfile(home_directory(), globals.APP_NAME), fullfile(home_directory(), ['.' globals.APP_NAME]));
            if ~exist(ret, 'dir')                
                mkdir(ret)
            end            
        end
        
        function ret = CACHE_DIRECTORY()
            ret = [globals.DATA_DIRECTORY '/cache'];
            if ~exist(ret, 'dir')                
                mkdir(ret)
            end           
        end
    end
end