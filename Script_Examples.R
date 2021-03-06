### Examples

### Required pacakges
require(bipartite)
require(plotrix) # for plotting

### Load functions

source("./Functions/extinction.mod.R")
source("./Functions/one.second.extinct.mod.R")
source("./Functions/calc.mean.one.second.extinct.mod.R")
source("./Functions/matrix.p1.R")
source("./Functions/IC.R") # calc of 95 percent confidence interval

### Load the data

# Network - mutualistic plant-hummingbird network (from Vizentin-Bugoni et al. (2016)  https://doi.org/10.1111/1365-2656.12459)
network <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_network.csv", row.names = 1))
network

# Raw hummingbirds abundances
h_abund <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_h_abund.csv", row.names = 1))
h_abund

# Raw plant abundance
pl_abund <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_pl_abund.csv", row.names = 1))
pl_abund

# Trait (bill lenght) of hummingbirds
h_morph <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_h_morph.csv", row.names = 1))
h_morph

# Trait (corolla depth) of plants
pl_morph <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_pl_morph.csv", row.names = 1))
pl_morph

# Phenological distribution of hummingbirds
h_phen <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_h_phen.csv", row.names = 1))
h_phen

# Phenological distribution of plants
pl_phen <- as.matrix(read.csv("./DataSetExamples/SantaVirginia/SantaVirginia_dataset_pl_phen.csv", row.names = 1))
pl_phen

### Define rewiring probabilities

## Abundances

# Relative abundances of pairwise bird and plant species
abundance <- pl_abund%*%t(h_abund)
abundance

# Relative abundances of plants
abundance_pl <- sweep(abundance, 2, colSums(abundance), "/")
abundance_pl

# Relative abundances of hummingbirds
abundance_h <- sweep(abundance, 1, rowSums(abundance), "/") 
abundance_h

## Morphological matching

# Morphological matching
morphological <- 1-(as.matrix(vegdist(rbind(h_morph,pl_morph), method = "gower"))[(length(h_morph)+1):(length(h_morph)+length(pl_morph)),(1:length(h_morph))])
morphological

## Temporal coexistence

# Relative temporal coexistence (phenological overlap)
temporal <- pl_phen%*%t(h_phen)
temporal <- temporal/max(temporal) # In our case 'max(temporal)' equals 24 as at least two partners overlap thoughout the entire study (i.e. 24 months). If it is not the case, users must specify how many temporal sampling replicates (e.g., months, weeks) the dataset includes.
temporal

## Fuzzy sets

# Distance between pairs of plant species
pl_morph_dist <- as.matrix(vegdist(pl_morph, method = "euclidean", na.rm = TRUE)) # Euclidean distance between species
pl_morph_dist

# Distance between pairs of hummingbirds species
h_morph_dist <- as.matrix(vegdist(h_morph, method = "euclidean", na.rm = TRUE)) # Euclidean distance between species
h_morph_dist

# Probability based on fuzzy trait similarity to plant
Tpl <- t(matrix.p1(t(network), pl_morph_dist)$matrix.P)
Tpl

# Probability fuzzy trait similarity to hummingbirds
Th <- matrix.p1(network, h_morph_dist)$matrix.P
Th

## All equals one
one <- network
one[] <- 1
one

## Combined probabilities

# Morphological matching and phenological overlap
MP <- morphological*temporal # Hadamard product
MP

# Probability based on fuzzy trait similarity to hummingbirds and phenological overlap
ThP <- Th*temporal

# Probability based on fuzzy trait similarity to plants and phenological overlap
TplP <- Tpl*temporal

### Simulate secondary extinctions in networks 

## Define the number of replications
nrep <- 1000

## Define the participant to be extinct
participant <- "lower"
participant

## Define method to remove species
method <- "random"
method

## Define method of rewiring
method.rewiring <- "one.try.single.partner"
method.rewiring

## Define the matrices of probability based on which rewiring will take place

# To plants loss ("lower" participants)
probabilities.rewiring1 <- abundance_pl # plant relative abundances
probabilities.rewiring1 # Probability of choice of a potential partner

## Run secondary extinctions with specified parameters (results are list)
# The argument probabilities.rewiring2 to specify the probabilities of rewiring 
RES.without.rewiring <- replicate(nrep, one.second.extinct.mod(network, participant = participant, method = method, rewiring = FALSE), simplify = FALSE)
RES.with.rewiring.M <- replicate(nrep, one.second.extinct.mod(network, participant = participant, method = method, rewiring = TRUE, probabilities.rewiring1 = probabilities.rewiring1, probabilities.rewiring2 = morphological, method.rewiring = method.rewiring), simplify = FALSE)
RES.with.rewiring.P <- replicate(nrep, one.second.extinct.mod(network, participant = participant, method = method, rewiring = TRUE, probabilities.rewiring1 = probabilities.rewiring1, probabilities.rewiring2 = temporal, method.rewiring = method.rewiring), simplify = FALSE)
RES.with.rewiring.T <- replicate(nrep, one.second.extinct.mod(network, participant = participant, method = method, rewiring = TRUE, probabilities.rewiring1 = probabilities.rewiring1, probabilities.rewiring2 = Tpl, method.rewiring = method.rewiring), simplify = FALSE)
RES.with.rewiring.MP <- replicate(nrep, one.second.extinct.mod(network, participant = participant, method = method, rewiring = TRUE, probabilities.rewiring1 = probabilities.rewiring1, probabilities.rewiring2 = MP, method.rewiring = method.rewiring), simplify = FALSE)
RES.with.rewiring.TP <- replicate(nrep, one.second.extinct.mod(network, participant = participant, method = method, rewiring = TRUE, probabilities.rewiring1 = probabilities.rewiring1, probabilities.rewiring2 = TplP, method.rewiring = method.rewiring), simplify = FALSE)

## Calculate robustness to species extinctions
RES.robustness.without.rewiring <- sapply(RES.without.rewiring, robustness)
RES.robustness.with.rewiring.M <- sapply(RES.with.rewiring.M, robustness)
RES.robustness.with.rewiring.P <- sapply(RES.with.rewiring.P, robustness)
RES.robustness.with.rewiring.T <- sapply(RES.with.rewiring.T, robustness)
RES.robustness.with.rewiring.MP <- sapply(RES.with.rewiring.MP, robustness)
RES.robustness.with.rewiring.TP <- sapply(RES.with.rewiring.TP, robustness)

# Organize the results
res.robustness <- data.frame(robustness.without.rewiring = RES.robustness.without.rewiring, 
                             robustness.with.rewiring.M = RES.robustness.with.rewiring.M,
                             robustness.with.rewiring.P = RES.robustness.with.rewiring.P,
                             robustness.with.rewiring.T = RES.robustness.with.rewiring.T,
                             robustness.with.rewiring.MP = RES.robustness.with.rewiring.MP,
                             robustness.with.rewiring.TP = RES.robustness.with.rewiring.TP)
res.robustness

# Compute 95% confidence intervals
res.robustness.summary <- as.data.frame(t(sapply(res.robustness, IC)))
res.robustness.summary$rewiring <- c("0", "M", "P", "T", "MP", "TP") # add code for rewiring
res.robustness.summary

# Plot results
plot(NA, xlim = c((1-0.5),(nrow(res.robustness.summary)+0.5)), ylim = c(0.8,1), 
     type = "n", las = 1, xaxt ="n", 
     ylab = "Robustness", xlab ="Mode of rewiring",
     main = paste("Participant =", participant, ";", "Method =", method))
axis(1, at = 1:nrow(res.robustness.summary), labels = res.robustness.summary$rewiring)
plotCI(1:nrow(res.robustness.summary), res.robustness.summary$mean, 
       ui = res.robustness.summary$upper, 
       li = res.robustness.summary$lower, 
       add = TRUE, pch = 19, cex = 0.7) # mean and confidence intervals
abline(h = c(res.robustness.summary$lower[1], res.robustness.summary$upper[1]), lty = 3) # lines of confidence interval to scenario without rewiring
