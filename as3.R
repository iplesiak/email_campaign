# clear workspace 
rm(list = ls())

#load in datasets
data4<- read.csv("Downloads/MADS Assignment 3 (4)(1).csv")
library(contextual)
library(base)

#Applying Gaussian distribution -> normality assumed for the arms
#Average conversion for each campaign (arm) (means for distribution)
reward1 <-(sum(data4$Conversions_version_1)/28)/100
reward2 <-(sum(data4$Conversions_version_2)/28)/100
reward3 <-(sum(data4$Conversions_version_3)/28)/100
reward4 <-(sum(data4$Conversions_version_4)/28)/100
#standard deviation
sigma1 <-sd(data4$Conversions_version_1)/100
sigma2 <-sd(data4$Conversions_version_2)/100
sigma3 <-sd(data4$Conversions_version_3)/100
sigma4 <-sd(data4$Conversions_version_4)/100

reward_arm =c(reward1,reward2,reward3,reward4)
sigma_arm = c(sigma1,sigma2,sigma3,sigma4)
#calculate regrets of all models
bandit <- BasicGaussianBandit$new(reward_arm, sigma_arm)
policy <- EpsilonGreedyPolicy$new(1)
agents <- list(Agent$new(EpsilonGreedyPolicy$new(1), bandit, "EGreedy - Epsilon 1"),
               Agent$new(EpsilonGreedyPolicy$new(0.5), bandit, "EGreedy - Epsilon 0.5"),
               Agent$new(EpsilonGreedyPolicy$new(0.3), bandit, "EGreedy - Epsilon 0.3"), 
               Agent$new(EpsilonGreedyPolicy$new(0.1), bandit, "EGreedy - Epsilon 0.1"), 
               Agent$new(UCB1Policy$new(), bandit, "UCB1"), 
               Agent$new(UCB2Policy$new(), bandit, "UCB2"),
               Agent$new(ThompsonSamplingPolicy$new(), bandit, "TS")) 
#simulation = 100 for 100 emails per day per each arm, horizon = 400 emails per 28 days (all emails in total)
simulation <- Simulator$new(agents, simulations = 100, horizon = 400*28, do_parallel = TRUE) 
history <- simulation$run()
#plotting regrets 
plot(history, type = "cumulative", rate = FALSE, legend_position = "topleft") 
#Thompson sample has the lowest regret
#plot the choices of the best performing model
plot(history, type = "arms", rate = FALSE,limit_agents="EGreedy - Epsilon 0.1") 
plot(history, type = "arms", rate = FALSE,limit_agents= "UCB2")
plot(history, type = "arms", rate = FALSE,limit_agents="TS")

#Allocate emails from day 29 to 56 
set.seed(1234)
#Implementing the Thompson Sample 
Percentagedistribution<-{}
b_Probs<-reward_arm
b_Sent<-rep(0, length(b_Probs))
b_Reward<-rep(0, length(b_Probs))
email<-400
N<-11200
steps<-floor(N/email)
msgs<-length(b_Probs)
for (i in 1:steps) {
  B<-matrix(rbeta(400*msgs, b_Reward+1, (b_Sent-b_Reward)+1),400, byrow = TRUE)
  P<-table(factor(max.col(B), levels=1:ncol(B)))/dim(B)[1]
  # tmp are the weights for each time step
  tmp<-round(P*email,0)
  
  # Update the Rewards
  b_Reward<-b_Reward+rbinom(rep(1,msgs), size=tmp, prob = b_Probs)
  
  #Update the Sent
  b_Sent<-b_Sent+tmp
  
  #print(P)
  Percentagedistribution<-as.data.frame(rbind(Percentagedistribution, t(matrix(P))))
}
# Calculate weight of each arm
Percentagedistribution
Percentagedistribution <- as.data.frame(Percentagedistribution)
colnames(Percentagedistribution) <- c("Arm1%", "Arm2%", "Arm3%", "Arm4%")
# create a data frame
Newdays <- 29:56
Emailsent <- cbind(Newdays, Percentagedistribution)
Emailsent$Campaign1 <- Emailsent$`Arm1%` * 400
Emailsent$Campaign2 <- Emailsent$`Arm2%` * 400
Emailsent$Campaign3 <- Emailsent$`Arm3%` * 400
Emailsent$Campaign4 <- Emailsent$`Arm4%` * 400

#Final data with the new allocation of emails
Emailsent <- Emailsent[, -c(2,3,4,5)]





