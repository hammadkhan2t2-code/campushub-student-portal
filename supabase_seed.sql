-- =============================================================
-- CampusHub Official University Academic Dataset Seed
-- Source: Original CampusHub mockData.ts (Islamia College Peshawar)
-- Safe, idempotent execution using ON CONFLICT DO UPDATE / NOTHING
-- =============================================================

-- 1. DEPARTMENTS
INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), 'Computer Science', 'CS')
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;
INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), 'Software Engineering', 'SE')
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;
INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), 'Artificial Intelligence', 'AI')
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;

-- 2. PROGRAMS / DEGREES
INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, 'BS Computer Science', 'BSCS', 4
FROM public.departments d
WHERE d.name = 'Computer Science'
ON CONFLICT (name) DO UPDATE SET short_code = EXCLUDED.short_code, duration_years = EXCLUDED.duration_years;
INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, 'BS Software Engineering', 'BSSE', 4
FROM public.departments d
WHERE d.name = 'Software Engineering'
ON CONFLICT (name) DO UPDATE SET short_code = EXCLUDED.short_code, duration_years = EXCLUDED.duration_years;
INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, 'BS Artificial Intelligence', 'BSAI', 4
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT (name) DO UPDATE SET short_code = EXCLUDED.short_code, duration_years = EXCLUDED.duration_years;

-- 3. SEMESTERS
INSERT INTO public.semesters (id, name, number)
VALUES (gen_random_uuid(), '1st', 1)
ON CONFLICT (name) DO UPDATE SET number = EXCLUDED.number;
INSERT INTO public.semesters (id, name, number)
VALUES (gen_random_uuid(), '3rd', 3)
ON CONFLICT (name) DO UPDATE SET number = EXCLUDED.number;
INSERT INTO public.semesters (id, name, number)
VALUES (gen_random_uuid(), '5th', 5)
ON CONFLICT (name) DO UPDATE SET number = EXCLUDED.number;
INSERT INTO public.semesters (id, name, number)
VALUES (gen_random_uuid(), '7th', 7)
ON CONFLICT (name) DO UPDATE SET number = EXCLUDED.number;

-- 4. SECTIONS
INSERT INTO public.sections (id, name)
VALUES (gen_random_uuid(), 'A')
ON CONFLICT (name) DO NOTHING;
INSERT INTO public.sections (id, name)
VALUES (gen_random_uuid(), 'B')
ON CONFLICT (name) DO NOTHING;

-- 5. BATCHES
INSERT INTO public.batches (id, name, start_year, end_year)
VALUES (gen_random_uuid(), 'Fall 2026 – 2030', 2026, 2030)
ON CONFLICT (name) DO UPDATE SET start_year = EXCLUDED.start_year, end_year = EXCLUDED.end_year;
INSERT INTO public.batches (id, name, start_year, end_year)
VALUES (gen_random_uuid(), 'Fall 2025 – 2029', 2025, 2029)
ON CONFLICT (name) DO UPDATE SET start_year = EXCLUDED.start_year, end_year = EXCLUDED.end_year;
INSERT INTO public.batches (id, name, start_year, end_year)
VALUES (gen_random_uuid(), 'Fall 2024 – 2028', 2024, 2028)
ON CONFLICT (name) DO UPDATE SET start_year = EXCLUDED.start_year, end_year = EXCLUDED.end_year;
INSERT INTO public.batches (id, name, start_year, end_year)
VALUES (gen_random_uuid(), 'Fall 2023 – 2027', 2023, 2027)
ON CONFLICT (name) DO UPDATE SET start_year = EXCLUDED.start_year, end_year = EXCLUDED.end_year;

-- 6. ROOMS & LABORATORIES
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 1', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Smart Board', 'Multimedia Projector', 'Audio System']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 2', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 3', 'CS Academic Block', 'Ground Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 4', 'CS Academic Block', '1st Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Smart Board']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 5', 'CS Academic Block', '1st Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 6', 'CS Academic Block', '1st Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 7', 'CS Academic Block', '2nd Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Room 8', 'CS Academic Block', '2nd Floor', 55, 'Lecture Hall', ARRAY['Multimedia Projector', 'Whiteboard']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Lab 1', 'CS Computing Laboratories', 'Ground Floor', 60, 'Computer Lab', ARRAY['Workstations', 'High-Speed LAN', 'Dedicated UPS Power', 'Multimedia Projector']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Lab 2', 'CS Computing Laboratories', 'Ground Floor', 60, 'Computer Lab', ARRAY['Workstations with Database Engines', 'Gigabit Networking']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Lab 3', 'CS Computing Laboratories', '1st Floor', 60, 'Computer Lab', ARRAY['Programming & Compiler Workstations', 'High-Speed Internet', 'Projector']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Lab 4', 'CS Computing Laboratories', '1st Floor', 60, 'Computer Lab', ARRAY['Development Terminals', 'Multimedia Projector']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Lab 5', 'CS Computing Laboratories', '2nd Floor', 60, 'Computer Lab', ARRAY['Software Engineering & Testing Workstations', 'Dual-display Terminals']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Lab 6', 'CS Computing Laboratories', '2nd Floor', 60, 'Computer Lab', ARRAY['Computer Networks & Assembly Language Hardware Stations', 'Network Racks']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'DIP Lab', 'Advanced Research Facility', '2nd Floor', 60, 'Computer Lab', ARRAY['Digital Image Processing GPU Workstations', 'Smart Display']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;
INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), 'Stats Deptt', 'Statistics & Allied Sciences Block', 'Ground Floor', 55, 'Seminar Room', ARRAY['Lecture Podiums', 'Multimedia Projector', 'Sound System']::text[])
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;

-- 7. FACULTY & TEACHERS
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Tauseef-ur-Rehman', 'Assistant Professor', 'Ph.D. in Computer Science', 'Programming Methodologies, Computing Ethics, Algorithms', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Mr. Salahuddin', 'Lecturer', 'MS in Information Technology', 'Information & Communication Technologies, Network Essentials', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Muhammad Sajjad', 'Professor', 'Ph.D. in Computer Science', 'Machine Learning, Deep Learning, Digital Image Processing, Computer Vision', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Naveed Abbas', 'Associate Professor', 'Ph.D. in Computer Science & Systems', 'Multi-Agent Systems, Modeling & Simulation, Professional Ethics', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Atif Khan', 'Associate Professor', 'Ph.D. in Database Engineering', 'Database Systems, Data Engineering, Query Optimization', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Muhammad Waseem', 'Assistant Professor', 'Ph.D. in Computer Science', 'Data Structures, Computational Complexity, Algorithms', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Khalid Haseeb', 'Associate Professor', 'Ph.D. in Telecommunications & Networks', 'Computer Networks, Wireless Sensor Networks, IoT, Software Architecture', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Mr. Faisal Saeed', 'Lecturer', 'MS in Computer Engineering', 'Low-level Systems Programming, Microprocessor Architecture', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Mansoor Nasir', 'Associate Professor', 'Ph.D. in Computer Science', 'Modern Web Architectures, Distributed Applications', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Mr. Inaam Ul Haq', 'Lecturer', 'MS in Software Engineering', 'Software Quality Assurance, Computing Ethics, Professional Standards', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Mr. Muhammad Zubair', 'Lecturer', 'MS in Computer Science', 'Compiler Design, Network Security, Cryptography', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Faculty (Mathematics Dept)', 'Department of Mathematics', 'M.Phil / Ph.D. in Mathematics', 'Applied Calculus, Analytical Geometry, Differential Equations, Linear Algebra', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Faculty (English Dept)', 'Department of English', 'M.Phil in Applied Linguistics', 'Technical Writing, Academic English Communication', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Faculty (Physics Dept)', 'Department of Physics', 'M.Phil / Ph.D. in Applied Physics', 'Applied Physics, Semiconductor Physics', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Shaukat Ali', 'Associate Professor', 'Ph.D. in Computer Science', 'Database Systems, Automata & Formal Languages, Distributed Systems', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Irshad', 'Assistant Professor', 'Ph.D. in Computer Science', 'Algorithms, Data Structures, Computer Graphics', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Bilal', 'Assistant Professor', 'Ph.D. in Computer Science', 'Database Engineering, Data Structures, Theory of Computation', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Israr Iqbal', 'Assistant Professor', 'Ph.D. in Software Engineering', 'Software Architecture, Distributed Systems, Software Design Patterns', d.id
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Dr. Naila Habib', 'Assistant Professor', 'Ph.D. in Software Engineering', 'Software Project Management, Software Evolution & Re-Engineering', d.id
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;
INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), 'Faculty (Islamic & Pak Studies)', 'Humanities Department', 'M.Phil in Islamic & Pakistan Studies', 'Islamic Jurisprudence, Constitutional History of Pakistan', d.id
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;

-- 8. COURSES
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-101L', 'Programming Fundamentals Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-102L', 'ICT Lab (G2)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-102', 'ICT', d.id, 2, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-101', 'Programming Fundamentals', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'PHY-101', 'Physics', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'MATH-101', 'Basic Math - I', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'ENG-101', 'Functional English', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'IS-101', 'Islamic Studies', d.id, 2, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'PS-101', 'Pakistan Studies', d.id, 2, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'HQ-101', 'Holy Quran', d.id, 1, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-201L', 'Database Systems Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-201', 'Database Systems', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'MATH-201', 'Calculus & Analytical Geometry', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-202', 'Data Structures', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-202L', 'Data Structures Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'SE-201', 'Software Engineering', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'SS-201', 'Civics & Community Engagement', d.id, 2, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-203', 'Professional Practice', d.id, 2, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-301L', 'Assembly Language Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-301', 'Assembly Language', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-304', 'Web Technologies', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-302', 'Theory of Automata', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'MATH-301', 'Multivariate Calculus', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-303', 'Computer Networks', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-303L', 'Computer Networks Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-304L', 'Web Technologies Lab (G2)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'SE-301L', 'Software Design & Architecture Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-305L', 'Computer Organization & Assembly Language Lab (G2)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'SE-301', 'Software Design & Architecture', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-305', 'Computer Organization & Assembly Language', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-302', 'Machine Learning', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-301', 'Programming for AI', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-302L', 'Machine Learning Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-301L', 'Programming for AI Lab (G2)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-403', 'Professional Practices', d.id, 2, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-401', 'Compiler Construction', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-402', 'Information Security', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Computer Science'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-404L', 'Computer Graphics Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'SE-402', 'Software Project Management', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'SE-401', 'Software Re-Engineering', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'CS-404', 'Computer Graphics', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Software Engineering'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-402', 'Deep Learning', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-402L', 'Deep Learning Lab (G1)', d.id, 1, 'Lab'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'STAT-401', 'Advance Statistics', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;
INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), 'AI-401', 'Agent Based Modeling', d.id, 3, 'Lecture'
FROM public.departments d
WHERE d.name = 'Artificial Intelligence'
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;

-- 9. TIMETABLE ENTRIES (Exact mapping from mockData.ts)
-- Ensures Section A and Section B records remain strictly segregated.
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Fundamentals Lab (G1)',
  'Dr. Tauseef-ur-Rehman',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G2)',
  'Mr. Salahuddin',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Mr. Salahuddin',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Tauseef-ur-Rehman',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math - I',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Fundamentals Lab (G2)',
  'Dr. Tauseef-ur-Rehman',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G1)',
  'Mr. Salahuddin',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Mr. Salahuddin',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Tauseef-ur-Rehman',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math - I',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Tauseef-ur-Rehman',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math - I',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Tauseef-ur-Rehman',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-I',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Tauseef-ur-Rehman',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-I',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Fundamentals Lab (G1)',
  'Dr. Tauseef-ur-Rehman',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G2)',
  'Mr. Salahuddin',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Mr. Salahuddin',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Tauseef-ur-Rehman',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-I',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Fundamentals Lab (G2)',
  'Dr. Tauseef-ur-Rehman',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G1)',
  'Mr. Salahuddin',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Mr. Salahuddin',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-1',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Lab (G1)',
  'Dr. Sajjad',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G2)',
  'Dr. Naveed Abbas',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-1',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Lab (G2)',
  'Dr. Sajjad',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G1)',
  'Dr. Naveed Abbas',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-1',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 4',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Sajjad',
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-1',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-1',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pakistan Studies',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Muhammad Sajjad',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math-1',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Lab (G1)',
  'Dr. Muhammad Sajjad',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G2)',
  'Dr. Naveed Abbas',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room Unspecified',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Muhammad Sajjad',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Lab (G2)',
  'Dr. Muhammad Sajjad',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G1)',
  'Dr. Naveed Abbas',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming',
  'Dr. Muhammad Sajjad',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pak Studies',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math 1',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '05:00 PM',
  '08:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Fundamentals Lab (G1)',
  'Dr. Naveed Abbas',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '05:00 PM',
  '08:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G2)',
  'Mr. Salahuddin',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'HQ-101',
  'Holy Quran',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PS-101',
  'Pak Studies',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math 1',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '05:00 PM',
  '08:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101L',
  'Programming Fundamentals Lab (G2)',
  'Dr. Naveed Abbas',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '05:00 PM',
  '08:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102L',
  'ICT Lab (G1)',
  'Mr. Salahuddin',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'PHY-101',
  'Physics',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-101',
  'Basic Math 1',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Mr. Salahuddin',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'IS-101',
  'Islamic Studies',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-102',
  'ICT',
  'Mr. Salahuddin',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'ENG-101',
  'Functional English',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-101',
  'Programming Fundamentals',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '1st'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2026 – 2030'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G1)',
  'Dr. Atif Khan',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Atif Khan',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Muhammad Waseem',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G1)',
  'Dr. Atif Khan',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Atif Khan',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Muhammad Waseem',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G1)',
  'Dr. Muhammad Waseem',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Atif Khan',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Khalid Haseeb',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Muhammad Waseem',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G2)',
  'Dr. Muhammad Waseem',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Dr. Naveed Abbas',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Dr. Naveed Abbas',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Muhammad Waseem',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G1)',
  'Dr. Muhammad Waseem',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Muhammad Waseem',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Muhammad Waseem',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G2)',
  'Dr. Muhammad Waseem',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G1)',
  'Dr. Atif Khan',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Atif Khan',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Mr. Inaam Ul Haq',
  'Stats Deptt',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G2)',
  'Dr. Atif Khan',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Atif Khan',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Khalid Haseeb',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Mr. Inaam Ul Haq',
  'Stats Deptt',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Atif Khan',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Shaukat Ali',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Naveed Abbas',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Irshad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G1)',
  'Dr. Shaukat Ali',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Shaukat Ali',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Naveed Abbas',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Irshad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G2)',
  'Dr. Shaukat Ali',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Shaukat Ali',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Naveed Abbas',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Irshad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G1)',
  'Dr. Irshad',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Mr. Inaam Ul Haq',
  'Stats Deptt',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G2)',
  'Dr. Irshad',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Mr. Inaam Ul Haq',
  'Stats Deptt',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Shaukat Ali',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Naveed Abbas',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G1)',
  'Dr. Irshad',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Shaukat Ali',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Naveed Abbas',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G2)',
  'Dr. Irshad',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Shaukat Ali',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Naveed Abbas',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G1)',
  'Dr. Shaukat Ali',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Mr. Inaam Ul Haq',
  'Stats Deptt',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Irshad',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G2)',
  'Dr. Shaukat Ali',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Mr. Inaam Ul Haq',
  'Stats Deptt',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Irshad',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Irshad',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Israr Iqbal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Bilal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '06:00 PM',
  '09:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G1)',
  'Dr. Bilal',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SS-201',
  'Civics & Community Engagement',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Israr Iqbal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Bilal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '06:00 PM',
  '09:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201L',
  'Database Systems Lab (G2)',
  'Dr. Bilal',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-201',
  'Calculus & Analytical Geometry',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-201',
  'Software Engineering',
  'Dr. Israr Iqbal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-201',
  'Database Systems',
  'Dr. Bilal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '06:00 PM',
  '09:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G1)',
  'Dr. Bilal',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Dr. Israr Iqbal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Bilal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '06:00 PM',
  '09:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202L',
  'Data Structures Lab (G2)',
  'Dr. Bilal',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-203',
  'Professional Practice',
  'Dr. Israr Iqbal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Bilal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '06:00 PM',
  '07:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-202',
  'Data Structures',
  'Dr. Bilal',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '3rd'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2025 – 2029'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301L',
  'Assembly Language Lab (G1)',
  'Mr. Faisal Saeed',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301',
  'Assembly Language',
  'Mr. Faisal Saeed',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  'Dr. Mansoor Nasir',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301L',
  'Assembly Language Lab (G2)',
  'Mr. Faisal Saeed',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301',
  'Assembly Language',
  'Mr. Faisal Saeed',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  'Dr. Mansoor Nasir',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Shaukat Ali',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Shaukat Ali',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Shaukat Ali',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G1)',
  'Dr. Khalid Haseeb',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G2)',
  'Dr. Mansoor Nasir',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G2)',
  'Dr. Khalid Haseeb',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G1)',
  'Dr. Mansoor Nasir',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  'Dr. Mansoor Nasir',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G1)',
  'Dr. Khalid Haseeb',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301',
  'Assembly Language',
  'Mr. Faisal Saeed',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G2)',
  'Dr. Khalid Haseeb',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301',
  'Assembly Language',
  'Mr. Faisal Saeed',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301L',
  'Assembly Language Lab (G1)',
  'Mr. Faisal Saeed',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G1)',
  'Dr. Mansoor Nasir',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Shaukat Ali',
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  'Dr. Mansoor Nasir',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Khalid Haseeb',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301L',
  'Assembly Language Lab (G2)',
  'Mr. Faisal Saeed',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G2)',
  'Dr. Mansoor Nasir',
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Shaukat Ali',
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Shaukat Ali',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301L',
  'Software Design & Architecture Lab (G1)',
  'Dr. Israr Iqbal',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305L',
  'Computer Organization & Assembly Language Lab (G2)',
  NULL,
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G1)',
  'Dr. Israr Iqbal',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Israr Iqbal',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301L',
  'Software Design & Architecture Lab (G2)',
  'Dr. Israr Iqbal',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305L',
  'Computer Organization & Assembly Language Lab (G1)',
  NULL,
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G2)',
  'Dr. Israr Iqbal',
  'Lab 3',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Israr Iqbal',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  NULL,
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G1)',
  NULL,
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301',
  'Software Design & Architecture',
  'Dr. Israr Iqbal',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305',
  'Computer Organization & Assembly Language',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  NULL,
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305',
  'Computer Organization & Assembly Language',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G2)',
  NULL,
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301',
  'Software Design & Architecture',
  'Dr. Israr Iqbal',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G1)',
  NULL,
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304L',
  'Web Technologies Lab (G2)',
  NULL,
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 8',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301L',
  'Software Design & Architecture Lab (G1)',
  'Dr. Israr Iqbal',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305L',
  'Computer Organization & Assembly Language Lab (G2)',
  NULL,
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G1)',
  'Dr. Israr Iqbal',
  'Room Unspecified',
  'CS Academic Block',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 6',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301L',
  'Software Design & Architecture Lab (G2)',
  'Dr. Israr Iqbal',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305L',
  'Computer Organization & Assembly Language Lab (G1)',
  NULL,
  'Lab 6',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303L',
  'Computer Networks Lab (G2)',
  'Dr. Israr Iqbal',
  'Room Unspecified',
  'CS Academic Block',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-304',
  'Web Technologies',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Israr Iqbal',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '09:00 AM',
  '10:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-303',
  'Computer Networks',
  'Dr. Israr Iqbal',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301',
  'Software Design & Architecture',
  'Dr. Israr Iqbal',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-301',
  'Software Design & Architecture',
  'Dr. Israr Iqbal',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305',
  'Computer Organization & Assembly Language',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-305',
  'Computer Organization & Assembly Language',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-302',
  'Machine Learning',
  'Dr. Muhammad Sajjad',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Bilal',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '05:00 PM',
  '08:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301L',
  'Assembly Language Lab (G1)',
  'Mr. Faisal Saeed',
  'Lab Unspecified',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-302',
  'Machine Learning',
  'Dr. Muhammad Sajjad',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 7',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Bilal',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '05:00 PM',
  '08:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301L',
  'Assembly Language Lab (G2)',
  'Mr. Faisal Saeed',
  'Lab Unspecified',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301',
  'Programming for AI',
  'Dr. Atif Khan',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '02:00 PM',
  '03:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'MATH-301',
  'Multivariate Calculus',
  NULL,
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301',
  'Assembly Language',
  'Mr. Faisal Saeed',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '04:00 PM',
  '05:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-302',
  'Theory of Automata',
  'Dr. Bilal',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301',
  'Programming for AI',
  'Dr. Atif Khan',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-301',
  'Assembly Language',
  'Mr. Faisal Saeed',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '04:00 PM',
  '07:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-302L',
  'Machine Learning Lab (G1)',
  'Dr. Muhammad Sajjad',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '04:00 PM',
  '07:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301L',
  'Programming for AI Lab (G2)',
  'Dr. Atif Khan',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '04:00 PM',
  '07:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-302L',
  'Machine Learning Lab (G2)',
  'Dr. Muhammad Sajjad',
  'Lab 4',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '04:00 PM',
  '07:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301L',
  'Programming for AI Lab (G1)',
  'Dr. Atif Khan',
  'Lab 5',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '5th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2024 – 2028'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301L',
  'Programming for AI Lab (G1)',
  'Dr. Muhammad Sajjad',
  'DIP Lab',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301',
  'Programming for AI',
  'Dr. Muhammad Sajjad',
  'DIP Lab',
  'CS Computing Laboratories',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-403',
  'Professional Practices',
  'Mr. Inaam Ul Haq',
  'Stats Department',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301L',
  'Programming for AI Lab (G2)',
  'Dr. Muhammad Sajjad',
  'DIP Lab',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301',
  'Programming for AI',
  'Dr. Muhammad Sajjad',
  'DIP Lab',
  'CS Computing Laboratories',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-403',
  'Professional Practices',
  'Mr. Inaam Ul Haq',
  'Stats Department',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-401',
  'Compiler Construction',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-402',
  'Information Security',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-403',
  'Professional Practices',
  'Mr. Inaam Ul Haq',
  'Stats Department',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-401',
  'Compiler Construction',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-402',
  'Information Security',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-401',
  'Compiler Construction',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-402',
  'Information Security',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-401',
  'Compiler Construction',
  'Mr. Muhammad Zubair',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-402',
  'Information Security',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-403',
  'Professional Practices',
  'Mr. Inaam Ul Haq',
  'Stats Department',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-401',
  'Compiler Construction',
  'Mr. Muhammad Zubair',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-402',
  'Information Security',
  'Mr. Muhammad Zubair',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-403',
  'Professional Practices',
  'Mr. Inaam Ul Haq',
  'Stats Department',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301L',
  'Programming for AI Lab (G1)',
  'Dr. Muhammad Sajjad',
  'DIP Lab',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-401',
  'Compiler Construction',
  'Mr. Muhammad Zubair',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301',
  'Programming for AI',
  'Dr. Muhammad Sajjad',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '01:00 PM',
  '02:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-403',
  'Professional Practices',
  'Mr. Inaam Ul Haq',
  'Stats Department',
  'Statistics & Allied Sciences Block',
  'Lecture',
  2
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301L',
  'Programming for AI Lab (G2)',
  'Dr. Muhammad Sajjad',
  'DIP Lab',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-402',
  'Information Security',
  'Mr. Muhammad Zubair',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-301',
  'Programming for AI',
  'Dr. Muhammad Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Computer Science'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Computer Science'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404L',
  'Computer Graphics Lab (G1)',
  'Dr. Irshad',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-402',
  'Software Project Management',
  'Dr. Naila Habib',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404L',
  'Computer Graphics Lab (G2)',
  'Dr. Irshad',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-402',
  'Software Project Management',
  'Dr. Naila Habib',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-401',
  'Software Re-Engineering',
  'Dr. Naila Habib',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-402',
  'Software Project Management',
  'Dr. Naila Habib',
  'Room 2',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-401',
  'Software Re-Engineering',
  'Dr. Naila Habib',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404',
  'Computer Graphics',
  'Dr. Irshad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-401',
  'Software Re-Engineering',
  'Dr. Naila Habib',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404',
  'Computer Graphics',
  'Dr. Irshad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-402',
  'Software Project Management',
  'Dr. Naila Habib',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-401',
  'Software Re-Engineering',
  'Dr. Naila Habib',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404',
  'Computer Graphics',
  'Dr. Irshad',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '08:00 AM',
  '09:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-402',
  'Software Project Management',
  'Dr. Naila Habib',
  'Room 5',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-401',
  'Software Re-Engineering',
  'Dr. Naila Habib',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '12:00 PM',
  '01:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404',
  'Computer Graphics',
  'Dr. Irshad',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404L',
  'Computer Graphics Lab (G1)',
  'Dr. Irshad',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '08:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'CS-404L',
  'Computer Graphics Lab (G2)',
  'Dr. Irshad',
  'Lab 1',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '10:00 AM',
  '11:00 AM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-402',
  'Software Project Management',
  'Dr. Naila Habib',
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '11:00 AM',
  '12:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'SE-401',
  'Software Re-Engineering',
  'Dr. Naila Habib',
  'Room 4',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Software Engineering'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'B'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Software Engineering'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-402',
  'Deep Learning',
  'Dr. Muhammad Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Monday',
  '06:00 PM',
  '09:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-402L',
  'Deep Learning Lab (G1)',
  'Dr. Muhammad Sajjad',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-402',
  'Deep Learning',
  'Dr. Muhammad Sajjad',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Tuesday',
  '06:00 PM',
  '09:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-402L',
  'Deep Learning Lab (G2)',
  'Dr. Muhammad Sajjad',
  'Lab 2',
  'CS Computing Laboratories',
  'Lab',
  1
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'STAT-401',
  'Advance Statistics',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Wednesday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-401',
  'Agent Based Modeling',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'STAT-401',
  'Advance Statistics',
  NULL,
  'Room 3',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Thursday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-401',
  'Agent Based Modeling',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '03:00 PM',
  '04:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'STAT-401',
  'Advance Statistics',
  NULL,
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  'Friday',
  '05:00 PM',
  '06:00 PM',
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  'AI-401',
  'Agent Based Modeling',
  'Dr. Naveed Abbas',
  'Room 1',
  'CS Academic Block',
  'Lecture',
  3
FROM public.departments d
JOIN public.programs p ON p.name = 'BS Artificial Intelligence'
JOIN public.semesters sem ON sem.name = '7th'
JOIN public.sections sec ON sec.name = 'A'
JOIN public.batches b ON b.name = 'Fall 2023 – 2027'
WHERE d.name = 'Artificial Intelligence'
ON CONFLICT DO NOTHING;
