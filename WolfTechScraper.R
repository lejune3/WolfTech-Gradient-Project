library(writexl) # convert table into usable excel sheet
library(rvest) # webscrape tables
library(dplyr) #data manipulation
library(tidyverse)
library(RSelenium)
library(netstat)
library(data.table)
library(stringr)
library(XML)
library(plyr)

#Run the below code to start chrome and login
#to NCSU gradient using unity ID and password
#################################################################
rs_driver_object <- rsDriver(browser = "chrome",
                             chromever = "103.0.5060.134",
                             verbose = F,
                             port = free_port())

remDr <- rs_driver_object$client

remDr$navigate("https://gradient.ncsu.edu/")

full_grades <- data.frame()
################################################################

#THE STATISTICS COURSES WE ARE INTERESTED IN
stCourses <- c(307, 308, 311, 312, 350, 361, 370, 371, 372, 380, 401, 404, 405, 412, 421, 422, 430, 431, 432, 435, 437, 440, 442, 445, 446, 491, 495)

#LOOP THROUGH ALL THE COURSES ASSIGNED TO stCourses
for (i in stCourses) {
  subject_button <- remDr$findElement(using = 'xpath', '//select[@id="subjectSelect"]')
  subject_button$clickElement()
  Sys.sleep(1)
  
  st_click <- remDr$findElement(using = 'xpath', '//select[@id = "subjectSelect"]/option[@value = "ST"]')$clickElement()
  Sys.sleep(1)
  
  course_button <- remDr$findElement(using = 'xpath', '//select[@id="courseSelect"]')
  course_button$clickElement()
  
  course_click <- remDr$findElement(using = 'xpath', paste0("//select[@id = 'courseSelect']/option[@value = '",i,"']"))$clickElement()
  Sys.sleep(2)
  
  show_grades_button <- remDr$findElement(using = 'xpath', '//button[@type="button"]')
  remDr$mouseMoveToLocation(webElement = show_grades_button)
  show_grades_button$clickElement()
  Sys.sleep(2)
  
  courses <- remDr$findElements(using = 'xpath', '//div[@class="panel panel-default distribution"]/div[@class="panel-heading"]/h3[@class="panel-title"]') 
  course_numbers <- lapply(courses, function(x) x$getElementText()) %>% unlist()
  course_numbers <- sub("\\ -.*", "", course_numbers)
  
  course_names <- remDr$findElements(using = 'xpath', '//div[@id="description"]/h3')
  course_text <- lapply(course_names, function(x) x$getElementText()) %>% unlist() 
  course_titles <- sub(".*- ", "", course_text)
  
  
  professors <- remDr$findElements(using = 'xpath', '//div[@class="panel panel-default distribution"]/div[@class="panel-heading"]/em')
  professor_names <- lapply(professors, function(x) x$getElementText()) %>% unlist()
  professor_names <- sub("\\ -.*", "", professor_names)
  
  years_text <- lapply(professors, function(x) x$getElementText()) %>% unlist()
  years <- sub(".*- ", "", years_text)
  
  
  gradesLetterA <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[1]')
  grades_A <- lapply(gradesLetterA, function(x) x$getElementText()) %>% unlist()
  
  gradesLetterB <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[2]')
  grades_B <- lapply(gradesLetterB, function(x) x$getElementText()) %>% unlist()
  
  gradesLetterC <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[3]')
  grades_C <- (lapply(gradesLetterC, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterD <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[4]')
  grades_D <- (lapply(gradesLetterD, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterF <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[5]')
  grades_F <- (lapply(gradesLetterD, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterS <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[6]')
  grades_S <- (lapply(gradesLetterS, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterU <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[7]')
  grades_U <- (lapply(gradesLetterS, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterIN <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[8]')
  grades_IN <- (lapply(gradesLetterIN, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterLA <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[9]')
  grades_LA <- (lapply(gradesLetterLA, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterAU <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[10]')
  grades_AU <- (lapply(gradesLetterAU, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterNR <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[11]')
  grades_NR <- (lapply(gradesLetterNR, function(x) x$getElementText()) %>% unlist())
  
  gradesLetterW <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[12]')
  grades_W <- (lapply(gradesLetterW, function(x) x$getElementText()) %>% unlist())
  
  total <- remDr$findElements(using = 'xpath', '//table[@class="table table-bordered table-condensed"]/tbody/tr[1]/td[13]')
  grades_Total <- (lapply(total, function(x) x$getElementText()) %>% unlist())
  
  Sys.sleep(2)
  
  full_grades <- rbind.fill(full_grades, data.frame(course_numbers, course_titles, professor_names, years, grades_A, grades_B, grades_C, grades_D, grades_F, grades_S, grades_U, grades_IN, grades_LA, grades_AU, grades_NR, grades_W, grades_Total, stringsAsFactors = FALSE))
}

#Create csv file for ncsu statistics data
write.csv(full_grades, file = "ncsu_statistics_class_grades.csv" )