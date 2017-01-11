close all;
clear all;
clc;

addpath('dataSetPietonRGB');
addpath('dataSetFondRGB');
addpath('src');
addpath('img');

%% 
N = 36;
for n = 1:N
    
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.4d'),'.jpeg'];

    data = double(imread(pietName));   
    pietData(n,:) =  reshape(data(:,:,:),1,[]);
    
    data = double(imread(fondName));
    fondData(n,:) = reshape(data(:,:,:),1,[]);
    
    % Test d'affichage
    % imagesc(squeeze(pietData(1,:,:,:)))
end

dataRef = [pietData;fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');

% Attention utilisé un noyau de classification linéaire et non quadratic
% pour la classification en RGB



%% Test avec vecteur d'apprentissage 
clear dataAlea
nb = 72;
indexAlea = ceil(rand(nb,1)*nb);
dataAlea = dataRef(indexAlea,:); 

rep = svmclassify(svmStruct,dataAlea);
stem(indexAlea,rep);
close all;


%% Load data img

addpath('src');

imgName = ['detection_',num2str(200,'%0.4d'),'.jpeg'];
img = double(imread(imgName));

wL = 100;
wH = 40;
dec = 10;
vectImgDecoupe = decoupeVectRGB(img,wL,wH,dec);

% 2376 = (480-40)*(640-100)/100

%%

addpath('data');
load('vectImgDecoupe.mat');
addpath('dataDetect');
cheminOut = '/home/jguichon/Documents/min_projet_git/ProjetE-ComptagePersonnes/dataDetect/';

for i = 1:size(vectImgDecoupe,1)
    i
    rep(i) = svmclassify(svmStruct,vectImgDecoupe(i,:));
    if rep(i) == 1
        imgNameOut = ['det_',num2str(i,'%0.4d'),'.jpeg'];
        imwrite(reshape(vectImgDecoupe(i,:),[100,40,3]),[cheminOut,imgNameOut],'jpeg');
    end
    close
end

%%

posPieton = vec2mat(rep,(640-40)/10);

subplot(1,2,1);imagesc(img);colormap(gray);axis equal
subplot(1,2,2);imagesc(posPieton);colormap(gray);axis equal