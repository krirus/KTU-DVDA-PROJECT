library(readr)

library(tidyverse)

data <- read_csv("../../project/1-data/1-sample_data.csv")

select(data, y)


select(data, y)

data_additional <- read_csv("../../project/1-data/3-additional_features.csv")

joined_data <- inner_join(data, data_additional, by = "id")

write_csv(joined_data, "../../project/1-data/train_data.csv") 



data_additional2 <- read_csv("../../project/1-data/2-additional_data.csv")
data_additional3 <- read_csv("../../project/1-data/3-additional_features.csv")

joined_data <- union(data, data_additional2)


data_full <- joined_data %>%
   inner_join(data_additional3, by = "id")


write_csv(data_full, "../../project/1-data/train_data2.csv") 
