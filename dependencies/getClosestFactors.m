function [a b] = getClosestFactors(number)
%http://stackoverflow.com/questions/28328437/is-there-a-way-to-find-the-2-whole-factors-of-an-int-that-are-closest-together
% Get closest factors:
% interesting for plotting subplots: always get a nice 

% Basically, you know that in any pair of factors, the lowest factor must be less than or equal 
% to the square root. So if you start at the integer equal to or less than the square root of your 
% input, and count down, the first factor you find will be the smaller of the pair of closest 
% factors. This terminates for all integers > 0 because you will eventually reach 1, which is 
% a factor of all other numbers.

testNum = floor(sqrt(number)); %square root of your number as an integer (you want to truncate, not round)
%Test if that value is a factor of your input; if so, your input divided by that number are your answer. 

if testNum*testNum == number
    a = testNum;
    b = testNum;
else
    a = testNum;
    b = ceil(number/testNum); 
    
end

