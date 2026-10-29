-- schema.sql: деректер базасының схемасы
-- Файлды қайта-қайта іске қосуға болады: алдымен ескі кестелерді жояды.
-- DROP TABLE IF EXISTS — кесте жоқ болса қате бермейді, бар болса жояды.
-- Тәртіп маңызды: enrollments екеуіне де сілтейді, сондықтан соңынан жойылады.

DROP TABLE IF EXISTS enrollments, students, courses;

-- -----------------------------------------------------------------------
-- courses кестесі — курс деректері
-- -----------------------------------------------------------------------
CREATE TABLE courses (
    -- id: курстың slug-і (мысалы: web-security), PRIMARY KEY — қайталанбайды
    id          text    PRIMARY KEY,

    -- title, description: міндетті өрістер, бос қалдыруға болмайды
    title       text    NOT NULL,
    description text    NOT NULL,

    -- credits: кредит саны, міндетті, нөлден үлкен болуы керек
    credits     integer NOT NULL CHECK (credits > 0),

    -- is_elective: таңдау пәні ме? әдепкі мән — false (міндетті пән)
    is_elective boolean NOT NULL DEFAULT false,

    -- likes: лайк саны, әдепкі 0, теріс болмайды
    likes       integer NOT NULL DEFAULT 0 CHECK (likes >= 0)
);

-- -----------------------------------------------------------------------
-- students кестесі — студент деректері
-- -----------------------------------------------------------------------
CREATE TABLE students (
    -- id: автоматты сан (1, 2, 3...), өзіміз берудің қажеті жоқ
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- name: аты, міндетті, 2 символдан кем болмауы керек
    name  text   NOT NULL CHECK (length(name) >= 2),

    -- email: міндетті, UNIQUE — екі студент бір email-ды бөліспейді
    email text   NOT NULL UNIQUE
);

-- -----------------------------------------------------------------------
-- enrollments кестесі — кім қай курсқа жазылған (байланыс кестесі)
-- courses пен students арасындағы many-to-many байланысты шешеді
-- -----------------------------------------------------------------------
CREATE TABLE enrollments (
    -- id: автоматты нөмір
    id          bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- course_id: қай курсқа жазылды, RESTRICT — тіркелуі бар курсты жоя алмайсың
    course_id   text        NOT NULL REFERENCES courses(id)  ON DELETE RESTRICT,

    -- student_id: қай студент жазылды, CASCADE — студентті жойсаң тіркелулері де жойылады
    student_id  bigint      NOT NULL REFERENCES students(id) ON DELETE CASCADE,

    -- enrolled_at: тіркелу уақыты, автоматты қойылады (UTC уақыт белдеуімен)
    enrolled_at timestamptz NOT NULL DEFAULT now(),

    -- бір студент бір курсқа екі рет жазыла алмайды
    UNIQUE (course_id, student_id)
);

-- -----------------------------------------------------------------------
-- Index: enrollments.student_id бағанына
-- PostgreSQL PRIMARY KEY мен UNIQUE үшін автоматты index жасайды,
-- бірақ FOREIGN KEY үшін жасамайды.
-- student_id бойынша іздеу жиі болады (GET /enrollments, CASCADE delete),
-- сондықтан қолмен index қосамыз — Seq Scan орнына Index Scan болады.
-- -----------------------------------------------------------------------
CREATE INDEX enrollments_student_id_idx ON enrollments (student_id);
