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
for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    data = double(imread(pietName));
    pietData(n,:) = hog_feature_vector(data);
    data = double(imread(fondName));
    fondData(n,:) = hog_feature_vector(data);
end

dataRef = [pietData(1:Na,:);fondData(1:Na,:)];
dataTest = [pietData(Na+1:N,:);fondData(Na+1:N,:)];
classType = [ones(size(pietData(1:Na,:),1),1);zeros(size(fondData(1:Na,:),1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','quadratic');



%% Test avec images selectionnees
figure;
indexAlea = ceil(rand(40,1)*40);
repSetAlea = svmclassify(svmStruct,dataRef(indexAlea,:));
stem(indexAlea,repSetAlea);


%% Load data img

addpath('src');

imgName = ['detection_',num2str(200,'%0.4d'),'.jpeg'];
img = rgb2gray(imread(imgName));

wL = 100;
wH = 40;
dec = 1;
imgDecoupe = decoupe(img,wL,wH,dec);



for i = 1:size(imgDecoupe,3)
    i
    hogData = hog_feature_vector(double(imgDecoupe(:,:,i)));
    rep(i) = svmclassify(svmStruct,hogData);

    close
end

%%

posPieton = vec2mat(rep,(640-100)/dec);

subplot(1,2,1);imagesc(img);colormap(gray);axis equal
subplot(1,2,2);imagesc(posPieton);colormap(gray);axis equal