%{
#include <stdio.h>

%}
 /* Identifier definitions go here such as */

integer 0|-?[1-9][0-9]*
double [0-9]+[.][0-9]+

%%
{integer} {return INT;}
%%
 /* custom main definition goes here though it is not needed */
