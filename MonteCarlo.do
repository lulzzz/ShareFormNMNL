/* Monte Carlo */
/* We are going to do a monte carlo experiment */
/* for the NMNL */

/* Here, we have an example with three groups and one parameter */

	clear all
	set seed 5150
	set obs 10000
	set more off
	gen e = rnormal(0,1)
	mata: mid = (1::1000)#J(10,1,1)
	getmata mid

	bysort mid: gen pid = _n
	gen group = 1
	replace group = 2 if pid > 3 & pid < 7
	replace group = 3 if pid > 6 & pid < 10
	replace group = 0 if pid == 10

	bysort mid group: egen N = count(pid)

/* This sets up three groups with a null category. Group level constants */

    gen     mu = 0
	replace mu = -1 if group == 1
    replace mu = -2 if group == 2
	replace mu = -3 if group == 3
	
/* The last group is the null category, so this will normalize its utility */
/* to one (I think!) */

	replace e = 0 if group == 0
	
/* within-group parameter */
    
	scalar rho = .5
	
/* Generating shares and utilities */
    
	gen eui = exp((mu+e)/(1-rho))
	bysort mid group: egen totaleui = total(eui)
	bysort mid group: gen lg = _n == _N
	gen swg = eui/totaleui
	
	replace totaleui = totaleui^(1 - rho)
	
	bysort mid: egen sumoverg = total(lg*totaleui)
	
/* We are now done with the null group, so we can drop it */

   drop if group == 0
   
/* Group shares */

    gen sg    = totaleui / sumoverg
	gen share = swg*sg
	
/* Now, let's see what we can get with a maximum likelihood routine */
/* Or how about a regression? */

    bysort mid: egen ts = total(share)
	gen s0 = 1- ts
	
	gen lns = ln(share) - ln(s0)
	gen lnswg = ln(swg)
	
	gen g2 = group == 2
	gen g3 = group == 3
	
	reg lns lnswg g2 g3
	
/* Maximum likelihood */

capture program drop mlfunbase
program mlfunbase
    version 14.1
    args lnf mu rho sigma
	quietly replace `lnf' = -($ML_y1 - `mu' - `rho'*$ML_y2)^2/(2*`sigma') - 1/2*ln(`sigma')  
	quietly replace `lnf' = `lnf' - ($ML_y3 - 1)*ln(1-`rho') if $ML_y4 == 1
end
	
ml model lf mlfunbase (mu: lns lnswg N lg = g2 g3) (rho:) (sigma:)
ml maximize
	
/* Above doesn't work...the rho parameter wanders off - unstable! */

/* Let's now introduce the above where we use a different version of the parms */


   
	
	
	
	
	
	
	
	
	
