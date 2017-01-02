%%
function [ array ] = decoupe_Berta( A,wL,wH,step)

[H,L] = size(A);
index = 1;
for n  = 1 : step : wH
    A1 = A(:,n:L);
    [H1,L1] = size(A1);
    if rem(H1,wH) ~=0 
        A1 = A1(1:H1 - rem(H1,wH),:);
    end
    if rem(L1,wL) ~=0 
        A1 = A1(:,1:L1 - rem(L1,wL));
    end 
    [H1 L1] = size(A1); 
       
    B = mat2cell(A1,repmat(wH,H1/wH,1),repmat(wL,L1/wL,1));
    
    for i = 1 : size(B,1)
        for j = 1 : size(B,2)
            array(:,:,index) = B{i,j};
%             decoupepos(1,index) = (index - 1)*;
%             decoupepos(2,index) = l;
            index = index + 1; 
        end
    end
       
end

for n  = 1 : step : wL
    A1 = A(n:H,:);
    [H1,L1] = size(A1);
    if rem(H1,wH) ~=0 
        A1 = A1(1:H1 - rem(H1,wH),:);
    end
    if rem(L1,wL) ~=0 
        A1 = A1(:,1:L1 - rem(L1,wL));
    end 
    [H1 L1] = size(A1); 
       
    B = mat2cell(A1,repmat(wH,H1/wH,1),repmat(wL,L1/wL,1));
    
    for i = 1 : size(B,1)
        for j = 1 : size(B,2)
            array(:,:,index) = B{i,j};
            index = index + 1; 
        end
    end
end
h1 = index
end

% %%
% function [ array, decoupepos ] = decoupe( A,wL,wH,step)
% %decoupe l'image en rectangles de nxm et renvoie un tableau contenant
% %toutes les images obtenues, decales de dec pixels a chaque fois
% [H L] = size(A);
% 
% index = 1;
% % array = zeros(H,L,(-1+floor((H-wH)/step))*(-1+floor((L-wL)/step));
% % decoupepos = zeros(2,(-1+floor((H-wH)/step))*(-1+floor((L-wL)/step));
% for h = 1:step:H-wH
%     for l=1:step:L-wL
%         array(:,:,index) = A(h:(h+wH-1),l:(l+wL-1));
%         index = index + 1;
%         decoupepos(1,index) = h;
%         decoupepos(2,index) = l;
%     end
% end
% h2 = index
% end

%%
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