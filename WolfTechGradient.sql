WITH CTE_Ncsu AS
(SELECT
	ncsu.professor_names, -- list of professor names
	course_numbers, -- statistics courses
	course_titles, -- title of statistic course
	years AS semester, -- list year as semester
	TRIM(RIGHT(years, 2)) AS year_date, -- list only the year
	ncsu2.avg_students_taught, -- avg # of students taught per professor
	SUM(grades_Total) AS num_of_students, -- # of students each professor has taught in designated course, year, etc.
	SUM(grades_A) AS Total_A, -- students who received A's in their classes
	SUM(grades_A)/SUM(grades_total) AS percent_of_As, -- set percent of A's to the whole class
	-- Setting up A's metric criteria by AVERAGE OF A's IN ALL STATISTICS CLASSES
	"average_A's_Total" = (SELECT SUM(grades_A)/SUM(grades_total)
							FROM PortfolioProject.dbo.ncsu_statistics_class_grades$
							WHERE grades_total >= 30),
	---------------------------------------------------------------------------------
	SUM(grades_B) AS Total_B, -- students who received B's in their classes
	SUM(grades_B)/SUM(grades_total) AS percent_of_Bs, -- set percent of B's to the whole class
	-- Average of B's in ALL OF STATISTICS CLASSES
	"average_B's_Total" = (SELECT SUM(grades_B)/SUM(grades_total)
							FROM PortfolioProject.dbo.ncsu_statistics_class_grades$
							WHERE grades_total >= 30),
	---------------------------------------------------------------------------------
	SUM(grades_C) AS Total_C, -- students who received C's in their classes
	SUM(grades_C)/SUM(grades_total) AS percent_of_Cs, -- set percent of C's to the whole class
	-- Average of C's in ALL OF STATISTICS CLASSES
	"average_C's_Total" = (SELECT SUM(grades_C)/SUM(grades_total)
							FROM PortfolioProject.dbo.ncsu_statistics_class_grades$
							WHERE grades_total >= 30)
	---------------------------------------------------------------------------------
FROM 
	PortfolioProject.dbo.ncsu_statistics_class_grades$ AS ncsu
LEFT JOIN
	PortfolioProject.dbo.ncsu_professor_avg_students AS ncsu2
ON
	ncsu.professor_names = ncsu2.professor_names

/*
** Stat courses to select from (307, 308, 311, 312, 350, 361, 370, 371,
** 372, 380, 401, 404, 405, 412, 421, 422, 430, 431, 432, 435, 437,
** 440, 442, 445, 446, 491, 495)
*/
-- Select only the relevant courses I am interested in with high sample sizes
WHERE course_numbers IN
		(SELECT course_numbers
		FROM PortfolioProject.dbo.ncsu_statistics_class_grades$
		WHERE course_numbers LIKE 'ST 3%' OR course_numbers LIKE 'ST 3%'
		OR course_numbers LIKE 'ST 42%' OR course_numbers LIKE 'ST 43%'
		OR course_numbers = 'ST 412')
GROUP BY
	ncsu.professor_names,
	ncsu.years,
	ncsu.course_numbers,
	ncsu.course_titles,
	ncsu2.avg_students_taught
-- filter out low sample sizes
HAVING
	SUM(grades_total) >= 30
)
SELECT
	*,
	CASE
	WHEN percent_of_As >= .43351 THEN 'above average' -- Above 2 STD
	WHEN percent_of_As >= .31561 THEN 'average' -- Within 2 standard deviations of "average_A's_Total", decimal taken to 5
	WHEN percent_of_As < .31561 THEN 'below average' -- Below 2 STD
	END AS Grade_Distribution_For_A,
	CASE
	WHEN percent_of_Bs >= .33658 THEN 'above average' -- Above 2 STD
	WHEN percent_of_Bs >= .25274 THEN 'average' -- Within 2 standard deviations of "average_B's_Total", decimal taken to 5
	WHEN percent_of_Bs < .25274 THEN 'below average' -- Below 2 STD
	END AS Grade_Distribution_For_B,
	CASE
	WHEN percent_of_Cs >= .17150 THEN 'above average' -- Above 2 STD
	WHEN percent_of_Cs >= .10601 THEN 'average' -- Within 2 standard deviations of "average_B's_Total", decimal taken to 5
	WHEN percent_of_Cs < .10601 THEN 'below average' -- Below 2 STD
	END AS Grade_Distribution_For_C
FROM CTE_Ncsu
ORDER BY
	course_numbers




