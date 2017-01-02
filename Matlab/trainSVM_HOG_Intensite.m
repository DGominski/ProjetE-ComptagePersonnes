
for n = 1:Nref
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    data = double(imread(pietName));
    pietData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
    pietData2(n,:) = data(:);
    data = double(imread(fondName));
    fondData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
    fondData2(n,:) = data(:);
end

dataRef = [pietData;fondData];
dataRef2 = [pietData2;fondData2]';
classType = [ones(Nref,1);zeros(Nref,1)];
classType2 = [ones(Nref,1);zeros(Nref,1)];

%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');
svmStruct2 = svmtrain(dataRef2,classType2,'kernel_function','linear');
