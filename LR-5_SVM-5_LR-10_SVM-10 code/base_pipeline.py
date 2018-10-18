__author__ = 'Sebastien Levy'

from cross_validation import CVP_Set
from processing import ADOS_Data, get_ease_score

def base_pipeline(module, features_set, get_feature_ease=False, ease_file=None, scale_with_ease=False, ease_thres=None):
    N_FOLD = 10
    PRED_RATIO = 0.2
    SCALING_PARAM = 4
    EASE_THRES = 8
    # Binary or Replacement
    MISSING_VALUE_STRATEGY = 'Binary'
    # poly, linear, indicator, interaction_ind, pca_comp
    PROCESSING_STRATEGY = 'linear'

    POLY_DEGREE = 2
    NORMALIZE = True

    ADOS_FILE = module+"/data/ados_"+module+"_allData.csv"
    label_id = "ASD"
    label_age = "age_months"
    label_gender = "male"
    columns_to_delete = ["Subject.Id", "Diagnosis"]
    sub_diagnosis_id = ["social_affect_calc","restricted_repetitive_calc","SA_RRI_total_calc","severity_calc"]

    # We import the data
    data = ADOS_Data.read_csv(ADOS_FILE)
    sub_diagnosis = data[sub_diagnosis_id]

    # We drop the columns that are not interesting for us, and the row with no label
    data.select_good_columns(columns_to_delete+sub_diagnosis_id)


    data.full_preprocessing(NORMALIZE, MISSING_VALUE_STRATEGY, PROCESSING_STRATEGY, label_age, label_gender, label_id)
    if features_set != []:
        data.select_good_columns(features_set, keep_the_column=True)

    if get_feature_ease:
        ease_score, bad_cols = get_ease_score(ease_file, data.columns, thres=ease_thres)
        print(bad_cols)
        data.select_good_columns(bad_cols)
        print(data.columns)
        if scale_with_ease:
            data.scale(ease_score)


    # We create the Cross-Validation + Prediction error sets (undersampling (cvp) and normal unbalanced sets (ncv))
    cvp_set = CVP_Set(data, data.labels, N_FOLD, PRED_RATIO)
    cvp_set.undersampling_cv_set(ratio=1, sampling_type="random")
    ncv_set = CVP_Set(data, data.labels, N_FOLD, PRED_RATIO)

    if get_feature_ease:
        return cvp_set, ncv_set, ease_score


    return cvp_set, ncv_set
