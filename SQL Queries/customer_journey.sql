SELECT * FROM customer_journey;

-- Common Table Expression (CTE) to identify and tag duplicate records
WITH DuplicateRecords AS (
     SELECT 
        JourneyID,  -- Select the unique identifier for each journey (and any other columns you want to include in the final result set)
        CustomerID,  -- Select the unique identifier for each customer
        ProductID,  -- Select the unique identifier for each product
        VisitDate,  -- Select the date of the visit, which helps in determining the timeline of customer interactions
        Stage,  -- Select the stage of the customer journey (e.g., Awareness, Consideration, etc.)
        Action,  -- Select the action taken by the customer (e.g., View, Click, Purchase)
        Duration,  -- Select the duration of the action or interaction
        -- Use ROW_NUMBER() to assign a unique row number to each record within the partition defined below
        ROW_NUMBER() OVER (
            -- PARTITION BY groups the rows based on the specified columns that should be unique
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action  
            -- ORDER BY defines how to order the rows within each partition (usually by a unique identifier like JourneyID)
            ORDER BY JourneyID  
        ) AS row_num  -- This creates a new column 'row_num' that numbers each row within its partition
    FROM 
        customer_journey  -- Specifies the source table from which to select the data
)

-- Select all records from the CTE where row_num > 1, which indicates duplicate entries
SELECT *
FROM DuplicateRecords
WHERE row_num > 1  -- Filters out the first occurrence (row_num = 1) and only shows the duplicates (row_num > 1)
ORDER BY JourneyID;


-- Common Table Expression (CTE) to clean and standardize customer journey data
WITH CleanedData AS (
    SELECT
        JourneyID,  -- Unique identifier for each customer journey record
        CustomerID,  -- Identifier for the customer
        ProductID,  -- Identifier for the product interacted with
        VisitDate,  -- Date of the customer visit or interaction
        UPPER(Stage) AS Stage,  -- Standardize 'Stage' values to uppercase for consistency
        Action,  -- Action taken by the customer (e.g., View, Click, Purchase)
        Duration,  -- Duration of the interaction (can be NULL)
        
        -- Compute average duration per VisitDate to fill missing Duration values later
        AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,
        
        -- Assign row numbers to identify duplicates based on key columns
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action  -- Group by these fields
            ORDER BY JourneyID  -- Order within the group to retain the first (original) record
        ) AS row_num
    FROM customer_journey  -- Source table
)

-- Final selection of cleaned data
SELECT
    JourneyID,  -- Retain the original JourneyID
    CustomerID,  -- Customer identifier
    ProductID,  -- Product identifier
    VisitDate,  -- Visit date
    Stage,  -- Cleaned (uppercased) stage
    Action,  -- Action taken
    COALESCE(Duration, avg_duration) AS Duration  -- Fill missing Duration with average for that date
FROM CleanedData
WHERE row_num = 1;  -- Keep only the first (non-duplicate) record per group
