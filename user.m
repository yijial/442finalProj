load('category.mat');
% request the name of input image to be recognized
% prompt = 'Please enter the name of input image to be recognized: ';
% filename = input(prompt,'s');
filename = '/Users/yijialiu/Desktop/Courses_UMich/EECS442/finalProj/NCset/10.jpeg';
img = imread(filename);
feature = generate_feature(img)';
for i = 1:size(feature, 2)
    feature(i) = (feature(i) - mu_features(i))/sigma_features(i);
end
newfeat = real(W'*feature')';
for i = 1:size(newfeat, 2)
    newfeat(:, i) = (newfeat(:, i) - mu_newfeat(i))/sigma_newfeat(i);
end
predictedlabel = predict(mdl, newfeat);
labels = extractfield(category, 'categoryID');
building = category(labels == predictedlabel).categoryName;
disp(building);
