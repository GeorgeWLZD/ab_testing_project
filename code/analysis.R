#ANALYSIS OF VARIANCE ===================================================================================================

#The steps we will follow to perform this analysis are:
#1. Import the data
#2. Perform simple transformations: NA and recoding (1=A, 2=B, and 3=C)
#3. Provide a brief description of the data
#4. Explore the normal distribution with a histogram
#5. Confirm the normal distribution with the K-S test
#6. Confirm the homoscedasticity assumption with Levene's test
#7. Run the ANOVA
#8. Run the Bonferroni and Tukey post hoc tests

#1. Import the data ====================================================================================================

#Set a new working directory
setwd("C:/Users/Usuario/Downloads/0_data_general/Aditionals/1_Materials/Portfolio/Statistical_Analysis/ABN_Testing_store")
#Verify the working directory
getwd()

#Read the file with the sample
sample <- read.csv("Sampling.csv", header = TRUE)

#Verify if it is a dataframe
class(sample)

#View the first few rows
head(sample)

#Check the data structure
str(sample)

#2. Perform simple transformations =====================================================================================

#Load the dplyr package
library(dplyr)

#Check if there is at least one missing value
any(is.na(sample))

#Change the variable type to factor
sample$Copy_Type <- as.factor(sample$Copy_Type)

#Verify the change to factor
str(sample$Copy_Type)

# Perform recoding (car package must be loaded)
sample$Copy_Type <- factor(sample$Copy_Type,
                           levels = levels(sample$Copy_Type),
                           labels = c("A", "B", "C"),
                           ordered = FALSE)

#Verify the change
head(sample, 10)

#Check unique values
unique(sample$Copy_Type)
nrow(sample)

#3. Brief description of the data ====================================================================================

#Summary table
sample %>%                               
  group_by(Copy_Type) %>% 
  summarise(min = min(Sales),
            q1 = quantile(Sales, 0.25),
            median = median(Sales),
            mean = mean(Sales),
            q3 = quantile(Sales, 0.75),
            max = max(Sales))

#Amount of cases per copy type
table(sample$Copy_Type)

#Line chart using ggplot2
library(ggplot2)
line <- ggplot(sample, aes(Copy_Type, Sales)) 
line + 
  stat_summary(fun = mean, geom = "point") + 
  stat_summary(fun = mean, geom = "line", aes(group = 1), colour = "Blue", linetype = "dashed") +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", width = 0.2) +
  stat_summary(
    fun = mean, 
    geom = "text", 
    aes(label = round(..y.., 2)), 
    vjust = -0.5  # Ajusta la posición del texto
  ) +
  labs(x = "Copy Type", y = "Average Sales", title = "Average Sales by Copy Type")

#4. Explore the normal distribution with a histogram ===================================================================

#Histogram
sales_hist <- ggplot(sample, aes(x = Sales)) + 
  geom_histogram(binwidth = 10, color = "black", fill = "gray") +
  labs(x = "Total Sales", y = "Frequency", title = "Sales Histogram")
sales_hist

#5. Confirm the normal distribution with the K-S test ==================================================================

#Normality tests
ks.test(sample$Sales, "pnorm", mean = mean(sample$Sales), sd = sd(sample$Sales))

#Apply Liliefors corrections
library(nortest)
lillie.test(sample$Sales)

#6. Confirm the homoscedasticity assumption with Levene's test =========================================================

#Visualize this with a boxplot
boxplot(Sales ~ Copy_Type,
        data = sample,
        main = "Sales by Copy",
        xlab = "Copy Type",
        ylab = "Sales",
        col = "steelblue",
        border = "black")

#Levene test
library(car)
leveneTest(sample$Sales, sample$Copy_Type, center = "mean")

#7. Run the ANOVA ======================================================================================================

MyAnalysis <- aov(Sales ~ Copy_Type, data = sample)
summary(MyAnalysis)

#8. Run the Bonferroni and Tukey post hoc tests ========================================================================

#Bonferroni
pairwise.t.test(sample$Sales, sample$Copy_Type, paired = FALSE, p.adjust.method = "bonferroni")

#Tukey
tukey <- TukeyHSD(MyAnalysis)
tukey
