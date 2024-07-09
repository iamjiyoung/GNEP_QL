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

## Example

Here is code for Example 6.5 when $J =$ (\{1,4\}, \{3,6\}).
```bash
N = 2;
n = [2 2]; 
definevar

f(1) = x1(1)*x2(1)^3 + x1(2)*x2(2)^3 - x1(1)^2*x1(2)^2;
f(2) = x2(2)*x2'*x2 - 2*x1(2)*x2(1) - x1(1)*x1(2)*x2(2);

A{1} = [1     0
        0    -2
        3    -1
       -4     3
       -6    -5
        0    -5];

A{2} = [-2     0
        -4     4
        -2     7
        -1     4
        -3     4
         2     1];

B1 = [0     0     0
     -1    -1     0
     -2    -1    -1
     -3    -2    -3
     -1    -1    -2
      0     1    -1];

C1 = [0     0     0
      0     1     0
      0    -1     1
      0     0     0
      0     0     0
      1     0     0];

b{1} = B1*[1; x2] + C1*[x2(1)^2; x2(1)*x2(2); x2(2)^2];

B2 = [0    -1    -1
     -6     0    -1
      4    -3    -3
     -4     1    -3
      3     0    -1
     -1     0     0];

C2 = [1    -1     0
      0     1    -1
     -1     0     0
      0     1     0
     -1     0     0
      0     0     1];

b{2} = B2*[1; x1] + C2*[x1(1)^2; x1(1)*x1(2); x1(2)^2];

J{1} = [1 4]; J{2} = [3 6];

RESULT = GNEP_QL(n,f,A,b,J)
```

The following is the result.
```bash
RESULT = 

  struct with fields:

                J: {[1 4]  [3 6]}
    number_of_GNE: 1
              GNE: [4×1 double]
              KKT: [4×1 double]
         timeforJ: 3.5629
             time: 3.6315
```
