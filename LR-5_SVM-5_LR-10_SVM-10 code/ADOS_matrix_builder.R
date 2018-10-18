########################################################################################
######################################### ADOS #########################################
########################################################################################

##############################
#### MODULE 1 AGGREGATION ####
##############################
AC.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/Autism_Consortium_Data/All_Measures/ADOS_Module_1.csv"
AC.df = df = read.csv(AC.file)
colnames(AC.df)


AC.df = AC.df[ which( ! AC.df$Subject.Id %in% c(NA, 'N/A', '')) , ]

AGRE.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/AGRE_2015/ADOS Mod1/ADOS11.csv"
AGRE.df = df = read.csv(AGRE.file)
colnames(AGRE.df)


svip1.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_1q21.1/ados_1.csv'
svip1.1 = df = read.csv(svip1.file)
svip1.1 = subset(svip1.1, ados_1.total >= 0)

svip2.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/ados_1.csv'
svip2.1 = df = read.csv(svip2.file)
svip2.1 = subset(svip2.1, ados_1.total >= 0)

SVIP.df = rbind(svip1.1, svip2.1)
colnames(SVIP.df)

SVIP2.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/svip_summary_variables.csv"
SVIP2.df = df = read.csv(SVIP2.file)
SVIP.gender = SVIP2.df[c('individual', 'svip_summary_variables.sex')]

SVIP.df = merge(SVIP.df, SVIP.gender, by = 'individual')

SSC.raw.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ados_1_raw.csv"
SSC.df = df = read.csv(SSC.raw.file)
head(SSC.df)


SSC.twin.raw.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/MZ Twin Data/ados_1_raw.csv"
SSC.twin.df = df = read.csv(SSC.twin.raw.file)
head(SSC.twin.df)


SSC.df = rbind(SSC.df, SSC.twin.df)
colnames(SSC.df)

SSC.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ssc_core_descriptive.csv"
SSC2.df = df = read.csv(SSC.file)
SSC.age = SSC2.df[c('individual', 'age_at_ados', 'sex')]

SSC.df = merge(SSC.df, SSC.age)

AGP.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/AGP_pheno_all_201112/ados_mod_1.csv"
AGP.df = df = read.csv(AGP.file)
AGP.df$Subject.Id = paste(AGP.df$FID, AGP.df$IID, sep = "-")



items = c('A1','A2','A3','A4','A5','A6','A7','A8','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','D1','D2','D3','D4','E1','E2','E3')
colnames(AC.df)[12:34] = items [1:23]; colnames(AC.df)[36] = 'D2'; colnames(AC.df)[38:39] = c('D3','D4'); colnames(AC.df)[41:43] = items[27:29]
colnames(SVIP.df)[7:35] = items
colnames(SSC.df)[3:31] = items
colnames(AGRE.df)[c(21:40,46:54)] = items
colnames(AGP.df)[5:33] = items


colnames(SVIP.df)[c(1,6)] = c('Subject.Id', 'age_months'); SVIP.df$gender[SVIP.df$svip_summary_variables.sex == 'male'] = 'M'; SVIP.df$gender[SVIP.df$svip_summary_variables.sex == 'female'] = 'F'
colnames(SSC.df)[c(1,32)] = c('Subject.Id', 'age_months'); SSC.df$gender[SSC.df$sex == 'male'] = 'M'; SSC.df$gender[SSC.df$sex == 'female'] = 'F'
colnames(AGRE.df)[7] = 'Subject.Id'; AGRE.df$age_months = AGRE.df$age*12; AGRE.df$gender[AGRE.df$Gender == 1] = 'M'; AGRE.df$gender[AGRE.df$Gender == 2] = 'F'; AGRE.df$gender = as.factor(AGRE.df$gender)
colnames(AC.df)[c(1,9,2)] = c('Subject.Id', 'age_months', 'gender')
colnames(AGP.df)[4] = 'age_months'; AGP.df$gender = NA

for(i in 5:33) {
  AGP.df[,i] <- as.numeric(AGP.df[,i])
}


myvars <- c('Subject.Id',items, 'age_months', 'gender')
AC.subset <- AC.df[myvars]
SVIP.subset <- SVIP.df[myvars]
AGRE.subset <- AGRE.df[myvars]
SSC.subset <- SSC.df[myvars]



m1.df = rbind(AC.subset, SVIP.subset, AGRE.subset, SSC.subset)


m1.df[,2:30][m1.df[,2:30] == '-1'] = 8
m1.df[,2:30][m1.df[,2:30] < 0] = 8
m1.df[,2:30][m1.df[,2:30] >= 7] = 8


m1.recode = m1.df
m1.recode[,2:30][m1.recode[,2:30] < 0] = 8
m1.recode[,2:30][m1.recode[,2:30] >= 7] = 0
m1.recode[,2:30][m1.recode[,2:30] == 3] = 2


for (i in (1:length(m1.df$A1))){
  if (m1.df$A1[i] %in% c(3,4,8)){
    m1.df$social_affect_calc[i] = (m1.recode$A2[i] + m1.recode$A8[i] + m1.recode$B1[i] + m1.recode$B3[i] + m1.recode$B4[i] + m1.recode$B5[i] +
                                     m1.recode$B9[i] + m1.recode$B10[i] + m1.recode$B11[i] + m1.recode$B12[i])
    m1.df$restricted_repetitive_calc[i] = (m1.recode$A3[i] + m1.recode$D1[i] + m1.recode$D2[i] + m1.recode$D4[i])
    m1.df$SA_RRI_total_calc[i] = (m1.df$social_affect_calc[i] + m1.df$restricted_repetitive_calc[i])
    if (m1.df$age_months[i] < 36.0){
      if (m1.df$SA_RRI_total_calc[i] <= 6){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 8){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 10){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 13){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 15){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 19){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 21){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 22){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 24){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 25){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] < 48.0){
      if (m1.df$SA_RRI_total_calc[i] <= 6){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 8){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 10){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 14){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 15){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 20){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 22){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 23){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 24){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 25){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] < 72.0){
      if (m1.df$SA_RRI_total_calc[i] <= 3){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 6){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 10){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 12){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 15){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 19){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 21){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 23){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 25){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 26){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] >= 72.0){
      if (m1.df$SA_RRI_total_calc[i] <= 3){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 6){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 10){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 13){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 15){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 19){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 22){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 24){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 25){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 26){m1.df$severity_calc[i] = 10}
    }
    
  } else if (m1.df$A1[i] %in% c(1,2,0)){
    m1.df$social_affect_calc[i] = (m1.recode$A2[i] + m1.recode$A7[i] + m1.recode$A8[i] + m1.recode$B1[i] + m1.recode$B3[i] + m1.recode$B4[i] + m1.recode$B5[i] +
                                     m1.recode$B9[i] + m1.recode$B10[i] + m1.recode$B12[i])
    m1.df$restricted_repetitive_calc[i] = (m1.recode$A5[i] + m1.recode$D1[i] + m1.recode$D2[i] + m1.recode$D4[i])
    m1.df$SA_RRI_total_calc[i] = (m1.df$social_affect_calc[i] + m1.df$restricted_repetitive_calc[i])
    if (m1.df$age_months[i] < 36.0){
      if (m1.df$SA_RRI_total_calc[i] <= 3){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 5){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 7){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 10){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 11){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 13){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 16){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 19){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 21){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 22){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] < 48.0){
      if (m1.df$SA_RRI_total_calc[i] <= 4){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 6){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 7){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 9){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 11){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 14){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 17){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 19){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 21){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 22){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] < 60.0){
      if (m1.df$SA_RRI_total_calc[i] <= 2){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 4){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 7){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 9){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 11){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 15){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 18){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 20){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 22){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 23){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] < 84.0){
      if (m1.df$SA_RRI_total_calc[i] <= 2){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 4){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 7){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 10){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 11){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 16){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 19){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 21){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 23){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 24){m1.df$severity_calc[i] = 10}
    }
    else if (m1.df$age_months[i] >= 84.0){
      if (m1.df$SA_RRI_total_calc[i] <= 2){m1.df$severity_calc[i] = 1}
      else if (m1.df$SA_RRI_total_calc[i] <= 5){m1.df$severity_calc[i] = 2}
      else if (m1.df$SA_RRI_total_calc[i] <= 7){m1.df$severity_calc[i] = 3}
      else if (m1.df$SA_RRI_total_calc[i] <= 9){m1.df$severity_calc[i] = 4}
      else if (m1.df$SA_RRI_total_calc[i] <= 11){m1.df$severity_calc[i] = 5}
      else if (m1.df$SA_RRI_total_calc[i] <= 18){m1.df$severity_calc[i] = 6}
      else if (m1.df$SA_RRI_total_calc[i] <= 20){m1.df$severity_calc[i] = 7}
      else if (m1.df$SA_RRI_total_calc[i] <= 21){m1.df$severity_calc[i] = 8}
      else if (m1.df$SA_RRI_total_calc[i] <= 23){m1.df$severity_calc[i] = 9}
      else if (m1.df$SA_RRI_total_calc[i] >= 24){m1.df$severity_calc[i] = 10}
    }
  }
}

m1.df$male = 0
m1.df$male[m1.df$gender == "M"] = 1

##############################
#### MODULE 2 AGGREGATION ####
##############################

AC.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/Autism_Consortium_Data/All_Measures/ADOS_Module_2.csv"
AC.df = df = read.csv(AC.file)
head(AC.df)

AC.df = AC.df[ which( ! AC.df$Subject.Id %in% c(NA, 'N/A', '')) , ]

AGRE.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/AGRE_2015/ADOS Mod2/ADOS21.csv"
AGRE.df = df = read.csv(AGRE.file)
head(AGRE.df)

svip1.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_1q21.1/ados_2.csv'
svip1.1 = df = read.csv(svip1.file)
svip1.1 = subset(svip1.1, ados_2.total >= 0)

svip2.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/ados_2.csv'
svip2.1 = df = read.csv(svip2.file)
svip2.1 = subset(svip2.1, ados_2.total >= 0)

SVIP.df = rbind(svip1.1, svip2.1)

SVIP2.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/svip_summary_variables.csv"
SVIP2.df = df = read.csv(SVIP2.file)
SVIP.gender = SVIP2.df[c('individual', 'svip_summary_variables.sex')]

SVIP.df = merge(SVIP.df, SVIP.gender, by = 'individual')

SSC.raw.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ados_2_raw.csv"
SSC.df = df = read.csv(SSC.raw.file)
head(SSC.df)


SSC.twin.raw.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/MZ Twin Data/ados_2_raw.csv"
SSC.twin.df = df = read.csv(SSC.twin.raw.file)
head(SSC.twin.df)


SSC.df = rbind(SSC.df, SSC.twin.df)

SSC.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ssc_core_descriptive.csv"
SSC2.df = df = read.csv(SSC.file)
SSC.age = SSC2.df[c('individual', 'age_at_ados', 'sex')]

SSC.df = merge(SSC.df, SSC.age)



AGP2.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/AGP_pheno_all_201112/ados_mod_2wps.csv"
AGP.df = df = read.csv(AGP2.file)
AGP.df$Subject.Id = paste(AGP.df$FID, AGP.df$IID, sep = "-")


items = c('A1','A2','A3','A4','A5','A6','A7','A8','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','C1','C2','D1','D2','D3','D4','E1','E2','E3')
length(items)
colnames(AC.df)[12:33] = items[1:22]; colnames(AC.df)[35] = "D2"; colnames(AC.df)[37:38] = c("D3", "D4"); colnames(AC.df)[43:45] = c("E1" ,"E2", "E3")
colnames(SVIP.df)[7:34] = items
colnames(SSC.df)[3:30] = items
colnames(AGRE.df)[c(21,52,22:35,38:49)] = items
colnames(AGP.df)[5:32] = items


colnames(SVIP.df)[c(1,6)] = c('Subject.Id', 'age_months'); SVIP.df$gender[SVIP.df$svip_summary_variables.sex == 'male'] = 'M'; SVIP.df$gender[SVIP.df$svip_summary_variables.sex == 'female'] = 'F'
colnames(SSC.df)[c(1,31)] = c('Subject.Id', 'age_months'); SSC.df$gender[SSC.df$sex == 'male'] = 'M'; SSC.df$gender[SSC.df$sex == 'female'] = 'F'
colnames(AGRE.df)[7] = 'Subject.Id'; AGRE.df$age_months = AGRE.df$age*12; AGRE.df$gender[AGRE.df$Gender == 1] = 'M'; AGRE.df$gender[AGRE.df$Gender == 2] = 'F'; AGRE.df$gender = as.factor(AGRE.df$gender)
colnames(AC.df)[c(1,9,2)] = c('Subject.Id', 'age_months', 'gender')
colnames(AGP.df)[4] = 'age_months'; AGP.df$gender = NA

for(i in 5:32) {
  AGP.df[,i] <- as.numeric(AGP.df[,i])
}


myvars <- c('Subject.Id',items, 'age_months', 'gender')
AC.subset <- AC.df[myvars]
SVIP.subset <- SVIP.df[myvars]
AGRE.subset <- AGRE.df[myvars]
SSC.subset <- SSC.df[myvars]
AGP.subset <- AGP.df[myvars]

m2.df = rbind(AC.subset, SVIP.subset, AGRE.subset, SSC.subset)

m2.df[,2:29][m2.df[,2:29] == '-1'] = 8
m2.df[,2:29][m2.df[,2:29] < 0] = 8
m2.df[,2:29][m2.df[,2:29] >= 7] = 8

colnames(m2.df)
m2.recode = m2.df

m2.recode[,2:29][m2.recode[,2:29] < 0] = 8
m2.recode[,2:29][m2.recode[,2:29] >= 7] = 0
m2.recode[,2:29][m2.recode[,2:29] == 3] = 2

### When calculating sub- and total-scores, note that ALL databases have used ADOS-G numbering, so the algorithm changes as follows:
### ADOS-2 | ADOS-G
###   A4   |   A5
###   A6   |   A7
###   A7   |   A8
###   B11  |   B10
###   B12  |   B11


for (i in (1:length(m2.df$Subject.Id))){
  m2.df$social_affect_calc[i] = (m2.recode$A7[i] + m2.recode$A8[i] + m2.recode$B1[i] + m2.recode$B2[i] + m2.recode$B3[i] + m2.recode$B5[i] +
                                   m2.recode$B6[i] + m2.recode$B8[i] + m2.recode$B10[i] + m2.recode$B11[i])
  m2.df$restricted_repetitive_calc[i] = (m2.recode$A5[i] + m2.recode$D1[i] + m2.recode$D2[i] + m2.recode$D4[i])
  m2.df$SA_RRI_total_calc[i] = (m2.df$social_affect_calc[i] + m2.df$restricted_repetitive_calc[i])
}
for (i in (1:length(m2.df$social_affect_calc))){
  if (m2.df$age_months[i] < 36.0){
    if (m2.df$SA_RRI_total_calc[i] <= 2){m2.df$severity_calc[i] = 1}
    else if (m2.df$SA_RRI_total_calc[i] <= 5){m2.df$severity_calc[i] = 2}
    else if (m2.df$SA_RRI_total_calc[i] <= 6){m2.df$severity_calc[i] = 3}
    else if (m2.df$SA_RRI_total_calc[i] <= 8){m2.df$severity_calc[i] = 4}
    else if (m2.df$SA_RRI_total_calc[i] <= 9){m2.df$severity_calc[i] = 5}
    else if (m2.df$SA_RRI_total_calc[i] <= 11){m2.df$severity_calc[i] = 6}
    else if (m2.df$SA_RRI_total_calc[i] <= 12){m2.df$severity_calc[i] = 7}
    else if (m2.df$SA_RRI_total_calc[i] <= 14){m2.df$severity_calc[i] = 8}
    else if (m2.df$SA_RRI_total_calc[i] <= 17){m2.df$severity_calc[i] = 9}
    else if (m2.df$SA_RRI_total_calc[i] >= 18){m2.df$severity_calc[i] = 10}
  }
  else if (m2.df$age_months[i] < 48.0){
    if (m2.df$SA_RRI_total_calc[i] <= 3){m2.df$severity_calc[i] = 1}
    else if (m2.df$SA_RRI_total_calc[i] <= 5){m2.df$severity_calc[i] = 2}
    else if (m2.df$SA_RRI_total_calc[i] <= 6){m2.df$severity_calc[i] = 3}
    else if (m2.df$SA_RRI_total_calc[i] <= 8){m2.df$severity_calc[i] = 4}
    else if (m2.df$SA_RRI_total_calc[i] <= 9){m2.df$severity_calc[i] = 5}
    else if (m2.df$SA_RRI_total_calc[i] <= 12){m2.df$severity_calc[i] = 6}
    else if (m2.df$SA_RRI_total_calc[i] <= 14){m2.df$severity_calc[i] = 7}
    else if (m2.df$SA_RRI_total_calc[i] <= 16){m2.df$severity_calc[i] = 8}
    else if (m2.df$SA_RRI_total_calc[i] <= 18){m2.df$severity_calc[i] = 9}
    else if (m2.df$SA_RRI_total_calc[i] >= 19){m2.df$severity_calc[i] = 10}
  }
  else if (m2.df$age_months[i] < 60.0){
    if (m2.df$SA_RRI_total_calc[i] <= 3){m2.df$severity_calc[i] = 1}
    else if (m2.df$SA_RRI_total_calc[i] <= 5){m2.df$severity_calc[i] = 2}
    else if (m2.df$SA_RRI_total_calc[i] <= 6){m2.df$severity_calc[i] = 3}
    else if (m2.df$SA_RRI_total_calc[i] <= 7){m2.df$severity_calc[i] = 4}
    else if (m2.df$SA_RRI_total_calc[i] <= 9){m2.df$severity_calc[i] = 5}
    else if (m2.df$SA_RRI_total_calc[i] <= 13){m2.df$severity_calc[i] = 6}
    else if (m2.df$SA_RRI_total_calc[i] <= 16){m2.df$severity_calc[i] = 7}
    else if (m2.df$SA_RRI_total_calc[i] <= 18){m2.df$severity_calc[i] = 8}
    else if (m2.df$SA_RRI_total_calc[i] <= 20){m2.df$severity_calc[i] = 9}
    else if (m2.df$SA_RRI_total_calc[i] >= 21){m2.df$severity_calc[i] = 10}
  }
  else if (m2.df$age_months[i] < 84.0){
    if (m2.df$SA_RRI_total_calc[i] <= 3){m2.df$severity_calc[i] = 1}
    else if (m2.df$SA_RRI_total_calc[i] <= 5){m2.df$severity_calc[i] = 2}
    else if (m2.df$SA_RRI_total_calc[i] <= 7){m2.df$severity_calc[i] = 3}
    else if (m2.df$SA_RRI_total_calc[i] <= 8){m2.df$severity_calc[i] = 4}
    else if (m2.df$SA_RRI_total_calc[i] <= 14){m2.df$severity_calc[i] = 6}
    else if (m2.df$SA_RRI_total_calc[i] <= 16){m2.df$severity_calc[i] = 7}
    else if (m2.df$SA_RRI_total_calc[i] <= 20){m2.df$severity_calc[i] = 8}
    else if (m2.df$SA_RRI_total_calc[i] <= 22){m2.df$severity_calc[i] = 9}
    else if (m2.df$SA_RRI_total_calc[i] >= 23){m2.df$severity_calc[i] = 10}
  }
  else if (m2.df$age_months[i] < 108.0){
    if (m2.df$SA_RRI_total_calc[i] <= 2){m2.df$severity_calc[i] = 1}
    else if (m2.df$SA_RRI_total_calc[i] <= 5){m2.df$severity_calc[i] = 2}
    else if (m2.df$SA_RRI_total_calc[i] <= 7){m2.df$severity_calc[i] = 3}
    else if (m2.df$SA_RRI_total_calc[i] <= 8){m2.df$severity_calc[i] = 4}
    else if (m2.df$SA_RRI_total_calc[i] <= 14){m2.df$severity_calc[i] = 6}
    else if (m2.df$SA_RRI_total_calc[i] <= 17){m2.df$severity_calc[i] = 7}
    else if (m2.df$SA_RRI_total_calc[i] <= 21){m2.df$severity_calc[i] = 8}
    else if (m2.df$SA_RRI_total_calc[i] <= 23){m2.df$severity_calc[i] = 9}
    else if (m2.df$SA_RRI_total_calc[i] >= 24){m2.df$severity_calc[i] = 10}
  }
  else if (m2.df$age_months[i] >= 108.0){
    if (m2.df$SA_RRI_total_calc[i] <= 2){m2.df$severity_calc[i] = 1}
    else if (m2.df$SA_RRI_total_calc[i] <= 5){m2.df$severity_calc[i] = 2}
    else if (m2.df$SA_RRI_total_calc[i] <= 7){m2.df$severity_calc[i] = 3}
    else if (m2.df$SA_RRI_total_calc[i] <= 8){m2.df$severity_calc[i] = 4}
    else if (m2.df$SA_RRI_total_calc[i] <= 14){m2.df$severity_calc[i] = 6}
    else if (m2.df$SA_RRI_total_calc[i] <= 17){m2.df$severity_calc[i] = 7}
    else if (m2.df$SA_RRI_total_calc[i] <= 20){m2.df$severity_calc[i] = 8}
    else if (m2.df$SA_RRI_total_calc[i] <= 23){m2.df$severity_calc[i] = 9}
    else if (m2.df$SA_RRI_total_calc[i] >= 24){m2.df$severity_calc[i] = 10}
  } 
}

m2.df$male = 0
m2.df$male[m2.df$gender == "M"] = 1

##############################
#### MODULE 3 AGGREGATION ####
##############################

AC.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/Autism_Consortium_Data/All_Measures/ADOS_Module_3.csv"
AC.df = df = read.csv(AC.file)
head(AC.df)

AC.df = AC.df[ which( ! AC.df$Subject.Id %in% c(NA, 'N/A', '')) , ]

AGRE.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/AGRE_2015/ADOS Mod3/ADOS31.csv"
AGRE.df = df = read.csv(AGRE.file)
head(AGRE.df)

svip1.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_1q21.1/ados_3.csv'
svip1.1 = df = read.csv(svip1.file)
svip1.1 = subset(svip1.1, ados_3.total >= 0)

svip2.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/ados_3.csv'
svip2.1 = df = read.csv(svip2.file)
svip2.1 = subset(svip2.1, ados_3.total >= 0)

SVIP.df = rbind(svip1.1, svip2.1)

SVIP2.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/svip_summary_variables.csv"
SVIP2.df = df = read.csv(SVIP2.file)
SVIP.gender = SVIP2.df[c('individual', 'svip_summary_variables.sex')]

SVIP.df = merge(SVIP.df, SVIP.gender, by = 'individual')

SSC.raw.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ados_3_raw.csv"
SSC.df = df = read.csv(SSC.raw.file)
head(SSC.df)


SSC.twin.raw.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/MZ Twin Data/ados_3_raw.csv"
SSC.twin.df = df = read.csv(SSC.twin.raw.file)
head(SSC.twin.df)


SSC.df = rbind(SSC.df, SSC.twin.df)

SSC.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ssc_core_descriptive.csv"
SSC2.df = df = read.csv(SSC.file)
SSC.age = SSC2.df[c('individual', 'age_at_ados', 'sex')]

SSC.df = merge(SSC.df, SSC.age)


items = c('A1','A2','A3','A4','A5','A6','A7','A8','A9','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','C1','D1','D2','D3','D4','D5','E1','E2','E3')
length(items)
colnames(AC.df)[12:32] = items [1:21]; colnames(AC.df)[34] = "D2"; colnames(AC.df)[35:37] = c("D3", "D4", "D5"); colnames(AC.df)[40:42] = items[26:28]
colnames(SVIP.df)[7:34] = items
colnames(SSC.df)[3:30] = items
colnames(AGRE.df)[c(21:36,38:49)] = items


colnames(SVIP.df)[c(1,6)] = c('Subject.Id', 'age_months'); SVIP.df$gender[SVIP.df$svip_summary_variables.sex == 'male'] = 'M'; SVIP.df$gender[SVIP.df$svip_summary_variables.sex == 'female'] = 'F'
colnames(SSC.df)[c(1,31)] = c('Subject.Id', 'age_months'); SSC.df$gender[SSC.df$sex == 'male'] = 'M'; SSC.df$gender[SSC.df$sex == 'female'] = 'F'
colnames(AGRE.df)[7] = 'Subject.Id'; AGRE.df$age_months = AGRE.df$age*12; AGRE.df$gender[AGRE.df$Gender == 1] = 'M'; AGRE.df$gender[AGRE.df$Gender == 2] = 'F'; AGRE.df$gender = as.factor(AGRE.df$gender)
colnames(AC.df)[c(1,9,2)] = c('Subject.Id', 'age_months', 'gender')


myvars <- c('Subject.Id',items, 'age_months', 'gender')
AC.subset <- AC.df[myvars]
SVIP.subset <- SVIP.df[myvars]
AGRE.subset <- AGRE.df[myvars]
SSC.subset <- SSC.df[myvars]


m3.df = rbind(AC.subset, SVIP.subset, AGRE.subset, SSC.subset)

m3.df[,2:29][m3.df[,2:29] == '-1'] = 8
m3.df[,2:29][m3.df[,2:29] < 0] = 8
m3.df[,2:29][m3.df[,2:29] >= 7] = 8

m3.recode = m3.df

m3.recode[,2:29][m3.recode[,2:29] < 0] = 8
m3.recode[,2:29][m3.recode[,2:29] >= 7] = 0
m3.recode[,2:29][m3.recode[,2:29] == 3] = 2


for (i in (1:length(m3.df$Subject.Id))){
  m3.df$social_affect_calc[i] = (m3.recode$A7[i] + m3.recode$A8[i] + m3.recode$A9[i] + m3.recode$B1[i] + m3.recode$B2[i] + m3.recode$B4[i] + m3.recode$B7[i] +
                                   m3.recode$B8[i] + m3.recode$B9[i] + m3.recode$B10[i])
  m3.df$restricted_repetitive_calc[i] = (m3.recode$A4[i] + m3.recode$D1[i] + m3.recode$D2[i] + m3.recode$D4[i])
  m3.df$SA_RRI_total_calc[i] = (m3.df$social_affect_calc[i] + m3.df$restricted_repetitive_calc[i])
}
for (i in (1:length(m3.df$social_affect_calc))){
  if (m3.df$age_months[i] < 72.0){
    if (m3.df$SA_RRI_total_calc[i] <= 3){m3.df$severity_calc[i] = 1}
    else if (m3.df$SA_RRI_total_calc[i] <= 4){m3.df$severity_calc[i] = 2}
    else if (m3.df$SA_RRI_total_calc[i] <= 6){m3.df$severity_calc[i] = 3}
    else if (m3.df$SA_RRI_total_calc[i] <= 7){m3.df$severity_calc[i] = 4}
    else if (m3.df$SA_RRI_total_calc[i] <= 8){m3.df$severity_calc[i] = 5}
    else if (m3.df$SA_RRI_total_calc[i] <= 11){m3.df$severity_calc[i] = 6}
    else if (m3.df$SA_RRI_total_calc[i] <= 12){m3.df$severity_calc[i] = 7}
    else if (m3.df$SA_RRI_total_calc[i] <= 15){m3.df$severity_calc[i] = 8}
    else if (m3.df$SA_RRI_total_calc[i] <= 17){m3.df$severity_calc[i] = 9}
    else if (m3.df$SA_RRI_total_calc[i] >= 18){m3.df$severity_calc[i] = 10}
  }
  else if (m3.df$age_months[i] < 120.0){
    if (m3.df$SA_RRI_total_calc[i] <= 2){m3.df$severity_calc[i] = 1}
    else if (m3.df$SA_RRI_total_calc[i] <= 4){m3.df$severity_calc[i] = 2}
    else if (m3.df$SA_RRI_total_calc[i] <= 6){m3.df$severity_calc[i] = 3}
    else if (m3.df$SA_RRI_total_calc[i] <= 7){m3.df$severity_calc[i] = 4}
    else if (m3.df$SA_RRI_total_calc[i] <= 8){m3.df$severity_calc[i] = 5}
    else if (m3.df$SA_RRI_total_calc[i] <= 10){m3.df$severity_calc[i] = 6}
    else if (m3.df$SA_RRI_total_calc[i] <= 12){m3.df$severity_calc[i] = 7}
    else if (m3.df$SA_RRI_total_calc[i] <= 14){m3.df$severity_calc[i] = 8}
    else if (m3.df$SA_RRI_total_calc[i] <= 17){m3.df$severity_calc[i] = 9}
    else if (m3.df$SA_RRI_total_calc[i] >= 18){m3.df$severity_calc[i] = 10}
  }
  else if (m3.df$age_months[i] >= 120.0){
    if (m3.df$SA_RRI_total_calc[i] <= 3){m3.df$severity_calc[i] = 1}
    else if (m3.df$SA_RRI_total_calc[i] <= 4){m3.df$severity_calc[i] = 2}
    else if (m3.df$SA_RRI_total_calc[i] <= 6){m3.df$severity_calc[i] = 3}
    else if (m3.df$SA_RRI_total_calc[i] <= 7){m3.df$severity_calc[i] = 4}
    else if (m3.df$SA_RRI_total_calc[i] <= 8){m3.df$severity_calc[i] = 5}
    else if (m3.df$SA_RRI_total_calc[i] <= 10){m3.df$severity_calc[i] = 6}
    else if (m3.df$SA_RRI_total_calc[i] <= 12){m3.df$severity_calc[i] = 7}
    else if (m3.df$SA_RRI_total_calc[i] <= 14){m3.df$severity_calc[i] = 8}
    else if (m3.df$SA_RRI_total_calc[i] <= 17){m3.df$severity_calc[i] = 9}
    else if (m3.df$SA_RRI_total_calc[i] >= 18){m3.df$severity_calc[i] = 10}
  }
}

m3.df$male = 0
m3.df$male[m3.df$gender == "M"] = 1

##############################
### DIAGNOSIS AGGREGATION ####
##############################
pedigree = read.csv("/Users/mduda/Google Drive/Work/PhenoDatabase/AGRE_2015/AGRE Pedigree Catalog 10-05-12/AGRE Pedigree Catalog 10-05-2012.csv")
pedigree = pedigree[c(3,12)]
pedigree$ASD = 0
pedigree$ASD[pedigree[,2] == "Autism"] = 2
pedigree$ASD[pedigree[,2] %in% c("ASD", "PDD-NOS", "BroadSpectrum")] = 1
colnames(pedigree) = c("individual", "Diagnosis", "ASD")
pedigree = pedigree[c(1,3,2)]

ac.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/Autism_Consortium_Data/All_Measures/AC_Medical_History.csv"
ac.df = df = read.csv(ac.file)
colnames(ac.df)[1] = 'Subject.Id'
ac.df$ASD = 0
ac.df$ASD[ac.df$ACCMHF_ASDChild %in% c(1,2)] = 1
ac.df$Diagnosis = "None"
ac.df$Diagnosis[ac.df$ACCMHF_ASDChild == 1] = 'autism'
ac.df$Diagnosis[ac.df$ACCMHF_ASDChild == 2] = 'autism spectrum'
ac.diag = ac.df[c("Subject.Id", "ASD", "Diagnosis")]
ac.diag$ASD[ac.diag$Diagnosis == 'autism spectrum'] = 1
ac.diag$ASD[ac.diag$Diagnosis == 'autism'] = 2
colnames(ac.diag)[1] = "individual"

ssc1.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/Proband Data/ssc_diagnosis.csv"
ssc2.file = "/Users/mduda/Google Drive/Work/PhenoDatabase/SSC Version 15 Phenotype Data Set 2/MZ Twin Data/ssc_diagnosis.csv"
ssc1.df = df = read.csv(ssc1.file)
ssc2.df = df = read.csv(ssc2.file)
ssc.df = rbind(ssc1.df, ssc2.df)
ssc.df$Diagnosis = ssc.df$q1a_autism_spectrum_dx
ssc.df$ASD = 0
ssc.df$ASD[ssc.df$q1_autism_spectrum == 'yes'] = 1
ssc.diag = ssc.df[c("individual", "ASD", "Diagnosis")]
ssc.diag1 <- with(ssc.diag,  ssc.diag[order(Diagnosis) , ])
ssc.diag1[c(69,100:103,106:393,1016,2260:2262,2285:2872),2] = 1
ssc.diag1[c(70:99,104:105,394:1015,1017:2259,2263:2284),2] = 2

svip1.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_1q21.1/diagnosis_summary.csv'
svip1.df = df = read.csv(svip1.file)
svip1.df = svip1.df[,c(1,14,70)]
svip2.file = '/Users/mduda/Google Drive/Work/PhenoDatabase/SVIP/SVIP_16p11.2/diagnosis_summary.csv'
svip2.df = df = read.csv(svip2.file)
svip2.df = svip2.df[,c(1,14,70)]
colnames(svip1.df) = colnames(svip2.df)
svip.df = rbind(svip1.df, svip2.df)
colnames(svip.df)
svip.df$Diagnosis = svip.df$diagnosis_summary.diagnosis_summary.v1a_diagnosis
svip.df$ASD = 0
svip.df$ASD[svip.df$diagnosis_summary.clinical_asd_dx == 'true'] = 1
svip.diag = svip.df[c("individual", "ASD", "Diagnosis")]
svip.diag$ASD[svip.diag$Diagnosis == "autistic-disorder"] = 2

diagnoses = rbind(pedigree, ac.diag, ssc.diag1, svip.diag)

## write.csv(diagnoses, "/Users/mduda/Google Drive/Work/ADOS_ML/diagnoses.csv")

##############################
####### MATRIX BUILDING ######
##############################

m1.diag = merge(m1.df, diagnoses, by.x="Subject.Id", by.y = "individual", all.x = T)
## m1.diag[2:30][m1.diag[2:30] > 3] = -1

## where clinical diagnosis is not available, we use the ADOS outcome as the class
for (i in (1:length(m1.diag$Subject.Id))){
  if (is.na(m1.diag$ASD[i])){
    if (m1.diag$A1[i] %in% c(3,4,8)){
      if (m1.diag$SA_RRI_total_calc[i] >= 16){
        m1.diag$ASD[i] = 2
        m1.diag$Diagnosis[i] = "Autism"
      }
      else if (m1.diag$SA_RRI_total_calc[i] >= 11){
        m1.diag$ASD[i] = 1
        m1.diag$Diagnosis[i] = "ASD"
      }
      else{
        m1.diag$ASD[i] = 0
        m1.diag$Diagnosis[i] = "Not Met"
      }
    }
    else if (m1.diag$A1[i] %in% c(0,1,2)){
      if (m1.diag$SA_RRI_total_calc[i] >= 12){
        m1.diag$ASD[i] = 2
        m1.diag$Diagnosis[i] = "Autism"
      }
      else if (m1.diag$SA_RRI_total_calc[i] >= 8){
        m1.diag$ASD[i] = 1
        m1.diag$Diagnosis[i] = "ASD"
      }
      else{
        m1.diag$ASD[i] = 0
        m1.diag$Diagnosis[i] = "Not Met"
      }
    }
  }
}

m1.diag = m1.diag[-32]

write.csv(m1.diag, "/Users/mduda/Google Drive/Work/ADOS_ML/m1/data/ados_m1_allData.csv")

### Module 2 ###
m2.diag = merge(m2.df, diagnoses, by.x="Subject.Id", by.y = "individual", all.x = T)


## where clinical diagnosis is not available, we use the ADOS outcome as the class
for (i in (1:length(m2.diag$Subject.Id))){
  if (is.na(m2.diag$ASD[i])){
    if (m2.diag$age_months[i] < 60){
      if (m2.diag$SA_RRI_total_calc[i] >= 10){
        m2.diag$ASD[i] = 2
        m2.diag$Diagnosis[i] = "Autism"
      }
      else if (m2.diag$SA_RRI_total_calc[i] >= 7){
        m2.diag$ASD[i] = 1
        m2.diag$Diagnosis[i] = "ASD"
      }
      else{
        m2.diag$ASD[i] = 0
        m2.diag$Diagnosis[i] = "Not Met"
      }
    }
    else if (m2.diag$age_months[i] >= 60){
      if (m2.diag$SA_RRI_total_calc[i] >= 9){
        m2.diag$ASD[i] = 2
        m2.diag$Diagnosis[i] = "Autism"
      }
      else if (m2.diag$SA_RRI_total_calc[i] == 8){
        m2.diag$ASD[i] = 1
        m2.diag$Diagnosis[i] = "ASD"
      }
      else{
        m2.diag$ASD[i] = 0
        m2.diag$Diagnosis[i] = "Not Met"
      }
    }
  }
}

m2.diag = m2.diag[-31]

write.csv(m2.diag, "/Users/mduda/Google Drive/Work/ADOS_ML/m2/data/ados_m2_allData.csv")


### Module 3 ###
m3.diag = merge(m3.df, diagnoses, by.x="Subject.Id", by.y = "individual", all.x = T)
## where clinical diagnosis is not available, we use the ADOS outcome as the class
for (i in (1:length(m3.diag$Subject.Id))){
  if (is.na(m3.diag$ASD[i])){
    if (m3.diag$SA_RRI_total_calc[i] >= 9){
      m3.diag$ASD[i] = 2
      m3.diag$Diagnosis[i] = "Autism"
    }
    else if (m3.diag$SA_RRI_total_calc[i] >= 7){
      m3.diag$ASD[i] = 1
      m3.diag$Diagnosis[i] = "ASD"
    }
    else{
      m3.diag$ASD[i] = 0
      m3.diag$Diagnosis[i] = "Not Met"
    }
  }
}

m3.diag = m3.diag[-31]


write.csv(m3.diag, "/Users/mduda/Google Drive/Work/ADOS_ML/m3/data/ados_m3_allData.csv")



##############################
####### SAMPLE SUMMARY #######
##############################

#### M1 ####
# 1742 total subjects - 120 ADOS imputed classes
# 1692 ASD
# 50 Control
# 34:1 ASD:Control

#### M2 ####
# 1389 total subjects - 75 ADOS imputed classes
# 1319 ASD
# 70 Control
# 19:1 ASD:Control

#### M3 ####
# 3143 total subjects - 125 ADOS imputed classes
# 2870 ASD
# 273 Non-ASD
# 11:1 ASD:Control

  