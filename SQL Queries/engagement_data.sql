SELECT * FROM engagement_data;

-- Query to clean and normalize the engagement_data table
SELECT 
    ContentID,  -- Selects the unique identifier for each piece of content
	CampaignID,  -- Selects the unique identifier for each marketing campaign
    ProductID,  -- Selects the unique identifier for each product
    UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,  -- Replaces "Socialmedia" with "Social Media" and then converts all ContentType values to uppercase
    LEFT(ViewAndLikes, INSTR(ViewAndLikes, '/') - 1) AS Views,  -- Extracts the Views part from the ViewAndLikes column by taking the substring before the '/' character
    RIGHT(ViewAndLikes, LENGTH(ViewAndLikes) - INSTR(ViewAndLikes, '/')) AS Likes,  -- Extracts the Likes part from the ViewAndLikes column by taking the substring after the '/' character
    -- Converts the EngagementDate to the dd.mm.yyyy format
    DATE_FORMAT(EngagementDate, '%d.%m.%Y') AS EngagementDate  -- Converts and formats the date as dd.mm.yyyy
FROM 
    engagement_data  -- Specifies the source table from which to select the data
WHERE 
    ContentType != 'Newsletter';  -- Filters out rows where ContentType is 'Newsletter' as these are not relevant for our analysis