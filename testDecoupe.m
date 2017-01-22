close all;
clear all;
clc;

addpath('img');

HOG_cell = [10 10];
Bins = 9;
imgName = ['detection_',num2str(0,'%0.4d'),'.jpeg'];
img = imread(imgName);


wH = 100;
wL = 40;

xRect = 100;
yRect = 200;
wRect = wL*10;
hRect = wH;

%imagesc(img);colormap(gray);
%rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');


%%
C = im2col(img(yRect+(1:hRect),xRect+(1:wRect)),[100 40]);
%subplot(1,2,1);imagesc(img);axis image;colormap(gray);
%rect = rectangle('Position',[xRect yRect wRect hRect],'EdgeColor','r');
for p = 1:size(C,2)
    divImg = vec2mat(C(:,p),100);
    data(p,:) = extractHOGFeatures(double(divImg),'CellSize',HOG_cell,'NumBins',Bins);
    %subplot(1,2,2);imagesc(ans');axis image;colormap(gray);
    %pause();
end
%extractHOGFeatures(double(img(yRect+(1:wH),w+(1:wL))),'CellSize',HOG_cell,'NumBins',Bins)