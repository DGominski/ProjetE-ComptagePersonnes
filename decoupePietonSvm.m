close all;
clear all;
clc;

% Decoupage de pieton pour la SVM
chemin = '/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/dataPietonRGB/';
cheminOut = '/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/dataSetPietonRGB/';
addpath('/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/img');
addpath(genpath('/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/Julien'));

%%

imgName = 'detection_0100.jpeg';
imgOutputName = 'fond_.jpeg';

xSize = 40;
ySize = 100;

for i = 1:60
    nbImg = round(rand()*500);
    imgName = ['detection_',num2str(nbImg,'%0.4d'),'.jpeg'];
    imgNameOut = ['fond_',num2str(i,'%0.4d'),'.jpeg'];
    img = imread(imgName);
    imagesc(img);

    [x,y] = ginput(1);

    imgOut = img(y-ySize/2:y-1+ySize/2,x-xSize/2:x-1+xSize/2,:);
    imwrite(imgOut,[chemin,imgNameOut],'jpeg');
end



%% Renommage

index = 1;
for i = 1:100
    imgNameTest = ['pieton_',num2str(i,'%0.4d'),'.jpeg'];
    imgNameOut = ['pieton_',num2str(index,'%0.4d'),'.jpeg'];
    if fopen([chemin,imgNameTest]) ~= -1
        img = imread([chemin,imgNameTest]);
        imwrite(img,[cheminOut,imgNameOut],'jpeg');
        index = index + 1;
    end
end