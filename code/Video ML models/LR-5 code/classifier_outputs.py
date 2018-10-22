__author__ = 'Sebastien Levy'

from classifier_results import ClassifierResult
from grid_search_classifiers import get_params
from grid_search_func import GridSearchConfig, update_CV_grid_search
from base_pipeline import base_pipeline
from os import listdir

SUMMARY_NAME = 'summary'

MODULE = 'm3'
MISSING = ['B3_miss', 'D3_miss']
STORE = True
PRINT = False
PLOT = True
RECOMPUTE = False
STORE_DIR = 'fig/m3 ess nose/'
FEATURE_SET = ['A2', 'A4', 'A8', 'B2', 'B7', 'B8', 'D4', 'male', 'B3_miss', 'D3_miss']

TO_DO = ['Relaxed Lasso']

NOT_TO_DO = [
    'Shrunken Centroids OCV', 'Shrunken Centroids UCV', 'Relaxed Lasso',
    'ANOVA - Radial SVM', 'Lasso - Radial SVM', 'Tree - Radial SVM'
]

CONFIG = GridSearchConfig(TO_DO, NOT_TO_DO, PRINT, PLOT, STORE, STORE_DIR, recompute=RECOMPUTE, just_fig=True)

cvp_set, ncv_set = base_pipeline(MODULE, FEATURE_SET)

cvp_set.printLabelCount()

param_classifier = get_params(ncv_set, cvp_set)

ClassifierResult.init_param(STORE_DIR, SUMMARY_NAME)
best_params = {name: ClassifierResult(name).params for name in listdir(STORE_DIR) if '.png' not in name}

update_CV_grid_search(param_classifier, best_params, CONFIG, missing=MISSING)

