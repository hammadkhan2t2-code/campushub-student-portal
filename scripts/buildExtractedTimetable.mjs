// Comprehensive extraction of 20-page Departmental Time Table (1).pdf
// Islamia College Peshawar - Department of Computer Science
import fs from 'fs';

const pagesData = [
  // ==========================================
  // PAGE 1: BS Computer Science Section A 1st Semester
  // ==========================================
  {
    page: 1,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '1st',
    section: 'A',
    batch: 'Fall 2026 – 2030',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming Fundamentals Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'ICT Lab', group: 'G2', room: 'Lab 4', teacher: 'Mr. Salahuddin', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'ICT', group: null, room: 'Room 3', teacher: 'Mr. Salahuddin', type: 'Lecture', creditHours: 2 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 1', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math - I', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming Fundamentals Lab', group: 'G2', room: 'Lab 4', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'ICT Lab', group: 'G1', room: 'Lab 3', teacher: 'Mr. Salahuddin', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'ICT', group: null, room: 'Room 3', teacher: 'Mr. Salahuddin', type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 1', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math - I', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Functional English', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 1', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math - I', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Functional English', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Islamic Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Pakistan Studies', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Holy Quran', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Functional English', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Islamic Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Pakistan Studies', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Holy Quran', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 1 }
    ]
  },

  // ==========================================
  // PAGE 2: BS Computer Science Section B 1st Semester
  // ==========================================
  {
    page: 2,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '1st',
    section: 'B',
    batch: 'Fall 2026 – 2030',
    entries: [
      // Monday
      { day: 'Monday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Functional English', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Holy Quran', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Pakistan Studies', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 4', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math-I', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Functional English', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Holy Quran', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Pakistan Studies', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 4', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math-I', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming Fundamentals Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'ICT Lab', group: 'G2', room: 'Lab 4', teacher: 'Mr. Salahuddin', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'ICT', group: null, room: 'Room 3', teacher: 'Mr. Salahuddin', type: 'Lecture', creditHours: 2 },
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 4', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math-I', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming Fundamentals Lab', group: 'G2', room: 'Lab 4', teacher: 'Dr. Tauseef-ur-Rehman', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'ICT Lab', group: 'G1', room: 'Lab 3', teacher: 'Mr. Salahuddin', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'ICT', group: null, room: 'Room 3', teacher: 'Mr. Salahuddin', type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Islamic Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Functional English', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Islamic Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 }
    ]
  },

  // ==========================================
  // PAGE 3: BS Software Engineering Section A 1st Semester
  // ==========================================
  {
    page: 3,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '1st',
    section: 'A',
    batch: 'Fall 2026 – 2030',
    entries: [
      // Monday
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Pakistan Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming', group: null, room: 'Room 1', teacher: 'Dr. Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Basic Math-1', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Programming Lab', group: 'G1', room: 'Lab 6', teacher: 'Dr. Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'ICT Lab', group: 'G2', room: 'Lab 5', teacher: 'Dr. Naveed Abbas', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'ICT', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Pakistan Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming', group: null, room: 'Room 1', teacher: 'Dr. Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Basic Math-1', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Programming Lab', group: 'G2', room: 'Lab 6', teacher: 'Dr. Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'ICT Lab', group: 'G1', room: 'Lab 5', teacher: 'Dr. Naveed Abbas', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'ICT', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 2 },
      { day: 'Wednesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Functional English', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Basic Math-1', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Holy Quran', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Physics', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Islamic Studies', group: null, room: 'Room Unspecified', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Functional English', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Programming', group: null, room: 'Room 1', teacher: 'Dr. Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Holy Quran', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Physics', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Islamic Studies', group: null, room: 'Room 4', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Programming', group: null, room: 'Room Unspecified', teacher: 'Dr. Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Functional English', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Programming', group: null, room: 'Room 1', teacher: 'Dr. Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Physics', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 4: BS Software Engineering Section B 1st Semester
  // ==========================================
  {
    page: 4,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '1st',
    section: 'B',
    batch: 'Fall 2026 – 2030',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Physics', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Holy Quran', group: null, room: 'Room Unspecified', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Basic Math-1', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Pakistan Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Physics', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Functional English', group: null, room: 'Room Unspecified', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Holy Quran', group: null, room: 'Room Unspecified', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Basic Math-1', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Pakistan Studies', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Physics', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Functional English', group: null, room: 'Room Unspecified', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming', group: null, room: 'Room 4', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Basic Math-1', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '04:00 PM', course: 'Programming Lab', group: 'G1', room: 'Lab 6', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '04:00 PM', course: 'ICT Lab', group: 'G2', room: 'Lab 5', teacher: 'Dr. Naveed Abbas', type: 'Lab', creditHours: 1 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'ICT', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Functional English', group: null, room: 'Room Unspecified', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming', group: null, room: 'Room 4', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Islamic Studies', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '04:00 PM', course: 'Programming Lab', group: 'G2', room: 'Lab 6', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '04:00 PM', course: 'ICT Lab', group: 'G1', room: 'Lab 5', teacher: 'Dr. Naveed Abbas', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'ICT', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming', group: null, room: 'Room 4', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Islamic Studies', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 }
    ]
  },

  // ==========================================
  // PAGE 5: BS Artificial Intelligence 1st Semester
  // ==========================================
  {
    page: 5,
    department: 'Artificial Intelligence',
    program: 'BS Artificial Intelligence',
    programCode: 'BSAI',
    semester: '1st',
    section: 'A', // Unsectioned cohort mapped cleanly
    batch: 'Fall 2026 – 2030',
    entries: [
      // Monday
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Holy Quran', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Monday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Pak Studies', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math 1', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '05:00 PM', endTime: '08:00 PM', course: 'Programming Fundamentals Lab', group: 'G1', room: 'Lab 4', teacher: 'Dr. Naveed Abbas', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '05:00 PM', endTime: '08:00 PM', course: 'ICT Lab', group: 'G2', room: 'Lab 1', teacher: 'Mr. Salahuddin', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Holy Quran', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 1 },
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Pak Studies', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math 1', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '05:00 PM', endTime: '08:00 PM', course: 'Programming Fundamentals Lab', group: 'G2', room: 'Lab 4', teacher: 'Dr. Naveed Abbas', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '05:00 PM', endTime: '08:00 PM', course: 'ICT Lab', group: 'G1', room: 'Lab 1', teacher: 'Mr. Salahuddin', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Islamic Studies', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Physics', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Functional English', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Basic Math 1', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'ICT', group: null, room: 'Room 1', teacher: 'Mr. Salahuddin', type: 'Lecture', creditHours: 2 },
      // Thursday
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Islamic Studies', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Functional English', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'ICT', group: null, room: 'Room 1', teacher: 'Mr. Salahuddin', type: 'Lecture', creditHours: 2 },
      // Friday
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Functional English', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Programming Fundamentals', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 6: BS Computer Science Section A 3rd Semester
  // ==========================================
  {
    page: 6,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '3rd',
    section: 'A',
    batch: 'Fall 2025 – 2029',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Database Systems Lab', group: 'G1', room: 'Lab 2', teacher: 'Dr. Atif Khan', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Data Structures', group: null, room: 'Room 1', teacher: 'Dr. Muhammad Waseem', type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Database Systems Lab', group: 'G1', room: 'Lab 2', teacher: 'Dr. Atif Khan', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Data Structures', group: null, room: 'Room 1', teacher: 'Dr. Muhammad Waseem', type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Data Structures Lab', group: 'G1', room: 'Lab 4', teacher: 'Dr. Muhammad Waseem', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Software Engineering', group: null, room: 'Room 5', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Data Structures', group: null, room: 'Room 1', teacher: 'Dr. Muhammad Waseem', type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Data Structures Lab', group: 'G2', room: 'Lab 4', teacher: 'Dr. Muhammad Waseem', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Software Engineering', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Civics & Community Engagement', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Civics & Community Engagement', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Professional Practice', group: null, room: 'Room 5', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Professional Practice', group: null, room: 'Room 5', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Software Engineering', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 7: BS Computer Science Section B 3rd Semester
  // ==========================================
  {
    page: 7,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '3rd',
    section: 'B',
    batch: 'Fall 2025 – 2029',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Data Structures', group: null, room: 'Room 4', teacher: 'Dr. Muhammad Waseem', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Engineering', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '03:00 PM', course: 'Data Structures Lab', group: 'G1', room: 'Lab 1', teacher: 'Dr. Muhammad Waseem', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Data Structures', group: null, room: 'Room 4', teacher: 'Dr. Muhammad Waseem', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Data Structures', group: null, room: 'Room 4', teacher: 'Dr. Muhammad Waseem', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Engineering', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '03:00 PM', course: 'Data Structures Lab', group: 'G2', room: 'Lab 1', teacher: 'Dr. Muhammad Waseem', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Database Systems Lab', group: 'G1', room: 'Lab 2', teacher: 'Dr. Atif Khan', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Database Systems', group: null, room: 'Room 4', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Professional Practice', group: null, room: 'Stats Deptt', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Database Systems Lab', group: 'G2', room: 'Lab 2', teacher: 'Dr. Atif Khan', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Database Systems', group: null, room: 'Room 1', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Software Engineering', group: null, room: 'Room 1', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Professional Practice', group: null, room: 'Stats Deptt', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Civics & Community Engagement', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 },
      // Friday
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Database Systems', group: null, room: 'Room 1', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Civics & Community Engagement', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 2 }
    ]
  },

  // ==========================================
  // PAGE 8: BS Software Engineering Section A 3rd Semester
  // ==========================================
  {
    page: 8,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '3rd',
    section: 'A',
    batch: 'Fall 2025 – 2029',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Database Systems', group: null, room: 'Room 3', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Software Engineering', group: null, room: 'Room 3', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Civics & Community Engagement', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Data Structures', group: null, room: 'Room 1', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Database Systems Lab', group: 'G1', room: 'Lab 2', teacher: 'Dr. Shaukat Ali', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Database Systems', group: null, room: 'Room 3', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Software Engineering', group: null, room: 'Room 3', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Civics & Community Engagement', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Data Structures', group: null, room: 'Room 1', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Database Systems Lab', group: 'G2', room: 'Lab 2', teacher: 'Dr. Shaukat Ali', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Software Engineering', group: null, room: 'Room 3', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Data Structures', group: null, room: 'Room 1', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Data Structures Lab', group: 'G1', room: 'Lab 2', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      // Thursday
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Professional Practice', group: null, room: 'Stats Deptt', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Data Structures Lab', group: 'G2', room: 'Lab 2', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Professional Practice', group: null, room: 'Stats Deptt', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 }
    ]
  },

  // ==========================================
  // PAGE 9: BS Software Engineering Section B 3rd Semester
  // ==========================================
  {
    page: 9,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '3rd',
    section: 'B',
    batch: 'Fall 2025 – 2029',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Engineering', group: null, room: 'Room 5', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Data Structures Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Engineering', group: null, room: 'Room 5', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Data Structures Lab', group: 'G2', room: 'Lab 3', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Database Systems', group: null, room: 'Room 5', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Engineering', group: null, room: 'Room 5', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Civics & Community Engagement', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Database Systems Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Shaukat Ali', type: 'Lab', creditHours: 1 },
      // Thursday
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Civics & Community Engagement', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Professional Practice', group: null, room: 'Stats Deptt', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Data Structures', group: null, room: 'Room 5', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Database Systems Lab', group: 'G2', room: 'Lab 3', teacher: 'Dr. Shaukat Ali', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Professional Practice', group: null, room: 'Stats Deptt', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Data Structures', group: null, room: 'Room 5', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Data Structures', group: null, room: 'Room 5', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 10: BS Artificial Intelligence 3rd Semester
  // ==========================================
  {
    page: 10,
    department: 'Artificial Intelligence',
    program: 'BS Artificial Intelligence',
    programCode: 'BSAI',
    semester: '3rd',
    section: 'A',
    batch: 'Fall 2025 – 2029',
    entries: [
      // Monday
      { day: 'Monday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Civics & Community Engagement', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Software Engineering', group: null, room: 'Room 2', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Database Systems', group: null, room: 'Room 2', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '06:00 PM', endTime: '09:00 PM', course: 'Database Systems Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Bilal', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Civics & Community Engagement', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 2 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Software Engineering', group: null, room: 'Room 2', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Database Systems', group: null, room: 'Room 2', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '06:00 PM', endTime: '09:00 PM', course: 'Database Systems Lab', group: 'G2', room: 'Lab 3', teacher: 'Dr. Bilal', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Calculus & Analytical Geometry', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Software Engineering', group: null, room: 'Room 2', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Database Systems', group: null, room: 'Room 2', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '06:00 PM', endTime: '09:00 PM', course: 'Data Structures Lab', group: 'G1', room: 'Lab 1', teacher: 'Dr. Bilal', type: 'Lab', creditHours: 1 },
      // Thursday
      { day: 'Thursday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Professional Practice', group: null, room: 'Room 2', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 2 },
      { day: 'Thursday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Data Structures', group: null, room: 'Room 2', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '06:00 PM', endTime: '09:00 PM', course: 'Data Structures Lab', group: 'G2', room: 'Lab 1', teacher: 'Dr. Bilal', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Professional Practice', group: null, room: 'Room 2', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 2 },
      { day: 'Friday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Data Structures', group: null, room: 'Room 2', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '06:00 PM', endTime: '07:00 PM', course: 'Data Structures', group: null, room: 'Room 2', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 11: BS Computer Science Section A 5th Semester
  // ==========================================
  {
    page: 11,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '5th',
    section: 'A',
    batch: 'Fall 2024 – 2028',
    entries: [
      // Monday
      { day: 'Monday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Assembly Language Lab', group: 'G1', room: 'Lab 4', teacher: 'Mr. Faisal Saeed', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Assembly Language', group: null, room: 'Room 5', teacher: 'Mr. Faisal Saeed', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Web Technologies', group: null, room: 'Room 4', teacher: 'Dr. Mansoor Nasir', type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Assembly Language Lab', group: 'G2', room: 'Lab 4', teacher: 'Mr. Faisal Saeed', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Assembly Language', group: null, room: 'Room 5', teacher: 'Mr. Faisal Saeed', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Web Technologies', group: null, room: 'Room 4', teacher: 'Dr. Mansoor Nasir', type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Theory of Automata', group: null, room: 'Room 1', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Theory of Automata', group: null, room: 'Room 1', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Theory of Automata', group: null, room: 'Room 1', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Computer Networks', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Networks Lab', group: 'G1', room: 'Lab 1', teacher: 'Dr. Khalid Haseeb', type: 'Lab', creditHours: 1 },
      { day: 'Friday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Web Technologies Lab', group: 'G2', room: 'Lab 2', teacher: 'Dr. Mansoor Nasir', type: 'Lab', creditHours: 1 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G2', room: 'Lab 2', teacher: 'Dr. Khalid Haseeb', type: 'Lab', creditHours: 1 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Web Technologies Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Mansoor Nasir', type: 'Lab', creditHours: 1 },
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Computer Networks', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 12: BS Computer Science Section B 5th Semester
  // ==========================================
  {
    page: 12,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '5th',
    section: 'B',
    batch: 'Fall 2024 – 2028',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Multivariate Calculus', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Web Technologies', group: null, room: 'Room 4', teacher: 'Dr. Mansoor Nasir', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G1', room: 'Lab 6', teacher: 'Dr. Khalid Haseeb', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Assembly Language', group: null, room: 'Room 3', teacher: 'Mr. Faisal Saeed', type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Multivariate Calculus', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G2', room: 'Lab 6', teacher: 'Dr. Khalid Haseeb', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Assembly Language', group: null, room: 'Room 3', teacher: 'Mr. Faisal Saeed', type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Multivariate Calculus', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Computer Networks', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Assembly Language Lab', group: 'G1', room: 'Lab 4', teacher: 'Mr. Faisal Saeed', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Web Technologies Lab', group: 'G1', room: 'Lab 6', teacher: 'Dr. Mansoor Nasir', type: 'Lab', creditHours: 1 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Theory of Automata', group: null, room: 'Room 6', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Web Technologies', group: null, room: 'Room 3', teacher: 'Dr. Mansoor Nasir', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Computer Networks', group: null, room: 'Room 4', teacher: 'Dr. Khalid Haseeb', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Assembly Language Lab', group: 'G2', room: 'Lab 4', teacher: 'Mr. Faisal Saeed', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '05:00 PM', course: 'Web Technologies Lab', group: 'G2', room: 'Lab 6', teacher: 'Dr. Mansoor Nasir', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Theory of Automata', group: null, room: 'Room 6', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Theory of Automata', group: null, room: 'Room 1', teacher: 'Dr. Shaukat Ali', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 13: BS Software Engineering Section A 5th Semester
  // ==========================================
  {
    page: 13,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '5th',
    section: 'A',
    batch: 'Fall 2024 – 2028',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Software Design & Architecture Lab', group: 'G1', room: 'Lab 5', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Organization & Assembly Language Lab', group: 'G2', room: 'Lab 6', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G1', room: 'Lab 3', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Computer Networks', group: null, room: 'Room 1', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Software Design & Architecture Lab', group: 'G2', room: 'Lab 5', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Organization & Assembly Language Lab', group: 'G1', room: 'Lab 6', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G2', room: 'Lab 3', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Computer Networks', group: null, room: 'Room 1', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 2', teacher: null, type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Web Technologies', group: null, room: 'Room 4', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Web Technologies Lab', group: 'G1', room: 'Lab 2', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Software Design & Architecture', group: null, room: 'Room 1', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Computer Organization & Assembly Language', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Web Technologies', group: null, room: 'Room 4', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Computer Organization & Assembly Language', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Web Technologies Lab', group: 'G2', room: 'Lab 2', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Software Design & Architecture', group: null, room: 'Room 1', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 }
      // Friday - empty (0 entries)
    ]
  },

  // ==========================================
  // PAGE 14: BS Software Engineering Section B 5th Semester
  // ==========================================
  {
    page: 14,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '5th',
    section: 'B',
    batch: 'Fall 2024 – 2028',
    entries: [
      // Monday
      { day: 'Monday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Web Technologies Lab', group: 'G1', room: 'Lab 2', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Web Technologies Lab', group: 'G2', room: 'Lab 2', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 8', teacher: null, type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Software Design & Architecture Lab', group: 'G1', room: 'Lab 5', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Organization & Assembly Language Lab', group: 'G2', room: 'Lab 6', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G1', room: 'Room Unspecified', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 6', teacher: null, type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Software Design & Architecture Lab', group: 'G2', room: 'Lab 5', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Organization & Assembly Language Lab', group: 'G1', room: 'Lab 6', teacher: null, type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '02:00 PM', course: 'Computer Networks Lab', group: 'G2', room: 'Room Unspecified', teacher: 'Dr. Israr Iqbal', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Web Technologies', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Web Technologies', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Computer Networks', group: null, room: 'Room 5', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '09:00 AM', endTime: '10:00 AM', course: 'Computer Networks', group: null, room: 'Room 5', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Software Design & Architecture', group: null, room: 'Room 3', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Software Design & Architecture', group: null, room: 'Room 3', teacher: 'Dr. Israr Iqbal', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Computer Organization & Assembly Language', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Computer Organization & Assembly Language', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 15: BS Artificial Intelligence 5th Semester
  // ==========================================
  {
    page: 15,
    department: 'Artificial Intelligence',
    program: 'BS Artificial Intelligence',
    programCode: 'BSAI',
    semester: '5th',
    section: 'A',
    batch: 'Fall 2024 – 2028',
    entries: [
      // Monday
      { day: 'Monday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Machine Learning', group: null, room: 'Room 3', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Theory of Automata', group: null, room: 'Room 1', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '05:00 PM', endTime: '08:00 PM', course: 'Assembly Language Lab', group: 'G1', room: 'Lab Unspecified', teacher: 'Mr. Faisal Saeed', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Machine Learning', group: null, room: 'Room 3', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 7', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Theory of Automata', group: null, room: 'Room 1', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '05:00 PM', endTime: '08:00 PM', course: 'Assembly Language Lab', group: 'G2', room: 'Lab Unspecified', teacher: 'Mr. Faisal Saeed', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Programming for AI', group: null, room: 'Room 4', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '02:00 PM', endTime: '03:00 PM', course: 'Multivariate Calculus', group: null, room: 'Room 5', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Assembly Language', group: null, room: 'Room 4', teacher: 'Mr. Faisal Saeed', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '04:00 PM', endTime: '05:00 PM', course: 'Theory of Automata', group: null, room: 'Room 3', teacher: 'Dr. Bilal', type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Programming for AI', group: null, room: 'Room 4', teacher: 'Dr. Atif Khan', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Assembly Language', group: null, room: 'Room 1', teacher: 'Mr. Faisal Saeed', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '04:00 PM', endTime: '07:00 PM', course: 'Machine Learning Lab', group: 'G1', room: 'Lab 4', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '04:00 PM', endTime: '07:00 PM', course: 'Programming for AI Lab', group: 'G2', room: 'Lab 5', teacher: 'Dr. Atif Khan', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '04:00 PM', endTime: '07:00 PM', course: 'Machine Learning Lab', group: 'G2', room: 'Lab 4', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Friday', startTime: '04:00 PM', endTime: '07:00 PM', course: 'Programming for AI Lab', group: 'G1', room: 'Lab 5', teacher: 'Dr. Atif Khan', type: 'Lab', creditHours: 1 }
    ]
  },

  // ==========================================
  // PAGE 16: BS Computer Science Section A 7th Semester
  // ==========================================
  {
    page: 16,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '7th',
    section: 'A',
    batch: 'Fall 2023 – 2027',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming for AI Lab', group: 'G1', room: 'DIP Lab', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming for AI', group: null, room: 'DIP Lab', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Professional Practices', group: null, room: 'Stats Department', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming for AI Lab', group: 'G2', room: 'DIP Lab', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Programming for AI', group: null, room: 'DIP Lab', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Professional Practices', group: null, room: 'Stats Department', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Compiler Construction', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Information Security', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Professional Practices', group: null, room: 'Stats Department', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Compiler Construction', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Information Security', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Compiler Construction', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Information Security', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 17: BS Computer Science Section B 7th Semester
  // ==========================================
  {
    page: 17,
    department: 'Computer Science',
    program: 'BS Computer Science',
    programCode: 'BSCS',
    semester: '7th',
    section: 'B',
    batch: 'Fall 2023 – 2027',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Compiler Construction', group: null, room: 'Room 1', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Information Security', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Professional Practices', group: null, room: 'Stats Department', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Compiler Construction', group: null, room: 'Room 1', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Information Security', group: null, room: 'Room 3', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Professional Practices', group: null, room: 'Stats Department', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming for AI Lab', group: 'G1', room: 'DIP Lab', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Compiler Construction', group: null, room: 'Room 1', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Programming for AI', group: null, room: 'Room 3', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '01:00 PM', endTime: '02:00 PM', course: 'Professional Practices', group: null, room: 'Stats Department', teacher: 'Mr. Inaam Ul Haq', type: 'Lecture', creditHours: 2 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Programming for AI Lab', group: 'G2', room: 'DIP Lab', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Information Security', group: null, room: 'Room 5', teacher: 'Mr. Muhammad Zubair', type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Programming for AI', group: null, room: 'Room 1', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 18: BS Software Engineering Section A 7th Semester
  // ==========================================
  {
    page: 18,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '7th',
    section: 'A',
    batch: 'Fall 2023 – 2027',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Graphics Lab', group: 'G1', room: 'Lab 1', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      { day: 'Monday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Software Project Management', group: null, room: 'Room 4', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Graphics Lab', group: 'G2', room: 'Lab 1', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      { day: 'Tuesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Software Project Management', group: null, room: 'Room 4', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Software Re-Engineering', group: null, room: 'Room 4', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Software Project Management', group: null, room: 'Room 2', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Software Re-Engineering', group: null, room: 'Room 4', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Computer Graphics', group: null, room: 'Room 1', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Software Re-Engineering', group: null, room: 'Room 4', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Computer Graphics', group: null, room: 'Room 1', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 19: BS Software Engineering Section B 7th Semester
  // ==========================================
  {
    page: 19,
    department: 'Software Engineering',
    program: 'BS Software Engineering',
    programCode: 'BSSE',
    semester: '7th',
    section: 'B',
    batch: 'Fall 2023 – 2027',
    entries: [
      // Monday
      { day: 'Monday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Software Project Management', group: null, room: 'Room 5', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Re-Engineering', group: null, room: 'Room 1', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Computer Graphics', group: null, room: 'Room 3', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      // Tuesday
      { day: 'Tuesday', startTime: '08:00 AM', endTime: '09:00 AM', course: 'Software Project Management', group: null, room: 'Room 5', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Re-Engineering', group: null, room: 'Room 1', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '12:00 PM', endTime: '01:00 PM', course: 'Computer Graphics', group: null, room: 'Room 3', teacher: 'Dr. Irshad', type: 'Lecture', creditHours: 3 },
      // Wednesday
      { day: 'Wednesday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Graphics Lab', group: 'G1', room: 'Lab 1', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      // Thursday
      { day: 'Thursday', startTime: '08:00 AM', endTime: '11:00 AM', course: 'Computer Graphics Lab', group: 'G2', room: 'Lab 1', teacher: 'Dr. Irshad', type: 'Lab', creditHours: 1 },
      // Friday
      { day: 'Friday', startTime: '10:00 AM', endTime: '11:00 AM', course: 'Software Project Management', group: null, room: 'Room 3', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '11:00 AM', endTime: '12:00 PM', course: 'Software Re-Engineering', group: null, room: 'Room 4', teacher: 'Dr. Naila Habib', type: 'Lecture', creditHours: 3 }
    ]
  },

  // ==========================================
  // PAGE 20: BS Artificial Intelligence 7th Semester
  // ==========================================
  {
    page: 20,
    department: 'Artificial Intelligence',
    program: 'BS Artificial Intelligence',
    programCode: 'BSAI',
    semester: '7th',
    section: 'A',
    batch: 'Fall 2023 – 2027',
    entries: [
      // Monday
      { day: 'Monday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Deep Learning', group: null, room: 'Room 1', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Monday', startTime: '06:00 PM', endTime: '09:00 PM', course: 'Deep Learning Lab', group: 'G1', room: 'Lab 2', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      // Tuesday
      { day: 'Tuesday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Deep Learning', group: null, room: 'Room 1', teacher: 'Dr. Muhammad Sajjad', type: 'Lecture', creditHours: 3 },
      { day: 'Tuesday', startTime: '06:00 PM', endTime: '09:00 PM', course: 'Deep Learning Lab', group: 'G2', room: 'Lab 2', teacher: 'Dr. Muhammad Sajjad', type: 'Lab', creditHours: 1 },
      // Wednesday
      { day: 'Wednesday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Advance Statistics', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Wednesday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Agent Based Modeling', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      // Thursday
      { day: 'Thursday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Advance Statistics', group: null, room: 'Room 3', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Thursday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Agent Based Modeling', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 },
      // Friday
      { day: 'Friday', startTime: '03:00 PM', endTime: '04:00 PM', course: 'Advance Statistics', group: null, room: 'Room 1', teacher: null, type: 'Lecture', creditHours: 3 },
      { day: 'Friday', startTime: '05:00 PM', endTime: '06:00 PM', course: 'Agent Based Modeling', group: null, room: 'Room 1', teacher: 'Dr. Naveed Abbas', type: 'Lecture', creditHours: 3 }
    ]
  }
];

// Verify metrics
let totalExtracted = 0;
let labCount = 0;
let teacherPresentCount = 0;
let teacherMissingCount = 0;
const courseWeeklyOccurrences = {};

pagesData.forEach(p => {
  p.entries.forEach(e => {
    totalExtracted++;
    if (e.group) labCount++;
    if (e.teacher) teacherPresentCount++;
    else teacherMissingCount++;

    const key = `${p.programCode}_Sem${p.semester}_Sec${p.section}_${e.course}${e.group ? ` (${e.group})` : ''}`;
    courseWeeklyOccurrences[key] = (courseWeeklyOccurrences[key] || 0) + 1;
  });
});

let repeatedSubjectOccurrences = 0;
Object.values(courseWeeklyOccurrences).forEach(count => {
  if (count > 1) {
    repeatedSubjectOccurrences += count;
  }
});

console.log('=== EXTRACTION SUMMARY ===');
console.log('Total Pages Processed:', pagesData.length);
console.log('Total Timetable Entries Extracted:', totalExtracted);
console.log('Total G1/G2 Lab Sessions:', labCount);
console.log('Entries with Teacher Names:', teacherPresentCount);
console.log('Entries with Missing Teacher Names:', teacherMissingCount);
console.log('Total Repeated Weekly Subject Occurrences:', repeatedSubjectOccurrences);

// Now generate the full TypeScript RawTimetableEntry[] array code
const courseCodeMap = {
  'Programming Fundamentals': 'CS-101',
  'Programming Fundamentals Lab': 'CS-101L',
  'Programming': 'CS-101',
  'Programming Lab': 'CS-101L',
  'ICT': 'CS-102',
  'ICT Lab': 'CS-102L',
  'Functional English': 'ENG-101',
  'Physics': 'PHY-101',
  'Islamic Studies': 'IS-101',
  'Pak Studies': 'PS-101',
  'Pakistan Studies': 'PS-101',
  'Basic Math - I': 'MATH-101',
  'Basic Math-I': 'MATH-101',
  'Basic Math-1': 'MATH-101',
  'Basic Math 1': 'MATH-101',
  'Holy Quran': 'HQ-101',
  'Database Systems': 'CS-201',
  'Database Systems Lab': 'CS-201L',
  'Software Engineering': 'SE-201',
  'Data Structures': 'CS-202',
  'Data Structures Lab': 'CS-202L',
  'Calculus & Analytical Geometry': 'MATH-201',
  'Professional Practice': 'CS-203',
  'Civics & Community Engagement': 'SS-201',
  'Assembly Language': 'CS-301',
  'Assembly Language Lab': 'CS-301L',
  'Theory of Automata': 'CS-302',
  'Computer Networks': 'CS-303',
  'Computer Networks Lab': 'CS-303L',
  'Web Technologies': 'CS-304',
  'Web Technologies Lab': 'CS-304L',
  'Multivariate Calculus': 'MATH-301',
  'Software Design & Architecture': 'SE-301',
  'Software Design & Architecture Lab': 'SE-301L',
  'Computer Organization & Assembly Language': 'CS-305',
  'Computer Organization & Assembly Language Lab': 'CS-305L',
  'Programming for AI': 'AI-301',
  'Programming for AI Lab': 'AI-301L',
  'Machine Learning': 'AI-302',
  'Machine Learning Lab': 'AI-302L',
  'Compiler Construction': 'CS-401',
  'Information Security': 'CS-402',
  'Professional Practices': 'CS-403',
  'Computer Graphics': 'CS-404',
  'Computer Graphics Lab': 'CS-404L',
  'Software Re-Engineering': 'SE-401',
  'Software Project Management': 'SE-402',
  'Agent Based Modeling': 'AI-401',
  'Deep Learning': 'AI-402',
  'Deep Learning Lab': 'AI-402L',
  'Advance Statistics': 'STAT-401'
};

const teacherIdMap = {
  'Dr. Tauseef-ur-Rehman': 'tch-tauseef',
  'Mr. Salahuddin': 'tch-salahuddin',
  'Dr. Sajjad': 'tch-sajjad',
  'Dr. Muhammad Sajjad': 'tch-sajjad',
  'Dr. Naveed Abbas': 'tch-naveed',
  'Dr. Atif Khan': 'tch-atif',
  'Dr. Muhammad Waseem': 'tch-waseem',
  'Dr. Khalid Haseeb': 'tch-khalid',
  'Dr. Shaukat Ali': 'tch-shaukat',
  'Dr. Irshad': 'tch-irshad',
  'Mr. Inaam Ul Haq': 'tch-inaam',
  'Dr. Bilal': 'tch-bilal',
  'Dr. Israr Iqbal': 'tch-israr',
  'Mr. Faisal Saeed': 'tch-faisal',
  'Dr. Mansoor Nasir': 'tch-mansoor',
  'Mr. Muhammad Zubair': 'tch-zubair',
  'Dr. Naila Habib': 'tch-naila'
};

const buildingMap = (room) => {
  if (!room || room === 'Room Unspecified') return 'CS Academic Block';
  if (room.toLowerCase().includes('lab')) return 'CS Computing Laboratories';
  if (room.toLowerCase().includes('stats')) return 'Statistics & Allied Sciences Block';
  return 'CS Academic Block';
};

let entryIndex = 1;
const rawEntries = [];

pagesData.forEach(p => {
  p.entries.forEach(e => {
    const courseCode = courseCodeMap[e.course] || 'CS-GEN';
    const teacherName = e.teacher || '';
    const teacherId = teacherIdMap[e.teacher] || '';
    const room = e.room || 'Room Unspecified';
    const building = buildingMap(room);
    const fullName = e.group ? `${e.course} (${e.group})` : e.course;
    const progSlug = p.programCode.toLowerCase();
    const semSlug = p.semester.toLowerCase();
    const secSlug = p.section.toLowerCase();
    const daySlug = e.day.substring(0, 3).toLowerCase();
    const id = `tt-${progSlug}-${semSlug}${secSlug}-${daySlug}-${entryIndex++}`;

    rawEntries.push({
      id,
      day: e.day,
      courseName: fullName,
      courseCode,
      teacherName,
      teacherId,
      classroomNumber: room,
      building,
      startTime: e.startTime,
      endTime: e.endTime,
      department: p.department,
      program: p.program,
      degree: p.program,
      semester: p.semester,
      section: p.section,
      batch: p.batch,
      type: e.type,
      creditHours: e.creditHours
    });
  });
});

console.log('Total Generated rawEntries:', rawEntries.length);
fs.writeFileSync('scripts/extractedTimetableEntries.json', JSON.stringify(rawEntries, null, 2));
