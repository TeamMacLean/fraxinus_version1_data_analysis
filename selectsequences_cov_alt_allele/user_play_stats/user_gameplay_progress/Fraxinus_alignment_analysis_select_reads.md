Analysis of Fraxinus Player stats
========================================================

Background
--------------------------------------------------------
Each Fraxinus player user access stats are printed such as number of days they are active and number pattern alignments they have attempted during the period

Resulting file has following header  
* `"UserId"   "NoofDays"  "TotalTasks"  "MeanTaskperDay"    "FBScore"   "FBBonus"   "FBID"`  

Meaning of the terms used in the headers mentioned above:

| Term              | Definition                                                  |
|:----------------- |:----------------------------------------------------------- |
| UserId            | User Id number                                              |
| NoofDays	        |	Number of days user has actively visited Fraxinus           |
| TotalTasks        |	Total number of pattern alignmnets perfomred by the User    |
| MeanTaskperDay	  |	Mean tasks per day                                          |
| FBScore           |	Points scored in Facebook                                   | 
| FBBonus           | Total number of bonus points achieved                       | 
| FBID              | Facebook User Id                                            | 

Analysis
--------------------------------------------------------
Resulting table was loaded in to R and the plots are generated to observe the trends in user alignments

Load libraries and the datage



There are 
## 24822 
players have accesssed Fraxinus


### Distribution of number of active days from all players:


```r
ggplot(data = user_data, aes(NoofDays)) + geom_histogram(binwidth = 5) + scale_y_sqrt() + 
    ggtitle("Distribution of no. of active days from all players")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.pdf) 



### Distribution of number of alignment task from all palyers:


```r
ggplot(data = user_data, aes(TotalTasks)) + geom_histogram(binwidth = 20) + 
    scale_y_sqrt() + ggtitle("Distribution of no. of alignment tasks from all players")
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.pdf) 



### Distribution of mean number of alignment task per day from all palyers:


```r
ggplot(data = user_data, aes(TotalTasks/NoofDays)) + geom_histogram(binwidth = 5) + 
    scale_y_sqrt() + ggtitle("Distribution of mean no. of alignment tasks per day from all players")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.pdf) 



### Distribution of facebook scores from all players:


```r
ggplot(data = user_data, aes(FBScore)) + geom_histogram(binwidth = 20) + scale_y_sqrt() + 
    ggtitle("Facebook scores from all players")
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.pdf) 



### Distribution of frequency days:


```r
user_data <- user_data[order(user_data$NoofDays, decreasing = TRUE), ]
user_data$Rank <- c(1:length(user_data$UserId))
ggplot(data = user_data, aes(Rank, NoofDays)) + geom_point() + scale_x_log10() + 
    scale_y_log10() + ggtitle("Log-log distribution")
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.pdf) 



### Distribution of frequency tasks:


```r
user_data <- user_data[order(user_data$TotalTasks, decreasing = TRUE), ]
user_data$Rank <- c(1:length(user_data$UserId))
ggplot(data = user_data, aes(Rank, TotalTasks)) + geom_point() + scale_x_log10() + 
    scale_y_log10() + ggtitle("Log-log distribution")
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.pdf) 



### Distribution of frequency FBScore:


```r
user_data <- user_data[order(user_data$FBScore, decreasing = TRUE), ]
user_data$Rank <- c(1:length(user_data$UserId))
ggplot(data = user_data, aes(Rank, FBScore)) + geom_point() + scale_x_log10() + 
    scale_y_log10() + ggtitle("Log-log distribution")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.pdf) 




### Cumulative distribution of visitor days:


```r
days <- user_data$NoofDays
breaks <- seq(-1, 19, by = 1)
dayscut <- cut(days, breaks, right = FALSE)
daysfreq <- table(dayscut)
days.freq <- cbind(daysfreq)
dayspercentfreq <- days.freq
dayspercentfreq[1:20] <- (days.freq[1:20] * 100)/nrow(user_data)
cumfreq <- data.frame(CumulativeUsers = cumsum(dayspercentfreq), NoofDays = seq(-1, 
    18, by = 1))
ggplot(data = cumfreq, aes(NoofDays, CumulativeUsers)) + geom_point() + xlim(0, 
    20) + ggtitle("Cumulative User distribution - active days")
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.pdf) 




### Cumulative distribution of visitor tasks:


```r
tasks <- user_data$TotalTasks
breaks = seq(-1, 19, by = 1)
taskscut <- cut(tasks, breaks, right = FALSE)
tasksfreq <- table(taskscut)
tasks.freq <- cbind(tasksfreq)
taskspercentfreq <- tasks.freq
taskspercentfreq[1:20] <- (tasks.freq[1:20] * 100)/nrow(user_data)
cumfreq <- data.frame(CumulativeUsers = cumsum(taskspercentfreq), NoofTasks = seq(-1, 
    18, by = 1))
ggplot(data = cumfreq, aes(NoofTasks, CumulativeUsers)) + geom_point() + xlim(0, 
    20) + ggtitle("Cumulative User distribution - active tasks")
```

```
## Warning: Removed 1 rows containing missing values (geom_point).
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.pdf) 



There are 
## 24822 
players have accesssed Fraxinus

There are 
## 22756
players have accessed the site 
## for less than three days

they account for
## 91.6767
percent of the players and these player have provided

## 31.3202
percent of the aligment solutions provided by all players

