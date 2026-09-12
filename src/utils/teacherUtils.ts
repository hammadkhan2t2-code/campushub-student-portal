import { Teacher, TimetableEntry, DayOfWeek } from '../types';

export const UNIVERSITY_OPERATING_HOURS = {
  monThu: '8:00 AM – 4:00 PM',
  fri: '8:00 AM – 3:00 PM',
  label: 'Mon–Thu: 8:00 AM – 4:00 PM | Fri: 8:00 AM – 3:00 PM'
};

/**
 * Returns operating hours for a specific day of the week.
 */
export function getUniversityHoursForDay(day: DayOfWeek): string {
  if (day === 'Friday') {
    return UNIVERSITY_OPERATING_HOURS.fri;
  }
  return UNIVERSITY_OPERATING_HOURS.monThu;
}

/**
 * Retrieves all actual scheduled teaching classes for a teacher from the real timetable data.
 */
export function getTeacherClasses(
  timetable: TimetableEntry[],
  teacher: Teacher | { id: string; name: string }
): TimetableEntry[] {
  const teacherNameLower = teacher.name.toLowerCase().trim();
  return timetable.filter((entry) => {
    if (entry.teacherId && teacher.id && entry.teacherId === teacher.id) {
      return true;
    }
    const entryTeacherLower = entry.teacherName.toLowerCase().trim();
    if (entryTeacherLower === teacherNameLower) {
      return true;
    }
    // Handle combined lab entries e.g. "Dr. Tauseef-ur-Rehman / Mr. Salahuddin"
    if (entryTeacherLower.includes(teacherNameLower) || teacherNameLower.includes(entryTeacherLower)) {
      return true;
    }
    return false;
  });
}

/**
 * Retrieves scheduled teaching sessions for a teacher on a specific day.
 */
export function getTeacherClassesForDay(
  timetable: TimetableEntry[],
  teacher: Teacher | { id: string; name: string },
  day: DayOfWeek
): TimetableEntry[] {
  return getTeacherClasses(timetable, teacher).filter((entry) => entry.day === day);
}

/**
 * Formats a teacher's actual teaching times for a specific day.
 * e.g., "08:00 AM – 10:00 AM, 11:00 AM – 12:00 PM"
 */
export function getTeacherTeachingTimesSummary(
  classes: TimetableEntry[]
): string {
  if (classes.length === 0) {
    return 'No lectures scheduled (Available for faculty duties & student consultation)';
  }
  return classes
    .map((c) => `${c.startTime} – ${c.endTime} (${c.courseName})`)
    .join(', ');
}
