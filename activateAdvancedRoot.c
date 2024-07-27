#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
   setuid( 0 );
   system( "/var/mobile/Whited00r/bin/activateAdvanced" );

   return 0;
}
