__author__ = 'Sebastien Levy'

from sklearn import grid_search
import matplotlib.pyplot as plt
import numpy as np
from math import sqrt
from os import listdir, makedirs

def perform_CV_grid_search(param_classifier, metric, config, missing=[], rule='best'):
    i=0
    for name, (params, classifier, cv_set, sparse, param_se) in param_classifier.items():

        # If the classifier need no to find best classifier (already computed or in config) we pass
        if not config.do(name):
            continue

        print('Grid Search for {}:'.format(name))

        # We perform the grid search on the data without refitting
        gs = grid_search.GridSearchCV(classifier, params, cv=cv_set, scoring=metric, refit=False)
        gs.fit(cv_set.cv_feat, cv_set.matrix_labels)

        # Given the rule we either take the best set of parameters or the most parsimonious within one standard error
        if rule == 'se':
            best_params, best_score = one_se_rule(gs, param_se, params[param_se])
        else:
            best_params = gs.best_params_
            best_score = gs.best_score_

        # We fit the chosen model and use custom cross validation result
        classifier.set_params(**best_params)
        res = cv_set.perform_CV(classifier, important_missing=missing, sparse=sparse)

        # According to configuration, we handle the result
        config.handle_result(res, sparse, name, cv_set.columns, i, len(param_classifier),
                             'Grid Search Score {} \n with {} \n'.format(best_score, best_params))

        i+= 1

    if config.plot:
        plt.show()

def update_CV_grid_search(param_classifier, best_params, config, missing=[]):
    i=0
    for name, (params, classifier, cv_set, sparse, param_se) in param_classifier.items():

        # If the classifier need not to find best classifier (already computed or in config) we pass
        if not config.do(name):
            continue

        if not name in list(best_params.keys()):
            continue

        # We fit the chosen model and use custom cross validation result
        print('Fit for {}'.format(name))
        classifier.set_params(**best_params[name])
        res = cv_set.perform_CV(classifier, important_missing=missing, sparse=sparse)

        # According to configuration, we handle the result
        config.handle_result(res, sparse, name, cv_set.columns, i, len(param_classifier), '')

        i+= 1

    if config.plot:
        plt.show()


def one_se_rule(gs_object, param_name, param_list):

    opt_params = gs_object.best_params_
    opt_res = find_results(gs_object.grid_scores_, opt_params)

    thres = opt_res.mean_validation_score
    se = np.std(opt_res.cv_validation_scores)/sqrt(len(opt_res.cv_validation_scores))
    thres -= se

    for param in param_list:
        if param == opt_params[param_name]:
            return opt_params, opt_res.mean_validation_score

        new_params = opt_params.copy()
        new_params[param_name] = param
        new_res = find_results(gs_object.grid_scores_, new_params)

        if new_res.mean_validation_score >= thres:
            return new_params, new_res.mean_validation_score

    return 'error'

def find_results(gs_scores, params):
    for res in gs_scores:
        if res.parameters == params:
            return res
    return 'ERROR'

class GridSearchConfig(object):
    def __init__(self, to_do, not_to_do, to_print, plot, store, store_dir, recompute=False, just_fig=False):
        self.to_do = to_do
        self.not_to_do = not_to_do
        self.to_print = to_print
        self.plot = plot
        self.store = store
        self.store_dir = store_dir
        self.recompute = recompute
        self.just_fig = just_fig

    def do(self, name):
        if self.to_do == [] and name in self.not_to_do:
            return False
        if self.to_do != [] and name not in self.to_do:
            return False
        if self.store and not self.recompute and (name in listdir(self.store_dir) and not self.just_fig):
            return False
        return True

    def handle_result(self, result, show_features, name, column_names, i, n, to_store):
        file_name = self.store_dir+name+'/'+'_'.join([s.lower() for s in name.split() if s != '-'])
        if not self.recompute and not self.just_fig and self.store:
            makedirs(self.store_dir+name)
        if self.to_print:
            print(to_store)
            print(result)
        if self.plot:
            result.plot_ROC(i=6*i, name=name, store=self.store, store_file=file_name+'_roc.png')
            result.plot_PR(i=6*i+1, name=name, store=self.store, store_file=file_name+'_pr.png')
            result.plot_invPR(i=6*i+4, name=name, store=self.store, store_file=file_name+'_inv_pr.png')
            result.plot_sev_probas(i=6*i+2, name=name, store=self.store, store_file=file_name+'_sev.png')
            result.plot_miss_probas(i=6*i+3, name=name, store=self.store, store_file=file_name+'_miss.png')
            result.hist_probas(i=6*i+5, name=name, store=self.store, store_file=file_name+'_hist.png')
        if self.store:
            to_store += result.__repr__()
        if show_features:
            if self.to_print:
                print(result.getFeatures())
            if self.plot:
                result.plot_features(column_names, i=6*n+i, name=name, store=self.store,
                                     store_file=file_name+'_feat.png')
            if self.store:
                to_store += '\n'+str(result.getFeatures())
        if not self.just_fig and self.store:
            with  open(file_name+'_summary.txt', 'w') as reader:
                reader.write(to_store)
            reader.close()
        if self.to_print:
            print('\n')

