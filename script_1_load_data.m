clear all;
close all;
clc;

addpath('images/pedxing-seq1');

idStart = 1599;
nbImg = 250;

figure;
id = idStart + 1;
fileToload = ['0000',num2str(id),'.jpg'];
img = imread(fileToload);
img = rgb2gray(img);
imagesc(img); colormap(gray); axis image;

[x,y] = ginput(2);
pt1 = [x(1),y(1)];
pt2 = [x(2),y(2)];
hold on; plot(pt1(1),pt1(2),'og');
hold on; plot(pt2(1),pt2(2),'og');
hold on; plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'-g');


v = pt2-pt1;
deltaX = abs(pt2(1)-pt1(1));
deltaY = abs(pt2(2)-pt1(2));
p = round(sqrt(deltaX^2 + deltaY^2));
A = zeros(p,nbImg);

for i=1:nbImg
   
    id = idStart + i;
    fileToload = ['0000',num2str(id),'.jpg'];
    img = imread(fileToload);
    img = rgb2gray(img);
    imagesc(img); colormap(gray); axis image;
    hold on; plot(pt1(1),pt1(2),'og');
    hold on; plot(pt2(1),pt2(2),'og');
    hold on; plot([pt1(1) pt2(1)],[pt1(2) pt2(2)],'-g');    
    title(num2str(i));
    pause(0.04);
    %disp([num2str(i),' / ',num2str(nbImg)])

    for t=0:p
         pt = round(pt1 + v*t/p);
        A(t+1,i) = img(pt(2),pt(1));
    end
end

%%
meanColumn = mean(A,2);
Ac = A;
for j=1:size(A,2)
    Ac(:,j) = A(:,j) - meanColumn;  
end
figure; imagesc(Ac);
