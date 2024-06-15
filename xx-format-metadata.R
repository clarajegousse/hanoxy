library(rgeos)
library(sf) # World map
library(rnaturalearth)
library(ggplot2)
library(devtools)
library(dplyr)
library(plyr)


# set the directory to save img
img.path = "/Users/Clara/Projects/haliea/FIG/"

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
longhurst <- sf::read_sf("/Users/Clara/Projects/haliea/INFOS/longhurst-world-v4-2010.shx")
names(longhurst)
head(longhurst)

# simplify data
longhurst <- longhurst %>%
  sf::st_simplify(dTolerance = 0.01) %>%
  dplyr::group_by(ProvCode,ProvDescr) %>%
  dplyr::summarise()
#plot(longhurst)

# draw map with Longhurst provinces
map + geom_sf(data = longhurst, aes(fill = ProvCode), size = .1, col = "white", alpha = .25) +
  ggtitle(paste("Longhurst Biogeochemical Provinces -", length(unique(longhurst$ProvCode)),"provinces")) +
  theme(legend.position="none") +
  geom_sf_text(data = longhurst %>% group_by(ProvCode), aes(label = ProvCode),
               colour = DarkGrey, size = 3, check_overlap = TRUE) +
  coord_sf(expand = FALSE) + labs(x = 'longitude', y = 'latitude')

df <- read.csv("/Users/Clara/Projects/haliea/INFOS/selected-run-biosamples-infos.txt", 
               sep = "\t", dec = ".", header = FALSE)
df
head(df)

colnames(df) <- c("biosample_accession", "sequencing_platform", "run_accession", 
                  "total_reads", "total_counts", "library_strategy", "sample_alias",
                  "taxid", "station_name", "sampling_date", "latitude", "longitude", "depth", 
                  "temperature", "salinity", "nitrate", "oxygen", "chlorophyll", "lower_size_fraction")
df <- unique(df)

map + geom_sf(data = longhurst, aes(fill = ProvCode), size = .1, col = "white", alpha=.4) +
  #scale_fill_manual(values = col$value) +
  theme(legend.position="none") +
  ggtitle(paste("Longhurst Biogeochemical Provinces -", length(unique(longhurst$ProvCode)),"provinces")) +
  geom_sf_text(data = longhurst %>% group_by(ProvCode), aes(label = ProvCode),
               colour = "white", size = 3, check_overlap = TRUE) +
  coord_sf(expand = FALSE) + #expand = FALSE,   clip = "on", xlim = c(0,60), ylim = c(-50,50)
  geom_point(aes(x = df$longitude, y = df$latitude), size = 0.5, color = "black") +
  geom_text(aes(x = df$longitude, y = df$latitude, label = substr(df$station_name, 1, 8)), 
            color = DarkGrey, size = 2, hjust=0, vjust=1)

df$longhurst_region <- NA
df[df$station_name == 'TARA_030',]$longhurst_region <- "MEDI"
df[df$station_name == 'TARA_031',]$longhurst_region <- "MEDI"
df[df$station_name == 'TARA_032',]$longhurst_region <- "REDS"
df[df$station_name == 'TARA_033',]$longhurst_region <- "REDS"
df[df$station_name == 'TARA_034',]$longhurst_region <- "REDS"
df[df$station_name == 'TARA_038',]$longhurst_region <- "ARAB"
df[df$station_name == 'TARA_041',]$longhurst_region <- "ARAB"
df[df$station_name == 'TARA_042',]$longhurst_region <- "MONS"
df[df$station_name == 'TARA_045',]$longhurst_region <- "MONS"
df[df$station_name == 'TARA_048',]$longhurst_region <- "MONS"
df[df$station_name == 'TARA_062',]$longhurst_region <- "EAFR"
df[df$station_name == 'TARA_066',]$longhurst_region <- "EAFR"
df[df$station_name == 'TARA_067',]$longhurst_region <- "BENG"
df[df$station_name == 'TARA_070',]$longhurst_region <- "SALT"
df[df$station_name == 'TARA_072',]$longhurst_region <- "SALT"
df[df$station_name == 'TARA_076',]$longhurst_region <- "SALT"
df[df$station_name == 'TARA_078',]$longhurst_region <- "SALT"
df[df$station_name == 'TARA_082',]$longhurst_region <- "FKLD"
df[df$station_name == 'TARA_084',]$longhurst_region <- "APLR"
df[df$station_name == 'TARA_085',]$longhurst_region <- "APLR"
df[df$station_name == 'TARA_093',]$longhurst_region <- "CHIL"
df[df$station_name == 'TARA_094',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_096',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_098',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_099',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_100',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_102',]$longhurst_region <- "CHIL"
df[df$station_name == 'TARA_109',]$longhurst_region <- "PNEC"
df[df$station_name == 'TARA_110',]$longhurst_region <- "CHIL"
df[df$station_name == 'TARA_111',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_112',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_122',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_123',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_124',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_125',]$longhurst_region <- "SPSG"
df[df$station_name == 'TARA_128',]$longhurst_region <- "PEQD"
df[df$station_name == 'TARA_132',]$longhurst_region <- "NPTG"
df[df$station_name == 'TARA_133',]$longhurst_region <- "CCAL"
df[df$station_name == 'TARA_137',]$longhurst_region <- "NPTG"
df[df$station_name == 'TARA_138',]$longhurst_region <- "PNEC"
df[df$station_name == 'TARA_140',]$longhurst_region <- "CAMR"
df[df$station_name == 'TARA_141',]$longhurst_region <- "GUIA"
df[df$station_name == 'TARA_142',]$longhurst_region <- "CARB"
df[df$station_name == 'TARA_145',]$longhurst_region <- "GFST"
df[df$station_name == 'TARA_146',]$longhurst_region <- "NASW"
df[df$station_name == 'TARA_149',]$longhurst_region <- "NASW"
df[df$station_name == 'TARA_150',]$longhurst_region <- "NASW"
df[df$station_name == 'TARA_151',]$longhurst_region <- "NASE"
df[df$station_name == 'TARA_152',]$longhurst_region <- "NADR"
df[df$station_name == 'TARA_155',]$longhurst_region <- "NADR"
df[df$station_name == 'TARA_158',]$longhurst_region <- "SARC"
df[df$station_name == 'TARA_163',]$longhurst_region <- "ARCT"
df[df$station_name == 'TARA_168',]$longhurst_region <- "SARC"
df[df$station_name == 'TARA_175',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_173',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_194',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_196',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_201',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_201',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_205',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_206',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_208',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_209',]$longhurst_region <- "BPLR"
df[df$station_name == 'TARA_210',]$longhurst_region <- "ARCT"


longh <- read.csv("/Users/Clara/Projects/haliea/INFOS/longhurst_regions.tsv", sep = '\t')

df <- merge(df, longh, by.x = 'longhurst_region', by.y = 'longhurst_code')


df <- df %>%
  group_by(station_name, sampling_date, longhurst_region, province_name, ocean, biome, latitude, longitude, depth, temperature, salinity, nitrate, oxygen, chlorophyll) %>%
  dplyr::summarise(total_reads = sum(total_reads), nb_runs = n())
mtdt.df <- as.data.frame(df)
rownames(mtdt.df) <- mtdt.df$station_name

# write a csv file
write.table(mtdt.df, file = "/Users/Clara/Projects/haliea/INFOS/metadata.csv", sep = ",",
            na = "NA", dec = ".")

map +  geom_sf(data = longhurst, aes(fill = ProvCode), size = .1, col = "white", alpha = .25) +
  #scale_fill_manual(values = col$value) +
  theme(legend.position="none") +
  ggtitle(paste("Longhurst Biogeochemical Provinces -", length(unique(longhurst$ProvCode)),"provinces")) +
  coord_sf(expand = FALSE) + #expand = FALSE,   clip = "on", xlim = c(0,60), ylim = c(-50,50)
  geom_point(aes(x = df$longitude, y = df$latitude), size = 1, color = MediumGrey, alpha = 0.5) +
  geom_text(aes(x = df$longitude, y = df$latitude, label = substr(df$station_name, 1, 8)), 
            color = DarkGrey, size = 2, hjust=0, vjust=1)

qc.df <- read.csv("/Users/Clara/Projects/haliea/SUMMARY/01-qc-summary.csv")
colnames(qc.df)<- c('station_name', "number_pairs_analyzed", 
                    "number_pairs_passed", "per_pairs_passed",
                    "samtools_overall_aln_rate")

df2 <- unique(join(df, qc.df, by = 'station_name')[c('station_name', 
                                                     'latitude', 'longitude',
                                                     'number_pairs_analyzed', 'number_pairs_passed', 
                                                     'per_pairs_passed', 'samtools_overall_aln_rate')])
library(ggrepel)

map + geom_sf(data = longhurst, size = .1, col = "white") +
  theme(legend.position="none") +
  ggtitle(paste("Longhurst Biogeochemical Provinces -", length(unique(longhurst$ProvCode)),"provinces")) +
  coord_sf(expand = FALSE) +
  geom_point(aes(x = df2$longitude, y = df2$latitude, size = df2$samtools_overall_aln_rate*100), 
             color = MediumGrey, alpha = 0.75) +
  geom_text_repel(aes(x = df2$longitude, y = df2$latitude, label = substr(df2$station_name, 1, 8)), 
                  color = DarkGrey, size = 2) +
  labs(x = 'longitude', y = 'latitude', size = 'Proportion of Halieaceae reads aligned') +
  theme(legend.position="bottom")
filename = paste0(img.path, "mag-nb-mapped-reads.png")
ggsave(filename, plot = last_plot(), scale = 1, dpi = 300)

map + geom_sf(data = longhurst, size = .1, col = "white") +
  ggtitle(paste("Longhurst Biogeochemical Provinces -", length(unique(longhurst$ProvCode)),"provinces")) +
  coord_sf(expand = FALSE) +
  geom_point(aes(x = df2$longitude, y = df2$latitude, size = df2$number_pairs_passed), 
             color = MediumGrey, alpha = 0.75) +
  geom_text_repel(aes(x = df2$longitude, y = df2$latitude, label = substr(df2$station_name, 1, 8)), 
                  color = DarkGrey, size = 2) +
  labs(x = 'longitude', y = 'latitude', size = 'Number of clean read pairs') +
  theme(legend.position="bottom")

filename = paste0(img.path, "mag-nb-cleaned-reads.png")
ggsave(filename, plot = last_plot(), scale = 1, dpi = 300)