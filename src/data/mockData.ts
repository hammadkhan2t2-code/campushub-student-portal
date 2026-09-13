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
 * - Authentic INITIAL_LOST_FOUND items
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

// 9. INITIAL_LOST_FOUND
export const INITIAL_LOST_FOUND: LostFoundItem[] = [
  {
    id: 'lf-casio-1',
    type: 'lost',
    itemName: 'Casio fx-991EX Scientific Calculator',
    category: 'Electronics',
    description: 'Casio fx-991EX ClassWiz calculator in black casing left on the second row desk in Lab 3.',
    location: 'CS Computing Laboratories, Lab 3',
    room: 'Lab 3',
    date: '2026-09-10',
    approximateTime: '10:30 AM',
    contactMethod: 'Contact Your CR',
    status: 'Lost',
    reportedBy: 'Hamza Khan',
    reportedByEmail: 'student@campushub.edu.pk',
    reportedAt: '2026-09-10T10:35:00.000Z'
  },
  {
    id: 'lf-wallet-2',
    type: 'found',
    itemName: 'Leather Wallet with University ID Card',
    category: 'Keys & Wallets',
    description: 'Brown leather wallet containing university student card and library card deposited with CR.',
    location: 'CS Academic Block, Room 3',
    room: 'Room 3',
    date: '2026-09-11',
    approximateTime: '12:15 PM',
    contactMethod: 'Contact Your CR',
    status: 'Found',
    reportedBy: 'Muhammad Bilal',
    reportedByEmail: 'student@campushub.edu.pk',
    reportedAt: '2026-09-11T12:20:00.000Z'
  },
  {
    id: 'lf-usb-3',
    type: 'found',
    itemName: 'HP 64GB USB 3.0 Flash Drive',
    category: 'Electronics',
    description: 'Silver metal HP USB flash drive found plugged into workstation #14 in Lab 1.',
    location: 'CS Computing Laboratories, Lab 1',
    room: 'Lab 1',
    date: '2026-09-12',
    approximateTime: '02:00 PM',
    contactMethod: 'Contact Your CR',
    status: 'Found',
    reportedBy: 'Zainab Bibi',
    reportedByEmail: 'student@campushub.edu.pk',
    reportedAt: '2026-09-12T14:05:00.000Z'
  },
  {
    id: 'lf-textbook-4',
    type: 'lost',
    itemName: 'Data Structures & Algorithms Textbook',
    category: 'Books & Stationery',
    description: 'Hardcover textbook with handwritten lecture notes and green bookmark in Room 5.',
    location: 'CS Academic Block, Room 5',
    room: 'Room 5',
    date: '2026-09-12',
    approximateTime: '11:45 AM',
    contactMethod: 'Contact Your CR',
    status: 'Lost',
    reportedBy: 'Usman Ali',
    reportedByEmail: 'student@campushub.edu.pk',
    reportedAt: '2026-09-12T11:50:00.000Z'
  },
  {
    id: 'lf-card-5',
    type: 'found',
    itemName: 'Campus Student ID Card (BSCS)',
    category: 'IDs & Cards',
    description: 'Official university student smart card handed back to owner upon verification.',
    location: 'CS Academic Block, Room 1',
    room: 'Room 1',
    date: '2026-09-08',
    approximateTime: '09:00 AM',
    contactMethod: 'Contact Your CR',
    status: 'Claimed',
    reportedBy: 'Class Representative',
    reportedByEmail: 'student@campushub.edu.pk',
    reportedAt: '2026-09-08T09:15:00.000Z',
    claimRecord: {
      claimedBy: 'Ahmad Shah',
      claimedByRoll: '25-CS-18',
      claimedByEmail: 'student@campushub.edu.pk',
      claimNote: 'Verified identity and roll number with student card copy.',
      contact: 'Contact Your CR',
      claimedAt: '2026-09-09T10:00:00.000Z'
    }
  }
];
