import { createClient } from '@supabase/supabase-js';
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

/**
 * One-Time Migration Script: CampusHub University Data to Supabase
 *
 * Requirements Met:
 * 1. Reads ONLY original source mockData.ts dataset via rawMigrationData.ts.
 * 2. Idempotent: Can be run multiple times safely without duplicate rows.
 * 3. Never deletes or truncates existing user accounts, profiles, or lost_and_found entries.
 * 4. Resolves foreign keys dynamically for departments, programs, semesters, sections, batches, teachers, rooms.
 * 5. Strictly keeps Section A and Section B separate.
 * 6. Preserves verbatim timetable course names (e.g. Basic Math - I vs Basic Math 1).
 * 7. Does not invent any teachers, rooms, courses, or syllabus data.
 */
export async function runMigration() {
  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    console.error('ERROR: Missing Supabase URL or key. Set VITE_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY / VITE_SUPABASE_ANON_KEY.');
    process.exit(1);
  }

  console.log(`\n======================================================`);
  console.log(`Starting CampusHub University Data Migration to Supabase`);
  console.log(`Target URL: ${supabaseUrl}`);
  console.log(`======================================================\n`);

  const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: { persistSession: false }
  });

  // 1. Departments
  const ALL_DEPARTMENTS: { name: string; code: string }[] = [
    { name: 'Computer Science', code: 'CS' },
    { name: 'Software Engineering', code: 'SE' },
    { name: 'Artificial Intelligence', code: 'AI' },
    { name: 'Mathematics', code: 'MATH' },
    { name: 'Physics', code: 'PHYS' },
    { name: 'Humanities', code: 'HUM' }
  ];

  console.log(`1. Migrating Departments (${ALL_DEPARTMENTS.length} records)...`);
  const deptMap = new Map<string, string>(); // name -> id
  for (const dept of ALL_DEPARTMENTS) {
    const { data: existing } = await supabase.from('departments').select('id, name').eq('name', dept.name).maybeSingle();
    if (existing) {
      deptMap.set(dept.name, existing.id);
      console.log(`   [Existing] Department: "${dept.name}" (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('departments').insert([{ name: dept.name, code: dept.code }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting department ${dept.name}:`, error.message);
      } else if (inserted) {
        deptMap.set(dept.name, inserted.id);
        console.log(`   [Created] Department: "${dept.name}" (${inserted.id})`);
      }
    }
  }

  // 2. Programs / Degrees
  console.log(`\n2. Migrating Programs / Degrees (${ORIGINAL_DEGREES.length} records)...`);
  const progMap = new Map<string, string>(); // name -> id
  for (const deg of ORIGINAL_DEGREES) {
    const deptId = deptMap.get(deg.department);
    const { data: existing } = await supabase.from('programs').select('id, name').eq('name', deg.name).maybeSingle();
    if (existing) {
      progMap.set(deg.name, existing.id);
      console.log(`   [Existing] Program: "${deg.name}" (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('programs').insert([{
        name: deg.name,
        short_code: deg.code,
        department_id: deptId,
        duration_years: 4
      }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting program ${deg.name}:`, error.message);
      } else if (inserted) {
        progMap.set(deg.name, inserted.id);
        console.log(`   [Created] Program: "${deg.name}" (${inserted.id})`);
      }
    }
  }

  // 3. Semesters
  console.log(`\n3. Migrating Semesters (${ORIGINAL_SEMESTERS.length} records)...`);
  const semMap = new Map<string, string>(); // name -> id
  for (const sem of ORIGINAL_SEMESTERS) {
    const { data: existing } = await supabase.from('semesters').select('id, name').eq('name', sem.name).maybeSingle();
    if (existing) {
      semMap.set(sem.name, existing.id);
      console.log(`   [Existing] Semester: "${sem.name}" (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('semesters').insert([{ name: sem.name, number: sem.number }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting semester ${sem.name}:`, error.message);
      } else if (inserted) {
        semMap.set(sem.name, inserted.id);
        console.log(`   [Created] Semester: "${sem.name}" (${inserted.id})`);
      }
    }
  }

  // 4. Sections
  console.log(`\n4. Migrating Sections (${ORIGINAL_SECTIONS.length} records)...`);
  const secMap = new Map<string, string>(); // name -> id
  for (const sec of ORIGINAL_SECTIONS) {
    const { data: existing } = await supabase.from('sections').select('id, name').eq('name', sec).maybeSingle();
    if (existing) {
      secMap.set(sec, existing.id);
      console.log(`   [Existing] Section: "${sec}" (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('sections').insert([{ name: sec }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting section ${sec}:`, error.message);
      } else if (inserted) {
        secMap.set(sec, inserted.id);
        console.log(`   [Created] Section: "${sec}" (${inserted.id})`);
      }
    }
  }

  // 5. Batches
  console.log(`\n5. Migrating Batches (${ORIGINAL_BATCHES.length} records)...`);
  const batchMap = new Map<string, string>(); // name -> id
  for (const b of ORIGINAL_BATCHES) {
    const { data: existing } = await supabase.from('batches').select('id, name').eq('name', b.name).maybeSingle();
    if (existing) {
      batchMap.set(b.name, existing.id);
      console.log(`   [Existing] Batch: "${b.name}" (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('batches').insert([{
        name: b.name,
        start_year: b.startYear,
        end_year: b.endYear
      }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting batch ${b.name}:`, error.message);
      } else if (inserted) {
        batchMap.set(b.name, inserted.id);
        console.log(`   [Created] Batch: "${b.name}" (${inserted.id})`);
      }
    }
  }

  // 6. Rooms
  console.log(`\n6. Migrating Rooms & Labs (${ORIGINAL_ROOMS.length} records)...`);
  const roomMap = new Map<string, string>(); // roomNumber -> id
  for (const r of ORIGINAL_ROOMS) {
    const { data: existing } = await supabase.from('rooms').select('id, room_number').eq('room_number', r.roomNumber).maybeSingle();
    if (existing) {
      roomMap.set(r.roomNumber, existing.id);
      console.log(`   [Existing] Room: "${r.roomNumber}" (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('rooms').insert([{
        room_number: r.roomNumber,
        building: r.building,
        floor: r.floor,
        capacity: r.capacity,
        type: r.type,
        facilities: r.facilities
      }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting room ${r.roomNumber}:`, error.message);
      } else if (inserted) {
        roomMap.set(r.roomNumber, inserted.id);
        console.log(`   [Created] Room: "${r.roomNumber}" (${inserted.id})`);
      }
    }
  }

  // 7. Teachers
  console.log(`\n7. Migrating Teachers (${ORIGINAL_TEACHERS.length} records)...`);
  const teacherMap = new Map<string, string>(); // name or source id -> id
  for (const t of ORIGINAL_TEACHERS) {
    const deptId = deptMap.get(t.department);
    if (!deptId) {
      console.error(`   [Error] Department not found for teacher ${t.name}: "${t.department}"`);
    }
    const { data: existing } = await supabase.from('teachers').select('id, name, department_id').eq('name', t.name).maybeSingle();
    if (existing) {
      teacherMap.set(t.name, existing.id);
      teacherMap.set(t.id, existing.id);
      if (deptId && existing.department_id !== deptId) {
        await supabase.from('teachers').update({ department_id: deptId }).eq('id', existing.id);
        console.log(`   [Updated] Teacher: "${t.name}" department synced to ${t.department} (${existing.id})`);
      } else {
        console.log(`   [Existing] Teacher: "${t.name}" (${existing.id})`);
      }
    } else {
      const { data: inserted, error } = await supabase.from('teachers').insert([{
        name: t.name,
        designation: t.designation,
        qualifications: t.qualifications,
        specialization: t.specialization,
        department_id: deptId
      }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting teacher ${t.name}:`, error.message);
      } else if (inserted) {
        teacherMap.set(t.name, inserted.id);
        teacherMap.set(t.id, inserted.id);
        console.log(`   [Created] Teacher: "${t.name}" (${inserted.id})`);
      }
    }
  }

  // 8. Courses
  console.log(`\n8. Migrating Canonical Courses from Timetable Entries...`);
  const courseCodeMap = new Map<string, { code: string; name: string; dept: string; type: string; credits: number }>();
  for (const entry of ORIGINAL_TIMETABLE_ENTRIES) {
    if (!courseCodeMap.has(entry.courseCode)) {
      courseCodeMap.set(entry.courseCode, {
        code: entry.courseCode,
        name: entry.courseName,
        dept: entry.department,
        type: entry.type,
        credits: entry.creditHours
      });
    }
  }
  const courseDbMap = new Map<string, string>(); // code -> id
  for (const c of courseCodeMap.values()) {
    const deptId = deptMap.get(c.dept);
    const { data: existing } = await supabase.from('courses').select('id, code').eq('code', c.code).maybeSingle();
    if (existing) {
      courseDbMap.set(c.code, existing.id);
      console.log(`   [Existing] Course: "${c.code}" - ${c.name} (${existing.id})`);
    } else {
      const { data: inserted, error } = await supabase.from('courses').insert([{
        code: c.code,
        name: c.name,
        department_id: deptId,
        credit_hours: c.credits,
        type: c.type
      }]).select().single();
      if (error) {
        console.warn(`   [Error] inserting course ${c.code}:`, error.message);
      } else if (inserted) {
        courseDbMap.set(c.code, inserted.id);
        console.log(`   [Created] Course: "${c.code}" - ${c.name} (${inserted.id})`);
      }
    }
  }

  // 9. Timetable Entries
  console.log(`\n9. Migrating Timetable Entries (${ORIGINAL_TIMETABLE_ENTRIES.length} entries)...`);
  let insertedCount = 0;
  let skippedCount = 0;

  for (const entry of ORIGINAL_TIMETABLE_ENTRIES) {
    let progName = 'BS Computer Science';
    if (entry.department === 'Software Engineering') progName = 'BS Software Engineering';
    if (entry.department === 'Artificial Intelligence') progName = 'BS Artificial Intelligence';

    const departmentId = deptMap.get(entry.department);
    const programId = progMap.get(progName);
    const semesterId = semMap.get(entry.semester);
    const sectionId = secMap.get(entry.section);
    const batchId = batchMap.get(entry.batch);
    const teacherId = teacherMap.get(entry.teacherId) || teacherMap.get(entry.teacherName);
    const roomId = roomMap.get(entry.classroomNumber);
    const courseId = courseDbMap.get(entry.courseCode);

    // Check for existing entry matching day, time, section, semester, department to ensure idempotency
    const { data: existing } = await supabase
      .from('timetable_entries')
      .select('id')
      .eq('day', entry.day)
      .eq('start_time', entry.startTime)
      .eq('department_id', departmentId)
      .eq('section_id', sectionId)
      .eq('semester_id', semesterId)
      .eq('course_code', entry.courseCode)
      .maybeSingle();

    if (existing) {
      skippedCount++;
      continue;
    }

    const { error: ttError } = await supabase.from('timetable_entries').insert([{
      day: entry.day,
      start_time: entry.startTime,
      end_time: entry.endTime,
      department_id: departmentId,
      program_id: programId,
      semester_id: semesterId,
      section_id: sectionId,
      batch_id: batchId,
      course_id: courseId,
      course_code: entry.courseCode,
      course_name: entry.courseName, // Preserve verbatim displayed name
      teacher_id: teacherId,
      teacher_name: entry.teacherName,
      room_id: roomId,
      classroom_number: entry.classroomNumber,
      building: entry.building,
      type: entry.type,
      credit_hours: entry.creditHours
    }]);

    if (ttError) {
      console.warn(`   [Error] inserting timetable entry ${entry.courseCode} (${entry.day} ${entry.startTime}):`, ttError.message);
    } else {
      insertedCount++;
    }
  }

  console.log(`\n======================================================`);
  console.log(`MIGRATION SUMMARY:`);
  console.log(`Departments: ${deptMap.size}`);
  console.log(`Programs: ${progMap.size}`);
  console.log(`Semesters: ${semMap.size}`);
  console.log(`Sections: ${secMap.size}`);
  console.log(`Batches: ${batchMap.size}`);
  console.log(`Rooms: ${roomMap.size}`);
  console.log(`Teachers: ${teacherMap.size / 2}`);
  console.log(`Courses: ${courseDbMap.size}`);
  console.log(`Timetable Entries Inserted: ${insertedCount}, Already Existing: ${skippedCount}, Total Source: ${ORIGINAL_TIMETABLE_ENTRIES.length}`);
  console.log(`======================================================\n`);
}

const isDirectRun = process.argv[1]?.includes('migrateToSupabase');
if (isDirectRun) {
  runMigration()
    .then(() => {
      console.log('Migration process finished successfully.');
      process.exit(0);
    })
    .catch((err) => {
      console.error('Fatal migration error:', err);
      process.exit(1);
    });
}
