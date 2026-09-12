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

/**
 * Parses time strings such as "08:00 AM", "1:30 PM", "12:00 PM" into total minutes from midnight.
 */
export function parseTimeToMinutes(timeStr: string | undefined | null): number {
  if (!timeStr) return 0;
  const match = timeStr.trim().match(/^(\d{1,2}):(\d{2})\s*(AM|PM)?$/i);
  if (!match) return 0;
  let hours = parseInt(match[1], 10);
  const minutes = parseInt(match[2], 10);
  const meridiem = match[3]?.toUpperCase();

  if (meridiem === 'PM' && hours < 12) {
    hours += 12;
  } else if (meridiem === 'AM' && hours === 12) {
    hours = 0;
  }
  return hours * 60 + minutes;
}

export const ACADEMIC_WORKING_DAYS: DayOfWeek[] = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday'
];

export interface PeshawarDateTimeInfo {
  date: Date;
  weekday: string; // 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday' | 'Saturday' | 'Sunday'
  currentMinutes: number; // 0 to 1439
  isWeekend: boolean;
  isWorkingDay: boolean;
  formattedDate: string;
}

/**
 * Computes the current date, time, weekday, and weekend status in the Pakistan/Peshawar timezone.
 */
export function getPeshawarDateTime(refDate: Date = new Date()): PeshawarDateTimeInfo {
  try {
    const dtf = new Intl.DateTimeFormat('en-US', {
      timeZone: 'Asia/Karachi',
      weekday: 'long',
      year: 'numeric',
      month: 'numeric',
      day: 'numeric',
      hour: 'numeric',
      minute: 'numeric',
      hour12: false
    });

    const parts = dtf.formatToParts(refDate);
    const map: Record<string, string> = {};
    for (const part of parts) {
      map[part.type] = part.value;
    }

    const weekday = map.weekday || 'Monday';
    let hour = parseInt(map.hour, 10) || 0;
    if (hour === 24) hour = 0;
    const minute = parseInt(map.minute, 10) || 0;
    const currentMinutes = hour * 60 + minute;

    const isWeekend = weekday === 'Saturday' || weekday === 'Sunday';
    const isWorkingDay = !isWeekend && ACADEMIC_WORKING_DAYS.includes(weekday as DayOfWeek);

    const displayFormatter = new Intl.DateTimeFormat('en-PK', {
      timeZone: 'Asia/Karachi',
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    });
    const formattedDate = displayFormatter.format(refDate);

    return {
      date: refDate,
      weekday,
      currentMinutes,
      isWeekend,
      isWorkingDay,
      formattedDate
    };
  } catch (err) {
    // Resilient fallback to local system time if Intl fails
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const weekday = days[refDate.getDay()];
    const isWeekend = weekday === 'Sunday' || weekday === 'Saturday';
    const currentMinutes = refDate.getHours() * 60 + refDate.getMinutes();
    return {
      date: refDate,
      weekday,
      currentMinutes,
      isWeekend,
      isWorkingDay: !isWeekend,
      formattedDate: refDate.toLocaleDateString('en-PK', {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
        year: 'numeric'
      })
    };
  }
}

export interface NextUpcomingClassInfo {
  entry: TimetableEntry;
  dayLabel: string;
  startsLabel: string; // e.g. "Starts Monday at 08:00 AM", "Starts at 08:30 AM"
  isToday: boolean;
}

/**
 * Determines the next scheduled class for the student:
 * - On a weekday (Monday-Friday): looks for remaining classes today based on current time.
 *   If no remaining classes today, searches forward through subsequent working days.
 * - On Saturday or Sunday: searches forward starting from Monday through Friday.
 * - If a working day has no classes, continues searching until the next scheduled class is found.
 */
export function getNextUpcomingClass(
  enrolledClasses: TimetableEntry[],
  currentWeekday: string,
  currentMinutes: number
): NextUpcomingClassInfo | null {
  if (!enrolledClasses || enrolledClasses.length === 0) {
    return null;
  }

  const isWorking = ACADEMIC_WORKING_DAYS.includes(currentWeekday as DayOfWeek);

  if (isWorking) {
    const todayClasses = enrolledClasses
      .filter((c) => c.day === currentWeekday)
      .sort((a, b) => parseTimeToMinutes(a.startTime) - parseTimeToMinutes(b.startTime));

    // Look for classes today that haven't ended yet
    const remainingToday = todayClasses.filter(
      (c) => parseTimeToMinutes(c.endTime) > currentMinutes
    );

    if (remainingToday.length > 0) {
      const target = remainingToday[0];
      const hasStarted = parseTimeToMinutes(target.startTime) <= currentMinutes;
      return {
        entry: target,
        dayLabel: currentWeekday,
        startsLabel: hasStarted
          ? `In progress (ends at ${target.endTime})`
          : `Starts at ${target.startTime}`,
        isToday: true
      };
    }

    // No remaining classes today: search forward through the remaining days of the week (wrap-around)
    const currentIdx = ACADEMIC_WORKING_DAYS.indexOf(currentWeekday as DayOfWeek);
    for (let i = 1; i <= 5; i++) {
      const nextDay = ACADEMIC_WORKING_DAYS[(currentIdx + i) % 5];
      const dayClasses = enrolledClasses
        .filter((c) => c.day === nextDay)
        .sort((a, b) => parseTimeToMinutes(a.startTime) - parseTimeToMinutes(b.startTime));

      if (dayClasses.length > 0) {
        return {
          entry: dayClasses[0],
          dayLabel: nextDay,
          startsLabel: `Starts ${nextDay} at ${dayClasses[0].startTime}`,
          isToday: false
        };
      }
    }
  } else {
    // Saturday or Sunday: look ahead starting from Monday
    for (const day of ACADEMIC_WORKING_DAYS) {
      const dayClasses = enrolledClasses
        .filter((c) => c.day === day)
        .sort((a, b) => parseTimeToMinutes(a.startTime) - parseTimeToMinutes(b.startTime));

      if (dayClasses.length > 0) {
        return {
          entry: dayClasses[0],
          dayLabel: day,
          startsLabel: `Starts ${day} at ${dayClasses[0].startTime}`,
          isToday: false
        };
      }
    }
  }

  return null;
}

