function [L,N] = cleanlist( LL, NL )

if ( nargin == 2 ),
  N = NL;
  dokill = true;
else
  dokill = false;
end

L = LL;
n = length(L);
for i=n:-1:1,
  for j=1:length(L),
    if i ~= j,
      if strfind( L{j}, L{i} ),
	%fprintf( 'killing %s\n', L{i} );
	L(i) = [];
	if ( dokill )
	  N(i) = [];
	end
	break;
      end
    end
  end
end
