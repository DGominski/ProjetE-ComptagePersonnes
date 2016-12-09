function [ array ] = decoupe( A,wL,wH,step)
%decoupe l'image en rectangles de nxm et renvoie un tableau contenant
%toutes les images obtenues, decales de dec pixels a chaque fois
[H L] = size(A);

index = 1;
for l=1:step:L-wL
    for h = 1:step:H-wH
        array(:,:,index) = A(h:(h+wH-1),l:(l+wL-1));
        index = index + 1;
    end
end

end

% function [ array ] = decoupe( A,n,m )
% %decoupe l'image en rectangles de nxm et renvoie un tableau contenant
% %toutes les images obtenues, decales de dec pixels a chaque fois
% [k l] = size(A);
% array = zeros(n,m,k-n+l-m);
% index = 1;
% for i=1:k-n
%     for j=1:l-m
%         index = index + j;
%         array(:,:,index) = A(i:n+i-1,j:m+j-1);
%     end
% end
% 
% end