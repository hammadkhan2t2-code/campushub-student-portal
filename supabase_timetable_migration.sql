-- ============================================================================
-- CampusHub Authoritative Timetable Migration
-- Source: Official 20-Page Departmental Time Table PDF
-- Verified Totals: BSCS = 150 | BSSE = 148 | BSAI = 72 | Grand Total = 370
-- Exact Schema Reconciliation against Authoritative Database Schema:
--   - timetable_entries.id is TEXT PRIMARY KEY (deterministic ID)
--   - timetable_entries.teacher_id is TEXT (FK to teachers.id)
--   - timetable_entries.room_id is TEXT (FK to rooms.id)
--   - timetable_entries.course_code is TEXT (FK to courses.code)
--   - courses PK is "code" (NO courses.id, NO courses.type)
--   - batches uses "is_active" (NO batches.active)
--   - semesters uses "order_seq" (NO semesters.number)
--   - section_id is intentionally nullable (BSAI is single cohort = NULL)
--   - teacher_id & teacher_name are intentionally nullable (134 unassigned slots = NULL)
-- Safety: Does NOT touch auth.users, profiles, lost_found_items, or lost_found_claims.
-- Atomic: Runs inside a single BEGIN / COMMIT transaction block with strict assertions.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- STEP 0: SCHEMA ADJUSTMENTS & NULLABILITY RELAXATIONS
-- Allow section_id to be NULL for BSAI (single cohort without sections)
-- Allow teacher_id & teacher_name to be NULL for 134 unassigned/blank faculty slots
-- Adjust unique schedule constraints to partial unique indexes so NULLs & lab groups do not conflict
-- ----------------------------------------------------------------------------
ALTER TABLE public.timetable_entries ALTER COLUMN section_id DROP NOT NULL;
ALTER TABLE public.timetable_entries ALTER COLUMN teacher_id DROP NOT NULL;
ALTER TABLE public.timetable_entries ALTER COLUMN teacher_name DROP NOT NULL;

-- Drop obsolete or restrictive unique constraints if present, replacing them with partial unique indexes
DO $$
BEGIN
  -- Drop constraint unique_class_schedule if exists
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unique_class_schedule') THEN
    ALTER TABLE public.timetable_entries DROP CONSTRAINT unique_class_schedule;
  END IF;
  -- Drop constraint unique_room_schedule if exists
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unique_room_schedule') THEN
    ALTER TABLE public.timetable_entries DROP CONSTRAINT unique_room_schedule;
  END IF;
  -- Drop constraint unique_teacher_schedule if exists
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'unique_teacher_schedule') THEN
    ALTER TABLE public.timetable_entries DROP CONSTRAINT unique_teacher_schedule;
  END IF;
END $$;

-- Recreate teacher schedule uniqueness only when teacher_id is NOT NULL
CREATE UNIQUE INDEX IF NOT EXISTS idx_timetable_unique_teacher_schedule 
  ON public.timetable_entries (day, teacher_id, start_time) 
  WHERE teacher_id IS NOT NULL;

-- ----------------------------------------------------------------------------
-- STEP 1: CLEAR EXISTING TIMETABLE ENTRIES ONLY
-- (Does not touch auth, profiles, lost_found, or other application tables)
-- ----------------------------------------------------------------------------
DELETE FROM public.timetable_entries;

-- ----------------------------------------------------------------------------
-- STEP 2: ENSURE EXACTLY THE 3 CANONICAL DEPARTMENTS (CS, SE, AI)
-- Valid ON CONFLICT target: departments.name and departments.code are UNIQUE
-- ----------------------------------------------------------------------------
INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), 'Computer Science', 'CS')
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;
INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), 'Software Engineering', 'SE')
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;
INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), 'Artificial Intelligence', 'AI')
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;

-- Reassign any legacy courses, teachers, or programs pointing to non-canonical departments to Computer Science
UPDATE public.courses
SET department_id = (SELECT id FROM public.departments WHERE code = 'CS' LIMIT 1)
WHERE department_id IN (SELECT id FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI'));

UPDATE public.teachers
SET department_id = (SELECT id FROM public.departments WHERE code = 'CS' LIMIT 1)
WHERE department_id IN (SELECT id FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI'));

UPDATE public.programs
SET department_id = (SELECT id FROM public.departments WHERE code = 'CS' LIMIT 1)
WHERE department_id IN (SELECT id FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI'));

-- Delete non-canonical departments safely
DELETE FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI');

-- ----------------------------------------------------------------------------
-- STEP 3: ENSURE THE 3 CANONICAL DEGREE PROGRAMS
-- Valid ON CONFLICT target: programs.name is UNIQUE
-- ----------------------------------------------------------------------------
INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, 'BS Computer Science', 'BSCS', 4
FROM public.departments d
WHERE d.code = 'CS'
ON CONFLICT (name) DO UPDATE 
SET short_code = EXCLUDED.short_code,
    duration_years = EXCLUDED.duration_years,
    department_id = EXCLUDED.department_id;
INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, 'BS Software Engineering', 'BSSE', 4
FROM public.departments d
WHERE d.code = 'SE'
ON CONFLICT (name) DO UPDATE 
SET short_code = EXCLUDED.short_code,
    duration_years = EXCLUDED.duration_years,
    department_id = EXCLUDED.department_id;
INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, 'BS Artificial Intelligence', 'BSAI', 4
FROM public.departments d
WHERE d.code = 'AI'
ON CONFLICT (name) DO UPDATE 
SET short_code = EXCLUDED.short_code,
    duration_years = EXCLUDED.duration_years,
    department_id = EXCLUDED.department_id;

-- ----------------------------------------------------------------------------
-- STEP 4: ENSURE SEMESTERS (1st, 3rd, 5th, 7th)
-- Confirmed Schema: id UUID PK, name TEXT UNIQUE, order_seq INT UNIQUE (NO "number")
-- Valid ON CONFLICT target: semesters.name is UNIQUE
-- ----------------------------------------------------------------------------
INSERT INTO public.semesters (id, name, order_seq)
VALUES (gen_random_uuid(), '1st', 1)
ON CONFLICT (name) DO UPDATE SET order_seq = EXCLUDED.order_seq;
INSERT INTO public.semesters (id, name, order_seq)
VALUES (gen_random_uuid(), '3rd', 3)
ON CONFLICT (name) DO UPDATE SET order_seq = EXCLUDED.order_seq;
INSERT INTO public.semesters (id, name, order_seq)
VALUES (gen_random_uuid(), '5th', 5)
ON CONFLICT (name) DO UPDATE SET order_seq = EXCLUDED.order_seq;
INSERT INTO public.semesters (id, name, order_seq)
VALUES (gen_random_uuid(), '7th', 7)
ON CONFLICT (name) DO UPDATE SET order_seq = EXCLUDED.order_seq;

-- ----------------------------------------------------------------------------
-- STEP 5: ENSURE SECTIONS (A, B for BSCS and BSSE)
-- Note: BSAI is a single cohort without section divisions (section_id will be NULL)
-- Valid ON CONFLICT target: sections.name is UNIQUE
-- ----------------------------------------------------------------------------
INSERT INTO public.sections (id, name)
VALUES (gen_random_uuid(), 'A')
ON CONFLICT (name) DO NOTHING;
INSERT INTO public.sections (id, name)
VALUES (gen_random_uuid(), 'B')
ON CONFLICT (name) DO NOTHING;

-- ----------------------------------------------------------------------------
-- STEP 6: ENSURE BATCHES
-- Confirmed Schema: id UUID PK, name TEXT UNIQUE, start_year INT, end_year INT, is_active BOOL (NO "active")
-- Valid ON CONFLICT target: batches.name is UNIQUE
-- ----------------------------------------------------------------------------
INSERT INTO public.batches (id, name, start_year, end_year, is_active)
VALUES (gen_random_uuid(), 'Fall 2026 – 2030', 2026, 2030, true)
ON CONFLICT (name) DO UPDATE 
SET start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year,
    is_active = EXCLUDED.is_active;
INSERT INTO public.batches (id, name, start_year, end_year, is_active)
VALUES (gen_random_uuid(), 'Fall 2025 – 2029', 2025, 2029, true)
ON CONFLICT (name) DO UPDATE 
SET start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year,
    is_active = EXCLUDED.is_active;
INSERT INTO public.batches (id, name, start_year, end_year, is_active)
VALUES (gen_random_uuid(), 'Fall 2024 – 2028', 2024, 2028, true)
ON CONFLICT (name) DO UPDATE 
SET start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year,
    is_active = EXCLUDED.is_active;
INSERT INTO public.batches (id, name, start_year, end_year, is_active)
VALUES (gen_random_uuid(), 'Fall 2023 – 2027', 2023, 2027, true)
ON CONFLICT (name) DO UPDATE 
SET start_year = EXCLUDED.start_year,
    end_year = EXCLUDED.end_year,
    is_active = EXCLUDED.is_active;

-- ----------------------------------------------------------------------------
-- STEP 7: ENSURE ROOMS & LABORATORIES
-- Confirmed Schema: id TEXT PRIMARY KEY, room_number TEXT UNIQUE
-- Valid ON CONFLICT target: rooms.room_number is UNIQUE
-- Complies with constraint valid_room_capacity:
--   * Computer Lab: capacity = 60
--   * Lecture Hall / Seminar Room: capacity = 55
-- ----------------------------------------------------------------------------
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-1', 'Room 1', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Smart Board', 'Multimedia Projector', 'Audio System']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-2', 'Room 2', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-3', 'Room 3', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-4', 'Room 4', 'CS Academic Block', '1st Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Smart Board']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-5', 'Room 5', 'CS Academic Block', '1st Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-6', 'Room 6', 'CS Academic Block', '1st Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-7', 'Room 7', 'CS Academic Block', '2nd Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-8', 'Room 8', 'CS Academic Block', '2nd Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-1', 'Lab 1', 'CS Computing Laboratories', 'Ground Floor', 60, 'Computer Lab', ARRAY['Workstations', 'High-Speed LAN', 'Dedicated UPS Power', 'Multimedia Projector']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-2', 'Lab 2', 'CS Computing Laboratories', 'Ground Floor', 60, 'Computer Lab', ARRAY['Workstations with Database Engines', 'Gigabit Networking']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-3', 'Lab 3', 'CS Computing Laboratories', '1st Floor', 60, 'Computer Lab', ARRAY['Programming & Compiler Workstations', 'High-Speed Internet', 'Projector']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-4', 'Lab 4', 'CS Computing Laboratories', '1st Floor', 60, 'Computer Lab', ARRAY['Development Terminals', 'Multimedia Projector']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-5', 'Lab 5', 'CS Computing Laboratories', '2nd Floor', 60, 'Computer Lab', ARRAY['Software Engineering & Testing Workstations', 'Dual-display Terminals']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-6', 'Lab 6', 'CS Computing Laboratories', '2nd Floor', 60, 'Computer Lab', ARRAY['Computer Networks & Assembly Language Hardware Stations', 'Network Racks']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('lab-dip', 'DIP Lab', 'Advanced Research Facility', '2nd Floor', 60, 'Computer Lab', ARRAY['Digital Image Processing GPU Workstations', 'Smart Display']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-stats', 'Stats Deptt', 'Statistics & Allied Sciences Block', 'Ground Floor', 55, 'Seminar Room', ARRAY['Lecture Podiums', 'Multimedia Projector', 'Sound System']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-room-unspecified', 'Room Unspecified', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-lab-unspecified', 'Lab Unspecified', 'CS Computing Laboratories', 'Ground Floor', 60, 'Computer Lab', ARRAY['Workstations', 'High-Speed LAN', 'Dedicated UPS Power', 'Multimedia Projector']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES ('rm-stats-dept', 'Stats Department', 'Statistics & Allied Sciences Block', 'Ground Floor', 55, 'Seminar Room', ARRAY['Lecture Podiums', 'Multimedia Projector', 'Sound System']::text[])
ON CONFLICT (room_number) DO UPDATE
SET building = EXCLUDED.building,
    floor = EXCLUDED.floor,
    capacity = EXCLUDED.capacity,
    type = EXCLUDED.type,
    facilities = EXCLUDED.facilities;

-- ----------------------------------------------------------------------------
-- STEP 8: ENSURE FACULTY MEMBERS
-- Confirmed Schema: id TEXT PRIMARY KEY, name TEXT (NOT UNIQUE), designation TEXT, qualifications TEXT, specialization TEXT, department_id UUID
-- Valid ON CONFLICT target: teachers.id is PRIMARY KEY
-- ----------------------------------------------------------------------------
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-tauseef', 'Dr. Tauseef-ur-Rehman', 'Assistant Professor', 'Ph.D. in Computer Science', 'Programming Methodologies, Computing Ethics, Algorithms', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-salahuddin', 'Mr. Salahuddin', 'Lecturer', 'MS in Information Technology', 'Information & Communication Technologies, Network Essentials', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-sajjad', 'Dr. Muhammad Sajjad', 'Professor', 'Ph.D. in Computer Science', 'Machine Learning, Deep Learning, Digital Image Processing, Computer Vision', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-naveed', 'Dr. Naveed Abbas', 'Associate Professor', 'Ph.D. in Computer Science & Systems', 'Multi-Agent Systems, Modeling & Simulation, Professional Ethics', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-atif', 'Dr. Atif Khan', 'Associate Professor', 'Ph.D. in Database Engineering', 'Database Systems, Data Engineering, Query Optimization', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-waseem', 'Dr. Muhammad Waseem', 'Assistant Professor', 'Ph.D. in Computer Science', 'Data Structures, Computational Complexity, Algorithms', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-khalid', 'Dr. Khalid Haseeb', 'Associate Professor', 'Ph.D. in Telecommunications & Networks', 'Computer Networks, Wireless Sensor Networks, IoT, Software Architecture', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-faisal', 'Mr. Faisal Saeed', 'Lecturer', 'MS in Computer Engineering', 'Low-level Systems Programming, Microprocessor Architecture', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-mansoor', 'Dr. Mansoor Nasir', 'Associate Professor', 'Ph.D. in Computer Science', 'Modern Web Architectures, Distributed Applications', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-inaam', 'Mr. Inaam Ul Haq', 'Lecturer', 'MS in Software Engineering', 'Software Quality Assurance, Computing Ethics, Professional Standards', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-zubair', 'Mr. Muhammad Zubair', 'Lecturer', 'MS in Computer Science', 'Compiler Design, Network Security, Cryptography', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-math', 'Faculty (Mathematics Dept)', 'Department of Mathematics', 'M.Phil / Ph.D. in Mathematics', 'Applied Calculus, Analytical Geometry, Differential Equations, Linear Algebra', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-english', 'Faculty (English Dept)', 'Department of English', 'M.Phil in Applied Linguistics', 'Technical Writing, Academic English Communication', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-physics', 'Faculty (Physics Dept)', 'Department of Physics', 'M.Phil / Ph.D. in Applied Physics', 'Applied Physics, Semiconductor Physics', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-shaukat', 'Dr. Shaukat Ali', 'Associate Professor', 'Ph.D. in Computer Science', 'Database Systems, Automata & Formal Languages, Distributed Systems', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-irshad', 'Dr. Irshad', 'Assistant Professor', 'Ph.D. in Computer Science', 'Algorithms, Data Structures, Computer Graphics', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-bilal', 'Dr. Bilal', 'Assistant Professor', 'Ph.D. in Computer Science', 'Database Engineering, Data Structures, Theory of Computation', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-israr', 'Dr. Israr Iqbal', 'Assistant Professor', 'Ph.D. in Software Engineering', 'Software Architecture, Distributed Systems, Software Design Patterns', d.id
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-naila', 'Dr. Naila Habib', 'Assistant Professor', 'Ph.D. in Software Engineering', 'Software Project Management, Software Evolution & Re-Engineering', d.id
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-islamic', 'Faculty (Islamic & Pak Studies)', 'Humanities Department', 'M.Phil in Islamic & Pakistan Studies', 'Islamic Jurisprudence, Constitutional History of Pakistan', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT 'tch-dr-sajjad', 'Dr. Sajjad', 'Professor', 'Ph.D. in Computer Science', 'Machine Learning, Deep Learning, Digital Image Processing, Computer Vision', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    designation = EXCLUDED.designation,
    qualifications = EXCLUDED.qualifications,
    specialization = EXCLUDED.specialization,
    department_id = EXCLUDED.department_id;

-- ----------------------------------------------------------------------------
-- STEP 9: ENSURE COURSES
-- Confirmed Schema: code TEXT PRIMARY KEY, name TEXT, credit_hours INT, department_id UUID
-- NO courses.id, NO courses.type column!
-- Valid ON CONFLICT target: courses.code is PRIMARY KEY
-- ----------------------------------------------------------------------------
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-101L', 'Programming Fundamentals Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-102L', 'ICT Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-102', 'ICT', d.id, 2
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-101', 'Programming Fundamentals', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'PHY-101', 'Physics', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'MATH-101', 'Basic Math - I', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'ENG-101', 'Functional English', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'IS-101', 'Islamic Studies', d.id, 2
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'PS-101', 'Pakistan Studies', d.id, 2
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'HQ-101', 'Holy Quran', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-201L', 'Database Systems Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-201', 'Database Systems', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'MATH-201', 'Calculus & Analytical Geometry', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-202', 'Data Structures', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-202L', 'Data Structures Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'SE-201', 'Software Engineering', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'SS-201', 'Civics & Community Engagement', d.id, 2
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-203', 'Professional Practice', d.id, 2
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-301L', 'Assembly Language Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-301', 'Assembly Language', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-304', 'Web Technologies', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-302', 'Theory of Automata', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'MATH-301', 'Multivariate Calculus', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-303', 'Computer Networks', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-303L', 'Computer Networks Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-304L', 'Web Technologies Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'SE-301L', 'Software Design & Architecture Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-305L', 'Computer Organization & Assembly Language Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'SE-301', 'Software Design & Architecture', d.id, 3
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-305', 'Computer Organization & Assembly Language', d.id, 3
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-302', 'Machine Learning', d.id, 3
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-301', 'Programming for AI', d.id, 3
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-302L', 'Machine Learning Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-301L', 'Programming for AI Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-403', 'Professional Practices', d.id, 2
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-401', 'Compiler Construction', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-402', 'Information Security', d.id, 3
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-404L', 'Computer Graphics Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'SE-402', 'Software Project Management', d.id, 3
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'SE-401', 'Software Re-Engineering', d.id, 3
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'CS-404', 'Computer Graphics', d.id, 3
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-402', 'Deep Learning', d.id, 3
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-402L', 'Deep Learning Lab', d.id, 1
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'STAT-401', 'Advance Statistics', d.id, 3
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;
INSERT INTO public.courses (code, name, department_id, credit_hours)
SELECT 'AI-401', 'Agent Based Modeling', d.id, 3
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credit_hours = EXCLUDED.credit_hours,
    department_id = EXCLUDED.department_id;

-- ----------------------------------------------------------------------------
-- STEP 10: INSERT EXACTLY 370 AUTHORITATIVE TIMETABLE ENTRIES
-- Breakdown: BSCS = 150 | BSSE = 148 | BSAI = 72 | Total = 370
-- BSCS & BSSE: Segregated into Section A and B
-- BSAI: Single cohort without sections; section_id is NULL, section_name is 'No Section'
-- Deterministic TEXT id for every entry (no gen_random_uuid())
-- course_code references courses(code)
-- teacher_id references teachers(id) (NULL for unassigned)
-- room_id references rooms(id)
-- All denormalized name columns strictly populated
-- ----------------------------------------------------------------------------

-- >>> BS Computer Science - 1st Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-mon-1', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'Programming Fundamentals Lab (G1)',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-mon-2', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'ICT Lab (G2)',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-mon-3', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'ICT',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-mon-4', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-mon-5', 'Monday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-mon-6', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math - I',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-tue-7', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'Programming Fundamentals Lab (G2)',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-tue-8', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'ICT Lab (G1)',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-tue-9', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'ICT',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-tue-10', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-tue-11', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-tue-12', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math - I',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-wed-13', 'Wednesday', '09:00 AM', '10:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-wed-14', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-wed-15', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-wed-16', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math - I',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-thu-17', 'Thursday', '09:00 AM', '10:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-thu-18', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-thu-19', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-thu-20', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-fri-21', 'Friday', '09:00 AM', '10:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-fri-22', 'Friday', '10:00 AM', '11:00 AM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-fri-23', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1sta-fri-24', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
-- >>> BS Computer Science - 1st Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-mon-25', 'Monday', '09:00 AM', '10:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-mon-26', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-mon-27', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-mon-28', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-mon-29', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math-I',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-tue-30', 'Tuesday', '09:00 AM', '10:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-tue-31', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-tue-32', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-tue-33', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-tue-34', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-tue-35', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math-I',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-wed-36', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Programming Fundamentals Lab (G1)',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-wed-37', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'ICT Lab (G2)',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-wed-38', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'ICT',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-wed-39', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-wed-40', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-wed-41', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math-I',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-thu-42', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Programming Fundamentals Lab (G2)',
  'tch-tauseef', 'Dr. Tauseef-ur-Rehman',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-thu-43', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'ICT Lab (G1)',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-thu-44', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'ICT',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-thu-45', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-thu-46', 'Thursday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-fri-47', 'Friday', '09:00 AM', '10:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-1stb-fri-48', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
-- >>> BS Software Engineering - 1st Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-mon-49', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-mon-50', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'Programming',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-mon-51', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Basic Math-1',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-mon-52', 'Monday', '02:00 PM', '05:00 PM',
  c.code, 'Programming Lab (G1)',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-mon-53', 'Monday', '02:00 PM', '05:00 PM',
  c.code, 'ICT Lab (G2)',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-tue-54', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'ICT',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-tue-55', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-tue-56', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'Programming',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-tue-57', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Basic Math-1',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-tue-58', 'Tuesday', '02:00 PM', '05:00 PM',
  c.code, 'Programming Lab (G2)',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-tue-59', 'Tuesday', '02:00 PM', '05:00 PM',
  c.code, 'ICT Lab (G1)',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-wed-60', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'ICT',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-wed-61', 'Wednesday', '10:00 AM', '11:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-wed-62', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Basic Math-1',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-wed-63', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-wed-64', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-thu-65', 'Thursday', '08:00 AM', '09:00 AM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-thu-66', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-thu-67', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Programming',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-thu-68', 'Thursday', '01:00 PM', '02:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-thu-69', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-fri-70', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-fri-71', 'Friday', '09:00 AM', '10:00 AM',
  c.code, 'Programming',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-fri-72', 'Friday', '10:00 AM', '11:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-fri-73', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Programming',
  'tch-dr-sajjad', 'Dr. Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1sta-fri-74', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
-- >>> BS Software Engineering - 1st Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-mon-75', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-mon-76', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-mon-77', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Basic Math-1',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-mon-78', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-tue-79', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-tue-80', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-tue-81', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-tue-82', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Basic Math-1',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-tue-83', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Pakistan Studies',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-wed-84', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-wed-85', 'Wednesday', '10:00 AM', '11:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-wed-86', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'Programming',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-wed-87', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Basic Math-1',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-wed-88', 'Wednesday', '02:00 PM', '04:00 PM',
  c.code, 'Programming Lab (G1)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-wed-89', 'Wednesday', '02:00 PM', '04:00 PM',
  c.code, 'ICT Lab (G2)',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-thu-90', 'Thursday', '08:00 AM', '09:00 AM',
  c.code, 'ICT',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-thu-91', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-thu-92', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'Programming',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-thu-93', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-thu-94', 'Thursday', '02:00 PM', '04:00 PM',
  c.code, 'Programming Lab (G2)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-thu-95', 'Thursday', '02:00 PM', '04:00 PM',
  c.code, 'ICT Lab (G1)',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-fri-96', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'ICT',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-fri-97', 'Friday', '11:00 AM', '12:00 PM',
  c.code, 'Programming',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-1stb-fri-98', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
-- >>> BS Artificial Intelligence - 1st Semester (Cohort without sections) <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-mon-99', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-mon-100', 'Monday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-mon-101', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Pak Studies',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-mon-102', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math 1',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-mon-103', 'Monday', '05:00 PM', '08:00 PM',
  c.code, 'Programming Fundamentals Lab (G1)',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-mon-104', 'Monday', '05:00 PM', '08:00 PM',
  c.code, 'ICT Lab (G2)',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-tue-105', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Holy Quran',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'HQ-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-tue-106', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-tue-107', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Pak Studies',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PS-101'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-tue-108', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math 1',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-tue-109', 'Tuesday', '05:00 PM', '08:00 PM',
  c.code, 'Programming Fundamentals Lab (G2)',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-tue-110', 'Tuesday', '05:00 PM', '08:00 PM',
  c.code, 'ICT Lab (G1)',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-wed-111', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-wed-112', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Physics',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'PHY-101'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-wed-113', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-wed-114', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Basic Math 1',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'MATH-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-wed-115', 'Wednesday', '04:00 PM', '05:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-wed-116', 'Wednesday', '05:00 PM', '06:00 PM',
  c.code, 'ICT',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-thu-117', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Islamic Studies',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'IS-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-thu-118', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-thu-119', 'Thursday', '04:00 PM', '05:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-thu-120', 'Thursday', '05:00 PM', '06:00 PM',
  c.code, 'ICT',
  'tch-salahuddin', 'Mr. Salahuddin',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-102'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-fri-121', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Functional English',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'ENG-101'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-1sta-fri-122', 'Friday', '04:00 PM', '05:00 PM',
  c.code, 'Programming Fundamentals',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
JOIN public.courses c ON c.code = 'CS-101'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
-- >>> BS Computer Science - 3rd Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-mon-123', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'Database Systems Lab (G1)',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-mon-124', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'Database Systems',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-mon-125', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-mon-126', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Data Structures',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-tue-127', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'Database Systems Lab (G1)',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-tue-128', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'Database Systems',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-tue-129', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-tue-130', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Data Structures',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-wed-131', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Data Structures Lab (G1)',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-wed-132', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'Database Systems',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-wed-133', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Software Engineering',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-wed-134', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-wed-135', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Data Structures',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-thu-136', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Data Structures Lab (G2)',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-thu-137', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Software Engineering',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-fri-138', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-fri-139', 'Friday', '09:00 AM', '10:00 AM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-fri-140', 'Friday', '10:00 AM', '11:00 AM',
  c.code, 'Professional Practice',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-fri-141', 'Friday', '11:00 AM', '12:00 PM',
  c.code, 'Professional Practice',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rda-fri-142', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Software Engineering',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
-- >>> BS Computer Science - 3rd Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-mon-143', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Data Structures',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-mon-144', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Software Engineering',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-mon-145', 'Monday', '12:00 PM', '03:00 PM',
  c.code, 'Data Structures Lab (G1)',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-mon-146', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-tue-147', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Data Structures',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-tue-148', 'Tuesday', '09:00 AM', '10:00 AM',
  c.code, 'Data Structures',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-tue-149', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Software Engineering',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-tue-150', 'Tuesday', '12:00 PM', '03:00 PM',
  c.code, 'Data Structures Lab (G2)',
  'tch-waseem', 'Dr. Muhammad Waseem',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-tue-151', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-wed-152', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Database Systems Lab (G1)',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-wed-153', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Database Systems',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-wed-154', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Professional Practice',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Deptt', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-stats'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-wed-155', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-thu-156', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Database Systems Lab (G2)',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-thu-157', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Database Systems',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-thu-158', 'Thursday', '01:00 PM', '02:00 PM',
  c.code, 'Software Engineering',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-thu-159', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Professional Practice',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Deptt', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-stats'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-thu-160', 'Thursday', '03:00 PM', '04:00 PM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-fri-161', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Database Systems',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-3rdb-fri-162', 'Friday', '03:00 PM', '04:00 PM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Computer Science';
-- >>> BS Software Engineering - 3rd Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-mon-163', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Database Systems',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-mon-164', 'Monday', '09:00 AM', '10:00 AM',
  c.code, 'Software Engineering',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-mon-165', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-mon-166', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-mon-167', 'Monday', '01:00 PM', '02:00 PM',
  c.code, 'Data Structures',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-mon-168', 'Monday', '02:00 PM', '05:00 PM',
  c.code, 'Database Systems Lab (G1)',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-tue-169', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Database Systems',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-tue-170', 'Tuesday', '09:00 AM', '10:00 AM',
  c.code, 'Software Engineering',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-tue-171', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-tue-172', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-tue-173', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Data Structures',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-tue-174', 'Tuesday', '02:00 PM', '05:00 PM',
  c.code, 'Database Systems Lab (G2)',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-wed-175', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'Database Systems',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-wed-176', 'Wednesday', '09:00 AM', '10:00 AM',
  c.code, 'Software Engineering',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-wed-177', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-wed-178', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Data Structures',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-wed-179', 'Wednesday', '02:00 PM', '05:00 PM',
  c.code, 'Data Structures Lab (G1)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-thu-180', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'Professional Practice',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Deptt', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-stats'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-thu-181', 'Thursday', '02:00 PM', '05:00 PM',
  c.code, 'Data Structures Lab (G2)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rda-fri-182', 'Friday', '11:00 AM', '12:00 PM',
  c.code, 'Professional Practice',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Deptt', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-stats'
WHERE d.name = 'Software Engineering';
-- >>> BS Software Engineering - 3rd Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-mon-183', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-mon-184', 'Monday', '09:00 AM', '10:00 AM',
  c.code, 'Database Systems',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-mon-185', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Software Engineering',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-mon-186', 'Monday', '02:00 PM', '05:00 PM',
  c.code, 'Data Structures Lab (G1)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-tue-187', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-tue-188', 'Tuesday', '09:00 AM', '10:00 AM',
  c.code, 'Database Systems',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-tue-189', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Software Engineering',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-tue-190', 'Tuesday', '02:00 PM', '05:00 PM',
  c.code, 'Data Structures Lab (G2)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-wed-191', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-wed-192', 'Wednesday', '09:00 AM', '10:00 AM',
  c.code, 'Database Systems',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-wed-193', 'Wednesday', '10:00 AM', '11:00 AM',
  c.code, 'Software Engineering',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-wed-194', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-wed-195', 'Wednesday', '02:00 PM', '05:00 PM',
  c.code, 'Database Systems Lab (G1)',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-thu-196', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-thu-197', 'Thursday', '12:00 PM', '01:00 PM',
  c.code, 'Professional Practice',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Deptt', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-stats'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-thu-198', 'Thursday', '01:00 PM', '02:00 PM',
  c.code, 'Data Structures',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-thu-199', 'Thursday', '02:00 PM', '05:00 PM',
  c.code, 'Database Systems Lab (G2)',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-fri-200', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Professional Practice',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Deptt', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-stats'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-fri-201', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Data Structures',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-3rdb-fri-202', 'Friday', '03:00 PM', '04:00 PM',
  c.code, 'Data Structures',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
-- >>> BS Artificial Intelligence - 3rd Semester (Cohort without sections) <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-mon-203', 'Monday', '01:00 PM', '02:00 PM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-mon-204', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-mon-205', 'Monday', '04:00 PM', '05:00 PM',
  c.code, 'Software Engineering',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-mon-206', 'Monday', '05:00 PM', '06:00 PM',
  c.code, 'Database Systems',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-mon-207', 'Monday', '06:00 PM', '09:00 PM',
  c.code, 'Database Systems Lab (G1)',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-tue-208', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Civics & Community Engagement',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-tue-209', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-tue-210', 'Tuesday', '04:00 PM', '05:00 PM',
  c.code, 'Software Engineering',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-tue-211', 'Tuesday', '05:00 PM', '06:00 PM',
  c.code, 'Database Systems',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-tue-212', 'Tuesday', '06:00 PM', '09:00 PM',
  c.code, 'Database Systems Lab (G2)',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-wed-213', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Calculus & Analytical Geometry',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'MATH-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-wed-214', 'Wednesday', '04:00 PM', '05:00 PM',
  c.code, 'Software Engineering',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'SE-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-wed-215', 'Wednesday', '05:00 PM', '06:00 PM',
  c.code, 'Database Systems',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-201'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-wed-216', 'Wednesday', '06:00 PM', '09:00 PM',
  c.code, 'Data Structures Lab (G1)',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-thu-217', 'Thursday', '04:00 PM', '05:00 PM',
  c.code, 'Professional Practice',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-thu-218', 'Thursday', '05:00 PM', '06:00 PM',
  c.code, 'Data Structures',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-thu-219', 'Thursday', '06:00 PM', '09:00 PM',
  c.code, 'Data Structures Lab (G2)',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-fri-220', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Professional Practice',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-203'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-fri-221', 'Friday', '05:00 PM', '06:00 PM',
  c.code, 'Data Structures',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-3rda-fri-222', 'Friday', '06:00 PM', '07:00 PM',
  c.code, 'Data Structures',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
JOIN public.courses c ON c.code = 'CS-202'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Artificial Intelligence';
-- >>> BS Computer Science - 5th Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-mon-223', 'Monday', '11:00 AM', '02:00 PM',
  c.code, 'Assembly Language Lab (G1)',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-mon-224', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Assembly Language',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-mon-225', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Web Technologies',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-tue-226', 'Tuesday', '11:00 AM', '02:00 PM',
  c.code, 'Assembly Language Lab (G2)',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-tue-227', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Assembly Language',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-tue-228', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Web Technologies',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-wed-229', 'Wednesday', '10:00 AM', '11:00 AM',
  c.code, 'Theory of Automata',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-wed-230', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-thu-231', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Theory of Automata',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-thu-232', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'Theory of Automata',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-thu-233', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Computer Networks',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-thu-234', 'Thursday', '03:00 PM', '04:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-fri-235', 'Friday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Networks Lab (G1)',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-fri-236', 'Friday', '08:00 AM', '11:00 AM',
  c.code, 'Web Technologies Lab (G2)',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-fri-237', 'Friday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G2)',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-fri-238', 'Friday', '11:00 AM', '02:00 PM',
  c.code, 'Web Technologies Lab (G1)',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-fri-239', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Computer Networks',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5tha-fri-240', 'Friday', '03:00 PM', '04:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Computer Science';
-- >>> BS Computer Science - 5th Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-mon-241', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-mon-242', 'Monday', '09:00 AM', '10:00 AM',
  c.code, 'Web Technologies',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-mon-243', 'Monday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G1)',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-mon-244', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Assembly Language',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-tue-245', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-tue-246', 'Tuesday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G2)',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-tue-247', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Assembly Language',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-wed-248', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-wed-249', 'Wednesday', '10:00 AM', '11:00 AM',
  c.code, 'Computer Networks',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-wed-250', 'Wednesday', '11:00 AM', '02:00 PM',
  c.code, 'Assembly Language Lab (G1)',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-wed-251', 'Wednesday', '02:00 PM', '05:00 PM',
  c.code, 'Web Technologies Lab (G1)',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-thu-252', 'Thursday', '08:00 AM', '09:00 AM',
  c.code, 'Theory of Automata',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-thu-253', 'Thursday', '09:00 AM', '10:00 AM',
  c.code, 'Web Technologies',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-thu-254', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Computer Networks',
  'tch-khalid', 'Dr. Khalid Haseeb',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-thu-255', 'Thursday', '11:00 AM', '02:00 PM',
  c.code, 'Assembly Language Lab (G2)',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-thu-256', 'Thursday', '02:00 PM', '05:00 PM',
  c.code, 'Web Technologies Lab (G2)',
  'tch-mansoor', 'Dr. Mansoor Nasir',
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-fri-257', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'Theory of Automata',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-5thb-fri-258', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Theory of Automata',
  'tch-shaukat', 'Dr. Shaukat Ali',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
-- >>> BS Software Engineering - 5th Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-mon-259', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'Software Design & Architecture Lab (G1)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-mon-260', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Organization & Assembly Language Lab (G2)',
  NULL, NULL,
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-mon-261', 'Monday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G1)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-mon-262', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Computer Networks',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-mon-263', 'Monday', '03:00 PM', '04:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-tue-264', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'Software Design & Architecture Lab (G2)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-tue-265', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Organization & Assembly Language Lab (G1)',
  NULL, NULL,
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-tue-266', 'Tuesday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G2)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Lab 3', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'lab-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-tue-267', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Computer Networks',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-tue-268', 'Tuesday', '03:00 PM', '04:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-wed-269', 'Wednesday', '09:00 AM', '10:00 AM',
  c.code, 'Web Technologies',
  NULL, NULL,
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-wed-270', 'Wednesday', '11:00 AM', '02:00 PM',
  c.code, 'Web Technologies Lab (G1)',
  NULL, NULL,
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-wed-271', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Software Design & Architecture',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-wed-272', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-thu-273', 'Thursday', '08:00 AM', '09:00 AM',
  c.code, 'Computer Organization & Assembly Language',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-thu-274', 'Thursday', '09:00 AM', '10:00 AM',
  c.code, 'Web Technologies',
  NULL, NULL,
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-thu-275', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Computer Organization & Assembly Language',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-thu-276', 'Thursday', '11:00 AM', '02:00 PM',
  c.code, 'Web Technologies Lab (G2)',
  NULL, NULL,
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5tha-thu-277', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Software Design & Architecture',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
-- >>> BS Software Engineering - 5th Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-mon-278', 'Monday', '11:00 AM', '02:00 PM',
  c.code, 'Web Technologies Lab (G1)',
  NULL, NULL,
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-mon-279', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-tue-280', 'Tuesday', '11:00 AM', '02:00 PM',
  c.code, 'Web Technologies Lab (G2)',
  NULL, NULL,
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-tue-281', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 8', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-8'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-wed-282', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Software Design & Architecture Lab (G1)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-wed-283', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Organization & Assembly Language Lab (G2)',
  NULL, NULL,
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-wed-284', 'Wednesday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G1)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-wed-285', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 6', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-thu-286', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Software Design & Architecture Lab (G2)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-thu-287', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Organization & Assembly Language Lab (G1)',
  NULL, NULL,
  r.id, 'Lab 6', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305L'
JOIN public.rooms r ON r.id = 'lab-6'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-thu-288', 'Thursday', '11:00 AM', '02:00 PM',
  c.code, 'Computer Networks Lab (G2)',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room Unspecified', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303L'
JOIN public.rooms r ON r.id = 'rm-room-unspecified'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-thu-289', 'Thursday', '02:00 PM', '03:00 PM',
  c.code, 'Web Technologies',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-thu-290', 'Thursday', '03:00 PM', '04:00 PM',
  c.code, 'Web Technologies',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-304'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-fri-291', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'Computer Networks',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-fri-292', 'Friday', '09:00 AM', '10:00 AM',
  c.code, 'Computer Networks',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-303'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-fri-293', 'Friday', '11:00 AM', '12:00 PM',
  c.code, 'Software Design & Architecture',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-fri-294', 'Friday', '12:00 PM', '01:00 PM',
  c.code, 'Software Design & Architecture',
  'tch-israr', 'Dr. Israr Iqbal',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'SE-301'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-fri-295', 'Friday', '02:00 PM', '03:00 PM',
  c.code, 'Computer Organization & Assembly Language',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-5thb-fri-296', 'Friday', '03:00 PM', '04:00 PM',
  c.code, 'Computer Organization & Assembly Language',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-305'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
-- >>> BS Artificial Intelligence - 5th Semester (Cohort without sections) <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-mon-297', 'Monday', '01:00 PM', '02:00 PM',
  c.code, 'Machine Learning',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-302'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-mon-298', 'Monday', '02:00 PM', '03:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-mon-299', 'Monday', '04:00 PM', '05:00 PM',
  c.code, 'Theory of Automata',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-mon-300', 'Monday', '05:00 PM', '08:00 PM',
  c.code, 'Assembly Language Lab (G1)',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Lab Unspecified', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301L'
JOIN public.rooms r ON r.id = 'rm-lab-unspecified'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-tue-301', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Machine Learning',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-302'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-tue-302', 'Tuesday', '02:00 PM', '03:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 7', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-7'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-tue-303', 'Tuesday', '04:00 PM', '05:00 PM',
  c.code, 'Theory of Automata',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-tue-304', 'Tuesday', '05:00 PM', '08:00 PM',
  c.code, 'Assembly Language Lab (G2)',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Lab Unspecified', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301L'
JOIN public.rooms r ON r.id = 'rm-lab-unspecified'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-wed-305', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Programming for AI',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-301'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-wed-306', 'Wednesday', '02:00 PM', '03:00 PM',
  c.code, 'Multivariate Calculus',
  NULL, NULL,
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'MATH-301'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-wed-307', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Assembly Language',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-wed-308', 'Wednesday', '04:00 PM', '05:00 PM',
  c.code, 'Theory of Automata',
  'tch-bilal', 'Dr. Bilal',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-302'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-thu-309', 'Thursday', '01:00 PM', '02:00 PM',
  c.code, 'Programming for AI',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-301'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-thu-310', 'Thursday', '03:00 PM', '04:00 PM',
  c.code, 'Assembly Language',
  'tch-faisal', 'Mr. Faisal Saeed',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'CS-301'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-thu-311', 'Thursday', '04:00 PM', '07:00 PM',
  c.code, 'Machine Learning Lab (G1)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-302L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-thu-312', 'Thursday', '04:00 PM', '07:00 PM',
  c.code, 'Programming for AI Lab (G2)',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-301L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-fri-313', 'Friday', '04:00 PM', '07:00 PM',
  c.code, 'Machine Learning Lab (G2)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Lab 4', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-302L'
JOIN public.rooms r ON r.id = 'lab-4'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-5tha-fri-314', 'Friday', '04:00 PM', '07:00 PM',
  c.code, 'Programming for AI Lab (G1)',
  'tch-atif', 'Dr. Atif Khan',
  r.id, 'Lab 5', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
JOIN public.courses c ON c.code = 'AI-301L'
JOIN public.rooms r ON r.id = 'lab-5'
WHERE d.name = 'Artificial Intelligence';
-- >>> BS Computer Science - 7th Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-mon-315', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'Programming for AI Lab (G1)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'DIP Lab', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301L'
JOIN public.rooms r ON r.id = 'lab-dip'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-mon-316', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'Programming for AI',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'DIP Lab', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301'
JOIN public.rooms r ON r.id = 'lab-dip'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-mon-317', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Professional Practices',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Department', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-403'
JOIN public.rooms r ON r.id = 'rm-stats-dept'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-tue-318', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'Programming for AI Lab (G2)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'DIP Lab', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301L'
JOIN public.rooms r ON r.id = 'lab-dip'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-tue-319', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'Programming for AI',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'DIP Lab', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301'
JOIN public.rooms r ON r.id = 'lab-dip'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-tue-320', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Professional Practices',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Department', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-403'
JOIN public.rooms r ON r.id = 'rm-stats-dept'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-wed-321', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'Compiler Construction',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-401'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-wed-322', 'Wednesday', '10:00 AM', '11:00 AM',
  c.code, 'Information Security',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-402'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-wed-323', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Professional Practices',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Department', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-403'
JOIN public.rooms r ON r.id = 'rm-stats-dept'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-thu-324', 'Thursday', '08:00 AM', '09:00 AM',
  c.code, 'Compiler Construction',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-401'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-thu-325', 'Thursday', '10:00 AM', '11:00 AM',
  c.code, 'Information Security',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-402'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-fri-326', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'Compiler Construction',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-401'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7tha-fri-327', 'Friday', '10:00 AM', '11:00 AM',
  c.code, 'Information Security',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-402'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
-- >>> BS Computer Science - 7th Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-mon-328', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Compiler Construction',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-mon-329', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Information Security',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-402'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-mon-330', 'Monday', '01:00 PM', '02:00 PM',
  c.code, 'Professional Practices',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Department', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-403'
JOIN public.rooms r ON r.id = 'rm-stats-dept'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-tue-331', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Compiler Construction',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-tue-332', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Information Security',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-402'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-tue-333', 'Tuesday', '01:00 PM', '02:00 PM',
  c.code, 'Professional Practices',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Department', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-403'
JOIN public.rooms r ON r.id = 'rm-stats-dept'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-wed-334', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Programming for AI Lab (G1)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'DIP Lab', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301L'
JOIN public.rooms r ON r.id = 'lab-dip'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-wed-335', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'Compiler Construction',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-wed-336', 'Wednesday', '12:00 PM', '01:00 PM',
  c.code, 'Programming for AI',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-wed-337', 'Wednesday', '01:00 PM', '02:00 PM',
  c.code, 'Professional Practices',
  'tch-inaam', 'Mr. Inaam Ul Haq',
  r.id, 'Stats Department', 'Statistics & Allied Sciences Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-403'
JOIN public.rooms r ON r.id = 'rm-stats-dept'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-thu-338', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Programming for AI Lab (G2)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'DIP Lab', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301L'
JOIN public.rooms r ON r.id = 'lab-dip'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-thu-339', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'Information Security',
  'tch-zubair', 'Mr. Muhammad Zubair',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-402'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Computer Science';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bscs-7thb-fri-340', 'Friday', '10:00 AM', '11:00 AM',
  c.code, 'Programming for AI',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-301'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Computer Science';
-- >>> BS Software Engineering - 7th Semester Section A <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-mon-341', 'Monday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Graphics Lab (G1)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-mon-342', 'Monday', '11:00 AM', '12:00 PM',
  c.code, 'Software Project Management',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-402'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-tue-343', 'Tuesday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Graphics Lab (G2)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-tue-344', 'Tuesday', '11:00 AM', '12:00 PM',
  c.code, 'Software Project Management',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-402'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-wed-345', 'Wednesday', '08:00 AM', '09:00 AM',
  c.code, 'Software Re-Engineering',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-401'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-wed-346', 'Wednesday', '11:00 AM', '12:00 PM',
  c.code, 'Software Project Management',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 2', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-402'
JOIN public.rooms r ON r.id = 'rm-2'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-thu-347', 'Thursday', '08:00 AM', '09:00 AM',
  c.code, 'Software Re-Engineering',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-401'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-thu-348', 'Thursday', '11:00 AM', '12:00 PM',
  c.code, 'Computer Graphics',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-fri-349', 'Friday', '08:00 AM', '09:00 AM',
  c.code, 'Software Re-Engineering',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-401'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7tha-fri-350', 'Friday', '11:00 AM', '12:00 PM',
  c.code, 'Computer Graphics',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
-- >>> BS Software Engineering - 7th Semester Section B <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-mon-351', 'Monday', '08:00 AM', '09:00 AM',
  c.code, 'Software Project Management',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-402'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-mon-352', 'Monday', '10:00 AM', '11:00 AM',
  c.code, 'Software Re-Engineering',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-mon-353', 'Monday', '12:00 PM', '01:00 PM',
  c.code, 'Computer Graphics',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-tue-354', 'Tuesday', '08:00 AM', '09:00 AM',
  c.code, 'Software Project Management',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 5', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-402'
JOIN public.rooms r ON r.id = 'rm-5'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-tue-355', 'Tuesday', '10:00 AM', '11:00 AM',
  c.code, 'Software Re-Engineering',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-tue-356', 'Tuesday', '12:00 PM', '01:00 PM',
  c.code, 'Computer Graphics',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-wed-357', 'Wednesday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Graphics Lab (G1)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-thu-358', 'Thursday', '08:00 AM', '11:00 AM',
  c.code, 'Computer Graphics Lab (G2)',
  'tch-irshad', 'Dr. Irshad',
  r.id, 'Lab 1', 'CS Computing Laboratories',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'CS-404L'
JOIN public.rooms r ON r.id = 'lab-1'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-fri-359', 'Friday', '10:00 AM', '11:00 AM',
  c.code, 'Software Project Management',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-402'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Software Engineering';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsse-7thb-fri-360', 'Friday', '11:00 AM', '12:00 PM',
  c.code, 'Software Re-Engineering',
  'tch-naila', 'Dr. Naila Habib',
  r.id, 'Room 4', 'CS Academic Block',
  d.id, p.id, sem.id, sec.id, b.id,
  d.name, p.name, sem.name, sec.name, b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'SE-401'
JOIN public.rooms r ON r.id = 'rm-4'
WHERE d.name = 'Software Engineering';
-- >>> BS Artificial Intelligence - 7th Semester (Cohort without sections) <<<
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-mon-361', 'Monday', '05:00 PM', '06:00 PM',
  c.code, 'Deep Learning',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-402'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-mon-362', 'Monday', '06:00 PM', '09:00 PM',
  c.code, 'Deep Learning Lab (G1)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-402L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-tue-363', 'Tuesday', '05:00 PM', '06:00 PM',
  c.code, 'Deep Learning',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-402'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-tue-364', 'Tuesday', '06:00 PM', '09:00 PM',
  c.code, 'Deep Learning Lab (G2)',
  'tch-sajjad', 'Dr. Muhammad Sajjad',
  r.id, 'Lab 2', 'CS Computing Laboratories',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lab', 1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-402L'
JOIN public.rooms r ON r.id = 'lab-2'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-wed-365', 'Wednesday', '03:00 PM', '04:00 PM',
  c.code, 'Advance Statistics',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'STAT-401'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-wed-366', 'Wednesday', '05:00 PM', '06:00 PM',
  c.code, 'Agent Based Modeling',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-thu-367', 'Thursday', '03:00 PM', '04:00 PM',
  c.code, 'Advance Statistics',
  NULL, NULL,
  r.id, 'Room 3', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'STAT-401'
JOIN public.rooms r ON r.id = 'rm-3'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-thu-368', 'Thursday', '05:00 PM', '06:00 PM',
  c.code, 'Agent Based Modeling',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-fri-369', 'Friday', '03:00 PM', '04:00 PM',
  c.code, 'Advance Statistics',
  NULL, NULL,
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'STAT-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, course_code, course_name, 
  teacher_id, teacher_name, room_id, classroom_number, building,
  department_id, program_id, semester_id, section_id, batch_id,
  department_name, program_name, semester_name, section_name, batch_name,
  type, credit_hours
)
SELECT
  'tt-bsai-7tha-fri-370', 'Friday', '05:00 PM', '06:00 PM',
  c.code, 'Agent Based Modeling',
  'tch-naveed', 'Dr. Naveed Abbas',
  r.id, 'Room 1', 'CS Academic Block',
  d.id, p.id, sem.id, NULL, b.id,
  d.name, p.name, sem.name, 'No Section', b.name,
  'Lecture', 3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
JOIN public.courses c ON c.code = 'AI-401'
JOIN public.rooms r ON r.id = 'rm-1'
WHERE d.name = 'Artificial Intelligence';

-- ----------------------------------------------------------------------------
-- STEP 11: RIGOROUS DATA INTEGRITY ASSERTIONS
-- (If any condition is violated, the entire transaction is automatically rolled back)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
  v_timetable_count integer;
  v_dept_count integer;
  v_invalid_depts integer;
  v_bscs_count integer;
  v_bsse_count integer;
  v_bsai_count integer;
  v_assigned_teachers integer;
  v_unassigned_teachers integer;
  v_missing_rel integer;
  v_invalid_sec integer;
  v_unique_ids integer;
  v_missing_courses integer;
  v_missing_rooms integer;
  v_missing_teachers integer;
  v_duplicate_count integer;
  v_invalid_room_capacities integer;
BEGIN
  -- 1. Verify grand total = 370
  SELECT count(*) INTO v_timetable_count FROM public.timetable_entries;
  IF v_timetable_count <> 370 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 370 timetable entries, found %', v_timetable_count;
  END IF;

  -- 2. Verify canonical departments
  SELECT count(*) INTO v_dept_count FROM public.departments WHERE code IN ('CS', 'SE', 'AI');
  IF v_dept_count <> 3 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 3 canonical departments (CS, SE, AI), found %', v_dept_count;
  END IF;

  SELECT count(*) INTO v_invalid_depts FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI');
  IF v_invalid_depts > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % non-canonical departments', v_invalid_depts;
  END IF;

  -- 3. Verify Program-specific breakdowns: BSCS = 150, BSSE = 148, BSAI = 72
  SELECT count(*) INTO v_bscs_count 
  FROM public.timetable_entries te
  JOIN public.programs p ON p.id = te.program_id
  WHERE p.short_code = 'BSCS';
  IF v_bscs_count <> 150 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 150 BSCS entries, found %', v_bscs_count;
  END IF;

  SELECT count(*) INTO v_bsse_count 
  FROM public.timetable_entries te
  JOIN public.programs p ON p.id = te.program_id
  WHERE p.short_code = 'BSSE';
  IF v_bsse_count <> 148 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 148 BSSE entries, found %', v_bsse_count;
  END IF;

  SELECT count(*) INTO v_bsai_count 
  FROM public.timetable_entries te
  JOIN public.programs p ON p.id = te.program_id
  WHERE p.short_code = 'BSAI';
  IF v_bsai_count <> 72 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 72 BSAI entries, found %', v_bsai_count;
  END IF;

  -- 4. Verify Teacher assignment counts: 236 assigned, 134 NULL
  SELECT count(*) INTO v_assigned_teachers
  FROM public.timetable_entries
  WHERE teacher_id IS NOT NULL AND teacher_name IS NOT NULL;
  IF v_assigned_teachers <> 236 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 236 assigned faculty slots, found %', v_assigned_teachers;
  END IF;

  SELECT count(*) INTO v_unassigned_teachers
  FROM public.timetable_entries
  WHERE teacher_id IS NULL AND teacher_name IS NULL;
  IF v_unassigned_teachers <> 134 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 134 unassigned faculty slots, found %', v_unassigned_teachers;
  END IF;

  -- 5. Verify foreign key relationship completeness
  SELECT count(*) INTO v_missing_rel
  FROM public.timetable_entries te
  WHERE te.department_id IS NULL
     OR te.program_id IS NULL
     OR te.semester_id IS NULL
     OR te.batch_id IS NULL
     OR te.room_id IS NULL
     OR te.course_code IS NULL
     OR te.department_name IS NULL
     OR te.program_name IS NULL
     OR te.semester_name IS NULL
     OR te.section_name IS NULL
     OR te.batch_name IS NULL;
  IF v_missing_rel > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % entries with missing required foreign keys or denormalized names', v_missing_rel;
  END IF;

  -- 6. Verify Section rules: BSCS/BSSE have section_id (A or B), BSAI has section_id = NULL
  SELECT count(*) INTO v_invalid_sec
  FROM public.timetable_entries te
  JOIN public.programs p ON p.id = te.program_id
  WHERE (p.short_code IN ('BSCS', 'BSSE') AND te.section_id IS NULL)
     OR (p.short_code = 'BSAI' AND te.section_id IS NOT NULL);
  IF v_invalid_sec > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % entries with invalid section assignments (BSAI must be NULL, BSCS/BSSE must not be NULL)', v_invalid_sec;
  END IF;

  -- 7. Verify Unique Timetable IDs
  SELECT count(DISTINCT id) INTO v_unique_ids FROM public.timetable_entries;
  IF v_unique_ids <> 370 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 370 distinct timetable entry IDs, found %', v_unique_ids;
  END IF;

  -- 8. Verify courses FK
  SELECT count(*) INTO v_missing_courses
  FROM public.timetable_entries te
  LEFT JOIN public.courses c ON c.code = te.course_code
  WHERE c.code IS NULL;
  IF v_missing_courses > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % timetable entries with invalid course_code references', v_missing_courses;
  END IF;

  -- 9. Verify rooms FK
  SELECT count(*) INTO v_missing_rooms
  FROM public.timetable_entries te
  LEFT JOIN public.rooms r ON r.id = te.room_id
  WHERE r.id IS NULL;
  IF v_missing_rooms > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % timetable entries with invalid room_id references', v_missing_rooms;
  END IF;

  -- 10. Verify teachers FK when assigned
  SELECT count(*) INTO v_missing_teachers
  FROM public.timetable_entries te
  LEFT JOIN public.teachers t ON t.id = te.teacher_id
  WHERE te.teacher_id IS NOT NULL AND t.id IS NULL;
  IF v_missing_teachers > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % timetable entries with invalid teacher_id references', v_missing_teachers;
  END IF;

  -- 11. Verify uniqueness of slots (no exact duplicate schedule entries)
  SELECT count(*) INTO v_duplicate_count
  FROM (
    SELECT day, start_time, end_time, program_id, semester_id, COALESCE(section_id, '00000000-0000-0000-0000-000000000000'::uuid), course_code, room_id, count(*)
    FROM public.timetable_entries
    GROUP BY day, start_time, end_time, program_id, semester_id, COALESCE(section_id, '00000000-0000-0000-0000-000000000000'::uuid), course_code, room_id
    HAVING count(*) > 1
  ) dups;
  IF v_duplicate_count > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % duplicate timetable entries', v_duplicate_count;
  END IF;

  -- 12. Verify valid_room_capacity compliance (Computer Labs = 60, Lecture/Seminar = 55)
  SELECT count(*) INTO v_invalid_room_capacities
  FROM public.rooms
  WHERE (type = 'Computer Lab' AND capacity <> 60)
     OR (type <> 'Computer Lab' AND capacity <> 55);
  IF v_invalid_room_capacities > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % rooms violating valid_room_capacity (Labs must be 60, Lecture/Seminar must be 55)', v_invalid_room_capacities;
  END IF;

  RAISE NOTICE '=======================================================';
  RAISE NOTICE 'SUCCESS: ALL 12 INTEGRITY ASSERTIONS PASSED';
  RAISE NOTICE '  - Total Timetable Entries: % (BSCS: %, BSSE: %, BSAI: %)', v_timetable_count, v_bscs_count, v_bsse_count, v_bsai_count;
  RAISE NOTICE '  - Assigned Faculty: % | Unassigned Faculty: %', v_assigned_teachers, v_unassigned_teachers;
  RAISE NOTICE '  - Departments: % (CS, SE, AI)', v_dept_count;
  RAISE NOTICE '  - BSAI has strictly NULL section_id';
  RAISE NOTICE '  - BSCS and BSSE have valid section_id';
  RAISE NOTICE '  - All room capacities verified (Labs: 60, Lecture/Seminar: 55)';
  RAISE NOTICE '  - All foreign keys and denormalized fields verified';
  RAISE NOTICE '=======================================================';
END $$;

-- ----------------------------------------------------------------------------
-- STEP 12: VERIFICATION SUMMARY QUERIES FOR SUPABASE SQL EDITOR
-- ----------------------------------------------------------------------------
-- Query 1: High-level database entity count
SELECT 
  (SELECT count(*) FROM public.departments) AS departments_count,
  (SELECT string_agg(code, ', ' ORDER BY code) FROM public.departments) AS department_codes,
  (SELECT count(*) FROM public.programs) AS programs_count,
  (SELECT count(*) FROM public.semesters) AS semesters_count,
  (SELECT count(*) FROM public.sections) AS sections_count,
  (SELECT count(*) FROM public.batches) AS batches_count,
  (SELECT count(*) FROM public.courses) AS courses_count,
  (SELECT count(*) FROM public.teachers) AS faculty_count,
  (SELECT count(*) FROM public.rooms) AS rooms_count,
  (SELECT count(*) FROM public.timetable_entries) AS timetable_entries_count;

-- Query 2: Detailed breakdown by program, semester, section, and batch
SELECT 
  p.name AS program,
  sem.name AS semester,
  COALESCE(sec.name, 'No Section (Single Cohort)') AS section,
  b.name AS batch,
  count(te.id) AS total_classes
FROM public.timetable_entries te
JOIN public.programs p ON p.id = te.program_id
JOIN public.semesters sem ON sem.id = te.semester_id
LEFT JOIN public.sections sec ON sec.id = te.section_id
JOIN public.batches b ON b.id = te.batch_id
GROUP BY p.name, sem.name, sec.name, b.name
ORDER BY p.name, sem.name, sec.name NULLS FIRST;

-- Query 3: Blank vs Named faculty distribution
SELECT 
  CASE WHEN teacher_id IS NULL THEN 'Unassigned / External Faculty (NULL)' ELSE 'Assigned Faculty' END AS faculty_status,
  count(*) AS class_count
FROM public.timetable_entries
GROUP BY CASE WHEN teacher_id IS NULL THEN 'Unassigned / External Faculty (NULL)' ELSE 'Assigned Faculty' END;

-- ----------------------------------------------------------------------------
-- STEP 13: TRANSACTION COMMIT
-- ----------------------------------------------------------------------------
COMMIT;
