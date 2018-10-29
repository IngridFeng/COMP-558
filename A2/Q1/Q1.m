close all; clear;
I = imread('james.jpg');
J = I(:,:,2);%take the green channel
green = mat2gray(J);%grayscale
imwrite(green, 'green_only.jpg');

n = 200;%choose the number of iterations

%sigma value 4
sigma = 4; gfilter4 = imgaussfilt(green,sigma);%smoothing with gaussian
imwrite(gfilter4, 'filtered4.jpg');

heatIm4 = heateq(green, sigma, n);%smoothing with heat equation
imwrite(heatIm4, 'heatIm4.jpg');

difference4 = gfilter4-heatIm4;%calculating the difference
disp('Number of iterations:');
disp(n);
disp('difference total for sigma 4 =');
disp(sum(sum(abs(difference4))));%calculate and display difference total in absolute value

%sigma value 8
sigma = 8; gfilter8 = imgaussfilt(green,sigma);%smoothing with gaussian
imwrite(gfilter8, 'filtered8.jpg');

heatIm8 = heateq(green, sigma, n);%smoothing with heat equation
imwrite(heatIm8, 'heatIm8.jpg');

difference8 = gfilter8-heatIm8;%calculating the difference
disp('difference total for sigma 8 =');
disp(sum(sum(abs(difference8))));%calculate and display difference total in absolute value

%sigma value 12
sigma = 12; gfilter12 = imgaussfilt(green,sigma);%smoothing with gaussian
imwrite(gfilter12, 'filtered12.jpg');

heatIm12 = heateq(green, sigma, n);%smoothing with heat equation
imwrite(heatIm12, 'heatIm12.jpg');

difference12 = gfilter12-heatIm12;%calculating the difference
disp('difference total for sigma 12 =');
disp(sum(sum(abs(difference12))));%calculate and display difference total in absolute value

%sigma value 16
sigma = 16; gfilter16 = imgaussfilt(green,sigma);%smoothing with gaussian
imwrite(gfilter16, 'filtered16.jpg');

heatIm16 = heateq(green, sigma, n);%smoothing with heat equation
imwrite(heatIm16, 'heatIm16.jpg');

difference16 = gfilter16-heatIm16;%calculating the difference
disp('difference total for sigma 16 =');
disp(sum(sum(abs(difference16))));%calculate and display difference total in absolute value

figure(1)%displaying images formed by filter with gaussian
subplot(2,2,1); imshow(gfilter4); title('gaussian, sigma=4');
subplot(2,2,2); imshow(gfilter8); title('gaussian, sigma=8');
subplot(2,2,3); imshow(gfilter12); title('gaussian, sigma=12');
subplot(2,2,4); imshow(gfilter16); title('gaussian, sigma=16');

figure(2)%displaying images formed by smoothing with heat equation
subplot(2,2,1); imshow(heatIm4); title('heat equation, sigma=4');
subplot(2,2,2); imshow(heatIm8); title('heat equation, sigma=8');
subplot(2,2,3); imshow(heatIm12); title('heat equation, sigma=12');
subplot(2,2,4); imshow(heatIm16); title('heat equation, sigma=16');

