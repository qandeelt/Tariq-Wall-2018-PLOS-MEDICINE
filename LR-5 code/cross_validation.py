__author__ = 'Sebastien Levy'
from sklearn import model_selection, cross_validation, metrics
from pandas import Series
from collections import Counter
from metrics import severity_proba_ROC
from math import sqrt
import numpy as np
import itertools
import matplotlib.pyplot as plt

class CVP_Set(object):
    def __init__(self, features, labels, n_fold, pred_ratio):
        self.cv_feat, self.pred_feat, self.cv_labels, self.pred_labels = model_selection.train_test_split(
            features, labels, test_size=pred_ratio, random_state=0)
        self.cv_set = cross_validation.StratifiedKFold(self.cv_labels, n_folds=n_fold)
        self.columns = self.cv_feat.columns
        self.cv_feat = self.cv_feat.as_matrix()
        self.matrix_labels = self.cv_labels.as_matrix()

    def __iter__(self):
        return self.cv_set.__iter__()

    def __len__(self):
        return self.cv_set.__len__()

    @staticmethod
    def get_sample_severity(train_sev_id, i, nb_undersampling, sampling_type):
        i_range = len(train_sev_id)/nb_undersampling
        if sampling_type == "uniform":
            if i == nb_undersampling:
                return train_sev_id[int((nb_undersampling-1)*i_range):]
            else:
                return train_sev_id[int(i_range*i):int(i_range*(i+1)-1)]
        if sampling_type == "random":
            return list(np.random.permutation(train_sev_id)[:int(i_range)])

    def undersampling_cv_set(self, ratio=1, sev_values=[1,2], sampling_type="random"):
        new_cv_set = []
        for train_id, test_id in self.cv_set:
            train_dis_id = []
            for sev in sev_values:
                train_dis_id.append([i for i in train_id if self.matrix_labels[i] == sev])
            train_control_id = [i for i in train_id if self.matrix_labels[i] == 0]
            dis_range = len(train_control_id)*ratio
            nb_undersampling = int(sum([len(dis_id) for dis_id in train_dis_id])/dis_range)
            for i in range(nb_undersampling):
                dis_list = [self.get_sample_severity(dis, i, nb_undersampling, sampling_type) for dis in train_dis_id]
                new_cv_set.append((list(itertools.chain.from_iterable(dis_list))+train_control_id, test_id))
        self.cv_set = new_cv_set

    def perform_CV(self, classifier, important_missing=[], sparse=True, make_plot=False, print_lda=False):
        res = ResultMetric(self.columns, sparse, make_plot=make_plot, important_missing=important_missing)
        for train_id, test_id in self.cv_set:
            classifier.fit(self.cv_feat[train_id],
                           self.matrix_labels[train_id])
            if print_lda:
                print(classifier.coef_)
                print(classifier.xbar_)
            if sparse:
                if len(classifier.coef_.shape) == 2:
                    coefs = classifier.coef_[0]
                else:
                    coefs = classifier.coef_
            else:
                coefs = None
            res.update(classifier, self.cv_feat[test_id],self.matrix_labels[test_id], coefs)
            if make_plot:
                res.plot_data_update(classifier.predict_severity(self.cv_feat[test_id]), self.matrix_labels[test_id])
        return res


    def printLabelCount(self):
        print('Cross validation set:')
        print(Series(self.cv_labels).value_counts())
        print(Series(self.pred_labels).value_counts())

class ResultMetric(object):
    class_style = {0: 'bs', 1: 'g^', 2: 'ro'}

    def __init__(self, columns, sparse=True, make_plot=False, important_missing=[]):
        self.TP = 0
        self.TN = 0
        self.FP = 0
        self.FN = 0
        self.AUC = 0
        self.n_sets = 0
        self.sparse = sparse
        self.n_feat = []
        self.ROC = []
        self.PR = []
        self.invPR = []
        self.sev_proba = [[],[],[]]
        self.columns = columns
        self.important_missing = important_missing
        if sparse:
            self.feat_count = Counter()
        if make_plot:
            self.pred_labels = []
            self.true_labels = []
        if len(self.important_missing) > 0:
            self.miss_proba = [[[] for _ in range(len(self.important_missing)+1)] for _ in range(3)]

    def update(self, classifier, x, true_labels, coef=None):
        # We predict the label and the probabilities
        pred_labels = classifier.predict(x)
        if hasattr(classifier, 'predict_proba'):
            proba = classifier.predict_proba(x)
        else:
            proba = classifier.decision_function(x)

        # We store the probabilities by severity
        for prob, label in zip(proba, true_labels):
            self.sev_proba[label].append(self.extract_proba(prob))

        # We store the probabilities by missing values and severity
        if len(self.important_missing) > 0:
            for i, prob in enumerate(proba):
                found = False
                for j, feat in enumerate(self.important_missing):
                    if x[i][self.columns.get_loc(feat)] == 0:
                        self.miss_proba[true_labels[i]][j].append(self.extract_proba(prob))
                        found = True
                if not found:
                    self.miss_proba[true_labels[i]][len(self.important_missing)].append(self.extract_proba(prob))

        # We get rid of severity
        true_labels = [int(v!=0) for v in true_labels]

        # We compute different statistics
        self.TP += sum([int(pred == reg and pred == 1) for pred,reg in zip(pred_labels, true_labels)])
        self.FP += sum([int(pred != reg and pred == 1) for pred,reg in zip(pred_labels, true_labels)])
        self.FN += sum([int(pred != reg and pred == 0) for pred,reg in zip(pred_labels, true_labels)])
        self.TN += sum([int(pred == reg and pred == 0) for pred,reg in zip(pred_labels, true_labels)])

        self.n_sets += 1

        # We compute the ROC and the PR curves as well as the Area Under Curve of the ROC
        self.AUC += severity_proba_ROC(classifier, x, true_labels)
        self.ROC.append(severity_proba_ROC(classifier, x, true_labels, metrics.roc_curve))
        precision, recall, thres = severity_proba_ROC(classifier, x, true_labels, metrics.precision_recall_curve)
        self.PR.append((recall[::-1], precision[::-1], thres))
        inv_precision, inv_recall, inv_thres = severity_proba_ROC(classifier, x, [1-v for v in true_labels],
                                                      metrics.precision_recall_curve,
                                                      func_result=lambda x: [1-v for v in x])
        self.invPR.append((inv_recall[::-1], inv_precision[::-1], inv_thres))

        # If it is sparse, we summarize the features used
        if self.sparse:
            used_feat = [i for i,x in enumerate(coef) if x != 0]
            self.n_feat.append(len(used_feat))
            self.feat_count.update(self.columns[used_feat])
        else:
            self.n_feat.append(len(self.columns))

    def plot_data_update(self, sev_pred_labels, true_labels):
        self.pred_labels.append(sev_pred_labels)
        self.true_labels.append(true_labels)

    def plot_severity(self, i=1, show=True, n_set=20):
        plt.figure(i)
        for j,(t_labels, p_labels) in enumerate(zip(self.true_labels, self.pred_labels)):
            for t_lab, p_lab in zip(t_labels, p_labels):
                if t_lab == 0:
                    plt.subplot(311)
                    plt.plot(p_lab, j, self.class_style[t_lab])
                if t_lab == 1:
                    plt.subplot(312)
                    plt.plot(p_lab, j, self.class_style[t_lab])
                if t_lab == 2:
                    plt.subplot(313)
                    plt.plot(p_lab, j, self.class_style[t_lab])
            if j>=n_set:
                break
        if show:
            plt.show()

    def plot_ROC(self, i=1, name='classifier', show=False, store = False, store_file=None, plot_all_curves=False):
        self.plot_curve(self.ROC, 'ROC', 'False Positive Rate', 'True Positive Rate', True, store=store,
                        i=i, name=name, show=show, store_file=store_file, plot_all_curves=plot_all_curves)

    def plot_PR(self, i=1, name='classifier', show=False, store = False, store_file=None, plot_all_curves=False):
        self.plot_curve(self.PR, 'PR', 'Recall', 'Precision', False, store=store, store_file=store_file,
                        i=i, name=name, show=show, plot_all_curves=plot_all_curves, color='b', loc="lower left")

    def plot_invPR(self, i=1, name='classifier', show=False, store = False, store_file=None, plot_all_curves=False):
        self.plot_curve(self.invPR, 'invPR', 'Recall', 'Precision', False, store=store, store_file=store_file,
                        i=i, name=name, show=show, plot_all_curves=plot_all_curves, color='b', loc="lower left")

    def plot_curve(self, summary_var, summary_name, x_label, y_label, roc_like, i=1, name='classifier',
                    show=False, store = False, store_file=None, plot_all_curves=False, color='r', loc='lower right'):
        plt.figure(i)
        mean_tpr = 0.0
        sd_tpr = 0.0
        mean_fpr = np.linspace(0, 1, 100)
        for (fpr, tpr, thres) in summary_var:
            mean_tpr += np.interp(mean_fpr, fpr, tpr)
            if roc_like:
                mean_tpr[0] = 0.0
            sd_tpr += np.interp(mean_fpr, fpr, tpr**2)
            if roc_like:
                sd_tpr[0] = 0.0
            if plot_all_curves:
                plt.plot(fpr, tpr, lw=1)
        mean_tpr /= len(summary_var)
        sd_tpr = [sqrt((x/len(summary_var)-m**2)/len(summary_var)) for x,m in zip(sd_tpr,mean_tpr)]
        if roc_like:
            mean_tpr[-1] = 1.0
            sd_tpr[-1] = 0.0
        mean_auc = metrics.auc(mean_fpr, mean_tpr)
        plt.plot(mean_fpr, mean_tpr, color+'--',
                label='Mean '+summary_name+' (area: {0:.2f})'.format(mean_auc), lw=2)
        plt.plot(mean_fpr,mean_tpr-sd_tpr,
                 'b:', label='Confidence '+summary_name, lw=1)
        plt.plot(mean_fpr,mean_tpr+sd_tpr,
                 'b:', lw=1)
        if roc_like:
            plt.plot([0, 1], [0, 1], '--', color=(0.6, 0.6, 0.6), label='Luck')
        plt.xlim([-0.05, 1.05])
        plt.ylim([-0.05, 1.05])
        plt.xlabel(x_label)
        plt.ylabel(y_label)
        plt.title(summary_name+' curve for {}'.format(name))
        plt.legend(loc=loc)
        if store:
            plt.savefig(store_file)
        if show:
            plt.show()

    def hist_probas(self, i=1, name='classifier', show=False, store = False, store_file=None):
        plt.figure(i)
        m = min([min(l) for l in self.sev_proba])
        M = max([max(l) for l in self.sev_proba])
        if m >= 0 and M <= 1:
            m, M = 0.0, 1.0
        print('m: {}, M: {}'.format(m,M))
        lab = ['Control', 'Spectrum', 'Autism']
        for j in range(1,4):
            plt.subplot(310+j)
            plt.hist(self.sev_proba[j-1], range=[m-0.1,M+0.1], bins=30, label=lab[j-1])
        plt.ylabel("Number of values")
        plt.suptitle('Histograms or probabilities by label for {}'.format(name))
        if store:
            plt.savefig(store_file)
        if show:
            plt.show()

    def plot_features(self, features, i=1, name='classifier', show=False, store = False, store_file=None):
        plt.figure(i)
        fold_used = [self.feat_count[feat] for feat in features]
        plt.bar(list(range(len(fold_used))), fold_used)
        plt.xticks(list(range(len(fold_used))), features, rotation="vertical")
        plt.ylabel('Number of folds using the features')
        plt.title('Features used for {}'.format(name))
        if store:
            plt.savefig(store_file)
        if show:
            plt.show()

    def plot_sev_probas(self, i=1, name='classifier', show=False, store = False, store_file=None):
        plt.figure(i)
        min_y = -0.2
        if(min([np.min(p) for p in self.sev_proba])) < 0:
            min_y -= 1
        mean_proba = [np.mean(p) for p in self.sev_proba]
        sd_proba = [np.std(p) for p in self.sev_proba]
        plt.bar([-0.2,0.8,1.8], mean_proba, width=0.4, color='y', yerr=sd_proba)
        #plt.errorbar(range(3), mean_proba, sd_proba, fmt='o')
        plt.ylabel('Probability/Score of being detect as autist')
        plt.xlim([-0.7, 2.7])
        plt.ylim([min_y, 1.2])
        plt.xticks(list(range(3)), ['Control', 'Spectrum', 'Autism'])
        plt.title('Probability/Score vs severity for {}'.format(name))
        if store:
            plt.savefig(store_file)
        if show:
            plt.show()

    def plot_miss_probas(self, i=1, name='classifier', show=False, store = False, store_file=None):
        plt.figure(i)
        k = len(self.important_missing)+1
        min_y = -0.2
        if(min([np.min([np.min(p) for p in l if len(p) > 0]) for l in self.miss_proba])) < 0:
            min_y -= 1
        mean_proba = [[np.mean(p) for p in l] for l in self.miss_proba]
        sd_proba = [[np.std(p) for p in l] for l in self.miss_proba]
        len_proba = [[len(p) for p in l] for l in self.miss_proba]
        plt.bar([x-0.3 for x in range(k)], mean_proba[0], width=0.2, color='g', yerr=sd_proba[0])
        plt.bar([x-0.1 for x in range(k)], mean_proba[1], width=0.2, color='b', yerr=sd_proba[1])
        plt.bar([x+0.1 for x in range(k)], mean_proba[2], width=0.2, color='y', yerr=sd_proba[2])

        for x in range(k):
            for i in range(3):
                plt.text(x-0.3+0.2*i, -0.05, len_proba[i][x])

        #plt.errorbar(range(3), mean_proba, sd_proba, fmt='o')
        plt.ylabel('Probability of being detect as autist')
        plt.xlim([-0.8, k-0.2])
        plt.ylim([min_y, 1.2])
        plt.xticks(list(range(k)), self.important_missing+['No Missing'])
        plt.title('Probability vs Missing Values for {}'.format(name))
        if store:
            plt.savefig(store_file)
        if show:
            plt.show()


    def accuracy(self):
        return float(self.TP+self.TN)/(self.TP+self.FP+self.FN+self.TN)

    def sensitivity(self):
        return float(self.TP)/(self.TP+self.FN)

    def specificity(self):
        return float(self.TN)/(self.FP+self.TN)

    def auc(self):
        return self.AUC/self.n_sets

    def __repr__(self):
        return  "( {:.2f}, {:.2f}, {:.2f}), AUC = {:.3f}, using {:.2f} +- {:.2f} features".format(self.accuracy(),self.sensitivity(),self.specificity(),
                                                               self.auc(), np.mean(self.n_feat), np.std(self.n_feat))

    def getFeatures(self):
        return self.feat_count

    @staticmethod
    def extract_proba(prob):
        if len(prob.shape) < 1:
            return prob
        if prob.shape == (1,):
            return prob[0]
        return prob[1]
