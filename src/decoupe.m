function [ array ] = decoupe( A,n,m )
%decoupe l'image en rectangles de nxm et renvoie un tableau contenant
%toutes les images obtenues, decales de 1 pixel a chaque fois
[k l] = size(A);
array = zeros(n,m,k-n+l-m);
for i=1:k-n
    for j=1:l-m
        array(:,:,i+j) = A(i:n+i-1,j:m+j-1);
    end
end

    end