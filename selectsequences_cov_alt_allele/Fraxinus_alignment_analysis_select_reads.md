Analysis of Fraxinus user alignments
========================================================

Background
--------------------------------------------------------
Fraxinus user alingments with highest score for each puzzle are extracted from the SQL data base.  
Resulting file has following header  
* `"ID"  "HighScore"  "NoOfUsersWithHighScore"  "NoOfReadsinPuzzle"  "NoOfUsableReadsinPuzzle" "UserPercentDifferntToBWA"  "MeanPercentOfReadsDifferent"  "NoOfReadsinPuzzleCovALT"  "UserPercentDifferntToBWACovALT"	"MeanPercentOfReadsDifferentCovALT"`
* `ID  variant	HighScore	NoOfUsersWithHighScore	NoOfReadsinPuzzle	NoOfUsableReadsinPuzzle	UserPercentDifferntToBWA	MeanPercentOfReadsDifferent	NoOfReadsinPuzzleCovALT	UserPercentDifferntToBWACovALT	MeanPercentOfReadsDifferentCovALT`

Meaning of the terms used in the headers mentioned above:

| Term                                | Definition                                                                                                                            |
|:----------------------------------- |:------------------------------------------------------------------------------------------------------------------------------------  |
| HighScore                           | High Score                                                                                                                            |
| NoOfUsersWithHighScore	            |	Number of users with High Score for a puzzle                                                                                          |
| UserPercentDifferntToBWA            |	Praportion of Users in percent, that have made a puzzle alignment different from BWA                                                  |
| NoOfReadsinPuzzle			              |	Number of reads used in a Puzzule                                                                                                     |
| MeanPercentOfReadsDifferent         |	Mean of percent of reads that were aligned differently from BWA, from all users with high score that mapped differently for a puzzle  | 

Each puzzle has 21 nucleotides of reference and a maximum of 20 reads covering the region

Scoring of Alignment
Each match yields 5 points
Each mismatch    -3 points

For a SNP at one position in a puzzle, would result in a maximum score of 1940 
and maximum score for a perfect alignment is 2100 

Since there are reads that do not cover the variant position, 
these reads could give a higher score alignment with in the 21bp window, although it may not be a real alignment.
So i have used entries from "ashwellthorpe1_vs_tgac1-pe.sorted.bam" file

Two data sets were made, where for the initila dataset puzzles from above datasets are extracted and the data analysis was carried out
for the second dataset, puzzle information was used to extract the selected variant calls from vcf and then reads spanning the variant calls were pooled.
for puzzle data extraction, only these information from these reads is used. And the addtional reads not covering the variant position are ignored in calculations.

Analysis
--------------------------------------------------------
Resulting table was loaded in to R and the plots are generated to observe the trends in user alignments

Load libraries and the datage



There are 10087 puzzles in the present dataset


### Distribution of number of reads used in puzzles:


```r
plot1 <- ggplot(data = all_reads, aes(NoOfReadsinPuzzle)) + geom_histogram(binwidth = 1) + 
    scale_y_sqrt() + ggtitle("All reads in Puzzle distribution")
plot2 <- ggplot(data = all_reads, aes(NoOfUsableReadsinPuzzle)) + geom_histogram(binwidth = 1) + 
    scale_y_sqrt() + ggtitle("Usable reads in Puzzle distribution")
plot3 <- ggplot(data = all_reads, aes(NoOfReadsinPuzzleCovALT)) + geom_histogram(binwidth = 1) + 
    scale_y_sqrt() + ggtitle("Usable reads in Puzzle covering variant allele distribution")
grid.arrange(plot1, plot2, plot3, ncol = 3)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.pdf) 



### Distribution of number of users with a highscore for a puzzle:


```r
ggplot(data = all_reads, aes(NoOfUsersWithHighScore)) + geom_histogram(binwidth = 5) + 
    scale_y_sqrt() + ggtitle("Users with high Score distribution")
```

![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2.pdf) 



### Distribution of highscores from all puzzles:


```r
ggplot(data = all_reads, aes(HighScore)) + geom_histogram(binwidth = 10) + scale_y_sqrt() + 
    ggtitle("High Score distribution")
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3.pdf) 

```r

```



### Distribution of percentage of users made a puzzle alignment different from BWA:


```r
plot1 <- ggplot(data = all_reads, aes(UserPercentDifferntToBWA)) + geom_histogram(binwidth = 5) + 
    scale_y_sqrt() + ggtitle("All reads - % of users with HighScore different to BWA")
plot2 <- ggplot(data = all_reads, aes(UserPercentDifferntToBWACovALT)) + geom_histogram(binwidth = 5) + 
    scale_y_sqrt() + ggtitle("Selected reads - % of users with HighScore different to BWA")
grid.arrange(plot1, plot2, ncol = 2)
```

![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.pdf) 



### Distribution of mean of, percent of reads that were aligned differently from BWA, from all users with high score that mapped differently for a puzzle:


```r
plot1 <- ggplot(data = all_reads, aes(MeanPercentOfReadsDifferent)) + geom_histogram(binwidth = 1) + 
    scale_y_sqrt() + ggtitle("% Relative to all reads")
plot2 <- ggplot(data = all_reads, aes(MeanPercentOfReadsDifferentCovALT)) + 
    geom_histogram(binwidth = 1) + scale_y_sqrt() + ggtitle("% Relative to reads covering ALT allele")
grid.arrange(plot1, plot2, ncol = 2)
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.pdf) 



### Distribution of percentage of users made a puzzle alignment different from BWA with percent of reads different:


```r
plot1 <- ggplot(data = all_reads, aes(factor(round(all_reads$UserPercentDifferntToBWACovALT/5, 
    0) * 5), fill = factor(round(all_reads$MeanPercentOfReadsDifferentCovALT/5, 
    0) * 5))) + geom_bar(show_guide = FALSE) + labs(x = NULL, y = "Frequency") + 
    ggtitle("% user alignments different to BWA")
plot2 <- ggplot(data = all_reads, aes(factor(round(all_reads$UserPercentDifferntToBWACovALT/5, 
    0) * 5), fill = factor(round(all_reads$MeanPercentOfReadsDifferentCovALT/5, 
    0) * 5))) + geom_bar() + labs(x = NULL, y = "Frequency", fill = "% of reads different") + 
    ggtitle("% user alignments different to BWA") + ylim(0, 30) + theme(legend.position = "top")
grid.arrange(plot1, plot2, nrow = 2, heights = c(1.5, 1))
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.pdf) 




### Distribution of percentage of users made a puzzle alignment different from BWA:


```r
plot1 <- ggplot(data = all_reads, aes(factor(round(all_reads$UserPercentDifferntToBWACovALT/5, 
    0) * 5))) + geom_bar(show_guide = FALSE) + labs(x = NULL, y = "Frequency") + 
    ggtitle("% user alignments different to BWA")
plot2 <- ggplot(data = all_reads, aes(factor(round(all_reads$UserPercentDifferntToBWACovALT/5, 
    0) * 5))) + geom_bar() + labs(x = NULL, y = "Frequency") + ggtitle("% user alignments different to BWA") + 
    ylim(0, 30)
grid.arrange(plot1, plot2, nrow = 2, heights = c(1.5, 1))
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.pdf) 

```r

```



### Distribution of percentage of users made a puzzle alignment different from BWA with percent of reads different:


```r
snp <- all_reads[all_reads$variant == "snp", ]
row.names(snp) <- NULL

plot1 <- ggplot(data = snp, aes(factor(round(snp$UserPercentDifferntToBWACovALT/5, 
    0) * 5), fill = factor(round(snp$MeanPercentOfReadsDifferentCovALT/5, 0) * 
    5))) + geom_bar(show_guide = FALSE) + labs(x = NULL, y = "Frequency") + 
    ggtitle("% user alignments different to BWA")
plot2 <- ggplot(data = snp, aes(factor(round(snp$UserPercentDifferntToBWACovALT/5, 
    0) * 5), fill = factor(round(snp$MeanPercentOfReadsDifferentCovALT/5, 0) * 
    5))) + geom_bar() + labs(x = NULL, y = "Frequency", fill = "% of reads different") + 
    ggtitle("% user alignments different to BWA") + ylim(0, 30) + theme(legend.position = "top")
grid.arrange(plot1, plot2, nrow = 2, heights = c(1.5, 1))
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.pdf) 




### Distribution of percentage of users made a puzzle alignment different from BWA with percent of reads different:


```r
indel <- all_reads[all_reads$variant == "indel", ]
row.names(indel) <- NULL

plot1 <- ggplot(data = indel, aes(factor(round(indel$UserPercentDifferntToBWACovALT/5, 
    0) * 5), fill = factor(round(indel$MeanPercentOfReadsDifferentCovALT/5, 
    0) * 5))) + geom_bar(show_guide = FALSE) + labs(x = NULL, y = "Frequency") + 
    ggtitle("% user alignments different to BWA")
plot2 <- ggplot(data = indel, aes(factor(round(indel$UserPercentDifferntToBWACovALT/5, 
    0) * 5), fill = factor(round(indel$MeanPercentOfReadsDifferentCovALT/5, 
    0) * 5))) + geom_bar() + labs(x = NULL, y = "Frequency", fill = "% of reads different") + 
    ggtitle("% user alignments different to BWA") + ylim(0, 30) + theme(legend.position = "top")
grid.arrange(plot1, plot2, nrow = 2, heights = c(1.5, 1))
```

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.pdf) 





