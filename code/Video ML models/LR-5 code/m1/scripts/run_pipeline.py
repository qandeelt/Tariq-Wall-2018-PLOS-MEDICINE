import numpy as np
from sklearn.cross_validation import StratifiedKFold
from sklearn.metrics import accuracy_score, confusion_matrix
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import Imputer
from sklearn.svm import SVC

respData = np.genfromtxt('../data/ados_m1_asd.csv',
                         delimiter=',', skip_header = 1)
respData = respData[:,2:]
nonrespData = np.genfromtxt('../data/ados_m1_controls.csv',
                         delimiter=',', skip_header = 1)
nonrespData = nonrespData[:,2:]

respTarget = np.ones(respData.shape[0])
nonrespTarget = np.zeros(nonrespData.shape[0])
X1 = np.append(respData, nonrespData, axis=0)
Y = np.append(respTarget, nonrespTarget, axis=0)

imp = Imputer(missing_values='NaN', strategy='most_frequent', axis=0)
X = imp.fit_transform(X1)

scores = []
skf = StratifiedKFold(Y, n_folds = 5, shuffle = True)
for train, test in skf:
	Xtrain, Ytrain = X[train], Y[train]
	Xtest, Ytest = X[test], Y[test]
	clf = SVC()
	clf.fit(Xtrain, Ytrain)
	yPred = clf.predict(Xtest)
	scores.append(accuracy_score(Ytest, yPred))
	print confusion_matrix(Ytest, yPred)
    
print scores
    