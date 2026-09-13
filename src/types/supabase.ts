export interface DepartmentRecord {
  id: string;
  name: string;
  code?: string;
  created_at?: string;
}

export interface ProgramRecord {
  id: string;
  department_id?: string;
  name: string;
  short_code?: string;
  duration_years?: number;
  code?: string;
  degree_type?: string;
  created_at?: string;
}

export interface SemesterRecord {
  id: string;
  name: string; // e.g. '1st', '3rd', '5th', '7th'
  number?: number;
  created_at?: string;
}

export interface SectionRecord {
  id: string;
  name: string; // e.g. 'A', 'B'
  created_at?: string;
}

export interface BatchRecord {
  id: string;
  name: string; // e.g. 'Fall 2026 – 2030'
  start_year?: number;
  end_year?: number;
  created_at?: string;
}

export interface CourseRecord {
  id: string;
  name: string;
  code: string;
  department_id?: string;
  program_id?: string;
  semester_id?: string;
  credit_hours?: number;
  type?: string;
  created_at?: string;
}

export interface TeacherRecord {
  id: string;
  name: string;
  designation?: string;
  department_id?: string;
  department_name?: string;
  email?: string;
  office?: string;
  office_hours?: string;
  qualifications?: string;
  specialization?: string;
  created_at?: string;
}

export interface RoomRecord {
  id: string;
  room_number: string;
  building?: string;
  floor?: string;
  capacity?: number;
  type?: string;
  facilities?: string[] | string;
  created_at?: string;
}

export interface TimetableEntryRecord {
  id: string;
  day: string; // 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday'
  start_time: string;
  end_time: string;
  type?: string; // 'Lecture' | 'Lab' | 'Tutorial'
  credit_hours?: number;
  
  department_id?: string;
  program_id?: string;
  semester_id?: string;
  section_id?: string;
  batch_id?: string;
  
  course_id?: string;
  teacher_id?: string;
  room_id?: string;

  // Joined or denormalized columns if present in table or view
  course_name?: string;
  course_code?: string;
  teacher_name?: string;
  room_number?: string;
  classroom_number?: string;
  building?: string;
  department_name?: string;
  program_name?: string;
  semester_name?: string;
  section_name?: string;
  batch_name?: string;

  // Foreign key objects if joined
  courses?: { name?: string; code?: string; credit_hours?: number; type?: string };
  teachers?: { name?: string };
  rooms?: { room_number?: string; building?: string };
  departments?: { name?: string };
  programs?: { name?: string };
  semesters?: { name?: string };
  sections?: { name?: string };
  batches?: { name?: string };
}

export interface ProfileRecord {
  id: string;
  first_name?: string;
  last_name?: string;
  full_name?: string;
  roll_number?: string;
  email?: string;
  phone?: string;
  bio?: string;
  department_id?: string;
  program_id?: string;
  semester_id?: string;
  section_id?: string;
  batch_id?: string;
  
  // Denormalized name fields
  department?: string;
  degree?: string;
  program?: string;
  semester?: string;
  section?: string;
  admission_batch?: string;
  batch?: string;
  admission_year?: number;
  expected_graduation_year?: number;
  avatar_color?: string;
  created_at?: string;
  updated_at?: string;
}

export interface LostFoundRecord {
  id: string;
  type: string; // 'lost' | 'found'
  item_name: string;
  category: string;
  description?: string;
  location?: string;
  room?: string;
  date?: string;
  approximate_time?: string;
  image_url?: string;
  contact_method?: string;
  status: string; // 'Lost' | 'Found' | 'Claimed' | 'Resolved'
  reported_by?: string;
  reported_by_email?: string;
  reported_at?: string;
  claim_record?: Record<string, any>;
  claimed_by?: string;
  claimed_by_roll?: string;
  claimed_by_email?: string;
  claim_note?: string;
  claim_contact?: string;
  claimed_at?: string;
  created_at?: string;
}
