# GNEP

## GNEP_QL
Solve a Generalized Nash Equilibrium Problem (GNEP) with quasi-linear constraints.
(This code was used to solve examples in https://arxiv.org/abs/2405.03926)

The quasi-linear constraint is given by A(i)x(i) >= b(x(-i)),
where it is linear in x(i) but may be nonlinear in x(-i).

This function requires GloptiPoly, Yalmip, and Mosek to be properly installed.

[INPUT]

- n: A vector where the ith element corresponds to the dimensions of x(i).
  
- F: A vector where the ith element corresponds to the ith player's objective.
  
- A: A cell array where the ith cell corresponds to A(i).
  
- b: A cell array where the ith cell corresponds to b(x(-i)).

[OUTPUT]

RESULT is a struct array with six fields. RESULT(j) contains results extracted from K_J for some J in P.

- J: The index J for K_J.
  
- number_of_GNE: The number of Generalized Nash Equilibria (GNE) in K_J.
  
- GNE: A matrix storing all GNEs in K_J. If there are no GNEs in K_J, this field is empty.
  
- KKT: A matrix storing all Karush-Kuhn-Tucker (KKT) points in K_J. If there are no KKT points in K_J, this field is empty.
  
- timeforJ: The computational time for K_J.
  
- time: The accumulated time since executing GNEP_QL.

[Option]

To get results for a specific K_J, use:

   RESULT = GNEP_QL(n,F,A,b,J)
   
Here, J is a cell array where J{i} indicates the working constraints for the ith player.

Note that |J{i}| = n(i) based on the construction.





J. Choi, May 19, 2024

