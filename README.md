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

Here is code for Example 6.2 when $J =$ (\{2,5,7,8\}, \{1,4,5,7\}).
```bash
N = 2;
n = [4 4]; 
definevar

f(1) = (x1(1)-1)^2 + x2(4)*(x1(2)-1)^2 + (x1(3)-1)^2 + (x1(4)-2)^2 + (sum(x2)-1)*sum(x1);
f(2) = x1(1)*x2(1)^2 - x2(2) + x1(3)*(x2(3)-1)^2 + x1(4)*(x2(4)+1)^2;

A{1} = [eye(4);-eye(4); 0 0 0 -1];

b{1} = [0; 0; 0; 0; -x2; -x2(3)*(x2(3)-1)*(x2(3)-3)];

A{2} = [1 -1  0  0
       -1  1  0  0
        1  1  0  0
       -1 -1  0  0
        0  0  1  0
        0  0  0 -3
        0  0 -1 -1];

b{2} = [x1(2); -2*x1(1); -x1(1)-x1(2); 2*x1(2)-4*x1(1); 0; -x1(3)*(3*x1(3)-1)*(x1(3)-1); -3];

J{1} = [2 5 7 8]; J{2} = [1 4 5 7];

RESULT = GNEP_QL(n,f,A,b,J)
```

The following is the result.
```bash
RESULT = 

  struct with fields:

                J: {[2 5 7 8]  [1 4 5 7]}
    number_of_GNE: 5
              GNE: [8×5 double]
              KKT: [8×5 double]
         timeforJ: 65.6378
             time: 65.6816
```

To get GNEs, type __RESULT.GNE__.
```bash
>> RESULT.GNE

ans =

    0.7071    0.5000    0.0000    0.3333    0.0000
    0.0000    0.0000    0.0000    0.0000    0.0000
    0.0000    0.0000    1.0000    0.3333    0.0000
   -0.0000   -0.0000   -0.0000   -0.0000   -0.0000
    0.7071    1.0000    0.0000    0.6667    0.0000
    0.7071    1.0000    0.0000    0.6667    0.0000
    0.0000    0.0000    1.0000    1.0000    3.0000
   -0.0000   -0.0000   -0.0000   -0.0000   -0.0000
```
