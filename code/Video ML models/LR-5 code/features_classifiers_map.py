__author__ = 'Sebastien Levy'

from os import listdir
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from classifier_results import ClassifierResult

DIRECTORY = 'fig/m3/m3 ease roc S&T+/'
SUMMARY_NAME = 'summary'


def comp_miss(x,y):
    if x == y:
        return 0
    if (x[-4:] == 'miss') == (y[-4:] == 'miss'):
        if x[0] == 'B' and y[0] == 'B' and len(y) != len(x):
            return int(len(x) < len(y))*2 - 1
        return int(x < y)*2 - 1
    return int(y[-4:] == 'miss')*2 -1

if __name__ == '__main__':

    ClassifierResult.init_param(DIRECTORY, SUMMARY_NAME)
    classifiers_results = [ClassifierResult(name, put_auc=True) for name in listdir(ClassifierResult.directory)
                           if not '.' in name]

    features = pd.DataFrame.from_dict([cl.feats for cl in classifiers_results])
    features.index = [cl.name for cl in classifiers_results]
    features.loc['     ', 'AUC'] = 0.90
    features.loc['  ', 'AUC'] = 0.91
    features.loc['   ', 'AUC'] = 0.92
    features.loc['    ', 'AUC'] = 0.93
    features.fillna(value=0, inplace=True)
    features.sort('AUC', axis=0, inplace=True, ascending=False)
    features = features[ sorted(features.columns, cmp= comp_miss, reverse=True)]

    fig, ax = plt.subplots()

    # put the major ticks at the middle of each cell
    ax.set_xticks(np.arange(len(features.columns))+0.5, minor=False)
    ax.set_yticks(np.arange(len(features.index))+0.5, minor=False)

    # We plot the dashed red lines
    ax2 = ax.twinx()
    val = []
    for i, name in enumerate(features.index):
        if '  ' in name:
            ax.axhline(i+0.5, color='red', ls='--')
            val.append(str(int(features.loc[name, 'AUC']*100))+'%')
        else:
            val.append(' ')

    ax2.set_yticks(np.arange(len(features.index))+0.5, minor=False)
    ax2.invert_yaxis()
    ax2.set_yticklabels(val, minor=False)

    # We drop AUC and create the heatmap
    features.drop('AUC', axis=1, inplace=True)
    heatmap = ax.pcolor(features, cmap=plt.cm.Blues)

    # want a more natural, table-like display
    ax.invert_yaxis()
    ax.xaxis.tick_top()

    ax.set_xticklabels(features.columns, minor=False, rotation='vertical')
    ax.set_yticklabels(features.index, minor=False)



    plt.show()
    print(features)
