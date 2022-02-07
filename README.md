# email_campaign
A manager at a hotel booking site did a split test where she sent 4 email campaigns to the potential customer set. 
The goal of this email is to converge in a booking. Applying multiple multi-armed bandit methods to calculate the best way to maximize expected gain.
Also it was calculated how many emails per campaign should be sent in the future (29-56 days) in order to maximaze amount of bookings.

The best performing MAB method is represented by the Thompson Sampling.
For this reason, it is implemented in order to allocate emails for the following 28 days (29 to 56) by making a for loop. Although in the
previous steps a normal distribution was used, in this case it is necessary to perform a Bernoulli distribution, and a beta distribution as 
posterior due to our experimental setting: the TS algorithm allocates each email individually and learns about which campaign performs the best. 
Subsequently, the following email is sent taking in consideration the results of the posterior distribution and therefore is already earning while learning,
reducing the costs of the hotel manager. In each loop the posterior distribution is taken into account and then the arm with the highest expectation 
is selected. After finishing the process we get an output of the percentage distribution of each arm, meaning how often one arm (campaign) was chosen 
each day when sending out the 400 emails. To get the absolute allocation of the emails sent we multiplied these with the total number of emails sent 
per day across all campaigns. This resulted in a dataset with the actual number of emails sent per campaign per each day from 29 to 56. We can see on 
the final day (day 56) that 2 emails were sent for campaign 1, 395 emails were sent for campaign 2, zero emails were sent to campaign 3 and 3 emails 
for campaign 4. Campaign 2 is the best performing campaign and therefore the most emails are sent for this campaign, campaign 3 is the worst converting campaign. 
Implementing the Thompson sampling on this experiment leads to higher earnings because it is already allocating the emails correctly and leading to a higher 
amount of conversions already during the process of the experimentation time period.
