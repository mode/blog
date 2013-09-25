###################
# File: drafting_model.R
# Description: Calculates best possible fantasy football draft results. Currently configured
#	for ESPN, but can be configured for CBS by replacing all espn_whatever column names with
# 	cbs_whatever column names.
# Author: Benn Stancil (@bennstancil, benn@modeanalytics.com
###################


###################
###  Libraries  ###
###################

library('ggplot2')
library('gdata')
library('gtools')


###################
###  Functions  ###
###################

#Cleans players names of team abbreviations
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

#Trims player list down to just those who would be starters in a 10-team league
trim_players <- function(players,teams) {
	trim_a <- players[(players$'espn_pts_rank_by_position' <= teams) |
						(players$'espn_pts_rank_by_position' <= teams*3 &
							players$'position' == "wr") |
						(players$'espn_pts_rank_by_position' <= teams*3 &
							players$'position' == "rb"),]
	return(trim_a) 
}

#Finds all picks given your first pick and league size
find_pick_numbers <- function(draft_pick,teams) {
	your_picks <- c(draft_pick,
					2*teams - draft_pick + 1,
					2*teams + draft_pick,
					4*teams - draft_pick + 1,
					4*teams + draft_pick,
					6*teams - draft_pick + 1,
					6*teams + draft_pick,
					8*teams - draft_pick + 1,
					8*teams + draft_pick,
					10*teams - draft_pick + 1)
	return(your_picks)
}

#Generates all possible permutations of position pick orders
possible_orders <- function () {
	numbers = permutations(10,10)
	numbers[numbers == 1] <- "qb"
	numbers[numbers == 2] <- "rb"
	numbers[numbers == 3] <- "rb"
	numbers[numbers == 4] <- "rb"
	numbers[numbers == 5] <- "wr"
	numbers[numbers == 6] <- "wr"
	numbers[numbers == 7] <- "wr"
	numbers[numbers == 8] <- "te"
	numbers[numbers == 9] <- "k"
	numbers[numbers == 10] <- "dst"
	numbers <- unique(numbers)
	return(numbers)
}

#Simulates draft results, given players, your picks, and your position order
pick_scores <- function(position_vector,pick_vector,players) {
	pick_pts <- vector()
	players_left <- players
	l <- length(position_vector)
	for (i in 1:l) {
		pos_drafted <- players_left[players_left$'position' == position_vector[i],]
		highest_left <- max(pos_drafted$'pick')
		if (highest_left >= pick_vector[i]) {
			find_pick <- pos_drafted[pos_drafted$'pick' >= pick_vector[i],]
			pick_pts <- c(pick_pts,find_pick[1,]$'espn_pts')
			players_left <- players_left[players_left$'pick' != find_pick[1,]$'pick',]
		}
		else {
			l <- length(pos_drafted[,1])
			pick_pts <- c(pick_pts,pos_drafted[l,]$'espn_pts')
			pick_num <- c(pick_pts,pos_drafted[l,]$'pick')
			players_left <- players_left[players_left$'pick' != pos_drafted[l,]$'pick',]
		}
	}
	return(pick_pts)
}

#Loops over all position combinations for a given first pick position -- IT'S VERY SLOW
draft_iterations <- function(draft_pick,teams,players,position_matrix) {
	perm <- length(position_matrix[,1])
	pick_vector <- find_pick_numbers(draft_pick,teams)
	top_scores <- c(1:101)		#This is hella hacky
	summary <- vector()
	
	for(i in 1:perm) {
		position_vector <- position_matrix[i,]
		perm_score <- pick_scores(position_vector,pick_vector,players)
		score <-  sum(perm_score)
		n <- length(top_scores)
		if (score >= sort(top_scores,partial=n-100)[n-100]) {
			perm_summary <- c(score,pos_orders[i,],perm_score)
			summary <- rbind(summary,perm_summary)
			top_scores <- c(top_scores,score)
		}
		if (i %% 100 == 0) {
			print(i)
		}
	}
	ordered <- summary[rev(sort.list(summary[,1])),]
	top_hundo <- ordered[1:100,]
	return(top_hundo)
}

#Loops over each starting draft position. Is 10x slower than then very iteration function
draft_type_loop <- function(players,league_sizes,pos_orders) {
	final_summary <- vector()
	l <- length(league_sizes)
	for (i in 1:l) {
		print("--league size--")
		print(i)
		#Trim data before running
		plyrs <- trim_players(players,league_sizes[i])
		plyrs <- plyrs[,c('clean_name','position','espn_avg_draft_position','espn_pts','espn_pts_rank_by_position')]
		plyrs <- plyrs[with(plyrs, order(espn_avg_draft_position, espn_pts)),]
		
		#Add draft position counter
		player_count <- length(plyrs[,1])
		counter <- data.frame(pick = c(1:player_count))
		plyrs <- cbind(plyrs,counter)	
		
		for (j in 1:league_sizes[i]) {
			print("--draft pick--")
			print(j)
			top_hundo <- draft_iterations(j,league_sizes[i],plyrs,pos_orders)
			summary <- cbind(league_sizes[i],j,top_hundo)
			final_summary <- rbind(final_summary,summary)
		}
	}
	return(final_summary)
}

##############
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
    'espn_avg_bid_value','espn_pts','espn_pts_rank_by_position')]

cbs  <- merge(x = cbs_draft, y = cbs_proj, by = c("clean_name","position"))
cbs  <- cbs[,c('clean_name','position','cbs_position_draft_position','cbs_avg_draft_position',
    'cbs_overall_draft_position','cbs_pts','cbs_pts_rank_by_position')]

all_ff <- merge(x= espn, y = cbs, by = c("clean_name","position"))

#################
###  Scripts  ###
#################

#Variables
players <- all_ff
league_size <- 10

#Get all possible position orders and picks - takes some time
pos_orders <- possible_orders()

#Calculate all possibilities - takes a very long time
top_results_ten <- draft_type_loop(players,league_size,pos_orders)
