function [ Ac ] = backgroundfilter( A )
%récupère la colonne moyenne, la soustrait à l'image d'entrée

meanColumn = mean(A,2);
Ac = A;
for j=1:size(A,2)
    Ac(:,j) = A(:,j) - meanColumn;  
end
figure; imagesc(Ac); colormap(gray);

end

