

%% define the range of transformation
rotation_range=60;
width_shift_range=0.2;
height_shift_range=0.2;
shear_range=0.2;
zoom_range=0.2;
projective_rage = 0.0005;

imagefiles = dir('*.jpg');
nfiles = length(imagefiles);

for n = 1:nfiles
    filename = imagefiles(n).name;
    I = imread(filename);
    [r,c,~] = size(I);
    imwrite(I,[num2str(n), '0.jpeg']);
    I = imresize(I, 1200/c);
    [r,c,~] = size(I);
    % for each image, we generate 5 transformation of it
    for i = 1:5
        rot = randi([-1,1])*(rand * rotation_range) * pi / 180; % angle of rotation
        sx = rand * zoom_range + 1; % scale along x axis
        sy = rand * zoom_range + 1; % scale along y axis
        sfx = rand * width_shift_range * c;
        sfy = rand * height_shift_range * r;
        shx = rand * shear_range; % shear along x axis
        shy = rand * shear_range; % shear along y axis
        proj1 = rand * projective_rage;
        proj2 = rand * projective_rage;
        A = [sx*cos(rot) -shx*sin(rot) sfx;
            shy*sin(rot) sy*cos(rot) sfy;
            0 0 1]';
        T = maketform('affine',A);
        B = imtransform(I,T);
        figure;imshow(B);
        % try to crop the rectangular region..
        [h, w, ~] = size(B);
        [~, left] = max(B(:,1,1));
        [~, right] = max(B(:,w,1));
        [~, top] = max(B(1,:,1));
        [~, bot] = max(B(h,:,1));
        B = B(min(left,right):max(left,right),min(top, bot):max(top, bot),:);
        imwrite(B,[num2str(n),num2str(i),'.jpeg']);
    end

end
