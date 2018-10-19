__author__ = 'Sebastien Levy'

from sklearn import metrics

def ROC(e,x,y, func_result= lambda x:x):
    y = [int(v!=0) for v in y]
    y_pred = e.predict(x)
    return metrics.roc_auc_score(y, func_result(y_pred))

def naive_proba_ROC(e, x, y, func_result= lambda x:x):
    y = [int(v != 0) for v in y]
    y_probs = e.predict_proba(x)
    if y_probs.shape[1] == 1:
        return metrics.roc_auc_score(y, func_result(y_probs))
    return metrics.roc_auc_score(y, func_result(y_probs[:,1]))

def severity_proba_ROC(e, x, y, func=metrics.roc_auc_score, handle_reg=False, sev_weight=2, func_result= lambda x:x):
    y = [int(v != 0) for v in y]
    if handle_reg and hasattr(e, 'reg'):
        y_score = e.reg.predict(x)
    elif hasattr(e, 'severity') and e.severity and not hasattr(e, 'reg'):
        y_probs = e.predict_proba_sev(x)
        y_score = y_probs[:,1] + sev_weight*y_probs[:,2]
    else:
        if hasattr(e, 'predict_proba'):
            y_score = e.predict_proba(x)
        else:
            y_score = e.decision_function(x)
        if len(y_score.shape) > 1 and y_score.shape[1] == 2:
            y_score = y_score[:,1]
    return func(y, func_result(y_score))

def inv_PR(e, x, y, handle_reg=False, sev_weight=2):
    inv_y = [1-int(p != 0) for p in y]
    inv_func = lambda x: [1-p for p in x]
    return severity_proba_ROC(e, x, inv_y,
                              func_result=inv_func,
                              func=metrics.average_precision_score,
                              handle_reg=handle_reg, sev_weight=sev_weight)


def feat_sel_ROC(e, x, y, fs_ratio=0.1, handle_reg=False, sev_weight=2, func_ratio= lambda x:x, func_result= lambda x:x):
    score = severity_proba_ROC(e,x,y,handle_reg=handle_reg, sev_weight=sev_weight, func_result=func_result)
    if not hasattr(e, "coef_"):
        return score - fs_ratio
    n_feat = x.shape[1]
    if len(e.coef_.shape) == 2:
        coefs = e.coef_[0]
    else:
        coefs = e.coef_
    n_feat_used = len([i for i,x in enumerate(coefs) if x != 0])
    return score - fs_ratio * func_ratio(float(n_feat_used) / n_feat)

def scoring_ease_ROC(e, x, y, feat_ease=None, fs_ratio=0.1, handle_reg=False, sev_weight=2, func_ratio= lambda x:x, func_result= lambda x:x):
    if feat_ease is None:
        return feat_sel_ROC(e, x, y, fs_ratio=fs_ratio, handle_reg=handle_reg, sev_weight=sev_weight,
                            func_ratio=func_ratio, func_result=func_result)
    score = severity_proba_ROC(e, x, y, handle_reg=handle_reg, sev_weight=sev_weight, func_result=func_result)
    if not hasattr(e, "coef_"):
        return score - fs_ratio
    n_feat = x.shape[1]
    if len(e.coef_.shape) == 2:
        coefs = e.coef_[0]
    else:
        coefs = e.coef_
    scoring_ease = sum(feat_ease[i] for i,x in enumerate(coefs) if x != 0)
    return score - fs_ratio * func_ratio(float(scoring_ease) / sum(feat_ease))