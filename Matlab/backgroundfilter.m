function [ Ac ] = backgroundfilter( A )


for j=1:size(A,3)
    Ac(:,:,j) = A(:,:,j) - A(:,:,1);
end

end

