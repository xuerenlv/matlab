
function output=fu_file(n)
if n==1,
    output=1;
    return;
end



output = n*fu_file(n-1);