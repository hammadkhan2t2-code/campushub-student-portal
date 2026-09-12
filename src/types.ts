export type DayOfWeek = 'Monday' | 'Tuesday' | 'Wednesday' | 'Thursday' | 'Friday';

export interface User {
  id: string;
  firstName: string;
  lastName: string;
  rollNumber: string;
  email: string;
  department: string;
  degree: string;
  semester: string;
  section: string;
  admissionBatch: string;
  admissionYear: number;
  expectedGraduationYear: number;
  avatarColor?: string;
  phone?: string;
  emergencyContact?: string;
  password?: string;
  bio?: string;
  // Supabase relational foreign key references
  departmentId?: string;
  programId?: string;
  semesterId?: string;
  sectionId?: string;
  batchId?: string;
}

export interface TimetableEntry {
  id: string;
  day: DayOfWeek;
  courseName: string;
  courseCode: string;
  teacherName: string;
  teacherId: string;
  classroomNumber: string;
  building: string;
  startTime: string;
  endTime: string;
  department: string;
  semester: string;
  section: string;
  batch: string;
  type: 'Lecture' | 'Lab' | 'Tutorial';
  creditHours: number;
}

export interface Room {
  id: string;
  roomNumber: string;
  building: string;
  floor: string;
  capacity: number;
  type: 'Lecture Hall' | 'Computer Lab' | 'Hardware Lab' | 'Seminar Room' | 'Auditorium';
  facilities: string[];
}

export interface Teacher {
  id: string;
  name: string;
  designation: string;
  department: string;
  email?: string;
  office?: string;
  officeHours?: string;
  courses: string[];
  qualifications: string;
  specialization: string;
}

export type LostFoundStatus = 'Lost' | 'Found' | 'Claimed' | 'Resolved';
export type ItemType = 'lost' | 'found';
export type ItemCategory = 'Electronics' | 'IDs & Cards' | 'Books & Stationery' | 'Keys & Wallets' | 'Accessories' | 'Other';

export interface ClaimRecord {
  claimedBy: string;
  claimedByRoll: string;
  claimedByEmail: string;
  claimNote: string;
  contact: string;
  claimedAt: string;
}

export interface LostFoundItem {
  id: string;
  type: ItemType;
  itemName: string;
  category: ItemCategory;
  description: string;
  location: string;
  room?: string;
  date: string;
  approximateTime: string;
  imageUrl?: string;
  contactMethod?: string;
  status: LostFoundStatus;
  reportedBy: string;
  reportedByEmail: string;
  reportedAt: string;
  claimRecord?: ClaimRecord;
}

export type ActiveTab = 'home' | 'timetable' | 'rooms' | 'teachers' | 'lost-found' | 'profile';
