-- idx_data.sql: index эксперименті үшін көп деректер
-- idx_demo базасына жүктеледі (course_catalog емес!)
-- 500 курс, 20,000 студент, 50,000 тіркелу
-- generate_series(1, N) — 1-ден N-ге дейінгі сандар тізбегін жасайды
-- || — жолдарды біріктіреді ('course-' || 5 = 'course-5')

-- 500 курс жасайды: course-1, course-2, ..., course-500
INSERT INTO courses (id, title, description, credits)
SELECT 'course-' || g, 'Course ' || g, 'Test', 3
FROM generate_series(1, 500) AS g;

-- 20,000 студент жасайды: student1@example.com, ...
INSERT INTO students (name, email)
SELECT 'Student ' || g, 'student' || g || '@example.com'
FROM generate_series(1, 20000) AS g;

-- 50,000 тіркелу жасайды
-- % (modulo) — қалдықпен бөлу, курстар мен студенттерді циклмен таратады
INSERT INTO enrollments (course_id, student_id)
SELECT 'course-' || (1 + (g + g / 20000) % 500), 1 + g % 20000
FROM generate_series(1, 50000) AS g;

-- ANALYZE — планировщик қолданатын статистиканы жаңартады
-- Осынсыз EXPLAIN бұрыс cost есептеуі мүмкін
ANALYZE courses;
ANALYZE students;
ANALYZE enrollments;
