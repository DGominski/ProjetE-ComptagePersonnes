function [ streetAngle ] = getImgStreetAngle(img)

dataImg = rgb2gray(imread(img));

BW = edge(dataImg,'canny');

[H,theta,rho] = hough(BW);

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

x = theta(P(:,2));
y = rho(P(:,1));

% Paramètre pour avoir le trotoire gauche
line = houghlines(BW,theta,rho,P,'FillGap',10,'MinLength',170);

streetAngle = line.theta;

end

