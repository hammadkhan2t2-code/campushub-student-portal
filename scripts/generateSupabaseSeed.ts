import {
  ORIGINAL_DEPARTMENTS,
  ORIGINAL_DEGREES,
  ORIGINAL_SEMESTERS,
  ORIGINAL_SECTIONS,
  ORIGINAL_BATCHES,
  ORIGINAL_TEACHERS,
  ORIGINAL_ROOMS,
  ORIGINAL_TIMETABLE_ENTRIES
} from '../src/data/rawMigrationData';

function escapeSql(str: string | null | undefined): string {
  if (str === null || str === undefined) return 'NULL';
  return `'${str.replace(/'/g, "''")}'`;
}

export function generateSeedSql(): string {
  const lines: string[] = [];

  lines.push('-- =============================================================');
  lines.push('-- CampusHub Official University Academic Dataset Seed');
  lines.push('-- Source: Original CampusHub mockData.ts (Islamia College Peshawar)');
  lines.push('-- Safe, idempotent execution using ON CONFLICT DO UPDATE / NOTHING');
  lines.push('-- =============================================================\n');

  // 1. DEPARTMENTS
  lines.push('-- 1. DEPARTMENTS');
  const allDepartments: { name: string; code: string }[] = [
    { name: 'Computer Science', code: 'CS' },
    { name: 'Software Engineering', code: 'SE' },
    { name: 'Artificial Intelligence', code: 'AI' }
  ];

  for (const dept of allDepartments) {
    lines.push(`INSERT INTO public.departments (id, name, code)
VALUES (gen_random_uuid(), ${escapeSql(dept.name)}, ${escapeSql(dept.code)})
ON CONFLICT (name) DO UPDATE SET code = EXCLUDED.code;`);
  }
  lines.push('');

  // 2. PROGRAMS / DEGREES
  lines.push('-- 2. PROGRAMS / DEGREES');
  for (const deg of ORIGINAL_DEGREES) {
    lines.push(`INSERT INTO public.programs (id, department_id, name, short_code, duration_years)
SELECT gen_random_uuid(), d.id, ${escapeSql(deg.name)}, ${escapeSql(deg.code)}, 4
FROM public.departments d
WHERE d.name = ${escapeSql(deg.department)}
ON CONFLICT (name) DO UPDATE SET short_code = EXCLUDED.short_code, duration_years = EXCLUDED.duration_years;`);
  }
  lines.push('');

  // 3. SEMESTERS
  lines.push('-- 3. SEMESTERS');
  for (const sem of ORIGINAL_SEMESTERS) {
    lines.push(`INSERT INTO public.semesters (id, name, number)
VALUES (gen_random_uuid(), ${escapeSql(sem.name)}, ${sem.number})
ON CONFLICT (name) DO UPDATE SET number = EXCLUDED.number;`);
  }
  lines.push('');

  // 4. SECTIONS
  lines.push('-- 4. SECTIONS');
  for (const sec of ORIGINAL_SECTIONS) {
    lines.push(`INSERT INTO public.sections (id, name)
VALUES (gen_random_uuid(), ${escapeSql(sec)})
ON CONFLICT (name) DO NOTHING;`);
  }
  lines.push('');

  // 5. BATCHES
  lines.push('-- 5. BATCHES');
  for (const batch of ORIGINAL_BATCHES) {
    lines.push(`INSERT INTO public.batches (id, name, start_year, end_year)
VALUES (gen_random_uuid(), ${escapeSql(batch.name)}, ${batch.startYear}, ${batch.endYear})
ON CONFLICT (name) DO UPDATE SET start_year = EXCLUDED.start_year, end_year = EXCLUDED.end_year;`);
  }
  lines.push('');

  // 6. ROOMS
  lines.push('-- 6. ROOMS & LABORATORIES');
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

  // 7. TEACHERS
  lines.push('-- 7. FACULTY & TEACHERS');
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

  // 8. COURSES (Extracted canonically from original timetable entries)
  lines.push('-- 8. COURSES');
  const courseMap = new Map<string, { code: string; name: string; dept: string; type: string; credits: number }>();
  for (const entry of ORIGINAL_TIMETABLE_ENTRIES) {
    if (!courseMap.has(entry.courseCode)) {
      courseMap.set(entry.courseCode, {
        code: entry.courseCode,
        name: entry.courseName,
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

  // 9. TIMETABLE ENTRIES
  lines.push('-- 9. TIMETABLE ENTRIES (Exact mapping from mockData.ts)');
  lines.push(`-- Ensures Section A and Section B records remain strictly segregated.`);
  for (const entry of ORIGINAL_TIMETABLE_ENTRIES) {
    const programName = entry.program || (entry.department === 'Software Engineering' ? 'BS Software Engineering' : entry.department === 'Artificial Intelligence' ? 'BS Artificial Intelligence' : 'BS Computer Science');
    const teacherVal = entry.teacherName ? escapeSql(entry.teacherName) : 'NULL';

    // Lookups
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
WHERE d.name = ${escapeSql(entry.department)}
ON CONFLICT DO NOTHING;`);
  }
  lines.push('');

  return lines.join('\n');
}

import fs from 'fs';
import path from 'path';

const isDirectRun = process.argv[1]?.includes('generateSupabaseSeed');
if (isDirectRun) {
  const sql = generateSeedSql();
  const outPath = path.join(process.cwd(), 'supabase_seed.sql');
  fs.writeFileSync(outPath, sql, 'utf-8');
  console.log(`Generated supabase_seed.sql successfully at ${outPath} (${sql.length} characters)`);
}
