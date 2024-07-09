# GNEP_QL

This repository contains code for solving the Generalized Nash Equilibrium Problem (GNEP) with quasi-linear constraints, as described in [GNEP_QL](https://arxiv.org/abs/2405.03926) by Jiyoung Choi, Jiawang Nie, Xindong Tang, and Suhan Zhong.

The quasi-linear constraint is given by $A_i x_i \geq b_i(x_{-i})$, where it is linear in $x_i$ but may be nonlinear in $x_{-i}$. 
 
This function requires [GloptiPoly](https://homepages.laas.fr/henrion/software/gloptipoly3/), [YALMIP](https://yalmip.github.io/), and [MOSEK](https://www.mosek.com/).

## Input

- __n__ : A vector where the ith element corresponds to the dimensions of $x_i$.
  
- __F__ : A vector where the ith element corresponds to the ith player's objective.
  
- __A__ : A cell array where the ith cell corresponds to $A_i$.
  
- __b__ : A cell array where the ith cell corresponds to $b_i(x_{-i})$.

## Output

__RESULT__ is a struct array with six fields. __RESULT(j)__ contains results extracted from $\mathcal{K}_J$ for some $J$ in $\mathcal{P}$.

- __J__ : The index $J$ for $\mathcal{K}_J$.
  
- __number_of_GNE__ : The number of Generalized Nash Equilibria (GNE) in $\mathcal{K}_J$.
  
- __GNE__ : A matrix storing all GNEs in $\mathcal{K}_J$. If there are no GNEs in $\mathcal{K}_J$, this field is empty.
  
- __KKT__ : A matrix storing all Karush-Kuhn-Tucker (KKT) points in $\mathcal{K}_J$. If there are no KKT points in $\mathcal{K}_J$, this field is empty.
  
- __timeforJ__ : The computational time for $\mathcal{K}_J$.
  
- __time__: The accumulated time since executing __GNEP_QL__.

## Option

To get results for a specific $\mathcal{K}_J$, use:
```bash
 RESULT = GNEP_QL(n,F,A,b,J)
```
Here, J is a cell array where J{i} indicates the working constraints for the ith player. Note that |J{i}| = n(i) based on the construction.


