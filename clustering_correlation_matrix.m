 function cm = clustering_correlation_matrix(clus_res, config)    
    % measure the correlation between two matrices
    % defined by the first N elements of two clusters
    % (where N is the size of the smallest cluster).
    % Sort elements by their respective distance to the
    % centroids

    cm = zeros(clus_res.nclusters, clus_res.nclusters);

    feat_val = config.clustering_feature_values;
    
    for ic = 1:clus_res.nclusters
        for jc = ic:clus_res.nclusters
            if ic == jc
                cm(ic, jc) = 1;
                cm(jc, ic) = 1;
            else
                sel1 = find(clus_res.cluster_index == ic);
                sel2 = find(clus_res.cluster_index == jc);

                feat_norm1 = max(feat_val(sel1, :)) - min(feat_val(sel1, :));            
                feat_norm2 = max(feat_val(sel2, :)) - min(feat_val(sel2, :));            

                dist1 = sum(((feat_val(sel1, :) - repmat(clus_res.centroids(:, ic)', length(sel1), 1)) ./ repmat(feat_norm1, length(sel1), 1)).^2, 2);
                dist2 = sum(((feat_val(sel2, :) - repmat(clus_res.centroids(:, jc)', length(sel2), 1)) ./ repmat(feat_norm2, length(sel2), 1)).^2, 2);

                [~, ord] = sort(dist1);
                sel1 = sel1(ord);
                [~, ord] = sort(dist2);
                sel2 = sel2(ord);

                n1 = length(sel1);
                n2 = length(sel2);
                n = min(n1, n2);                                

                % compute the correlation between n elements
                rho = corr2( feat_val(sel1(1:n), :), feat_val(sel2(1:n), :) );
                cm(ic, jc) = rho;
                cm(jc, ic) = rho;                                    
            end
        end
    end
 end