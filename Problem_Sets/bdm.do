#delimit ;

cap log close ;
log using bdm.log , replace ;

clear ;
set mem 10m ;

cap prog drop runme ;
prog def runme ;

/* note that `1' is the first argument and `2' is the second argument
"argument" means the number supplied when calling the program */
global numstates = `1' ;
global nummc = `2' ;


tempfile mcdata mc_results ;

forvalues i = 1/$nummc { ;   /* monte carlo loop */

/* make up a data set */
	/* the "law" = 1 for first half of states, and for years after
		a random year in the 1985-1995 range */
	local year_trigger = 7 + floor(uniform() * 11) ;
	drop _all ;
	cap erase `mcdata' ;
	forvalues s = 1/$numstates { ;
		local index = floor(uniform() * 50) + 1 ; /* pick a state at random */
		qui use bdm_loaded if staterank == `index' ;
		gen law = 1 * ( (`s' <= ($numstates/2)) & (year >= `year_trigger') ) ;
		gen new_stateid = `s' ;
		cap append using `mcdata' ;
		qui save `mcdata' , replace ;
	} ;


/* now estimate the model, and save the parameter estimates */
	qui tab new_stateid, gen(stdum) ;
	drop stdum1 ;

	qui regress w law i.year , vce(bootstrap , reps(50) cluster(new_stateid) trace ) ;
	local reject = abs(_b[law] / _se[law]) > 1.96 ;

	qui drop _all ;
	qui set obs 1 ;
	gen reject = `reject' ;
	cap append using `mc_results' ;
	qui save `mc_results' , replace ;
} ;

/* now look at the saved results */
qui drop _all ;
use `mc_results' ;
qui summ ;
local rej_rate = r(mean) ;
local n = r(N) ;
local rej_se = sqrt(`rej_rate' * (1 - `rej_rate') / `n') ;

display "N = $numstates" _column(10) "Num MC reps = `n'" _column(30) 
	"Rejection rate = " %5.3f `rej_rate' "  (" %5.3f `rej_se' ")" ;

end ;


/* the first number is the number of states, the second number is how many MC replications */
runme 20 1 ;
*runme 6 50 ;

log close ;
