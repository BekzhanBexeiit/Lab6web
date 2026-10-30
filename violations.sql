-- =========================================================
-- violations.sql — CONSTRAINT VIOLATION LOG
-- Бұл файлдағы барлық командалар ҚАСАҚАНА ҚАТЕ жасайды!
-- Мақсат: әр constraint-тің SQLSTATE кодын тексеру
-- pgAdmin-де бірінен соң бірін іске қос
-- =========================================================


-- -------------------------------------------------------
-- 1. NULL in courses.title
-- ҚАТЕ: title бос болмауы керек (NOT NULL)
-- Күтілетін SQLSTATE: 23502
-- Constraint: NOT NULL (аты жоқ, баған аты көрінеді: title)
-- API жауабы: 422
-- -------------------------------------------------------
INSERT INTO courses (id, title, description, credits)
VALUES ('x-test', NULL, 'Test', 3);


-- -------------------------------------------------------
-- 2. courses.credits = 0
-- ҚАТЕ: credits нөлден үлкен болуы керек CHECK (credits > 0)
-- Күтілетін SQLSTATE: 23514
-- Constraint: courses_credits_check
-- API жауабы: 422
-- -------------------------------------------------------
INSERT INTO courses (id, title, description, credits)
VALUES ('x-test', 'Test', 'Test', 0);


-- -------------------------------------------------------
-- 3. courses.likes = -1
-- ҚАТЕ: likes теріс болмауы керек CHECK (likes >= 0)
-- Күтілетін SQLSTATE: 23514
-- Constraint: courses_likes_check
-- API жауабы: 500 (бұл біздің код қатесі — likes тек +1 болуы керек)
-- -------------------------------------------------------
UPDATE courses SET likes = -1 WHERE id = 'api-design';


-- -------------------------------------------------------
-- 4. Бір әріпті студент аты
-- ҚАТЕ: атау 2 символдан кем болмауы керек CHECK (length(name) >= 2)
-- Күтілетін SQLSTATE: 23514
-- Constraint: students_name_check
-- API жауабы: 422
-- -------------------------------------------------------
INSERT INTO students (name, email)
VALUES ('A', 'a@example.com');


-- -------------------------------------------------------
-- 5. Қайталанған student email
-- ҚАТЕ: email бірегей болуы керек (UNIQUE)
-- Күтілетін SQLSTATE: 23505
-- Constraint: students_email_key
-- API жауабы: 409 Conflict
-- -------------------------------------------------------
INSERT INTO students (name, email)
VALUES ('Dup Student', 'aigerim@example.com');


-- -------------------------------------------------------
-- 6. Қайталанған course id
-- ҚАТЕ: id PRIMARY KEY — қайталанбайды
-- Күтілетін SQLSTATE: 23505
-- Constraint: courses_pkey
-- API жауабы: 409 Conflict
-- -------------------------------------------------------
INSERT INTO courses (id, title, description, credits)
VALUES ('api-design', 'x', 'y', 1);


-- -------------------------------------------------------
-- 7. Бір студент бір курсқа екі рет жазылу
-- ҚАТЕ: (course_id, student_id) жұбы UNIQUE
-- Күтілетін SQLSTATE: 23505
-- Constraint: enrollments_course_id_student_id_key
-- API жауабы: 409 Conflict
-- -------------------------------------------------------
INSERT INTO enrollments (course_id, student_id)
VALUES ('modern-frontend', 1);


-- -------------------------------------------------------
-- 8. Жоқ курсқа тіркелу
-- ҚАТЕ: course_id REFERENCES courses — 'no-such-course' жоқ
-- Күтілетін SQLSTATE: 23503
-- Constraint: enrollments_course_id_fkey
-- API жауабы: 404 Not Found
-- -------------------------------------------------------
INSERT INTO enrollments (course_id, student_id)
VALUES ('no-such-course', 1);


-- -------------------------------------------------------
-- 9. Жоқ студентті тіркелу
-- ҚАТЕ: student_id REFERENCES students — id=999 жоқ
-- Күтілетін SQLSTATE: 23503
-- Constraint: enrollments_student_id_fkey
-- API жауабы: 404 Not Found
-- -------------------------------------------------------
INSERT INTO enrollments (course_id, student_id)
VALUES ('web-security', 999);


-- -------------------------------------------------------
-- 10. Тіркелуі бар курсты жою
-- ҚАТЕ: ON DELETE RESTRICT — enrollments бар, жоюға болмайды
-- Күтілетін SQLSTATE: 23001 (PostgreSQL 18)
-- Constraint: enrollments_course_id_fkey
-- API жауабы: 409 Conflict
-- -------------------------------------------------------
DELETE FROM courses WHERE id = 'modern-frontend';


-- -------------------------------------------------------
-- 11. Студентті жою — CASCADE (БҰЛ ҚАТЕ ЕМЕС!)
-- ON DELETE CASCADE — студент жойылса тіркелулері автоматты жойылады
-- SQLSTATE: жоқ (қате шықпайды)
-- Нәтиже: enrollments 6 → 3 (Daniyar-дың 3 тіркелуі жойылды)
-- BEGIN...ROLLBACK ішінде — деректер сақталады
-- -------------------------------------------------------
BEGIN;
SELECT count(*) AS enrollments_before FROM enrollments;

DELETE FROM students WHERE email = 'daniyar@example.com';

SELECT count(*) AS enrollments_after FROM enrollments;
ROLLBACK;

SELECT count(*) AS enrollments_after_rollback FROM enrollments;
