import fs from 'fs';
import {
  ORIGINAL_DEPARTMENTS,
  ORIGINAL_DEGREES,
  ORIGINAL_SEMESTERS,
  ORIGINAL_SECTIONS,
  ORIGINAL_BATCHES,
  ORIGINAL_TEACHERS,
  ORIGINAL_ROOMS,
  ORIGINAL_TIMETABLE_ENTRIES
} from '../src/data/rawMigrationData.js';

function escapeSql(str) {
  if (str === null || str === undefined || str === '') return 'NULL';
  return `'${String(str).replace(/'/g, "''")}'`;
}

function generateMigrationSql() {
  const lines = [];

  lines.push('-- ============================================================================');
  lines.push('-- CampusHub Authoritative Timetable Migration');
  lines.push('-- Source: Official 20-Page Departmental Time Table PDF');
  lines.push('-- Scope: Safely replaces public.timetable_entries with the verified 370 entries.');
  lines.push('-- Safety: Does NOT touch auth.users, profiles, or lost_found tables.');
  lines.push('-- Atomic: Runs inside a BEGIN / COMMIT transaction block with strict validations.');
  lines.push('-- ============================================================================\n');
  lines.push('BEGIN;\n');

  // STEP 1: Remove existing timetable entries
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 1: CLEAR EXISTING TIMETABLE ENTRIES ONLY');
  lines.push('-- (Does not touch auth, profiles, lost_found, or other application tables)');
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('DELETE FROM public.timetable_entries;\n');

  // STEP 2: Canonical Departments
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 2: ENSURE EXACTLY THE 3 CANONICAL DEPARTMENTS (CS, SE, AI)');
  lines.push('-- Mathematics, Physics, and Humanities exist only as courses/subjects.');
  lines.push('-- ----------------------------------------------------------------------------');
  
  const depts = [
    { name: 'Computer Science', code: 'CS' },
    { name: 'Software Engineering', code: 'SE' },
    { name: 'Artificial Intelligence', code: 'AI' }
  ];

  for (const d of depts) {
    lines.push(`INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), ${escapeSql(d.name)}, ${escapeSql(d.code)})
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;`);
  }
  lines.push('');

  // Re-link any legacy courses/teachers/programs pointing to non-canonical departments, then delete non-core departments
  lines.push(`-- Reassign any legacy courses or teachers pointing to non-core departments to Computer Science
UPDATE public.courses
SET department_id = (SELECT id FROM public.departments WHERE code = 'CS' LIMIT 1)
WHERE department_id IN (SELECT id FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI'));

UPDATE public.teachers
SET department_id = (SELECT id FROM public.departments WHERE code = 'CS' LIMIT 1)
WHERE department_id IN (SELECT id FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI'));

UPDATE public.programs
SET department_id = (SELECT id FROM public.departments WHERE code = 'CS' LIMIT 1)
WHERE department_id IN (SELECT id FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI'));

-- Delete non-canonical departments (e.g. Mathematics, Physics, Humanities if previously created)
DELETE FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI');
`);

  // STEP 3: Ensure Programs / Degrees
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 3: ENSURE PROGRAMS / DEGREES');
  lines.push('-- ----------------------------------------------------------------------------');
  const programs = [
    { name: 'BS Computer Science', code: 'BSCS', deptCode: 'CS' },
    { name: 'BS Software Engineering', code: 'BSSE', deptCode: 'SE' },
    { name: 'BS Artificial Intelligence', code: 'BSAI', deptCode: 'AI' }
  ];

  for (const p of programs) {
    lines.push(`INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, ${escapeSql(p.name)}, ${escapeSql(p.code)}, 4
FROM public.departments d
WHERE d.code = ${escapeSql(p.deptCode)}
ON CONFLICT (name) DO UPDATE SET short_code = EXCLUDED.short_code, duration_years = EXCLUDED.duration_years;`);
  }
  lines.push('');

  // STEP 4: Semesters
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 4: ENSURE SEMESTERS (1st, 3rd, 5th, 7th)');
  lines.push('-- Note: Actual schema columns are id, name, and order_seq (NOT NULL)');
  lines.push('-- Mapping: 1st -> order_seq 1, 3rd -> order_seq 3, 5th -> order_seq 5, 7th -> order_seq 7');
  lines.push('-- ----------------------------------------------------------------------------');
  const semOrderMap = { '1st': 1, '3rd': 3, '5th': 5, '7th': 7 };
  for (const sem of ORIGINAL_SEMESTERS) {
    const orderSeq = semOrderMap[sem.name] || sem.number || 1;
    lines.push(`INSERT INTO public.semesters (id, name, order_seq)
VALUES (gen_random_uuid(), ${escapeSql(sem.name)}, ${orderSeq})
ON CONFLICT (name) DO UPDATE SET order_seq = EXCLUDED.order_seq;`);
  }
  lines.push('');

  // STEP 5: Sections
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 5: ENSURE SECTIONS (A, B)');
  lines.push('-- ----------------------------------------------------------------------------');
  for (const sec of ORIGINAL_SECTIONS) {
    lines.push(`INSERT INTO public.sections (id, name)
VALUES (gen_random_uuid(), ${escapeSql(sec)})
ON CONFLICT (name) DO NOTHING;`);
  }
  lines.push('');

  // STEP 6: Batches
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 6: ENSURE BATCHES');
  lines.push('-- Note: Actual schema columns are id, name, start_year (NOT NULL), end_year (NOT NULL)');
  lines.push('-- Fall 2026 – 2030 -> start_year 2026, end_year 2030');
  lines.push('-- Fall 2025 – 2029 -> start_year 2025, end_year 2029');
  lines.push('-- Fall 2024 – 2028 -> start_year 2024, end_year 2028');
  lines.push('-- Fall 2023 – 2027 -> start_year 2023, end_year 2027');
  lines.push('-- ----------------------------------------------------------------------------');
  for (const b of ORIGINAL_BATCHES) {
    lines.push(`INSERT INTO public.batches (id, name, start_year, end_year)
VALUES (gen_random_uuid(), ${escapeSql(b.name)}, ${b.startYear}, ${b.endYear})
ON CONFLICT (name) DO UPDATE SET 
  start_year = EXCLUDED.start_year, 
  end_year = EXCLUDED.end_year;`);
  }
  lines.push('');

  // STEP 7: Rooms
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 7: ENSURE ROOMS & LABORATORIES');
  lines.push('-- ----------------------------------------------------------------------------');
  for (const rm of ORIGINAL_ROOMS) {
    const facilitiesArray = `ARRAY[${rm.facilities.map(f => escapeSql(f)).join(', ')}]::text[]`;
    lines.push(`INSERT INTO public.rooms (id, room_number, building, floor, capacity, type, facilities)
VALUES (gen_random_uuid(), ${escapeSql(rm.roomNumber)}, ${escapeSql(rm.building)}, ${escapeSql(rm.floor)}, ${rm.capacity}, ${escapeSql(rm.type)}, ${facilitiesArray})
ON CONFLICT (room_number) DO UPDATE SET 
  building = EXCLUDED.building,
  floor = EXCLUDED.floor,
  capacity = EXCLUDED.capacity,
  type = EXCLUDED.type,
  facilities = EXCLUDED.facilities;`);
  }
  lines.push('');

  // STEP 8: Teachers
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 8: ENSURE FACULTY & INSTRUCTORS');
  lines.push('-- (Preserves exact names, designations, and departmental affiliations)');
  lines.push('-- ----------------------------------------------------------------------------');
  for (const tch of ORIGINAL_TEACHERS) {
    lines.push(`INSERT INTO public.teachers (id, name, designation, qualifications, specialization, department_id)
SELECT gen_random_uuid(), ${escapeSql(tch.name)}, ${escapeSql(tch.designation)}, ${escapeSql(tch.qualifications)}, ${escapeSql(tch.specialization)}, d.id
FROM public.departments d
WHERE d.name = ${escapeSql(tch.department)}
LIMIT 1
ON CONFLICT (name) DO UPDATE SET
  designation = EXCLUDED.designation,
  qualifications = EXCLUDED.qualifications,
  specialization = EXCLUDED.specialization,
  department_id = EXCLUDED.department_id;`);
  }
  lines.push('');

  // STEP 9: Courses
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 9: ENSURE COURSES');
  lines.push('-- (Mathematics, Physics, Humanities mapped to academic departments offering them)');
  lines.push('-- ----------------------------------------------------------------------------');
  const courseMap = new Map();
  for (const entry of ORIGINAL_TIMETABLE_ENTRIES) {
    if (!courseMap.has(entry.courseCode)) {
      const cleanName = entry.courseName.replace(/\s*\([Gg][12]\)/, '').trim();
      courseMap.set(entry.courseCode, {
        code: entry.courseCode,
        name: cleanName,
        dept: entry.department,
        type: entry.type,
        credits: entry.creditHours
      });
    }
  }

  for (const course of courseMap.values()) {
    lines.push(`INSERT INTO public.courses (id, code, name, department_id, credit_hours, type)
SELECT gen_random_uuid(), ${escapeSql(course.code)}, ${escapeSql(course.name)}, d.id, ${course.credits}, ${escapeSql(course.type)}
FROM public.departments d
WHERE d.name = ${escapeSql(course.dept)}
LIMIT 1
ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, credit_hours = EXCLUDED.credit_hours, type = EXCLUDED.type;`);
  }
  lines.push('');

  // STEP 10: Timetable Entries
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 10: INSERT 370 AUTHORITATIVE TIMETABLE OCCURRENCES');
  lines.push('-- (Section A & B segregated; G1 & G2 separate lab rows; blank teachers preserved as NULL)');
  lines.push('-- ----------------------------------------------------------------------------');
  
  let currentGroup = '';
  ORIGINAL_TIMETABLE_ENTRIES.forEach((entry, idx) => {
    const groupName = `${entry.program || entry.degree} - ${entry.semester} Semester Section ${entry.section}`;
    if (groupName !== currentGroup) {
      currentGroup = groupName;
      lines.push(`\n-- ${currentGroup}`);
    }

    const programName = entry.program || (entry.department === 'Software Engineering' ? 'BS Software Engineering' : entry.department === 'Artificial Intelligence' ? 'BS Artificial Intelligence' : 'BS Computer Science');
    const teacherVal = entry.teacherName && entry.teacherName.trim() ? escapeSql(entry.teacherName) : 'NULL';

    lines.push(`INSERT INTO public.timetable_entries (
  id, day, start_time, end_time, department_id, program_id, semester_id, section_id, batch_id, 
  course_code, course_name, teacher_name, classroom_number, building, type, credit_hours
)
SELECT
  gen_random_uuid(),
  ${escapeSql(entry.day)},
  ${escapeSql(entry.startTime)},
  ${escapeSql(entry.endTime)},
  d.id,
  p.id,
  sem.id,
  sec.id,
  b.id,
  ${escapeSql(entry.courseCode)},
  ${escapeSql(entry.courseName)},
  ${teacherVal},
  ${escapeSql(entry.classroomNumber)},
  ${escapeSql(entry.building)},
  ${escapeSql(entry.type)},
  ${entry.creditHours}
FROM public.departments d
JOIN public.programs p ON p.name = ${escapeSql(programName)}
JOIN public.semesters sem ON sem.name = ${escapeSql(entry.semester)}
JOIN public.sections sec ON sec.name = ${escapeSql(entry.section)}
JOIN public.batches b ON b.name = ${escapeSql(entry.batch)}
WHERE d.name = ${escapeSql(entry.department)};`);
  });

  lines.push('');
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 11: VERIFICATION & INTEGRITY ASSERTIONS');
  lines.push('-- (Fails transaction if any condition is not met)');
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push(`DO $$
DECLARE
  v_timetable_count integer;
  v_dept_count integer;
  v_invalid_depts integer;
  v_missing_rel integer;
  v_duplicate_count integer;
BEGIN
  -- 1. Verify exactly 370 timetable entries
  SELECT count(*) INTO v_timetable_count FROM public.timetable_entries;
  IF v_timetable_count <> 370 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected 370 timetable entries, but found %', v_timetable_count;
  END IF;

  -- 2. Verify exactly 3 departments
  SELECT count(*) INTO v_dept_count FROM public.departments;
  IF v_dept_count <> 3 THEN
    RAISE EXCEPTION 'Assertion Failed: Expected exactly 3 departments, but found %', v_dept_count;
  END IF;

  -- 3. Verify department codes are strictly CS, SE, AI
  SELECT count(*) INTO v_invalid_depts FROM public.departments WHERE code NOT IN ('CS', 'SE', 'AI');
  IF v_invalid_depts > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % unexpected departments outside CS, SE, AI', v_invalid_depts;
  END IF;

  -- 4. Verify no timetable entry is missing a required foreign key relationship
  SELECT count(*) INTO v_missing_rel
  FROM public.timetable_entries
  WHERE department_id IS NULL
     OR program_id IS NULL
     OR semester_id IS NULL
     OR section_id IS NULL
     OR batch_id IS NULL;
  IF v_missing_rel > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: % timetable entries are missing required relationships', v_missing_rel;
  END IF;

  -- 5. Verify no unintended duplicate rows created
  SELECT count(*) INTO v_duplicate_count
  FROM (
    SELECT day, start_time, end_time, program_id, semester_id, section_id, batch_id, course_code, course_name, classroom_number, count(*)
    FROM public.timetable_entries
    GROUP BY day, start_time, end_time, program_id, semester_id, section_id, batch_id, course_code, course_name, classroom_number
    HAVING count(*) > 1
  ) dups;
  IF v_duplicate_count > 0 THEN
    RAISE EXCEPTION 'Assertion Failed: Found % duplicate timetable entries', v_duplicate_count;
  END IF;

  RAISE NOTICE '=======================================================';
  RAISE NOTICE 'ALL INTEGRITY CHECKS PASSED:';
  RAISE NOTICE '  - Timetable Entries: %', v_timetable_count;
  RAISE NOTICE '  - Departments: % (CS, SE, AI)', v_dept_count;
  RAISE NOTICE '  - Zero missing relationships or duplicate rows';
  RAISE NOTICE '=======================================================';
END $$;
`);

  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 12: SUMMARY QUERIES FOR SUPABASE SQL EDITOR DISPLAY');
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push(`SELECT 
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
`);

  lines.push(`SELECT 
  p.name AS program,
  sem.name AS semester,
  sec.name AS section,
  b.name AS batch,
  count(te.id) AS total_classes
FROM public.timetable_entries te
JOIN public.programs p ON p.id = te.program_id
JOIN public.semesters sem ON sem.id = te.semester_id
JOIN public.sections sec ON sec.id = te.section_id
JOIN public.batches b ON b.id = te.batch_id
GROUP BY p.name, sem.name, sec.name, b.name
ORDER BY p.name, sem.name, sec.name;
`);

  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('-- STEP 13: ATOMIC COMMIT');
  lines.push('-- ----------------------------------------------------------------------------');
  lines.push('COMMIT;\n');

  return lines.join('\n');
}

const sql = generateMigrationSql();
fs.writeFileSync('supabase_timetable_migration.sql', sql, 'utf8');
console.log('Successfully generated supabase_timetable_migration.sql with length', sql.length);
