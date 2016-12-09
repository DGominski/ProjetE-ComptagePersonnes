close all;
clear all;
clc;

addpath('dataPieton');
addpath('img');
addpath('hog_feature_vector');

%% 
N = 20;
for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    data = double(imread(pietName));
    pietData(n,:) = data(:);
    data = double(imread(fondName));
    fondData(n,:) = data(:);
end

dataRef = [pietData;fondData]';
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','quadratic');


%% Test avec vecteur d'apprentissage 
clear dataAlea
nb = 20;
indexAlea = ceil(rand(nb,1)*nb);
dataAlea = dataRef(:,indexAlea); 

rep = svmclassify(svmStruct,dataAlea');
stem(indexAlea,rep);


%% Load data img

addpath('src');

imgName = ['detection_',num2str(200,'%0.4d'),'.jpeg'];
img = rgb2gray(imread(imgName));

wL = 100;
wH = 40;
dec = 10;
imgDecoupe = decoupe(img,wL,wH,dec);



dataTest = double(imgDecoupe);


for i = 1:size(dataTest,3)
    i
    temp = dataTest(:,:,i);
    rep(i) = svmclassify(svmStruct,temp(:)');
    
    close
end

%%

posPieton = vec2mat(rep,(640-40)/10);

subplot(1,2,1);imagesc(img);colormap(gray);axis equal
subplot(1,2,2);imagesc(posPieton);colormap(gray);axis equal