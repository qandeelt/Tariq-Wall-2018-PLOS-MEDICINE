__author__ = 'Sebastien Levy'

import numpy as np
from math import cos, pi

def cosine_kernel(x,y):
    n = np.linalg.norm(x-y)
    if n > 1 :
        return 0
    return cos(pi/2*n*n)

def scaled_kernel(x,y):
    if np.linalg.norm(x) == 0 or np.linalg.norm(y) == 0:
        return 0
    return np.dot(x,y.T)/(np.linalg.norm(x)*np.linalg.norm(y))
