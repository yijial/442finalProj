% EECS 442 Final Project 2017
% Yuqi Lei, Yijia Liu, Patrick Holmes
% group name: cv4meee
% group project: North Campus Building Recognition

% begin code -------
clear all;

% load the names of all images, randomly separate half
%   into training data, half into testing data
%allimages = dir(fullfile('Dataset','*', '*.jpeg'));
allimages = dir(fullfile('NCset','*.jpeg'));

shuffleidx = randperm(length(allimages), length(allimages));
shuffledimages = allimages(shuffleidx);
trainimages = shuffledimages(1:floor(3*length(shuffledimages)/4));
testimages = shuffledimages(floor(3*length(shuffledimages)/4)+1:end);

clear allimages shuffledimages

load imagelabels.mat
names = extractfield(imagelabels, 'imagename');

% generate features for each training image
tic
disp('Generating features for training data');
for i = 1:length(trainimages)
    imgname = trainimages(i).name;
    fullimgname = fullfile(trainimages(i).folder, trainimages(i).name);
    img = imread(fullimgname);
    trainimages(i).feat = generate_feature(img);
    trainimages(i).label = imagelabels(strcmp(names,trainimages(i).name)).label;
    %trainimages(i).label = str2double(imgname(2:(strfind(imgname, '-')) - 1));
end
toc

% sort training images by label
sortlabels = [trainimages.label]';
[~, sortidx] = sort(sortlabels, 'ascend');
trainimages = trainimages(sortidx);

% get a matrix of features, vector of labels
features = [trainimages.feat]';
labels = [trainimages.label]';
% normalize each column of the feature matrix...
%   subtract mean and divide by standard deviation
%   for each column
mu_features = mean(features);
sigma_features = std(features);
for i = 1:size(features, 2)
    features(:, i) = (features(:, i) - mu_features(i))/sigma_features(i);
end

% multiclass LDA -------
[newfeat, W] = FDA(features', labels);

% only take real part of newfeat (imaginary part very very very small)
newfeat = real(newfeat)';
mu_newfeat = mean(newfeat);
sigma_newfeat = std(newfeat);
% normalize the newfeat matrix
for i = 1:size(newfeat, 2)
    newfeat(:, i) = (newfeat(:, i) - mu_newfeat(i))/sigma_newfeat(i);
end

% trains the SVM based classifier
disp('Training the classifier!');
mdl = fitcecoc(newfeat, labels);

% hokay! time to test some images.
% generate features for each test image
tic
disp('Generating features for test data')
for i = 1:length(testimages)
    imgname = testimages(i).name;
    fullimgname = fullfile(testimages(i).folder, testimages(i).name);
    img = imread(fullimgname);
    testimages(i).feat = generate_feature(img);
    testimages(i).label = imagelabels(strcmp(names,testimages(i).name)).label;
    %testimages(i).label = str2double(imgname(2:(strfind(imgname, '-')) - 1));
end
toc

% get a matrix of test features, vector of test labels
testfeatures= [testimages.feat]';
testlabels = [testimages.label]';
% normalize each column of the feature mat
%   subtract mean and divide by standard deviation
%   (normalize by training image data).
for i = 1:size(testfeatures, 2)
    testfeatures(:, i) = (testfeatures(:, i) - mu_features(i))/sigma_features(i);
end

% project these features onto the LDA subspace
testnewfeat = W'*testfeatures';
testnewfeat = real(testnewfeat)';

% normalize the newfeat matrix
%   (normalize by training image data).
for i = 1:size(testnewfeat, 2)
    testnewfeat(:, i) = (testnewfeat(:, i) - mu_newfeat(i))/sigma_newfeat(i);
end

predictedlabel = predict(mdl, testnewfeat);

good = sum(predictedlabel == testlabels);
percentgood = good/length(testimages);
disp('%-------%');
disp(sprintf('Percent of images identified correctly: %f', percentgood*100));

