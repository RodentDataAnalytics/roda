function weka_init
    persistent wekajarpath;
    if isempty(wekajarpath)
        wekajarpath = fullfile(fileparts(mfilename('fullpath')), 'weka.jar');
        javaaddpathstatic(wekajarpath);        
        javaaddpathstatic(fullfile(fileparts(mfilename('fullpath')), 'Jama-1.0.3.jar'));
    end    
end