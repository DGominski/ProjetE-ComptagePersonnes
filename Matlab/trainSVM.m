
for n = 1:Nref
    pietName = ['pieton_',num2str(n,'%0.2d'),'.jpeg'];
    fondName = ['fond_',num2str(n,'%0.2d'),'.jpeg'];

    data = double(imread(pietName));
    pietData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
    data = double(imread(fondName));
    fondData(n,:) = extractHOGFeatures(data,'CellSize',HOG_cell);
end

dataRef = [pietData(1:Nref,:);fondData(1:Nref,:)];
classType = [ones(size(pietData(1:Nref,:),1),1);zeros(size(fondData(1:Nref,:),1),1)];


%% Apprentissage

svmStruct = svmtrain(dataRef,classType,'kernel_function','linear');