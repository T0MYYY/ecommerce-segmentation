# Read in data (change path as needed)
path <- '~/Documents/ADSP Leadership and Consulting/AUT 25/amazon_data/'
purchases <- read.csv(paste0(path,'amazon-purchases.csv'))[,-(4:6)]
names(purchases) <- c('orderdate','priceperunit','quantity','category','respondentid')

# Type conversion and feature engineering
purchases$orderdate <- as.Date.character(purchases$orderdate)
purchases$revenue <- purchases$priceperunit * purchases$quantity
head(purchases)
dim(purchases)

# Split into train and test sets
train <- subset(purchases,
                orderdate >= as.Date("2018-01-01") &
                orderdate <= as.Date("2019-12-31"))
test <- subset(purchases,
               orderdate >= as.Date("2020-01-01") &
               orderdate <= as.Date("2021-12-31"))

# Split each set by respondent
train <- split(train, train$respondentid)
test <- split(test, test$respondentid)

# Define summary function
respondentsummary <- function(df) {
  dailyspend <- aggregate(revenue ~ orderdate, data = df, sum)
  data.frame(
    respondentid = df$respondentid[1],
    firstpurchase = min(df$orderdate),
    lastpurchase = max(df$orderdate),
    avgdailyspend = mean(dailyspend$revenue),
    totalspend = sum(df$revenue),
    purchasedays = length(unique(df$orderdate)),
    totalpurchases = nrow(df))}

# Apply summary function and row-bind results
summary1819 <- do.call(rbind, lapply(train, respondentsummary))
summary2021 <- do.call(rbind, lapply(test, respondentsummary))

summary(summary1819)
dim(summary1819)
head(summary1819)

summary(summary2021)
dim(summary2021)
head(summary2021)

# Write out
write.csv(summary1819,paste0(path,'summary2018-19.csv'),row.names=FALSE)
write.csv(summary2021,paste0(path,'summary2020-21.csv'),row.names=FALSE)
