# Combine untidy data into a single CSV file

library('tidyverse')
library('lubridate')

files <- dir('raw_data/')

covid <- c()
for (file in files) {
  tmp <- read_csv(paste0('raw_data/', file),
                  col_names = c('label', 'day', 'N_cases'),
                  col_types = ('ccc')) %>%
    filter(day != 'Total') %>%
    mutate(dates = parse_date(day, format = '%m/%d/%Y')) %>%
    mutate(N_cases = as.double(gsub(',','', N_cases))) %>%
    pivot_wider(names_from = label, values_from = N_cases) %>%
    rename(N_tests = `Number of tests`, N_student_tests = `Number of student tests`,
           N_employee_tests = `Number of employee tests`,
           N_cases = `New Confirmed Positive, Total`) %>%
    select(-day) %>%
    replace_na(list(N_tests = 0, N_employee_tests = 0, N_cases = 0))
  
  covid <- rbind(covid, tmp)
}

duplicates_removed <- c()
for (d in as.list(unique(covid$dates))) {
  tmp <- covid %>% filter(dates == date(d))
  duplicates_removed <- rbind(duplicates_removed, tail(tmp, 1))
}

write_csv(duplicates_removed, 'cleaned_covid_data.csv')

