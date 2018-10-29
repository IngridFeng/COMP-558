close all; clear;
I = imread('james.jpg');

% I1 = imrotate(I, 20);
% I = imresize(I1, [1024 1024]);
%to rotate and resize the image for testing SIFT algorithm

J = I(:,:,2);%take the green channel
green = mat2gray(J);%grayscale
imwrite(green, 'green_only.jpg');
[m,n] = size(green);

%part 1
%level 0, sigma value 1
sigma = 1; gfilter0 = imgaussfilt(green,sigma);%filter with gaussian

%level 1, sigma value 2
sigma = 2; gfilter1 = imgaussfilt(green,sigma);
downsample1 = imresize(gfilter1, 1/2);%resize

%level 2, sigma value 4
sigma = 4; gfilter2 = imgaussfilt(green,sigma);
downsample2 = imresize(gfilter2, 1/4);%resize

%level 3, sigma value 8
sigma = 8; gfilter3 = imgaussfilt(green,sigma);
downsample3 = imresize(gfilter3, 1/8);%resize

%level 4, sigma value 16
sigma = 16; gfilter4 = imgaussfilt(green,sigma);
downsample4 = imresize(gfilter4, 1/16);%resize

%level 5, sigma value 32
sigma = 32; gfilter5 = imgaussfilt(green,sigma);
downsample5 = imresize(gfilter5, 1/32);%resize

figure(1)%displaying gaussian pyramid
subplot(2,3,1); imshow(gfilter0); title('gaussian, level 0, sigma = 1');
subplot(2,3,2); imshow(downsample1); title('gaussian, level 1, sigma = 2');
subplot(2,3,3); imshow(downsample2); title('gaussian, level 2, sigma = 4');
subplot(2,3,4); imshow(downsample3); title('gaussian, level 3, sigma = 8');
subplot(2,3,5); imshow(downsample4); title('gaussian, level 4, sigma = 16');
subplot(2,3,6); imshow(downsample5); title('gaussian, level 5, sigma = 32');

%part 2
%calculating each level of laplcian pyramid by taking difference of
% gaussians at successive scales
dog0 = gfilter0 - imresize(downsample1, 2);
dog1 = downsample1 - imresize(downsample2, 2);
dog2 = downsample2 - imresize(downsample3, 2);
dog3 = downsample3 - imresize(downsample4, 2);
dog4 = downsample4 - imresize(downsample5, 2);
dog5 = downsample5;

figure(2)%displaying laplacian pyramid
subplot(2,3,1); imshow(dog0,[]); title('DoG, level 0, sigma = 1');
subplot(2,3,2); imshow(dog1,[]); title('DoG, level 1, sigma = 2');
subplot(2,3,3); imshow(dog2,[]); title('DoG, level 2, sigma = 4');
subplot(2,3,4); imshow(dog3,[]); title('DoG, level 3, sigma = 8');
subplot(2,3,5); imshow(dog4,[]); title('DoG, level 4, sigma = 16');
subplot(2,3,6); imshow(dog5,[]); title('DoG, level 5, sigma = 32');

%part 3
log0 = conv2(green,fspecial('log',30,1),'same')*3;%convolution with Laplacian of gaussian
log1 = conv2(green,fspecial('log',30,2),'same')*3;
log2 = conv2(green,fspecial('log',30,4),'same')*3;
%convolution with difference of gaussian
cdog0 = conv2(green,dog0);
cdog1 = conv2(green,dog1);
cdog2 = conv2(green,dog2);
%displaying DoG
figure(3);
subplot(2,3,1); imshow(dog0, []); title('DoG, level 0, sigma = 1');
subplot(2,3,2); imshow(dog1, []); title('DoG, level 1, sigma = 2');
subplot(2,3,3); imshow(dog2, []); title('DoG, level 2, sigma = 4');
%displaying LoG
subplot(2,3,4); imshow(log0, []); title('LoG, level 0, sigma = 1');
subplot(2,3,5); imshow(log1, []); title('LoG, level 1, sigma = 2');
subplot(2,3,6); imshow(log2, []); title('LoG, level 2, sigma = 4');

log = imresize(log2, [128 128]);
dog = imresize(dog2, [128 128]);
figure(4); surf(dog-log); 
%visualization of the difference betwee dog and log at level 2

%part 4
%find SIFT keypoint locations
%firstly, save the levels in a 3d matrix
A = dog0;
A(:,:,2) = imresize(dog1, 2);
A(:,:,3) = imresize(dog2, 4);
A(:,:,4) = imresize(dog3, 8);
A(:,:,5) = imresize(dog4, 16);
A(:,:,6) = imresize(dog5, 32);

points = zeros(1,4);%create a 2d matrix to store the points
index = 1;
threshold = 0.03;

for i = 1:4%loop through the inner levels 1-4
    sigma = 2^i;%deduce the value of sigma at this level
    im = A(:,:,(i+1));
    im1 = A(:,:,(i+2));
    im2 = A(:,:,i);
    %image is the current level, image1 is the level above, image2 is the level below
    for a = 2:(m-1)
        for b = 2:(n-1)%iterate through each pixel in this level
            B = [im(a-1,b),im(a-1,b-1),im(a,b-1),im(a+1,b),...
                im(a+1,b+1),im(a,b+1),im(a+1,b-1),im(a-1,b+1),...
                im1(a,b),im1(a-1,b),im1(a-1,b-1),im1(a,b-1),im1(a+1,b),...
                im1(a+1,b+1),im1(a,b+1),im1(a+1,b-1),im1(a-1,b+1),...
                im2(a,b),im2(a-1,b),im2(a-1,b-1),im2(a,b-1),im2(a+1,b),...
                im2(a+1,b+1),im2(a,b+1),im2(a+1,b-1),im2(a-1,b+1)];
            %all the 26 points we need to compare with in the 3*3
            %neighbourhood above, below, and at the same level
            if ((im(a,b) ~= 0)&&(((im(a,b) >= max(B)) && (im(a,b) - mean(B) > threshold)) || ...
                    ((im(a,b) <= min(B)) && (mean(B) - im(a,b) > threshold))))
                %find the local maximum and minimum and evaluate based on
                %the difference between the point and the mean of the other
                %26 points
                points(index,:) = [a,b,sigma,index];%store local extrema in the 2d matrix
                index = index + 1;%increment the index
            end
        end
    end
end
    
% disp(points);
[p, q] = size(points);
figure(5)
imshow(I);
hold on%keep the image showing
for j = 1:p%iterate through each point
    radius = points(j,3);
    %allocate different color and different radii
    if points(j,3) == 2
        color = 'r';
    elseif points(j,3) == 4
        color = 'g';
    elseif points(j,3) == 8
        color = 'b';
    else
        color = 'm';
    end
    t = 0:0.1:2*pi;
    x = points(j,1) + radius*sin(t); 
    y = points(j,2) + radius*cos(t);
    plot(y,x,color);%plot the circle for this point

end
hold off
    
    
    
    
    










