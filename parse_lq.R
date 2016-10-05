library(rvest)
library(stringr)
library(tibble)
library(dplyr)

files = dir("data/lq/", "html", full.names = TRUE)

res = list()

for(i in seq_along(files))
{
  file = files[i]
  
  page = read_html(file)
  
  hotel_info = page %>% 
    html_nodes(".hotelDetailsBasicInfoTitle p") %>%
    html_text() %>% 
    str_split("\n") %>% 
    .[[1]] %>% 
    str_trim() %>%
    .[. != ""]

  n_rooms = page %>% 
    html_nodes(".hotelFeatureList li:nth-child(2)") %>%
    html_text() %>%
    str_trim() %>%
    str_replace("Rooms: ", "") %>%
    as.integer()
  
  map = page %>%
    html_nodes(".minimap") %>%
    html_attr("src") %>%
    str_split("\\|") %>%
    .[[1]] %>%
    .[2] %>%
    str_split("\\&") %>%
    .[[1]] %>%
    .[1] %>%
    str_split(",") %>%
    .[[1]]
  
  res[[i]] = data_frame(
    address = paste(hotel_info[1:2],collapse="\n"),
    phone = hotel_info[3] %>% str_replace("Phone: ", ""), 
    fax   = hotel_info[4] %>% str_replace("Fax: ", ""),
    n_rooms = n_rooms
  )
  
  if (i>3)
    break
}

hotels = bind_rows(res)
