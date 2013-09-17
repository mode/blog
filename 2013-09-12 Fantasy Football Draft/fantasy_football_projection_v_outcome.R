###################
# File: drafting_model.R
# Description: Examines relationship between league point projections and
#		draft results.
# Author: Benn Stancil (@bennstancil, benn@modeanalytics.com
###################


###################
###  Libraries  ###
###################

library('ggplot2')
library('gdata')
library('pylr')


###################
###  Functions  ###
###################

clean_name <- function(name_list) {
    l <- vector()
    for (i in 1:length(name_list)) {
        n1 <- unlist(strsplit(name_list[[i]],","))[1]
        n2 <- unlist(strsplit(n1,"\\*"))[1]
        n3 <- unlist(strsplit(n2,"D/ST"))[1]
        l <- rbind(l,n3)
    }
    return(l)
}

in_top_ten_rounds <- function(p,data) {
    trim_set <- data[data$espn_avg_draft_position <= 100,]
    return(trim_set)
}

###############
###  Data  ###
##############

#Load Data from CSV
espn_draft <- read.csv("~/fantasy_football_09_12/espn_draft_results.csv")
espn_proj  <- read.csv("~/fantasy_football_09_12/espn_projections.csv")
cbs_draft  <- read.csv("~/fantasy_football_09_12/cbs_draft_results.csv")
cbs_proj   <- read.csv("~/fantasy_football_09_12/cbs_projections.csv")

#Clean Names
cbs_proj <- cbs_proj[cbs_proj$'player' != "Steve Smith, TB",]
cbs_proj <- cbs_proj[cbs_proj$'player' != "Zach Miller, TB",]

espn_draft$'clean_name' <- trim(clean_name(as.character(espn_draft$'player')))
espn_proj$'clean_name'  <- trim(clean_name(as.character(espn_proj$'player')))
cbs_draft$'clean_name'  <- trim(clean_name(as.character(cbs_draft$'player')))
cbs_proj$'clean_name'   <- trim(clean_name(as.character(cbs_proj$'player')))


#Join ESPN and CBS data
espn <- merge(x = espn_draft, y = espn_proj, by = c("clean_name","position"))
espn <- espn[,c('clean_name','position','espn_position_draft_position','espn_avg_draft_position',
    'espn_avg_bid_value','espn_pts','espn_pts_rank_by_position','espn_bid_rank_by_position')]

cbs  <- merge(x = cbs_draft, y = cbs_proj, by = c("clean_name","position"))
cbs  <- cbs[,c('clean_name','position','cbs_position_draft_position','cbs_avg_draft_position',
    'cbs_overall_draft_position','cbs_pts','cbs_pts_rank_by_position')]

all_ff <- merge(x= espn, y = cbs, by = c("clean_name","position"))


#Trim all ESPN players who never get drafted
all_ff_trim <- all_ff[all_ff$'espn_avg_draft_position' < 170,]


##################
###  Analysis  ###
##################

#How do draft picks relate to results?
ggplot(all_ff_trim, aes(x=all_ff_trim$espn_pts_rank_by_position, y=all_ff_trim$espn_position_draft_position, color = position)) +
    geom_point(shape=1)

summary(lm(espn_pts_rank_by_position ~ espn_position_draft_position, data = all_ff_trim))


#How do point projections correlate with bids?
ggplot(all_ff_trim, aes(x=all_ff_trim$espn_avg_draft_position, y=all_ff_trim$espn_avg_bid_value)) +
    geom_point(shape=1)


#Comparing Predicitions and Results

#Differences in points and overall draft position
pts_rank_diff  <- all_ff_trim$espn_pts_rank_by_position - all_ff_trim$cbs_pts_rank_by_position
draft_avg_diff <- all_ff_trim$espn_avg_draft_position - all_ff_trim$cbs_avg_draft_position

#Plot and summary statistics
ggplot(all_ff_trim, aes(x=pts_rank_diff, y=draft_avg_diff)) +
    geom_point(shape=1) + geom_smooth(method=lm)

summary(lm(pts_rank_diff ~ draft_avg_diff, data = all_ff_trim))

#Only include picks in the top 100
pts_rank_diff_rnd  <- in_top_ten_rounds(1,all_ff_trim)$espn_pts_rank_by_position - 
	in_top_ten_rounds(1,all_ff_trim)$cbs_pts_rank_by_position
draft_avg_diff_rnd <- in_top_ten_rounds(1,all_ff_trim)$espn_avg_draft_position - 
	in_top_ten_rounds(1,all_ff_trim)$cbs_avg_draft_position


ggplot(in_top_ten_rounds(1,all_ff_trim), aes(x=pts_rank_diff_rnd, y=draft_avg_diff_rnd)) +
    geom_point(shape=1) + geom_smooth(method=lm)

summary(lm(pts_rank_diff_rnd ~ draft_avg_diff_rnd, data = in_top_ten_rounds(1,all_ff_trim)))


#Comparing Predictions and Bids
with_bids <- all_ff_trim
with_bids$'cbs_avg_bid_value'  <- 55.253*exp(-0.026*with_bids$'cbs_avg_draft_position')

#Find differences
bid_avg_diff <- with_bids$espn_avg_bid_value - with_bids$cbs_avg_bid_value
bid_avg_diff_rnd <- in_top_ten_rounds(1,with_bids)$espn_avg_bid_value - 
	in_top_ten_rounds(1,with_bids)$cbs_avg_bid_value

#Plotting and summary stats
#Top 100 picks
ggplot(in_top_ten_rounds(1,with_bids), aes(x=pts_rank_diff_rnd, y=bid_avg_diff_rnd)) +
    geom_point(shape=1) + geom_smooth(method=lm)

summary(lm(pts_rank_diff_rnd ~ bid_avg_diff_rnd, data = in_top_ten_rounds(1,with_bids)))




