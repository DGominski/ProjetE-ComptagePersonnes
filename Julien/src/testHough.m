close all;
clear all;
clc;

addpath('img');
addpath('src');
addpath('data')

I = rgb2gray(imread('detection_0000.jpeg'));
% rotI = imrotate(I,33,'crop');
rotI = I;
%figure;imshow(rotI);


BW = edge(rotI,'canny');
%figure;imshow(BW);

[H,theta,rho] = hough(BW);

% figure
% imshow(imadjust(mat2gray(H)),[],...
%        'XData',theta,...
%        'YData',rho,...
%        'InitialMagnification','fit');
% xlabel('\theta (degrees)')
% ylabel('\rho')
% axis on
% axis normal
% hold on
% colormap(hot)

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

x = theta(P(:,2));
y = rho(P(:,1));
%plot(x,y,'s','color','black');

%close all;

lines = houghlines(BW,theta,rho,P,'FillGap',10,'MinLength',170);

figure, imshow(rotI), hold on
max_len = 0;
index = 1;
for k = 1:length(lines)
   if abs(lines(k).theta) > 10
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
        selectLines(index) = lines(k);
        index = index + 1;
   end
end
% highlight the longest line segment
%angleImg = abs(selectLines(2).theta - selectLines(1).theta);
%angleImg = angleImg/2 + min(selectLines.theta);
%rotI = imrotate(I,angleImg ,'crop');
%imshow(rotI);
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
