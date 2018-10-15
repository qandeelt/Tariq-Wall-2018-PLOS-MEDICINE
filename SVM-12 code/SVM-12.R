library('e1071')
#
# Cog lassifier for kids who qualify for ADOS Mod3
#
createDataSet = function(df) {
    # edits the file so we can run it through the SVM

    df[is.na(df)] <- 0        # replace NAs with 0

    # keep only the 12 best features used in the SVM
    items = c("A4","A7","A8","A9","B1","B2","B7","B8","B9","D1","D2","D4")
    df <- subset(df,select = c(items,"Class"))

    # We need labels e.g. autism, non-spectrum
    diagnosis = as.character(df$Class)
    diagnosis[diagnosis == "Autism Spectrum"] = "Autism"
    df$Class = as.factor(diagnosis)
    
    return(df)
}


#                        edit the path here to the path of your Cog3TrainingSet.csv file
#                           |   
#                           v 
trainingSet <- read.csv('/Users/qandeel_peds/Desktop/new_phenotyping_analyses/Cog3TrainingSet.csv')
trainingSet <- createDataSet(trainingSet)

model <- svm(Class~., data=trainingSet, type='C', cross=10, kernel='radial', probability=TRUE)
table(actual=trainingSet$Class, predicted=predict(model, newdata=trainingSet, type="class"))


# ----------------------------------------------------------------------------------
# Perform testing
# ----------------------------------------------------------------------------------

# include your test set - new data -  here
testSet <- read.csv('/Users/qandeel_peds/Desktop/new_phenotyping_analyses/M3_videos_for_new_classifier.csv')
testSet <- createDataSet(testSet)

preds <- predict(model, newdata=testSet, probability=TRUE)
pred_probs <- attributes(preds)$probabilities
preds_mat <- data.frame(preds, pred_probs)
write.csv(preds_mat, "preds_mat.csv", row.names=FALSE)

# run the model and print out the results
table(actual=testSet$Class, predicted=predict(model, newdata=testSet, type="class"))
