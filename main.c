#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"

char *formulasFile  =  "formulas.txt";

//TODO: implementar
void run_tests(){
	obdd_mgr* mgr	= obdd_mgr_create();

	obdd* x1_obdd		= obdd_mgr_var(mgr, "x1");
	obdd* x2_obdd		= obdd_mgr_var(mgr, "x2");

obdd* res1 = obdd_apply_or(x1_obdd, x2_obdd);

obdd* res2 = obdd_apply_and(x1_obdd, x2_obdd);

obdd* res3 = obdd_apply_and(x1_obdd, obdd_apply_not(x2_obdd));

obdd* tmp14 = obdd_apply_and(x1_obdd, x2_obdd);
obdd* res4 = obdd_apply_or(obdd_apply_not(tmp14), x1_obdd);

obdd* tmp15 =  obdd_apply_equals(x2_obdd, res3);
char* var = dictionary_key_for_value(mgr->vars_dict, x2_obdd->root_obdd->var_ID);
obdd* res5 = obdd_exists(tmp15, var);

printf("\n-Parte 1:\n");
obdd_print(res1);
printf("x1 || x2 sat? : %s \n", is_sat(res1->mgr, res1->root_obdd) ? "yes" : "no");
printf("x1 || x2 taut? : %s \n", is_tautology(res1->mgr, res1->root_obdd) ? "yes" : "no");


printf("\n-Parte 2:\n");
obdd_print(res2);
printf("x1 && x2  sat? : %s \n", is_sat(res2->mgr, res2->root_obdd) ? "yes" : "no");
printf("x1 && x2  taut? : %s \n", is_tautology(res2->mgr, res2->root_obdd) ? "yes" : "no");

printf("\n-Parte 3:\n");
obdd_print(res3);
printf("x1 && !x2 sat? : %s \n", is_sat(res3->mgr, res3->root_obdd) ? "yes" : "no");
printf("x1 && !x2 taut? : %s \n", is_tautology(res3->mgr, res3->root_obdd) ? "yes" : "no");

printf("\n-Parte 4:\n");
obdd_print(res4);
printf("(x1 && x2) -> x1 sat? : %s \n", is_sat(res4->mgr, res4->root_obdd) ? "yes" : "no");
printf("(x1 && x2) -> x1 taut? : %s \n", is_tautology(res4->mgr, res4->root_obdd) ? "yes" : "no");

printf("\n-Parte 5:\n");
obdd_print(res5);
printf("Exists x2.(x2 =(x1 && !x1)) sat? : %s \n", is_sat(res5->mgr, res5->root_obdd) ? "yes" : "no");
printf("Exists x2.(x2 =(x1 && !x1)) taut? : %s \n", is_tautology(res5->mgr, res5->root_obdd) ? "yes" : "no");

obdd_destroy(x1_obdd);
obdd_destroy(x2_obdd);
obdd_destroy(res1);
obdd_destroy(res2);
obdd_destroy(res3);
obdd_destroy(res4);
obdd_destroy(res5);
obdd_destroy(tmp15);
obdd_destroy(tmp14);
obdd_mgr_destroy(mgr);
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
