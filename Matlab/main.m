clear all;
close all;
clc;

addpath('/img');

%% ACQUISITION DE L'IMAGE

img = imread('detection_0200.jpeg');
img = rgb2gray(img);

%% MOYENNAGE POUR ELIMINATION DE L'ARRIERE PLAN

% Ac = backgroundfilter(A);
% figure;
% histogram(Ac);

%% DECOUPAGE DE L'IMAGE
array = decoupe(img,50,80);
nombre_de_fenetres_testees = size(array,3)
figure;

%% EXTRACTION DE DESCRIPTEURS LOCAUX SUR LES BLOCS

horz = [-1 1; -1 1];
vert = [1 1 ; -1 -1];
diag = [1 -1 ; -1 1];

norm = size(array,1)*size(array,2);
for i=1:nombre_de_fenetres_testees
    horzarray(:,:,i) = filter2(horz,array(:,:,i));
    temp = histogram(horzarray,5);
    horzcount(:,i) = temp.Values/norm;
    vertarray(:,:,i) = filter2(vert,array(:,:,i));
    temp = histogram(vertarray,5);
    vertcount(:,i) = temp.Values/norm;
    diagarray(:,:,i) = filter2(diag,array(:,:,i));
    temp = histogram(diagarray,5);
    diagcount(:,i) = temp.Values/norm;
end



%% TRAINING SVM AVEC SET DE DONNEES DE REFERENCE


for i=1:10
    piet(:,:,i) = imread(['pieton_',num2str(i,'%2.2u'),'.jpeg']);
    fond(:,:,i) = imread(['fond_',num2str(i,'%2.2u'),'.jpeg']);
end

imgref = cat(3,piet,fond);
normref = size(piet,1)*size(piet,2);

for i=1:20
    refhorzarray(:,:,i) = filter2(horz,imgref(:,:,i));
    temp = histogram(refhorzarray,5);
    refhorzcount(:,i) = temp.Values/normref;
    refvertarray(:,:,i) = filter2(vert,imgref(:,:,i));
    temp = histogram(refvertarray,5);
    refvertcount(:,i) = temp.Values/normref;
    refdiagarray(:,:,i) = filter2(diag,imgref(:,:,i));
    temp = histogram(refdiagarray,5);
    refdiagcount(:,i) = temp.Values/normref;
end


refset = cat(1,refhorzcount,refvertcount,refdiagcount);
group = [zeros(1,10) ones(1,10)];
svmStruct = svmtrain(refset',group');

%% CLASSIFICATION

n = randn(1:20
set = cat(1,horzcount,vertcount,diagcount);
result = svmclassify(svmStruct',set');