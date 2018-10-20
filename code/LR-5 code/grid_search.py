__author__ = 'Sebastien Levy'

import pandas as pd
import numpy as np
from metrics import ROC, naive_proba_ROC, severity_proba_ROC, feat_sel_ROC, inv_PR, scoring_ease_ROC
from grid_search_classifiers import get_params
from grid_search_func import perform_CV_grid_search, GridSearchConfig
from base_pipeline import base_pipeline

MODULE = 'm2'
EASE_SCORE = False
EASE_DIRECTORY = 'm3_ease_of_scoring.csv'
EASE_THRES = 4
METRIC = feat_sel_ROC
# scoring_ease_ROC
MISSING = ['B3_miss']
STORE = True
PRINT = True
PLOT = True
RECOMPUTE = False
STORE_DIR = 'fig/m2/m2 pure/'
RULE = 'se'
FEATURE_SET = []
    #['A2', 'A4', 'A8', 'B2', 'B7', 'B8', 'B9', 'male', 'B3_miss']
    #['A2', 'A4', 'A8', 'B2', 'B7', 'B8', 'B9', 'male', 'B3_miss']
'''
'NS - Gradient Boosting','ANOVA - Gradient Boosting', 'Tree - Gradient Boosting', 'Lasso - Gradient Boosting',
    '''
TO_DO = [
# 'Shrunken Centroids OCV', 'Shrunken Centroids UCV', 
'Relaxed Lasso', 
'L2 Logistic Regression', 'L1 Logistic Regression', 'Linear Regression', 'Ridge',
# 'NS - Polynomial SVM', 'ANOVA - Polynomial SVM',  'Lasso - Polynomial SVM'
'NS - Radial SVM', 'ANOVA - Radial SVM',  'Lasso - Radial SVM',
'NS - Exponential SVM', 'ANOVA - Exponential SVM',  'Lasso - Exponential SVM'
]
'''

    'Elastic Net', 'ANOVA - Radial SVM', 'ANOVA - AdaBoost',
    'SVM UCV',  'Lasso - Radial SVM'
    '''
NOT_TO_DO = [
    'Tree - SVM', 'ANOVA - SVM', 'ANOVA - AdaBoost',
    # 'Shrunken Centroids OCV', 'Shrunken Centroids UCV', 'Relaxed Lasso',
    'ANOVA - Radial SVM', 'Lasso - Radial SVM', 'Tree - Radial SVM'
]

CONFIG = GridSearchConfig(TO_DO, NOT_TO_DO, PRINT, PLOT, STORE, STORE_DIR, RECOMPUTE)

if EASE_SCORE:
    cvp_set, ncv_set, ease_score = base_pipeline(MODULE, FEATURE_SET, get_feature_ease=True, ease_file=EASE_DIRECTORY,
                                                 ease_thres=EASE_THRES)
    if METRIC == scoring_ease_ROC:
        METRIC = lambda e, x, y: scoring_ease_ROC(e, x, y, feat_ease=ease_score)
else:
    ease_score = None
    cvp_set, ncv_set = base_pipeline(MODULE, FEATURE_SET)

cvp_set.printLabelCount()

param_classifier = get_params(ncv_set, cvp_set, ease_score=ease_score)


perform_CV_grid_search(param_classifier, METRIC, CONFIG, missing=MISSING, rule=RULE)



