
library(caret)
library(h2o)
library(tidyverse)
h2o.init()

df <- h2o.importFile("../../project/1-data/train_data.csv")
df

test_data <- h2o.importFile("../../project/1-data/test_data.csv")

class(df)
summary(df)
h2o.nacnt(df)
df <- h2o.na_omit(df)
df

cor(df)

y <- "y"
x <- setdiff(names(df), c(y, "id"))
# x <- setdiff(names(df), c(y, "id", "months_since_last_delinquent"))
df$y <- as.factor(df$y)
summary(df)


splits <- h2o.splitFrame(df, c(0.6,0.2), seed=123)
train  <- h2o.assign(splits[[1]], "train") # 60%
valid  <- h2o.assign(splits[[2]], "valid") # 20%
test   <- h2o.assign(splits[[3]], "test")  # 20%



# GBM

gbm_params1 <- list(max_depth = c(30),
                    sample_rate = c(0.85))

# gbm_params2 <- list(max_depth = c(25, 30),
#                     sample_rate = c(0.7,0.8)
                    # )

gbm_grid1 <- h2o.grid("gbm",
                      x = x,
                      y = y,
                      grid_id = "gbm_grid1",
                      training_frame = train,
                      validation_frame = valid,
                      ntrees = 50,
                      seed = 1234,
                      hyper_params = gbm_params1)

# gbm_grid2 <- h2o.grid("gbm", 
#                       x = x, 
#                       y = y,
#                       grid_id = "gbm_grid2",
#                       training_frame = train,
#                       validation_frame = valid,
#                       ntrees = 100,
#                       seed = 1235,
#                       hyper_params = gbm_params2)

# Get the grid results, sorted by validation AUC

gbm_gridperf1 <- h2o.getGrid(grid_id = "gbm_grid1",
                             sort_by = "auc",
                             decreasing = TRUE)
print(gbm_gridperf1)


model_gbm <- h2o.getModel("gbm_grid1_model_16")

model_gbm

var_imp <- h2o.varimp_plot(model_gbm)
h2o.performance(model_gbm, newdata = valid)

h2o.performance(model_gbm, newdata = test)

h2o.saveModel(model_gbm, "../4-model", filename = "gmb_grid")

predictions_rf <- h2o.predict(model_gbm, test_data) %>%
  as_tibble()

