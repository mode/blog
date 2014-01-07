# Import data
model <- read.csv("~/model_data.csv")
to_forecast <- read.csv("~/2013_data.csv")

# Generate model
return_logit <- glm(ceiling(return_songs/100) ~ years_since_debut + debut_position + debut_songs + total_hits + best_position + years_since_last, data = model, family = "binomial") 

# Apply predictions to 2013 data
p <- cbind(to_forecast[1], predict(return_logit, newdata = to_forecast, type = "link", se = TRUE))
p <- within(p, { probability_of_return <- plogis(fit) })