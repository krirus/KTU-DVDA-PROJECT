# Readme - titulinis lapas

Autoriai: komanda "yee"" - Kamilė Bagdonaitė, Kristijonas Ruškys

# Motivation

Help business to classify bad customers

# Goal

Create an analytical application for bank loan evaluation with the help of machine learning algorithms.

# Dependencies

-   R kernel
-   R packages:

```

        install.packages("h2o")
        install.packages("shiny")
        install.packages("tidyverse")
        install.packages("caret")
        install.packages("readr")
```

# Directory structure

        ├───1-data
        ├───2-report
        ├───3-R
        ├───4-model
        ├───5-predictions
        └───app

# How to execute code

-   Download data from [Google Drive](https://drive.google.com/drive/folders/17NsP84MecXHyctM94NLwps_tsowld_y8?usp=sharing)
-   Run data preparation script:

```
            git clone https://github.com/kibiras/KTU-DVDA-PROJECT.git
            cd KTU-DVDA-PROJECT/3-R
            RScript data_transformation.R
```

-   Run modelling script:
```
            RScript modelling.R
```
-   Run app:
```
            RScript app.R
```

# Results

-   Gradient boosting algorithm proved to be the best model and reached AUC = 0.79 on training dataset and 0,795 on test dataset. We did not use the "train_data2" dataset since neither of our computers could run it. "Challenge spėjimas 1" determined that our model reaches AUC=8,002
