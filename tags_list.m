classdef tags_list < handle
    %TAGS_LIST Summary of this class goes here
    %   Detailed explanation goes here    
    properties(GetAccess = 'public', SetAccess = 'protected')
        trajectories_hash = [];
        ids = [];
        tags = {};
        count = 0;
        description = [];
    end
    
    methods
        function inst = tags_list(desc, traj)
            % store all the identifications and hashes of the trajectories
            inst.description = desc;
            inst.trajectories_hash = traj.hash_value;
            inst.count = traj.count;
            inst.tags = cell(inst.count, 1);
            inst.ids = zeros(inst.count, 5);
            
            for i = 1:inst.count
                data_id = traj.items(i).data_identification;
                id = traj.items(i).identification;
                if id(4) == -1 % full trajectory ?
                    d = -1; % offset
                    l = 0; % len
                else % a segment -> use real values for offset/length
                    d = floor(traj.items(i).offset); % take only the integer part
                    l = floor(traj.items(i).compute_feature(base_config.FEATURE_LENGTH)); % idem, only integer part
                end
                inst.ids(i, :) = [data_id(1), data_id(2), data_id(3), d, l];                
            end        
        end
        
        function clear_tags(inst)
            inst.tags = cell(inst.count, 1);
        end
        
        function ret = remove_tag(inst, idx, input_tag)
             if isa(input_tag, 'tag')
                % use the tag object for matching - it can contain multiple
                % labels
                for i = 1:length(inst.tags{idx})
                    if input_tag.matches(inst.tags{idx}{i})
                        inst.tags{idx}{i} = [];
                        ret = 1;
                        break;
                    end
                end
            else
                % compare using a simple string comparison
                for i = 1:length(inst.tags{idx})
                    if strcmp(inst.tags{idx}{i}, input_tag)
                        inst.tags{idx}{i} = [];
                        ret = 1;
                        break;
                    end
                end
             end                        
        end        
        
        function ret = set_tag(inst, idx, input_tag)            
            found = 0;            
            if isa(input_tag, 'tag')
                % use the tag object for matching - it can contain multiple
                % labels
                new_tag = input_tag.abbreviation;
                for i = 1:length(inst.tags{idx})
                    if input_tag.matches(inst.tags{idx}{i})
                        found = 1;
                        break;
                    end
                end
            else
                new_tag = input_tag;
                for i = 1:length(inst.labels)
                    if strcmp(inst.tags{idx}{i}, input_tag)
                        found = 1;
                        break;
                    end
                end
            end
            if ~found
                if ~isempty(inst.tags{idx})
                    inst.tags{idx} = [inst.tags{idx}, input_tag];
                else
                    inst.tags{idx} = {input_tag};
                end
            end
            ret = ~found;
        end
        
        function ret = has_tag(inst, idx, input_tags)
            n = length(input_tags);
            ret = zeros(1, n);
            for t = 1:n
                if isa(input_tags(t), 'tag')
                    % use the tag object for matching - it can contain multiple
                    % labels
                    for i = 1:length(inst.tags{idx})
                        if input_tags(t).matches(inst.tags{idx}{i})
                            ret(t) = 1;
                            break;
                        end
                    end
                else
                    % compare using a simple string comparison
                    for i = 1:length(inst.tags{idx})
                        if strcmp(inst.tags{i}, input_tags(t))
                            ret(t) = 1;
                            break;
                        end
                    end
                end
            end
        end
        
        function replace_tags(inst, idx, input_tags)
            inst.tags{idx} = {};
            for t = 1:length(input_tags)
                if isa(input_tags(t), 'tag')
                    if t > 1
                        inst.tags{idx} = [inst.tags{idx}, input_tags(t).abbreviation];
                    else
                        inst.tags{idx} = {input_tags.abbreviation};
                    end                
                else
                    if t > 1                    
                        inst.tags{idx} = [inst.tags{idx}, input_tags(t)];
                    else
                        inst.tags{idx} = {input_tags};
                    end 
                end
            end
        end                
        
        function tags_abbrev = unique_tags(inst)
            all_tags = {};
            for i = 1:inst.count
                all_tags = [all_tags, inst.tags{i}];
            end
            tags_abbrev = unique(all_tags);
        end
                
        function mat = matrix(inst, selected_tags) 
            mat = zeros(inst.count, length(selected_tags));
            
            for i = 1:inst.count
                % this does all the job - multiple tags can be matched by
                % has_tag()
                mat(i, :) = inst.has_tag(i, selected_tags);
            end            
        end        
        
        function save_to_file(inst, fn)
            %SAVE_TAGS Summary of this function goes here
            %   Detailed explanation goes here            
            fid = fopen(fn, 'w');
            for i = 1:inst.count
                if ~isempty(inst.tags{i})
                    % we have something to write
                    
                    % store set,session,track#,offset,length
                    id = inst.ids(i, :);
                    str = sprintf('%d,%d,%d,%d,%d', id(1), id(2), id(3), id(4), id(5));
                    for j = 1:length(inst.tags{i})                                
                        str = strcat(str, sprintf(',%s', inst.tags{i}{j}));                        
                    end                
                    fprintf(fid, '%s\n', str);
                end
            end
            fclose(fid);
        end             
        
        function unmatched = load_from_file(inst, fn)
            % READ_TAGS(FN, TAG_TYPE)
            %   Reads tags from file FN filtering by tags of type TAG_TYPE only
            %   Tags are sorted according to their score value (if available)
            inst.clear_tags;
            unmatched = 0;
            
            % use an 3rd party function to read the file since matlab is unable to
            % parse anything other than a very basicc CSV file (!)
            labels = robustcsvread(fn);
            for i = 1:size(labels, 1)
                if isempty(labels{i, 1})
                    continue;
                end
                % set and track numbers
                set = sscanf(labels{i, 1}, '%d');
                day = sscanf(labels{i, 2}, '%d');
                track = sscanf(labels{i, 3}, '%d');
                off = sscanf(labels{i, 4}, '%d');
                len = sscanf(labels{i, 5}, '%d');
                id = [set, day, track, off, len];
                
                % find cooresponding item index
                idx = 0;
                for j = 1:inst.count
                   if issame(id, inst.ids(j, :))
                       idx = j;
                       break;
                   end
                end
                
                if idx > 0                
                    for k = 6:size(labels, 2)
                        if ~isempty(labels{i, k})
                            if isempty(inst.tags{idx})
                                inst.tags{idx} = {labels{i, k}};
                            else
                                inst.tags{idx} = [inst.tags{idx}, labels{i, k}];
                            end
                        end
                    end
                else
                    unmatched = unmatched + 1;
                end                
            end
        end
    end    
end