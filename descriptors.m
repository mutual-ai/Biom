function [features, valid_points] = descriptors(I, channel, erode_threshold, numOctaves, numScaleLevels);

% For Sclera images try numOctaves = 1 and numScaleLevels = 20
if nargin<5
    numScaleLevels = 4;  % Increse this for finer increment of scales
    if nargin < 4
        numOctaves = 3;  % Decrease this for detecting smaller blobs
        if nargin < 3
            erode_threshold = 80;   % Increase this to remove more boundary area
            if nargin < 2
                channel = 3;    % 3 for blue, 2 for green, 1 for red
            end
        end
    end
end
% Apply CLAHE
b = adapthisteq(I(:,:,channel)); 
% Search for the dark parts in the image
b_mask =1. - double(b<10);
% Remove the area near the boundaries so that we can remove features in
% that area
b_mask = imerode(b_mask, ones(erode_threshold, erode_threshold));
% Uncomment the following line to see the mask after erosion
%imagesc(b_mask);

% Extract SURF features
points = detectSURFFeatures(b, 'NumOctaves', numOctaves, 'NumScaleLevels', numScaleLevels);
[features, valid_points] = extractFeatures(b, points,'SURFSize',128);
figure; imshow(b); hold on;
%fprintf('Initial size of features is %d %d \n', size(features));
%fprintf('Initial size of valid points is %d %d \n', size(valid_points));
% For every point we check if it lies near the boundary. If yes then that
% point is considered invalid
%k = 0;
i = 1;
while(i <=length(valid_points) )   
    p = valid_points(i).Location; 
    if b_mask(round(p(2)),round(p(1))) < 0.1
        % The invalid points are plotted with red crosses
        plot(p(1), p(2), 'rx');
        valid_points(i)=[];
        %k = k+1;
        features(i,:) = [];
    else
        % The valid points with green
        plot(p(1),p(2),'go');
        drawnow;
        i = i+1;
    end
end 

%fprintf('Final size of features is %d %d \n', size(features));
%fprintf('Rejected features num is %d \n', k);
%fprintf('Final size of valid points is %d %d\n', size(valid_points));
pause;
close;