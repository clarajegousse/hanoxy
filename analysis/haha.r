
library(dplyr)
library(tidyr)
library(reshape)

count_dir <- "/Users/jegoussc/Repositories/hanoxy/results/counts"

count_files <- list.files(path = count_dir, pattern = 'tsv',
  full.names = TRUE)


counts <- NA
for (f in count_files) {
  print(f)
  r <- read.delim(file = f, header = TRUE,
    row.names = 1)
  counts = cbind(counts, r)
}

colnames(counts) <- substr(colnames(counts), 1, 8)
rownames(counts) <- substr(rownames(counts), 1, 13)
counts %>% 
  select(-counts) %>% 
  t() %>% melt()
heatmap(df)


df <- counts %>% 
  select(-counts) %>% 
  t() %>%
  melt(id.vars = 1, measure.vars = "counts", 
    preserve.na = TRUE)
colnames(df) <- c('station_name', "genomes", "counts")

longh <- read.csv("/Users/jegoussc/Repositories/haliea/INFOS/metadata.csv", 
  sep = ',')

df2 <- merge(longh, df, all = TRUE)


library(rgeos)
library(sf) # World map
library(rnaturalearth)
library(ggplot2)
library(devtools)
library(dplyr)
library(plyr)


# import colours
source_url('https://raw.githubusercontent.com/clarajegousse/colors/master/colors.R')

# retrieve world data
world_map <- rnaturalearth::ne_countries(scale = 'small', returnclass = c("sf"))

# Base map
map <- ggplot() +
  geom_sf(data = world_map, size = .2, fill = 'white', col = 'white') +
  theme(panel.grid.major = element_line(color = lightgrey, linetype = "dashed", size = 0.5))
map


# import longhurst provinces
longhurst <- sf::read_sf("/Users/jegoussc/Repositories/haliea/INFOS/longhurst-world-v4-2010.shx")
names(longhurst)
head(longhurst)

# simplify data
longhurst <- longhurst %>%
  sf::st_simplify(dTolerance = 0.01) %>%
  dplyr::group_by(ProvCode,ProvDescr) %>%
  dplyr::summarise()

# draw map with Longhurst provinces
ll <- map + geom_sf(data = longhurst, aes(fill = ProvCode), size = .1, col = "white", alpha = .25) +
  ggtitle(paste("Longhurst Biogeochemical Provinces -", length(unique(longhurst$ProvCode)),"provinces")) +
  theme(legend.position="none") +
  geom_sf_text(data = longhurst %>% group_by(ProvCode), aes(label = ProvCode),
    colour = DarkGrey, size = 3, check_overlap = TRUE) +
  coord_sf(expand = FALSE) + labs(x = 'longitude', y = 'latitude')

ll

ll + geom_point(aes(x = df2$longitude, y = df2$latitude, size = df2$counts, color = df2$genomes), alpha = 0.5)
