import { TimetableEntry, User, DayOfWeek } from '../types';

/**
 * Normalizes a semester string to a comparable digit or clean lowercase token.
 * Examples:
 * - "3rd" -> "3"
 * - "Semester 3" -> "3"
 * - "3rd Semester" -> "3"
 * - "3" -> "3"
 * - "1st" -> "1"
 * - "5th" -> "5"
 * - "7th" -> "7"
 */
export function normalizeSemester(sem: string | undefined | null): string {
  if (!sem) return '';
  const cleaned = sem.toString().toLowerCase().trim();
  // Extract digits first if present (e.g. "3rd" -> "3", "Semester 3" -> "3")
  const digitMatch = cleaned.match(/\d+/);
  if (digitMatch) {
    return digitMatch[0];
  }
  return cleaned.replace(/(st|nd|rd|th|semester|\s)/gi, '').trim();
}

/**
 * Normalizes admission batch string.
 * Handles differences in en-dash (–), em-dash (—), hyphen (-), and whitespace.
 * Examples:
 * - "Fall 2025 – 2029" -> "fall 2025-2029"
 * - "Fall 2025-2029" -> "fall 2025-2029"
 */
export function normalizeBatch(batch: string | undefined | null): string {
  if (!batch) return '';
  return batch
    .toString()
    .toLowerCase()
    .replace(/[\u2013\u2014\-]/g, '-')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Normalizes section string (e.g., "A", "b" -> "A", "B").
 */
export function normalizeSection(sec: string | undefined | null): string {
  if (!sec) return '';
  return sec.toString().trim().toUpperCase();
}

/**
 * Normalizes department or program string for resilient comparison.
 */
export function normalizeDept(text: string | undefined | null): string {
  if (!text) return '';
  return text.toString().toLowerCase().replace(/[^a-z0-9]/g, '');
}

/**
 * Checks if a timetable entry matches the student's saved academic profile.
 * Validates against:
 * 1. Department & Program / Degree
 * 2. Semester
 * 3. Section
 * 4. Admission Batch
 */
export function isMatchingStudentSchedule(
  entry: TimetableEntry,
  user: User | null | undefined
): boolean {
  if (!user) return false;

  // 1. Semester matching (e.g., "3rd" matches "3" or "3rd")
  const entrySem = normalizeSemester(entry.semester);
  const userSem = normalizeSemester(user.semester);
  if (entrySem && userSem && entrySem !== userSem) {
    return false;
  }

  // 2. Section matching (Strict: Section A vs Section B)
  const entrySec = normalizeSection(entry.section);
  const userSec = normalizeSection(user.section);
  if (entrySec && userSec && entrySec !== userSec) {
    return false;
  }

  // 3. Department / Degree / Program matching
  const entryDeptNorm = normalizeDept(entry.department);
  const userDeptNorm = normalizeDept(user.department);
  const userDegreeNorm = normalizeDept(user.degree);

  const progOrDegree = (entry as unknown as { program?: string; degree?: string }).program || 
                       (entry as unknown as { program?: string; degree?: string }).degree;
  const entryProgNorm = progOrDegree ? normalizeDept(progOrDegree) : '';

  const deptOrProgMatches =
    (entryDeptNorm && userDeptNorm && (entryDeptNorm === userDeptNorm || userDegreeNorm.includes(entryDeptNorm))) ||
    (entryProgNorm && (entryProgNorm === userDegreeNorm || userDegreeNorm.includes(entryProgNorm)));

  if (!deptOrProgMatches && entryDeptNorm && userDeptNorm) {
    return false;
  }

  // 4. Batch matching (e.g., "Fall 2025 – 2029")
  if (entry.batch && user.admissionBatch) {
    const entryBatchNorm = normalizeBatch(entry.batch);
    const userBatchNorm = normalizeBatch(user.admissionBatch);

    // Direct match or normalized match
    if (entryBatchNorm !== userBatchNorm) {
      // Check year overlap (e.g. 2025 in both)
      const entryYears: string[] = entry.batch.match(/\d{4}/g) || [];
      const userYears: string[] = user.admissionBatch.match(/\d{4}/g) || [];
      const hasSharedYear = entryYears.length > 0 && userYears.length > 0 &&
        entryYears.some((y: string) => userYears.includes(y));

      if (!hasSharedYear) {
        return false;
      }
    }
  }

  return true;
}

/**
 * Retrieves all classes matching the student's saved academic profile.
 */
export function getStudentEnrolledClasses(
  timetable: TimetableEntry[],
  user: User | null | undefined
): TimetableEntry[] {
  if (!user) return [];
  return timetable.filter((entry) => isMatchingStudentSchedule(entry, user));
}

/**
 * Groups student enrolled classes by weekday.
 */
export function getStudentWeeklySchedule(
  timetable: TimetableEntry[],
  user: User | null | undefined
): Record<DayOfWeek, TimetableEntry[]> {
  const enrolled = getStudentEnrolledClasses(timetable, user);
  return {
    Monday: enrolled.filter((e) => e.day === 'Monday'),
    Tuesday: enrolled.filter((e) => e.day === 'Tuesday'),
    Wednesday: enrolled.filter((e) => e.day === 'Wednesday'),
    Thursday: enrolled.filter((e) => e.day === 'Thursday'),
    Friday: enrolled.filter((e) => e.day === 'Friday')
  };
}

/**
 * Returns the exact read-only informational context header string as requested:
 * "BS Computer Science · Semester 3 · Section A · Fall 2025–2029"
 */
export function formatStudentAcademicContext(user: User | null | undefined): string {
  if (!user) return '';
  const degree = user.degree || user.department || 'BS Computer Science';
  const sem = user.semester?.toString().replace(/(st|nd|rd|th)/gi, '') || '3';
  const sec = user.section || 'A';
  const batch = user.admissionBatch || 'Fall 2025–2029';
  return `${degree} · Semester ${sem} · Section ${sec} · ${batch}`;
}
