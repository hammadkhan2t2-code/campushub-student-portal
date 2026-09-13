import {
  ORIGINAL_TEACHERS,
  ORIGINAL_ROOMS,
  ORIGINAL_TIMETABLE_ENTRIES,
  RawTeacher,
  RawRoom,
  RawTimetableEntry
} from './rawMigrationData';
import {
  DepartmentRecord,
  ProgramRecord,
  SemesterRecord,
  SectionRecord,
  BatchRecord,
  CourseRecord
} from '../types/supabase';
import { Teacher, Room, TimetableEntry, LostFoundItem, DayOfWeek } from '../types';

/**
 * ============================================================================
 * Official CampusHub Peshawar University Academic Dataset
 *
 * Source: Authentic Islamia College / University Dataset
 * Exact Counts:
 * - 3 degree-offering departments
 * - 3 allied departments (Total: 6 departments)
 * - 3 programs (BS Computer Science, BS Software Engineering, BS Artificial Intelligence)
 * - 4 semesters (1st, 3rd, 5th, 7th)
 * - 2 sections (A, B)
 * - 4 batches (Fall 2026 – 2030, Fall 2025 – 2029, Fall 2024 – 2028, Fall 2023 – 2027)
 * - 15 teachers
 * - 16 rooms
 * - 34 course codes
 * - 157 timetable entries
 * - Empty INITIAL_LOST_FOUND dataset (starts with zero items; user-submitted items only)
 * ============================================================================
 */

// 1. DEPARTMENTS (3 degree-offering + 3 allied = 6 departments)
export const DEPARTMENTS: (DepartmentRecord & { code: string; type: 'degree-offering' | 'allied' })[] = [
  { id: 'dept-cs', name: 'Computer Science', code: 'CS', type: 'degree-offering' },
  { id: 'dept-se', name: 'Software Engineering', code: 'SE', type: 'degree-offering' },
  { id: 'dept-ai', name: 'Artificial Intelligence', code: 'AI', type: 'degree-offering' },
  { id: 'dept-math', name: 'Mathematics', code: 'MATH', type: 'allied' },
  { id: 'dept-phys', name: 'Physics', code: 'PHYS', type: 'allied' },
  { id: 'dept-hum', name: 'Humanities', code: 'HUM', type: 'allied' }
];

// 2. DEGREES / PROGRAMS (3 programs)
export const DEGREES: (ProgramRecord & { department: string; code: string })[] = [
  {
    id: 'deg-bscs',
    name: 'BS Computer Science',
    department: 'Computer Science',
    code: 'BSCS',
    short_code: 'BSCS',
    duration_years: 4
  },
  {
    id: 'deg-bsse',
    name: 'BS Software Engineering',
    department: 'Software Engineering',
    code: 'BSSE',
    short_code: 'BSSE',
    duration_years: 4
  },
  {
    id: 'deg-bsai',
    name: 'BS Artificial Intelligence',
    department: 'Artificial Intelligence',
    code: 'BSAI',
    short_code: 'BSAI',
    duration_years: 4
  }
];

// 3. SEMESTERS (4 semesters)
export const SEMESTERS: SemesterRecord[] = [
  { id: 'sem-1', name: '1st', number: 1 },
  { id: 'sem-3', name: '3rd', number: 3 },
  { id: 'sem-5', name: '5th', number: 5 },
  { id: 'sem-7', name: '7th', number: 7 }
];

// 4. SECTIONS (2 sections)
export const SECTIONS: SectionRecord[] = [
  { id: 'sec-a', name: 'A' },
  { id: 'sec-b', name: 'B' }
];

// 5. BATCHES (4 batches)
export const BATCHES: (BatchRecord & { startYear: number; endYear: number })[] = [
  { id: 'batch-2026', name: 'Fall 2026 – 2030', startYear: 2026, endYear: 2030, start_year: 2026, end_year: 2030 },
  { id: 'batch-2025', name: 'Fall 2025 – 2029', startYear: 2025, endYear: 2029, start_year: 2025, end_year: 2029 },
  { id: 'batch-2024', name: 'Fall 2024 – 2028', startYear: 2024, endYear: 2028, start_year: 2024, end_year: 2028 },
  { id: 'batch-2023', name: 'Fall 2023 – 2027', startYear: 2023, endYear: 2027, start_year: 2023, end_year: 2027 }
];

// 6. TEACHERS (15 teachers)
export const TEACHERS: Teacher[] = ORIGINAL_TEACHERS.map((t: RawTeacher): Teacher => ({
  id: t.id,
  name: t.name,
  designation: t.designation,
  department: t.department,
  courses: [...t.courses],
  qualifications: t.qualifications,
  specialization: t.specialization,
  email: `${t.name.toLowerCase().replace(/[^a-z0-9]/g, '.').replace(/\.+/g, '.')}@campushub.edu.pk`,
  office: t.department === 'Computer Science' ? 'Faculty Block A, CS Dept' : 'Allied Sciences Faculty Block',
  officeHours: 'Mon–Thu: 10:00 AM – 12:00 PM | Fri: 09:00 AM – 11:00 AM'
}));

// 7. ROOMS (16 rooms)
export const ROOMS: Room[] = ORIGINAL_ROOMS.map((r: RawRoom): Room => ({
  id: r.id,
  roomNumber: r.roomNumber,
  building: r.building,
  floor: r.floor,
  capacity: r.capacity,
  type: r.type as Room['type'],
  facilities: [...r.facilities]
}));

// Helper to map department to degree name
function getDegreeForDepartment(dept: string): string {
  if (dept === 'Computer Science') return 'BS Computer Science';
  if (dept === 'Software Engineering') return 'BS Software Engineering';
  if (dept === 'Artificial Intelligence') return 'BS Artificial Intelligence';
  return 'BS ' + dept;
}

// 8. TIMETABLE_ENTRIES (157 entries)
export const TIMETABLE_ENTRIES: TimetableEntry[] = ORIGINAL_TIMETABLE_ENTRIES.map(
  (entry: RawTimetableEntry): TimetableEntry => ({
    id: entry.id,
    day: entry.day as DayOfWeek,
    courseName: entry.courseName,
    courseCode: entry.courseCode,
    teacherName: entry.teacherName,
    teacherId: entry.teacherId,
    classroomNumber: entry.classroomNumber,
    building: entry.building,
    startTime: entry.startTime,
    endTime: entry.endTime,
    department: entry.department,
    degree: getDegreeForDepartment(entry.department),
    semester: entry.semester,
    section: entry.section,
    batch: entry.batch,
    type: entry.type as 'Lecture' | 'Lab' | 'Tutorial',
    creditHours: entry.creditHours
  })
);

// Derived 34 unique courses
export const COURSES: CourseRecord[] = Array.from(
  ORIGINAL_TIMETABLE_ENTRIES.reduce((map, entry) => {
    if (!map.has(entry.courseCode)) {
      map.set(entry.courseCode, {
        id: `crs-${entry.courseCode.toLowerCase().replace(/[^a-z0-9]/g, '-')}`,
        name: entry.courseName,
        code: entry.courseCode,
        credit_hours: entry.creditHours,
        type: entry.type
      });
    }
    return map;
  }, new Map<string, CourseRecord>()).values()
);

// 9. INITIAL_LOST_FOUND (Empty dataset; starts with zero items)
export const INITIAL_LOST_FOUND: LostFoundItem[] = [];
