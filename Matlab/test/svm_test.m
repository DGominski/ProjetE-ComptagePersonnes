clear all; 
clc; 

folder = 'SVM'; 
dirImage = dir( folder ); 

numData = size(dirImage,1); 

M ={} ; 

%%
% baca data gambar

for i=1:numData
    nama = dirImage(i).name;  
    if regexp(nama, '(lion|tiger)-[0-9]{1,2}.jpg')
        B = cell(1,2); 
        if regexp(nama, 'lion-[0-9]{1,2}.jpg')
            B{1,1} = double(imread([folder, '/', nama]));
            B{1,2} = 1; 
        elseif regexp(nama, 'tiger-[0-9]{1,2}.jpg')
            B{1,1} = double(imread([folder, '/', nama]));
            B{1,2} = -1; 
        end
        M = cat(1,M,B); 
    end 
end
%%
% idStart = 1745;idStop = 1756;
% M ={} ; 
% for id=idStart:idStop
%     B = cell(1,2); 
%     fileToload = ['0000',num2str(id),'.jpg'];
%     img = double(imread(fileToload));
%     img = rgb2gray(img);
%     index = (id-idStart+1);
%     B{1,1} = img;
%     B{1,2} = 1;
%     M = cat(1,M,B);  
% end
%%
% konversi gambar untuk keperluan SVM
x = 480;
y = 640;
numDataTrain = size(M,1); 
class = zeros(numDataTrain,1);
arrayImage = zeros(numDataTrain, x * y);

for i=1:numDataTrain
    im = M{i,1} ;
    im = rgb2gray(im); 
    im = imresize(im, [x y]); 
    im = reshape(im', 1, x*y); 
    arrayImage(i,:) = im; 
    class(i) = M{i,2}; 
end

SVMStruct = svmtrain(arrayImage, class);

% test untuk lion
lionTest = double(imread('gambar 1/lion-test.jpg' )); 
lionTest = rgb2gray(lionTest); 
lionTest = imresize(lionTest, [x y]); 
lionTest = reshape(lionTest',1, x*y); 

result = svmclassify(SVMStruct, lionTest);  

result 



