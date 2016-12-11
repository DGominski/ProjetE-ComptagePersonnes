close all;
clear all;
clc;

addpath('dataPieton');
addpath('img');
addpath('hog_feature_vector');



%% 
N = 20;
Na = 20;
Ntest = N-Na;

HOG_cell = [8 8];

for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    data = double(imread(pietName));
    %pietData(n,:) = hog_feature_vector(data);
    pietData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
    data = double(imread(fondName));
    %fondData(n,:) = hog_feature_vector(data);
    fondData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
end

dataRef = [pietData(1:Na,:);fondData(1:Na,:)];
dataTest = [pietData(Na+1:N,:);fondData(Na+1:N,:)];
classType = [ones(size(pietData(1:Na,:),1),1);zeros(size(fondData(1:Na,:),1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');



%% Test avec images selectionnees
figure;
indexAlea = ceil(rand(40,1)*40);
repSetAlea = svmclassify(svmStruct,dataRef(indexAlea,:));
stem(indexAlea,repSetAlea);


%% Load data img

addpath('src');

imgName = ['detection_',num2str(200,'%0.4d'),'.jpeg'];
img = rgb2gray(imread(imgName));

wL = 40;
wH = 100;
dec = 10;
imgDecoupe = decoupe(img,wL,wH,dec);

chemin = 'D:\Documents\INSA LYON\2016-2017\Mini-projet-TDSI-Git\ProjetE-ComptagePersonnes\test\';

for i = 1:size(imgDecoupe,3)
    i
    %hogData = hog_feature_vector(double(imgDecoupe(:,:,i)));
    %imwrite(imgDecoupe(:,:,i),[chemin,'img_',num2str(i,'%0.6d'),'.jpeg']);
    hogData = extractHOGFeatures(double(imgDecoupe(:,:,i)),'CellSize',HOG_cell);
    rep(i) = svmclassify(svmStruct,hogData);
    if rep(i) == 1
        imwrite(imgDecoupe(:,:,i),[chemin,'img_',num2str(i,'%0.6d'),'.jpeg']);
    end

    close
end

%%

posPieton = vec2mat(rep,(640-40)/dec);

subplot(1,2,1);imagesc(img);colormap(gray);axis equal
subplot(1,2,2);imagesc(posPieton);colormap(gray);axis equal

%%
%subplot(1,2,1);imagesc(imread('pieton_01.jpeg'));colormap(gray);
%subplot(1,2,2);[a,b] = extractHOGFeatures(imread('pieton_01.jpeg'),'CellSize',[3 3]);plot(b);
