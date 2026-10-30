-- =========================================================
-- transaction.sql — TRANSACTION ЭКСПЕРИМЕНТІ
-- Студентті курсқа тіркеу = 2 insert бірге
-- =========================================================


-- -------------------------------------------------------
-- СЦЕНАРИЙ 1: 2-ші insert сәтсіз → екеуі де жойылады
-- -------------------------------------------------------

-- Transaction бастаймыз
BEGIN;

-- 1-ші insert: студент қосамыз (дұрыс)
INSERT INTO students (name, email)
VALUES ('Madina Ospanova', 'madina@example.com');

-- 2-ші insert: жоқ курсқа тіркелу (ҚАТЕ!) → 23503 FOREIGN KEY violation
INSERT INTO enrollments (course_id, student_id)
SELECT 'no-such-course', id
FROM students
WHERE email = 'madina@example.com';

-- Қате шықты → транзакция бұзылды (prompt =!> болды)
-- Барлығын жоямыз — Madina базада қалмайды
ROLLBACK;

-- Тексеру: Madina жоқ болуы керек → count = 0
SELECT count(*) AS madina_exists
FROM students
WHERE email = 'madina@example.com';


-- -------------------------------------------------------
-- СЦЕНАРИЙ 2: екі insert дұрыс → COMMIT жасаймыз
-- -------------------------------------------------------

-- Transaction бастаймыз
BEGIN;

-- 1-ші insert: студент қосамыз
INSERT INTO students (name, email)
VALUES ('Madina Ospanova', 'madina@example.com');

-- 2-ші insert: нақты бар курсқа тіркелу (дұрыс)
INSERT INTO enrollments (course_id, student_id)
SELECT 'web-security', id
FROM students
WHERE email = 'madina@example.com';

-- Екеуі де дұрыс → COMMIT жасаймыз
-- Осы сәтте басқа терезе (Window B) деректерді көреді
COMMIT;

-- Тексеру: Madina бар болуы керек → count = 1
SELECT count(*) AS madina_exists
FROM students
WHERE email = 'madina@example.com';

-- Тіркелуін тексеру
SELECT s.name AS student, c.title AS course
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses  c ON c.id = e.course_id
WHERE s.email = 'madina@example.com';

-- -------------------------------------------------------
-- Тазалау — Madina мен тіркелуін жоямыз (деректер қалпына)
-- CASCADE болғандықтан enrollments өзі жойылады
-- -------------------------------------------------------
DELETE FROM students WHERE email = 'madina@example.com';
