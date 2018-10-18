__author__ = 'Sebastien Levy'

import abc
import numpy as np
from sklearn.linear_model import Lasso


class Selection(object, metaclass=abc.ABCMeta):
    def __init__(self):
        pass

    @abc.abstractmethod
    def fit_transform(self, x, y):
        return

    @abc.abstractmethod
    def transform(self, x):
        return

    @abc.abstractmethod
    def get_params(self, **kwargs):
        return

    @abc.abstractmethod
    def inverse_transform(self, x_red):
        return

    def set_params(self, **parameters):
        for parameter, value in list(parameters.items()):
            setattr(self, parameter, value)
        return self

class NoSelection(Selection):
    def __init__(self):
        return

    def fit_transform(self, x, y):
        self.n_feat = x.shape[1]
        return x

    def transform(self, x):
        return x

    def inverse_transform(self, x_red):
        return x_red

    def get_params(self, **kwargs):
        return {}


class ByNonZeroSelection(Selection):
    def __init__(self):
        pass

    @abc.abstractmethod
    def get_non_zero(self, x, y):
        return

    def fit_transform(self, x, y):
        self.n_feat = x.shape[1]
        self.non_zero = self.get_non_zero(x,y)
        if len(self.non_zero) == 0:
            return np.ones((len(y),1))
        else:
            return x[:,self.non_zero]

    def transform(self, x):
        if self.n_feat != x.shape[1]:
            return x
        if not hasattr(self, 'non_zero') or len(self.non_zero)==0:
            return np.ones((x.shape[0],1))
        return x[:,self.non_zero]

    @abc.abstractmethod
    def get_params(self, **kwargs):
        return

    def inverse_transform(self, x_red):
        if len(x_red.shape) == 2:
            x_red = x_red[0]
        x = np.zeros(self.n_feat)
        for i, idx in enumerate(self.non_zero):
            x[idx] = x_red[i]
        return x

class LassoSelection(ByNonZeroSelection):
    def __init__(self, alpha=1):
        self.alpha = alpha
        self.classifier = Lasso(alpha=alpha)
        self.n_feat = 0
        self.non_zero = []

    def get_non_zero(self, x, y):
        self.classifier.fit(x,y)
        return [idx for idx, coef in enumerate(self.classifier.coef_) if coef != 0]

    def get_params(self, **kwargs):
        params = {}
        params['alpha'] = self.alpha
        return params

    def set_params(self, **parameters):
        for parameter, value in list(parameters.items()):
            if parameter == 'alpha':
                self.classifier.set_params(**{'alpha': value})
            setattr(self, parameter, value)
        return self

class TreeSelection(ByNonZeroSelection):
    def __init__(self, tree, type='thres', thres=None, k=None, ease_score=None):
        self.tree = tree
        self.n_feat = 0
        self.type = type
        self.thres = thres
        self.k = k
        self.non_zero = []
        self.ease_score = ease_score

    def get_non_zero(self, x, y):
        self.tree.fit(x,y)
        score = self.tree.feature_importances_
        if self.ease_score is not None:
            score = [imp / ease for (imp, ease) in zip(self.tree.feature_importances_, self.ease_score)]

        if self.type == 'thres':
            if self.thres is not None:
                m = self.thres
            else:
                m = np.mean(score)
            return [idx for idx, coef in enumerate(score) if coef >= m]
        if self.type == 'best' and self.k is not None:
            return np.argpartition(score, -self.k)[-self.k:]

        return list(range(x.shape[1]))

    def get_params(self, **kwargs):
        params = {}
        params['tree'] = self.tree
        return params

    def set_params(self, **parameters):
        del_keys = []
        for key in parameters.keys():
            if 'tree__' in key:
                param = '__'.join(key.split('__')[1:])
                self.tree.set_params(**{param: parameters[key]})
                del_keys.append(key)
        for key in del_keys:
            del parameters[key]
        super(ByNonZeroSelection, self).set_params(**parameters)