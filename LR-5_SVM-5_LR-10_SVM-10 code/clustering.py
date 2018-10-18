__author__ = 'Sebastien Levy'

from processing import ADOS_Data
from sklearn import decomposition
import matplotlib.pyplot as plt
import numpy as np

NORMALIZE = True
# Binary or Replacement
MISSING_VALUE_STRATEGY = 'Binary'

ADOS_FILE = "m3/data/ados_m3_allData.csv"
label_id = "ASD"
label_age = "age_months"
label_gender = "male"
columns_to_delete = ["Subject.Id", "Diagnosis"]
sub_diagnosis_id = ["social_affect_calc","restricted_repetitive_calc","SA_RRI_total_calc","severity_calc"]

def subplot_pca(full_pc, comp1, comp2, subplot, style0='bs', style1='g^', style2='ro'):
    plt.subplot(subplot)
    plt.plot(full_pc[:,comp2][full_pc[:,-1] == 0], full_pc[:,comp1][full_pc[:,-1] == 0], style0,
         full_pc[:,comp2][full_pc[:,-1] == 1], full_pc[:,comp1][full_pc[:,-1] == 1], style1,
         full_pc[:,comp2][full_pc[:,-1] == 2], full_pc[:,comp1][full_pc[:,-1] == 2], style2)

def pca_plot(pca, first_fig=1, show_coef=True):
    pc = pca.fit_transform(data)
    full_pc = np.zeros((pc.shape[0], pc.shape[1]+1))
    full_pc[:,:-1] = pc
    full_pc[:,-1] = data.labels

    plt.figure(first_fig)
    subplot_pca(full_pc, 0, 1, 231)
    subplot_pca(full_pc, 0, 2, 232)
    subplot_pca(full_pc, 0, 3, 233)
    subplot_pca(full_pc, 1, 2, 234)
    subplot_pca(full_pc, 1, 3, 235)
    subplot_pca(full_pc, 2, 3, 236)

    if show_coef:
        plt.figure(first_fig+2)
        plt.subplot(221)
        plt.bar(list(range(pca.components_.shape[1])), pca.components_[0,:], color="black")
        plt.subplot(223)
        plt.bar(list(range(pca.components_.shape[1])), pca.components_[2,:], color="red")
        plt.subplot(222)
        plt.bar(list(range(pca.components_.shape[1])), pca.components_[1,:])
        plt.subplot(224)
        plt.bar(list(range(pca.components_.shape[1])), pca.components_[3,:], color="green")

    plt.figure(first_fig+1)
    subplot_pca(full_pc, 0, 4, 231)
    subplot_pca(full_pc, 1, 4, 232)
    subplot_pca(full_pc, 2, 4, 233)
    subplot_pca(full_pc, 3, 4, 234)
    subplot_pca(full_pc, 0, 5, 235)
    subplot_pca(full_pc, 1, 5, 236)

# We import the data
data = ADOS_Data.read_csv(ADOS_FILE)
sub_diagnosis = data[sub_diagnosis_id]

# We drop the columns that are not interesting for us, and the row with no label
data.select_good_columns(columns_to_delete+sub_diagnosis_id)
data.preprocessing(label_id)
if NORMALIZE:
    data.normalize_age(label_age, label_gender)

if MISSING_VALUE_STRATEGY == 'Binary':
    # We create the binary columns
    data.create_missing_data_col()

if MISSING_VALUE_STRATEGY in ['Replacement', 'Binary']:
    # We replace missing values in the ADOS answers (8) by 0
    data.replace(8, 3, inplace=True)

pca = decomposition.PCA()
spca = decomposition.SparsePCA(alpha=0.02)
kpca = decomposition.KernelPCA(kernel='cosine')
kpca2 = decomposition.KernelPCA(kernel='sigmoid')

pca_plot(pca, 1)

plt.figure(4)
plt.plot(pca.explained_variance_ratio_)

pca_plot(spca, 5)

pca_plot(kpca, 8, show_coef=False)

pca_plot(kpca2, 10, show_coef=False)

plt.show()
