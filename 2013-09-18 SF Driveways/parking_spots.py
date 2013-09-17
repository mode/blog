###################
# File: parking_spots.py
# Description: For given inputs, finds the number of parking street spots in
#       if driveways are randomly positioned vs positioned to optimize for 
#       street parking.
# Author: Benn Stancil (@bennstancil, benn@modeanalytics.com)
###################


#################
##  Libraries  ##
#################

from random import randint
import random
import math

################
##   Inputs   ##
################

## Estimates in feet

driveway_width = 10
parking_spot_width = 16

short_block_length = 300
long_block_length = 700
variability = .1

short_block_houses = 10
long_block_houses = 23
driveway_percent = 0.7

residential_block_percent = .5
blocks_in_sf = 7400

#################
##  Functions  ##
#################

## Calculates parking spots fro best arragement on a given street
def best_arrangement(street_length,driveway_width,parking_spot,houses,driveway_percent):
    with_driveway = int(houses*driveway_percent)
    house_width = street_length/houses
    
    n = 0
    x = 0
    
    for i in range(with_driveway):
        x += driveway_width
        while x < (house_width * (i+1)):
            n += 1
            x += parking_spot
    if x > street_length:
        while x > street_length:
            n -= 1
            x -= parking_spot
    else:
        add = math.floor((street_length - x)/parking_spot)
        n = n + add
    return n

## Picks random spot for driveway for given house
def pick_driveway_spot(driveway_width,house_width):
    start_spot = random.random() * (house_width - driveway_width)
    return start_spot

## Picks all random driveway spots for given street
def pick_all_start_spots(houses,driveway_width,street_length,driveway_percent):
    driveway_spots = []
    house_width = street_length/houses
    for i in range(houses):
        if random.random() <= driveway_percent:
            start_spot = pick_driveway_spot(driveway_width,house_width)
            street_spot = start_spot + (i * house_width)
            driveway_spots += [street_spot]
    return driveway_spots

## Counts spots on a given street with set driveway positions
def count_spots(houses,starting_spots,street_length,parking_spot,driveway_width):
    parking_spots = 0
    for i in range(len(starting_spots)):
        if i == 0:
            space_for_parking = starting_spots[i] - 0
            spots = math.floor(space_for_parking/parking_spot)
            parking_spots = parking_spots + spots
        else:
            space_for_parking = starting_spots[i] - (starting_spots[i-1] + driveway_width)
            spots = math.floor(space_for_parking/parking_spot)
            parking_spots = parking_spots + spots
    
    if len(starting_spots) == 0:
        last_spot = 0
    else:
        last_spot = max(starting_spots) + driveway_width
    
    last_space = street_length - last_spot
    last_spots = math.floor(last_space/parking_spot)
    parking_spots += last_spots
    
    return parking_spots

## Randomizes driveway positions and counts parking spots
def random_spots(houses,driveway_width,parking_spot,street_length,driveway_percent):
    starting_spots = pick_all_start_spots(houses,driveway_width,street_length,driveway_percent)
    spots = count_spots(houses,starting_spots,street_length,parking_spot,driveway_width)
    return spots

## Loops over chosen number of streets of random length, finds driveway positions and counts spots
## Includes error term for variability in street length, driveway width, space size, and houses per street
## For those inputs, calcutes spots in random street and spots in optimal arrangement

def block_loop(houses,driveway_width,parking_spot,street_length,driveway_percent,blocks,error):
    rand_all = 0
    best_all = 0
    for i in range(blocks):
        sl = street_length + (((1 - random.random()*2)*error) * street_length)
        dw = driveway_width + (((1 - random.random()*2)*error) * driveway_width)
        ps = parking_spot + (((1 - random.random()*2)*error) * parking_spot)
        dp = driveway_percent + (((1 - random.random()*2)*error) * driveway_percent)
        h = randint(round(houses - error*houses),round(houses + error*houses))
        rand_spots = random_spots(h,dw,ps,sl,dp)
        best_spots = best_arrangement(sl,dw,ps,h,dp)
        rand_all += rand_spots
        best_all += best_spots
    return rand_all,best_all

#################
##   Script    ##
#################

## Determines number of residental blocks
## Blocks are multiplied by 4 because each block is assumed to have four sides

blocks = int(blocks_in_sf*residential_block_percent)*4

## Calculates number of random spots (x1) and optimal spots (x2) on short blocks and random (x3) and optimal (x4) spots on long blocks.
## Output formatted like (x1,x2,x3,x4)
## Blocks are divided by two because have the block sides are assumed to be short and half the sides are assumed to be long

block_loop(short_block_houses, driveway_width, parking_spot_width, short_block_length, driveway_percent, blocks/2, variability) + block_loop(long_block_houses, driveway_width, parking_spot_width, long_block_length, driveway_percent, blocks/2, variability)
