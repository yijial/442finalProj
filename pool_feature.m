function [feat] = pool_feature(Ifilt)

% Ifilt is a 16x1 cell of filtered images.
% Divide each filtered image into 4x4 windows
% Take the max response in each region

[r, c] = size(Ifilt{1});
rskip = floor(r/4);
cskip = floor(c/4);

feat = zeros(256, 1);
for i = 1:length(Ifilt)
    for j = 1:4
        for k = 1:4
            vals = Ifilt{i}(rskip*(j-1) + 1:rskip*(j), cskip*(k-1) + 1:cskip*(k));
            max_val = max(vals(:));
            
            feat(16*(i-1) + 4*(j-1) + (k-1) + 1, 1) = max_val;
        end
    end
end
            

end