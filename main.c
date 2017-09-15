#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"

char *formulasFile  =  "formulas.txt";

//TODO: implementar
void run_tests(){
obdd* res = obdd_apply_or(x1, x2);
obdd_print(res);
printf("eq1 == eq2 sat? : %s \n", is_sat(res->mgr, res->root_obdd) ? "yes" : "no");
printf("eq1 == eq2 taut? : %s \n", is_tautology(res->mgr, res->root_obdd) ? "yes" : "no");
}

int main (void){
	run_tests();
	int save_out = dup(1);
	remove(formulasFile);
	int pFile = open(formulasFile, O_RDWR|O_CREAT|O_APPEND, 0600);
	if (-1 == dup2(pFile, 1)) { perror("cannot redirect stdout"); return 255; }
	run_tests();
	fflush(stdout);
	close( pFile );
	dup2(save_out, 1);
	return 0;

}
