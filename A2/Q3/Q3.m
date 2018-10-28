close all; clear;
I = imread('james.jpg');
J = I(:,:,2);%take the green channel
green = mat2gray(J);%grayscale
imwrite(green, 'green_only.jpg');

sigma = 2; gfilter = imgaussfilt(green,sigma);

yld = conv2(gfilter, [1 1 1; 0 0 0; -1 -1 -1]);%local difference in y
xld = conv2(gfilter, [1 0 -1; 1 0 -1; 1 0 -1]);%local difference in x

magnitude = sqrt(double(xld.^2+yld.^2));%calculate gradient magnitude
orientation = atan(yld ./ xld);%calculate gradient orientation
binary = double(magnitude > 0.2);%choose the threshold


[xloc, yloc] = find(binary == 1);
%find all the x-y locations

theta = zeros(1,1);
[p,q] = size(xloc);

for k = 1:p
    theta(k,:) = orientation(xloc(k), yloc(k));
end

T = 100;%number of iteration
tr = 400;
tr_ori = 0.1;
%threshold to decide whether is an inlier/outlier
best = [0,0,0,0,0]; 
%first two values represent location of best edge, 3rd and 4th value
%represent m and b for the model line y =mx+b, last value represent count
%of the number of inliers.
for j = 1:T
    count = 0;
    rand_index = randi(p);
    rand_x = xloc(rand_index); 
    rand_y = yloc(rand_index);
    rand_ori = theta(rand_index,:);
    %line equation given by R = xcos(theta)+ysin(theta)
    R = rand_x*cos(rand_ori) + rand_y*sin(rand_ori);
    
    for k = 1:p
        %loop through every other edge point E_star and count number of inlier
        x = xloc(k);
        y = yloc(k);
        ori = theta(k,:);
        
        %if E_star is on the line, then g*m+b should be equal to h.
        if abs(x*cos(ori) + y*sin(ori) - R) <= tr && (abs(rand_ori - ori) < tr_ori)
            count = count + 1;
        end
    end
    
    if count > best(5)
        best = [rand_x,rand_y,rand_ori,R,count];
    end
end

R = best(4);
best_inliers = []; best_outliers = [];
i = 1; j = 1;
for k = 1:p
        %loop through every other edge point E_star and count number of inlier
        x = xloc(k);
        y = yloc(k);
        ori = theta(k,:);
        %if E_star is on the line, then g*m+b should be equal to h.
        if abs(x*cos(ori) + y*sin(ori) - R) <= tr && (abs(rand_ori - ori) < tr_ori)
            best_inliers = [best_inliers; [y,x,i]];
            i = i+1;
        else
            best_outliers = [best_outliers; [y,x,j]];
            j = j+1;
        end
end

disp(size(best_inliers));
disp(size(best_outliers));
%xy plot
scatter(best_inliers(:,2),best_inliers(:,1),0.5,'red');
hold on
scatter(best_outliers(:,2),best_outliers(:,1),0.5,'black');



    
    
        
