# Bibliotecas
library(tidyverse)
library(RSelenium)
library(rvest)
library(netstat)

# Web scrapping
html <- rvest::read_html("https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/todos-os-dados-abertos")

# Limpando o vetor de datas
data <- html %>% 
  rvest::html_elements(".summary-view-icon") %>%
  rvest::html_text() %>%
  str_replace_all(., pattern=" ", repl="") %>%
  str_replace_all(., pattern="\n", repl="") %>%
  as_tibble() %>%
  filter(value != "Link",
         !str_detect(value, 'h'),
         value != "Arquivo") %>%
  rename(Data = value) %>%
  mutate(Data = as.Date(Data, format = "%d/%m/%Y"))

# Limpando o vetor com os títulos 
indice <- html %>%
  rvest::html_elements(".url") %>%
  rvest::html_text() %>%
  as_tibble() %>%
  rename(Indice = value)

# Tibble com todos o dados disponvíveis para download no site de ANAC
dados_disp_anac <- cbind(data, indice)

# Retirando os vetores desnecessários
rm(list = c("data", "indice"))

# Coisa do Java
Sys.setenv(JAVA_HOME="C:/Program Files (x86)/Java/jre1.8.0_311")

# Baixando as bases
driver <- rsDriver(browser = "chrome", port = 4856L,
                   chromever = "96.0.4664.45",
                   check = T,
                   verbose = T)
remote_driver <- driver[["client"]]
url1 <- "https://www.anac.gov.br/acesso-a-informacao/dados-abertos/areas-de-atuacao/todos-os-dados-abertos"
remote_driver$navigate(url1)

  open_index <- remote_driver$findElement(using = "css selector", ".url")
  open_index$clickElement()
  open_index$findElement(using = "css selector", "p a") # Tá dando erro na maior debaixar esses dados
  open_index$clickElement()

