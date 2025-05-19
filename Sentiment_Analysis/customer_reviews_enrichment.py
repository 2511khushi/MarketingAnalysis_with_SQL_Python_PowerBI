import pandas as pd
import mysql.connector
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

# Download the VADER lexicon used for sentiment analysis (only needed once)
nltk.download('vader_lexicon')

# Step 1: Connect to MySQL and fetch data from the reviews table
def fetch_data_from_mysql():
    try:
        # Establish connection to MySQL database
        conn = mysql.connector.connect(
            host="localhost",         
            user="root",    
            password="2511Nishi", 
            database="Shopify"
        )

        # SQL query to retrieve reviews
        query = "SELECT CustomerID, ProductID, ReviewDate, Rating, ReviewText FROM customer_reviews"

        # Read query result into a DataFrame
        df = pd.read_sql(query, conn)
        return df
    
    except Exception as e:
        print("Error connecting to MySQL:", e)
        return pd.DataFrame()
    
    finally:
        if conn:
            conn.close()

# Step 2: Initialize the VADER sentiment analyzer
sia = SentimentIntensityAnalyzer()

# Step 3: Function to calculate compound sentiment score
def calculate_sentiment(review):
    sentiment = sia.polarity_scores(str(review))  # Ensure it's a string
    return sentiment['compound']

# Step 4: Function to categorize sentiment based on score and rating
def categorize_sentiment(score, rating):
    if score > 0.05:
        if rating >= 4:
            return 'Positive'
        elif rating == 3:
            return 'Mixed Positive'
        else:
            return 'Mixed Negative'
    elif score < -0.05:
        if rating <= 2:
            return 'Negative'
        elif rating == 3:
            return 'Mixed Negative'
        else:
            return 'Mixed Positive'
    else:
        if rating >= 4:
            return 'Positive'
        elif rating <= 2:
            return 'Negative'
        else:
            return 'Neutral'

# Step 5: Bucket sentiment scores into ranges
def sentiment_bucket(score):
    if score >= 0.5:
        return '0.5 to 1.0'
    elif 0.0 <= score < 0.5:
        return '0.0 to 0.49'
    elif -0.5 <= score < 0.0:
        return '-0.49 to 0.0'
    else:
        return '-1.0 to -0.5'

# Step 6: Run the sentiment pipeline
customer_reviews_df = fetch_data_from_mysql()

# Apply sentiment score calculation
customer_reviews_df['SentimentScore'] = customer_reviews_df['ReviewText'].apply(calculate_sentiment)

# Apply sentiment categorization
customer_reviews_df['SentimentCategory'] = customer_reviews_df.apply(
    lambda row: categorize_sentiment(row['SentimentScore'], row['Rating']), axis=1
)

# Apply sentiment bucket labeling
customer_reviews_df['SentimentBucket'] = customer_reviews_df['SentimentScore'].apply(sentiment_bucket)

# Step 7: Display result
print(customer_reviews_df.head())

# Step 8: Save to CSV for reporting or storage
customer_reviews_df.to_csv('customer_reviews_with_sentiment_j.csv', index=False)
