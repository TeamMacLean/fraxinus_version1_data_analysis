Analysis of Fraxinus Player stats
========================================================

Background
--------------------------------------------------------
Each Fraxinus player user access stats are printed such as number of days they are active and number pattern alignments they have attempted during the period

Resulting file has following header  
* `"Datsetid"   "Players_total"  "Players_active"  "No.ofalignments"    "Notempty_alignments"   "Maxscoreperread"   "Readnumber"`  

Meaning of the terms used in the headers mentioned above:

| Term                | Definition                                                  |
|:------------------- |:----------------------------------------------------------- |
| Datsetid            | Pattern Id |
| Players_total       |	Number of palyers accessed this pattern |
| Players_active      |	Number of palyers accessed this pattern gave an alignment |
| No.ofalignments     |	Total alignments registerd |
| Notempty_alignments |	Usable alignments that are not empty | 
| Maxscoreperread     | Highest score achieved divided by read number | 
| Readnumber          | No of reads in the pattern | 

Analysis
--------------------------------------------------------
Resulting table was loaded in to R and the plots are generated to observe the trends in user alignments

Load libraries and the datage



There are 
## 10087 
patterns presented in version 1 of Fraxinus


### Distribution of players visiting each puzzle:


```r
ggplot(data = user_data, aes(Players_total)) + geom_histogram(binwidth = 2) + 
    scale_y_sqrt() + ggtitle("Distribution of no. of players each puzzle")
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.pdf) 



### Distribution of active players visiting each puzzle:


```r
ggplot(data = user_data, aes(Players_active)) + geom_histogram(binwidth = 2) + 
    scale_y_sqrt() + ggtitle("Distribution of no. of active players each puzzle")
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.pdf) 



### Distribution of number of alignment per each puzzle:


```r
ggplot(data = user_data, aes(No.ofalignments)) + geom_histogram(binwidth = 2) + 
    scale_y_sqrt() + ggtitle("Distribution of number of alignment per each puzzle")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.pdf) 



### Distribution of number of usable alignment per each puzzle:


```r
ggplot(data = user_data, aes(Notempty_alignments)) + geom_histogram(binwidth = 2) + 
    scale_y_sqrt() + ggtitle("Distribution of number of usable alignment per each puzzle")
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.pdf) 




### Distribution of number of empty alignment per each puzzle:


```r
user_data$Empty <- user_data$No.ofalignments - user_data$Notempty_alignments
ggplot(data = user_data, aes(Empty)) + geom_histogram(binwidth = 2) + scale_y_sqrt() + 
    ggtitle("Distribution of number of empty alignment per each puzzle")
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.pdf) 




### Distribution of maximum scored per read per each puzzle:


```r
ggplot(data = user_data, aes(Maxscoreperread)) + geom_histogram(binwidth = 1) + 
    scale_y_sqrt() + ggtitle("Distribution of number of usable alignment per each puzzle")
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.pdf) 



### Distribution of number of reads per each puzzle:


```r
ggplot(data = user_data, aes(Readnumber)) + geom_histogram(binwidth = 1) + scale_y_sqrt() + 
    ggtitle("Distribution of number of usable alignment per each puzzle")
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.pdf) 



### Distribution of frequency days:

{r fig.width=7, fig.height=6}
user_data <- user_data[order(user_data$NoofDays, decreasing = TRUE),]
user_data$Rank <- c(1:length(user_data$UserId))
ggplot(data=user_data, aes(Rank, NoofDays)) + geom_point() + scale_x_log10() + scale_y_log10() + ggtitle("Log-log distribution")

```




### Distribution of frequency tasks:

{r fig.width=7, fig.height=6}
user_data <- user_data[order(user_data$TotalTasks, decreasing = TRUE),]
user_data$Rank <- c(1:length(user_data$UserId))
ggplot(data=user_data, aes(Rank, TotalTasks)) + geom_point() + scale_x_log10() + scale_y_log10() + ggtitle("Log-log distribution")

```




### Distribution of frequency FBScore:

{r fig.width=7, fig.height=6}
user_data <- user_data[order(user_data$FBScore, decreasing = TRUE),]
user_data$Rank <- c(1:length(user_data$UserId))
ggplot(data=user_data, aes(Rank, FBScore)) + geom_point() + scale_x_log10() + scale_y_log10() + ggtitle("Log-log distribution")

```




### Cumulative distribution of visitor days:

{r fig.width=7, fig.height=6}
user_data$NoofDays[user_data$NoofDays == 0] <- 1
days <- user_data$NoofDays
breaks <- seq(0,20, by=1)
dayscut <- cut(days, breaks, right=FALSE)
daysfreq <- table(dayscut)
days.freq <- cbind(daysfreq)
dayspercentfreq <- days.freq
dayspercentfreq[1:20] <- (days.freq[1:20]*100)/nrow(user_data)
cumfreq <- data.frame("CumulativeUsers"=cumsum(dayspercentfreq), "NoofDays"= seq(0,19, by=1))
ggplot(data=cumfreq, aes(NoofDays, CumulativeUsers)) + geom_point() + ggtitle("Cumulative User distribution - active days")

```



### Cumulative distribution of visitor tasks:

{r fig.width=7, fig.height=6}
tasks <- user_data$TotalTasks
breaks = seq(-1,19, by=1)
taskscut <- cut(tasks, breaks, right=FALSE)
tasksfreq <- table(taskscut)
tasks.freq <- cbind(tasksfreq)
taskspercentfreq <- tasks.freq
taskspercentfreq[1:20] <- (tasks.freq[1:20]*100)/nrow(user_data)
cumfreq <- data.frame("CumulativeUsers"=cumsum(taskspercentfreq), "NoofTasks"= seq(-1,18, by=1))
ggplot(data=cumfreq, aes(NoofTasks, CumulativeUsers)) + geom_point() + xlim(0,20) + ggtitle("Cumulative User distribution - active tasks")

```



