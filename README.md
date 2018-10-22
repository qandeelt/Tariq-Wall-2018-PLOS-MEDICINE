# video_phenotyping_autism_plos
Code for building ML classifiers described in the paper selected for publication in PLOS Medicine.

The methods used for building these classifiers have been described at length in these papers:

ADT8: From the paper: https://www.nature.com/articles/tp201210

ADT7: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0043855

SVM-9 and LR-12: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4445756/

LR-5, SVM-5, LR-10, SVM-10: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5735531/ (*)

LR-VF: Detailed jupyter notebook provided and steps to run it described below.

Datasets:
1. The primary dataset includes the videos used for the initial validation of the 8 classifiers to pick the top performing ones out of those  which were then validated on (2). This dataset was also used to construct the video feature classifier.
The csv includes:
child_id : the code assigned to the child whose video was rated
diagnosis of the child
rater_id: the rater who watched the video and scored the features associated
question1-question30: the 30 behavioral features that were rated
age: age of the child
gender: gender of the child

2. The validation dataset was used to re-validate the results of top performing historic classifiers and also validate the new video feature classifier which was trained and tested on the primaary dataset.

Code:
The code for the classifiers is given in the folders called "Video ML models" (model validated on video features) and "Video Feature Classifier" (model developed on video features). Each of the folders contain instructions on how to run the classifier. 

For further questions, please contact the-wall-lab@stanford.edu.
