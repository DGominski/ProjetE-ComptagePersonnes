close all;
clear all;
clc;

addpath('dataSetPietonRGB');
addpath('dataSetFondRGB');
addpath('src');
addpath('img');
addpath('data');
addpath('dataDetect');
cheminOut = 'D:\Documents\INSA LYON\2016-2017\Mini-projet-TDSI-Git\ProjetE-ComptagePersonnes\dataDetect\';


%% 
N = 36;
for n = 1:N
    pietName = ['pieton_',num2str(n,'%0.4d'),'.jpeg'];
%     fondName = ['fond_',num2str(n,'%0.4d'),'.jpeg'];

    data = imread(pietName);   
    pietData(n,:) =  reshape(data(:,:,:),1,[]);
    
%     data = double(imread(fondName));
%     fondData(n,:) = reshape(data(:,:,:),1,[]);
    
    % Test d'affichage
    % imagesc(squeeze(pietData(1,:,:,:)))
end

N = 2500;
index = 1;
for n = 1:N
    fondName = ['fond_',num2str(n,'%0.4d'),'.jpeg'];
    
    if exist(fondName,'file') == 2
        data = imread(fondName);
        fondData(index,:) = reshape(data(:,:,:),1,[]);
        index = index + 1;
    end

end

dataRef = [pietData;fondData];
classType = [ones(size(pietData,1),1);zeros(size(fondData,1),1)];


%% Apprentissage

svmStruct = svmtrain(double(dataRef),classType,'kernel_function','linear');

% Attention utilisé un noyau de classification linéaire et non quadratic
% pour la classification en RGB


%% Test avec vecteur d'apprentissage 
clear dataAlea
nb = 1000;
indexAlea = ceil(rand(nb,1)*nb);
dataAlea = dataRef(indexAlea,:); 

rep = svmclassify(svmStruct,double(dataAlea));
stem(indexAlea,rep);
close all;


%% Load data img

addpath('src');

imgName = ['detection_',num2str(150,'%0.4d'),'.jpeg'];
img = imread(imgName);

wL = 100;
wH = 40;
dec = 10;
vectImgDecoupe = decoupeVectRGB(img,wL,wH,dec);

% 2376 = (480-40)*(640-100)/100

%%
load('vectImgDecoupe.mat');

% ATTENTION AU CHEMIN
rep = svmclassify(svmStruct,double(vectImgDecoupe));


%%

posPieton = reshape(rep,[38,60]);

subplot(1,2,1);imagesc(img);axis equal
subplot(1,2,2);imagesc(posPieton);colormap(gray);axis equal