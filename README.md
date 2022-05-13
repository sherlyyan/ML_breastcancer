# SY_machinelearning

The data is from Wisconsin Breast Cancer Database
Compiled by Dr. William Wohlberg

699 instances of 9 attributes, broken Into 2 classes: Benign or Malignant
9. Class distribution:
Benign: 458 (65.5%)
Malignant: 241 (34.5%)

1. Sample code number		id number
2. Clump Thickness			1 - 10
3. Uniformity of Cell Size		1 - 10
4. Uniformity of Cell Shape		1 - 10
5. Marginal Adhesion			1 - 10
6. Single Epithelial Cell Size		1 - 10
7. Bare Nuclei				1 - 10
8. Bland Chromatin			1 - 10
9. Normal Nucleoli			1 - 10
10. Mitoses				1 - 10
11. Class:				(2 for benign, 4 for malignant)

Models used:
1. Clustering

2. Ridge & Lasso - determine which predictors are driving the model

3. Classification Trees - easy to interpret, fast to train

4. Bagging Trees & Forest - high accuracy


**Each model did well, over 95% accurate
However, different models performed differently in terms of the errors we made
Clustering showed that the data had a clean break in the data to create two clusters
Ridge performed slightly better than lasso, but lasso magnified the predictors that were more important (although it couldn’t eliminate any predictors)
Tree limits type II error, and is easily interpretable
Forest minimizes type I error, harder to interpret, takes longer to train
If prioritizing minimizing Overtreatment and Unnecessary Expenditures (Type I), choose Tree Model.
If prioritizing minimizing Missed Diagnoses and Potential Malpractice Suits (Type II), choose Random Forest.

