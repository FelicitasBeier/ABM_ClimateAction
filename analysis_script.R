library(lucode2)
setwd(readClipboard())

sim_data <- read.csv(file = "ClimateAction ConvincingPower-table.csv",header = TRUE,skip = 6)

library(ggplot2)

colnames(sim_data) <- c("run_no","influencers","energy_decline","denier_power","init_agents",
                        "energy_increase","activist_power","step","deniers","neutral","activist","emissions")

sim_data$activist_power <- paste0("Act ",sim_data$activist_power)
sim_data$denier_power <- paste0("Den ",sim_data$denier_power)

p <- ggplot(data = sim_data, aes(x=step, y=emissions)) + 
  facet_grid(denier_power~activist_power) + geom_point() +
  ylim(c(0,1300)) + theme(axis.text.x = element_text(angle = 90)) +
  geom_hline(yintercept=1200, linetype="dashed", color = "red")
p
ggsave(plot = p, filename = "scen_combi.png",height = 7,width = 7)

