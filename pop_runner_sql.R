

# This script is based on the PopRunner data - PopRunner is an online retailer
# Use the caselet and data (consumer.csv, pop_up.csv, purchase.csv, email.csv) 
# In this script, we will use SQL to do descriptive statistics
# Think about the managerial implications as you go along

options(warn=-1) # R function to turn off warnings
library(sqldf)

################################################################################

# Read the data in: consumer, pop_up, purchase and email tables

# set your working directory and use read.csv() to read files



consumer<-read.csv("consumer.csv",header=TRUE)
pop_up<- read.csv("pop_up.csv",header=TRUE)
purchase<-read.csv("purchase.csv",header=TRUE)
email<-read.csv("email.csv",header=TRUE)

# Let us first start with exploring various tables

################################################################################

# Using SQL's LIMIT clause, display first 5 rows of all the four tables

# observe different rows and columns of the tables

################################################################################

# Query 1) Display first 5 rows of consumer table

sqldf("
     SELECT * FROM consumer 
     LIMIT 5;
      ")

################################################################################

# Query 2) Display first 5 rows of pop_up table

sqldf("
      SELECT * FROM pop_up 
      LIMIT 5;
      ")

################################################################################

# Query 3) Display first 5 rows of purchase table

sqldf("
      SELECT * FROM purchase 
      LIMIT 5;
      ")

################################################################################

# Query 4) Display first 5 rows of email table

sqldf("
     SELECT * FROM email 
      LIMIT 5;
      ")

################################################################################

# Now, let's look at the descriptive statistics one table at a time: consumer table

# Query 5: Display how many consumers are female and male (column alias: gender_count), 
#          also show what is the average age (column alias: average_age) of consumers by gender



sqldf("
    SELECT gender, 
    COUNT(*) AS gender_count, 
    AVG(age) AS average_age
    FROM consumer
    GROUP BY gender;
      ")

# Interpret your output in simple English (1-2 lines): 
#The output shows that there are 6,903 female consumers with an average age of approximately 30.6 years, and 2,129 male consumers with an average age of around 32.5 years.

################################################################################

# Query 6: How many consumers are there in each loyalty status group (column alias: loyalty_count), 
# what is the average age (column alias: average_age) of consumers in each group



sqldf("
    SELECT loyalty_status, 
    COUNT(*) AS loyalty_count, 
    AVG(age) AS average_age
    FROM consumer
    GROUP BY loyalty_status;
      ")

# Interpret your output in simple English (1-2 lines):
#The output indicates that loyalty status 2 has the highest number of consumers (2,612) with an average age of about 30.7 years. Loyalty status 4 has the fewest consumers (1,766), but these consumers have the highest average age at 33.5 years.
################################################################################

# Next, let's look at the pop_up table

# Query 7: How many consumers (column alias: consumer_count) who received a
# pop_up message (column alias: pop_up)
# continue adding discount code to their card (column alias: discount_code) 
# opposed to consumers who do not receive a pop_up message



sqldf("
    SELECT COUNT(*) AS consumer_count, pop_up AS pop_up, 
    saved_discount AS discount_code
    FROM pop_up
    GROUP BY pop_up, saved_discount;
      ")

# Interpret your output in simple English (1-2 lines):
#The output shows that 4,516 consumers did not receive a pop-up message and thus did not save a discount code. Among those who received a pop-up message, 3,029 did not save the discount code, while 1,487 consumers saved the discount code in their cart.

################################################################################

# This is purchase table

# Query 8: On an average, how much did consumers spend on their 


sqldf("
      SELECT AVG(sales_amount_total) AS total_sales
      FROM purchase;
      ")

# Interpret your output in simple English (1-2 lines):
#On average, consumers spent approximately $135.21 on their total purchases during online transactions.
################################################################################

# Finally, let's look at the email table

# Query 9: How many consumers (column alias: consumer_count) of the total opened the email blast




sqldf("
      SELECT COUNT(*) AS consumer_count, opened_email
      FROM email
      GROUP BY opened_email;
      ")

# Interpret your output in simple English (1-2 lines):
#The output shows that 8,316 consumers did not open the email blast, while 716 consumers did open it. This indicates a relatively low engagement rate with the email advertisement.
######################################################################################################

# Now we will combine/ merge tables to find answers

# Query 10: Was the pop-up advertisement successful? Mention yes/ no. 
# In other words, did consumers who received a pop_up message buy more



sqldf("
    SELECT p.pop_up, 
    SUM(pr.sales_amount_total) AS sum_sales, 
    AVG(pr.sales_amount_total) AS avg_sales
    FROM purchase pr
    JOIN pop_up p ON pr.consumer_id = p.consumer_id
    GROUP BY p.pop_up;
      ")

# Interpret your output in simple English (1-2 lines):
#The output shows that consumers who did not receive a pop-up message had a slightly higher average sales amount ($138.69) than those who did receive it ($131.74). This suggests that the pop-up advertisement was not successful in increasing consumer purchases.
######################################################################################################

# Query 11) Did the consumer who spend the least during online shopping opened the pop_up message? Use nested queries.

# Write two separate queries 

# Query 11.1) Find the consumer_id who spent the least from the purchase table



sqldf("
      SELECT consumer_id 
      FROM purchase 
      ORDER BY sales_amount_total 
      LIMIT 1;
      ")

# Query 11.2) Use the consumer_id from the previous SELECT query to find if the consumer received a pop_up message from the pop_up table

sqldf("
     SELECT  pop_up 
     FROM pop_up 
     WHERE consumer_id = 12345;
      ")

# Query 11.3) Using ? for inner query, create a template to write nested query

sqldf("
      SELECT pop_up 
      FROM pop_up 
      WHERE consumer_id = ?;
      ")

# Query 11.4) Replace ? with the inner query




sqldf("
     SELECT  pop_up 
     FROM pop_up 
     WHERE consumer_id = (
        SELECT 
            consumer_id 
        FROM 
            purchase 
        ORDER BY 
            sales_amount_total 
        LIMIT 1
    );

      ")

# Interpret your output in simple English (1-2 lines):
#The output indicates that the consumer who spent the least during online shopping did not receive a pop-up advertisement, as the pop_up value for this consumer is 0.
######################################################################################################

# Query 12: Was the email blast successful? Mention yes/ no. 
# In other words, did consumers who opened the email blast buy more



sqldf("
      SELECT e.opened_email, 
      SUM(pr.sales_amount_total) AS sum_sales, 
      AVG(pr.sales_amount_total) AS avg_sales
      FROM 
      purchase pr
      JOIN 
      email e ON pr.consumer_id = e.consumer_id
      GROUP BY 
      e.opened_email;
      ")

# Interpret your output in simple English (1-2 lines):
#The output shows that consumers who opened the email blast had a significantly higher average sales amount ($240.83) compared to those who did not open it ($126.12). This suggests that the email blast was successful in driving higher purchases.
######################################################################################################

# Query 13) Did the consumer who spend the most during online shopping opened the email message? Use nested queries.

# Write two separate queries 

# Query 13.1) Find the consumer_id who spent the most from the purchase table



sqldf("
      SELECT  consumer_id 
      FROM  purchase 
      ORDER BY sales_amount_total DESC 
      LIMIT 1;
      ")

# Query 13.2) Use the consumer_id from the previous SELECT query to find if the consumer opened the email from the email table

sqldf("
      SELECT opened_email 
      FROM  email 
      WHERE  consumer_id =5955534353;
      ")

# Query 13.3) Using ? for inner query, create a template to write nested query

sqldf("
     SELECT opened_email 
     FROM email 
     WHERE consumer_id = ?;
      ")

# Query 13.4) Replace ? with the inner query




sqldf("
     SELECT opened_email 
     FROM  email 
     WHERE 
    consumer_id = (
        SELECT 
            consumer_id 
        FROM 
            purchase 
        ORDER BY 
            sales_amount_total DESC 
        LIMIT 1
    );

      ")

# Interpret your output in simple English (1-2 lines):
#The output indicates that the consumer who spent the most during online shopping did open the email blast, as the opened_email value for this consumer is 1.


