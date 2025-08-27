
# Load libraries
library(pdftools)
library(tabulizer)

url_spec <-"https://media.fisheries.noaa.gov/2022-03/bsai-harvest-specs-1986-present.pdf"
download.file(url_spec, destfile = "SPECS.pdf", mode = "wb")

# Extract tables from the PDF
tables <- extract_tables("SPECS.pdf")

test<-vector("list",length(tables))


## Look at the tables and see what line you are interested in 
## to pull from the table, in this case BS and BSAI values are 
## on lines 6 and 7

for(i in 1:length(tables)){
   N=ncol(tables[[i]])-2
   n=N/5
   x = seq(5, N, by = 5)


test[[i]]<- data.table(
  YEAR = rep(tables[[i]][1, x], each=5),
  LEVEL = rep(tables[[i]][2, c(3:7)], n),
  BSAI = tables[[i]][6, 3:ncol(tables[[i]])],
  BS = tables[[i]][7, 3:ncol(tables[[i]])],
  AI = tables[[i]][8, 3:ncol(tables[[i]])]
)
}

test<-do.call(rbind,test)

test$BS <- as.numeric(gsub(",", "", test$BS))
test$BSAI <- as.numeric(gsub(",", "", test$BSAI))
test$AI <- as.numeric(gsub(",", "", test$AI))

test1<-test[YEAR<2014]
test2<-test[YEAR>=2014]

test1<-dcast(test1[,c(1:3)],YEAR~LEVEL)
test2<-dcast(test2[,c(1:2,4)],YEAR~LEVEL)

test3<-rbind(test1,test2)
test3$GHL<-""

test3[YEAR>2015]$GHL<- test3[YEAR>2015]$ABC-test3[YEAR>2015]$TAC

test1<-test3[YEAR<2005]
test2<-test3[YEAR>=2005]
df2.5<-data.frame(cbind(test1,test2))

names(df2.5) <- make.unique(names(df2.5))

ft2.4 <- flextable::flextable(df2.4)
ft2.4 <- flextable::colformat_num(ft2.4, j = c(1,3), big.mark = "")
ft2.4 <- flextable::bold(ft2.4, part = "header")
ft2.4 <- flextable::set_header_labels(ft2.4, Catch.1="Catch",ABC.1="ABC", Year.1="Year",OFL.1="OFL", TAC.1="TAC", GHL.1="GHL")










d <- ggplot(
  data = test[YEAR < 2014],
  mapping = aes(x = YEAR, y = BSAI, color = LEVEL, group = LEVEL)) +
  geom_point(size=2) +
  geom_line(linewidth = 1.1) +
  geom_point(data = test[YEAR > 2013], aes(y = BS + AI)) +
  geom_line(data = test[YEAR > 2013], aes(y = BS + AI)) +
  theme_bw(base_size = 16) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  labs(
    x = "Year",
    y = "BSAI and BS (mt)",
    color = "Value",
    title = "BSAI combined Pacific cod management values"
  ) +
  theme(legend.position = "bottom")
print(d)

# Load libraries
library(pdftools)
library(tabulizer)


url <-"https://apps-afsc.fisheries.noaa.gov/Plan_Team/2023/EBSpcod.pdf"
download.file(url, destfile = "document.pdf", mode = "wb")

# Extract tables from the PDF
tables2 <- extract_tables("document.pdf")

test2<-vector("list",length(tables2))

split_str <- strsplit(tables2[[1]][3:16,2], split = " ")
split_str <- do.call(rbind, split_str)

split_str2 <- strsplit(tables2[[1]][3:16,3], split = " ")
split_str2 <- do.call(rbind, split_str2)



MANG_TABLE<-data.table(Quantity=tables2[[1]][c(3:16),1],matrix(ncol=2,as.numeric(gsub(",", "", gsub("\\*", "",split_str)))),matrix(ncol=2,as.numeric(gsub(",", "", gsub("\\*", "",split_str2)))))

names(MANG_TABLE)<-c("Quantity","A","B","C","D")


ft <- flextable(MANG_TABLE)

ft <- ft %>% theme_box() %>% autofit()
colformat_text(ft, j = 2:5, formatter = function(x, i) ifelse(i == 1, "", x))

ft <- width(ft, j = 1, width = 2.5)


ft <- set_formatter(ft, value = trunc(x) format(x, nsmall = 0), i = 2)

