
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
x <- setdiff(names(df), c(y, "id", "months_since_last_delinquent"))
df$y <- as.factor(df$y)
summary(df)

df <- df %>%
  mutate(term = ifelse(term == "short",0,1))



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

#----------------------GridSearch--------------------------
system.time(grid_cartesian <- h2o.grid("randomForest",
                              x=x,
                              y=y,
                              seed = 1111,
                              nfolds = 2,
                              training_frame = train,
                              hyper_params = list(ntrees=seq(30,80, by = 10),
                                             max_depth=c(20,25)
                                             ),
                              search_criteria = list(strategy = "Cartesian")
                      ))

# dl_params1 <- list(hidden = list(c(10,10), c(10,10,10)))
                                 

# dl_grid <- h2o.grid("randomForest",
#                     x = x,
#                     y = y,
#                     training_frame = train,
#                     hyper_params = dl_params1)
# 
# h2o.getGrid(grid_id = dl_grid@grid_id,
#             sort_by = "auc",
#             decreasing = TRUE)


#----------------------RandomForest------------------------

#150/30 0,77
#50/40 0,76

rf_model <- h2o.randomForest(x=x, 
                             y=y, 
                             training_fram = train, 
                             validation_frame = valid,
                             ntrees = 50,
                             max_depth = 30
                             )

rf_model

h2o.performance(rf_model, valid)

perf_test_rf <- h2o.performance(rf_model, newdata = test)
perf_test_rf

predictions_rf <- h2o.predict(rf_model, test_data) %>%
  as_tibble()

# aml <- h2o.automl(x = x,
#                   y = y,
#                   training_frame = train,
#                   validation_frame = valid,
#                   max_runtime_secs = 60)
# 
# aml@leaderboard
# 
# model <- aml@leader
# 
# model <- h2o.getModel("GBM_1_AutoML_1_20221111_181631")
# 
# perf <- h2o.performance(model, train = TRUE)
# perf
# perf_valid <- h2o.performance(model, valid = TRUE)
# perf_valid
# perf_test <- h2o.performance(model, newdata = test)
# perf_test
# 
# h2o.auc(perf)
# plot(perf_valid, type = "roc")
# 
test_data <- h2o.importFile("../project/1-data/test_data.csv")
h2o.performance(model, newdata = test_data)

predictions <- h2o.predict(model, test_data)

predictions %>%
  as_tibble() %>%
  mutate(id = row_number(), y = p0) %>%
  select(id, y) %>%
  write_csv("../project/5-predictions/predictions2.csv")
# 
# ### ID, Y
# 
# h2o.saveModel(model, "../4-model/", filename = "my_model")
# 
# model <- h2o.loadModel("../4-model/my_model")
# h2o.varimp_plot(model)
# 
# 
# ### deeplearning
# 
# dl_model <- h2o.deeplearning(x,
#                              y,
#                              training_frame = train,
#                              validation_frame = valid,
#                              activation = "Tanh",
#                              hidden = c(50, 50))
# 
# perf_test_dl <- h2o.performance(dl_model, newdata = test)
# perf_test_dl
# 
# 
# # gridsearch
# 
# dl_params1 <- list(hidden = list(10, c(10,10), c(10,10,10)))
# 
# dl_grid <- h2o.grid("deeplearning",
#                     x = x,
#                     y = y,
#                     training_frame = train,
#                     epochs = 3,
#                     hyper_params = dl_params1)
# 
# h2o.getGrid(grid_id = dl_grid@grid_id,
#             sort_by = "auc",
#             decreasing = TRUE)
# 
# 
# grid_dl <- h2o.getModel(dl_grid@model_ids[[1]])
# 
# 

h2o.shutdown()



