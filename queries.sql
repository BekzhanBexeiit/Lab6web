-- queries.sql: API маршруттарына арналған сұраныстар
-- Мәндер тікелей жазылған (мысалы: 'api-design', 3)
-- Деректерді өзгертетін сұраныстар BEGIN...ROLLBACK ішінде —
-- файлды қайта іске қосқанда деректер өзгермейді

-- -----------------------------------------------------------------------
-- 1. GET /courses?is_elective=false&sort=popular&page=1&page_size=3
-- Міндетті курстарды лайк санына қарай сорттайды, 1-бет (3 курс)
-- ORDER BY likes DESC — ең көп лайктан бастайды
-- LIMIT 3 OFFSET 0 — 1-беттің 3 курсы (offset = (page-1) * page_size)
-- -----------------------------------------------------------------------
SELECT id, title, credits, likes
FROM courses
WHERE is_elective = false
ORDER BY likes DESC, id
LIMIT 3 OFFSET 0;

-- 1b. Сол сұраныс, 2-бет: OFFSET = (2-1) * 3 = 3
SELECT id, title, credits, likes
FROM courses
WHERE is_elective = false
ORDER BY likes DESC, id
LIMIT 3 OFFSET 3;

-- -----------------------------------------------------------------------
-- 2. GET /courses/{course_id} — 'api-design' курсын алады
-- Табылмаса 0 rows қайтарады → API 404 береді
-- -----------------------------------------------------------------------
SELECT id, title, credits, is_elective, likes
FROM courses
WHERE id = 'api-design';

-- 2b. Жоқ курс — 0 rows, API 404 береді
SELECT id, title, credits, is_elective, likes
FROM courses
WHERE id = 'no-such-course';

-- -----------------------------------------------------------------------
-- 3. POST /courses/{course_id}/like — likes санын +1 арттырады
-- UPDATE ішінде likes = likes + 1 — бір командамен оқып жазады
-- RETURNING — жаңартылған мәнді бірден қайтарады
-- BEGIN...ROLLBACK — тест үшін, нақты деректер өзгермейді
-- -----------------------------------------------------------------------
BEGIN;

-- 'api-design' курсының likes санын +1 арттырып, жаңа мәнді қайтарады
UPDATE courses
SET likes = likes + 1
WHERE id = 'api-design'
RETURNING id, likes;

-- 3b. Жоқ курс — UPDATE 0, API 404 береді
UPDATE courses
SET likes = likes + 1
WHERE id = 'no-such-course'
RETURNING id, likes;

ROLLBACK;

-- -----------------------------------------------------------------------
-- 4. POST /enrollments — студентті курсқа тіркейді
-- id мен enrolled_at көрсетпейміз — база өзі қояды
-- RETURNING — жасалған жазбаны бірден қайтарады (201 Created)
-- BEGIN...ROLLBACK — тест үшін
-- -----------------------------------------------------------------------
BEGIN;

INSERT INTO enrollments (course_id, student_id)
VALUES ('web-security', 3)
RETURNING id, course_id, student_id;

ROLLBACK;

-- -----------------------------------------------------------------------
-- 5. GET /enrollments — барлық тіркелулер + студент аты + курс атауы
-- JOIN students — student_id арқылы студент атын аламыз
-- JOIN courses  — course_id арқылы курс атауын аламыз
-- Лаб 5-те тек атау сақталды, енді нақты кестелер арқылы аламыз
-- -----------------------------------------------------------------------
SELECT e.id,
       s.name  AS student,
       c.title AS course
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses  c ON c.id = e.course_id
ORDER BY e.id;

-- -----------------------------------------------------------------------
-- 6. Статистика: әр курсқа қанша студент жазылған (нөл болса да)
-- LEFT JOIN — тіркелуі жоқ курстарды да қосады (нөлмен)
-- count(e.id) — NULL мәндерді санамайды (LEFT JOIN-да NULL болады)
-- count(*) емес! — LEFT JOIN кезінде жалған 1 береді
-- -----------------------------------------------------------------------
SELECT c.id,
       count(e.id) AS enrolled
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id
ORDER BY enrolled DESC, c.id;
