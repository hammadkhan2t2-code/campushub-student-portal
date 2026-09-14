import { supabase, isSupabaseConfigured as isClientConfigured } from './supabase';
import {
  DepartmentRecord,
  ProgramRecord,
  SemesterRecord,
  SectionRecord,
  BatchRecord,
  CourseRecord,
  TeacherRecord,
  RoomRecord,
  TimetableEntryRecord,
  ProfileRecord,
  LostFoundRecord
} from '../types/supabase';
import { TimetableEntry, Room, Teacher, LostFoundItem, DayOfWeek, User } from '../types';

/**
 * Checks if Supabase client is available and configured with actual credentials
 */
export function isSupabaseConfigured(): boolean {
  return isClientConfigured;
}

// ----------------------------------------------------
// ACADEMIC METADATA
// ----------------------------------------------------

const CANONICAL_DEPARTMENTS = ['Computer Science', 'Software Engineering', 'Artificial Intelligence'];
const CANONICAL_PROGRAMS = ['BS Computer Science', 'BS Software Engineering', 'BS Artificial Intelligence'];

export async function fetchDepartments(): Promise<DepartmentRecord[]> {
  try {
    const { data, error } = await supabase
      .from('departments')
      .select('*')
      .order('name');
    if (error) {
      console.warn('Supabase fetchDepartments error:', error.message);
      return [];
    }
    // Filter strictly to the 3 original departments
    const filtered = (data || []).filter((d: DepartmentRecord) =>
      CANONICAL_DEPARTMENTS.includes(d.name)
    );
    return filtered;
  } catch (err) {
    console.warn('Failed to fetch departments from Supabase:', err);
    return [];
  }
}

export async function fetchPrograms(departmentId?: string): Promise<ProgramRecord[]> {
  try {
    let query = supabase
      .from('programs')
      .select('*')
      .order('name');

    if (departmentId) {
      query = query.eq('department_id', departmentId);
    }

    const { data, error } = await query;
    if (error) {
      console.warn('Supabase fetchPrograms error:', error.message);
      return [];
    }
    // Filter strictly to the 3 original programs
    const filtered = (data || []).filter((p: ProgramRecord) =>
      CANONICAL_PROGRAMS.includes(p.name)
    );
    return filtered;
  } catch (err) {
    console.warn('Failed to fetch programs from Supabase:', err);
    return [];
  }
}

export async function fetchProgramsByDepartmentId(departmentId: string): Promise<ProgramRecord[]> {
  return fetchPrograms(departmentId);
}

export async function fetchSemesters(): Promise<SemesterRecord[]> {
  try {
    const { data, error } = await supabase
      .from('semesters')
      .select('*');
    if (error) {
      console.warn('Supabase fetchSemesters error:', error.message);
      return [];
    }
    return data || [];
  } catch (err) {
    console.warn('Failed to fetch semesters from Supabase:', err);
    return [];
  }
}

export async function fetchSections(): Promise<SectionRecord[]> {
  try {
    const { data, error } = await supabase
      .from('sections')
      .select('*')
      .order('name');
    if (error) {
      console.warn('Supabase fetchSections error:', error.message);
      return [];
    }
    return data || [];
  } catch (err) {
    console.warn('Failed to fetch sections from Supabase:', err);
    return [];
  }
}

export async function fetchBatches(): Promise<BatchRecord[]> {
  try {
    const { data, error } = await supabase
      .from('batches')
      .select('*')
      .order('name', { ascending: false });
    if (error) {
      console.warn('Supabase fetchBatches error:', error.message);
      return [];
    }
    return data || [];
  } catch (err) {
    console.warn('Failed to fetch batches from Supabase:', err);
    return [];
  }
}

export async function fetchCourses(): Promise<CourseRecord[]> {
  try {
    const { data, error } = await supabase
      .from('courses')
      .select('*')
      .order('name');
    if (error) {
      console.warn('Supabase fetchCourses error:', error.message);
      return [];
    }
    return data || [];
  } catch (err) {
    console.warn('Failed to fetch courses from Supabase:', err);
    return [];
  }
}

// ----------------------------------------------------
// TEACHERS
// ----------------------------------------------------

export async function fetchTeachers(): Promise<Teacher[]> {
  try {
    const { data, error } = await supabase
      .from('teachers')
      .select(`
        id,
        name,
        designation,
        email,
        office,
        office_hours,
        qualifications,
        specialization,
        department_name,
        departments ( name )
      `)
      .order('name');

    if (error) {
      console.warn('Supabase fetchTeachers error:', error.message);
      return [];
    }

    if (!data) return [];

    return data.map((t: any) => {
      let deptName =
        t.department_name ||
        t.departments?.name ||
        'Computer Science';

      // Correct any teacher department mapping that was artificially changed to Mathematics, Physics, or Humanities
      if (['Mathematics', 'Physics', 'Humanities'].includes(deptName)) {
        deptName = 'Computer Science';
      }

      return {
        id: t.id,
        name: t.name,
        designation: t.designation || 'Faculty Member',
        department: deptName,
        email: t.email,
        office: t.office || 'Faculty Block A, CS Dept',
        officeHours: t.office_hours || 'Mon–Thu: 10:00 AM – 12:00 PM | Fri: 09:00 AM – 11:00 AM',
        courses: [],
        qualifications: t.qualifications || 'Faculty Member, University of Peshawar',
        specialization: t.specialization || 'Computing and Information Sciences'
      };
    });
  } catch (err) {
    console.warn('Failed to fetch teachers from Supabase:', err);
    return [];
  }
}

// ----------------------------------------------------
// ROOMS
// ----------------------------------------------------

export async function fetchRooms(): Promise<Room[]> {
  try {
    const { data, error } = await supabase
      .from('rooms')
      .select('*')
      .order('room_number');

    if (error) {
      console.warn('Supabase fetchRooms error:', error.message);
      return [];
    }

    if (!data) return [];

    return data.map((r: any) => {
      let facilitiesArr: string[] = [];
      if (Array.isArray(r.facilities)) {
        facilitiesArr = r.facilities;
      } else if (typeof r.facilities === 'string') {
        try {
          facilitiesArr = JSON.parse(r.facilities);
        } catch {
          facilitiesArr = r.facilities.split(',').map((s: string) => s.trim());
        }
      }

      return {
        id: r.id,
        roomNumber: r.room_number || r.name || 'Room',
        building: r.building || 'Main Academic Block',
        floor: r.floor || 'Ground Floor',
        capacity: Number(r.capacity) || 50,
        type: (r.type as Room['type']) || 'Lecture Hall',
        facilities: facilitiesArr.length > 0 ? facilitiesArr : ['Air Conditioning', 'Multimedia Projector', 'Whiteboard']
      };
    });
  } catch (err) {
    console.warn('Failed to fetch rooms from Supabase:', err);
    return [];
  }
}

// ----------------------------------------------------
// TIMETABLE ENTRIES
// ----------------------------------------------------

export interface TimetableFilterParams {
  department_id?: string;
  program_id?: string;
  semester_id?: string;
  section_id?: string;
  batch_id?: string;
}

export async function fetchTimetableEntries(params?: TimetableFilterParams): Promise<TimetableEntry[]> {
  try {
    let query = supabase
      .from('timetable_entries')
      .select(`
        id,
        day,
        start_time,
        end_time,
        type,
        credit_hours,
        department_id,
        program_id,
        semester_id,
        section_id,
        batch_id,
        course_name,
        course_code,
        teacher_name,
        room_number,
        classroom_number,
        building,
        department_name,
        program_name,
        semester_name,
        section_name,
        batch_name,
        courses ( id, name, code, credit_hours ),
        teachers ( id, name ),
        rooms ( id, room_number, building ),
        departments ( id, name ),
        programs ( id, name ),
        semesters ( id, name ),
        sections ( id, name ),
        batches ( id, name )
      `);

    // Strictly enforce section filter and academic filters when provided
    if (params?.department_id) {
      query = query.eq('department_id', params.department_id);
    }
    if (params?.program_id) {
      query = query.eq('program_id', params.program_id);
    }
    if (params?.semester_id) {
      query = query.eq('semester_id', params.semester_id);
    }
    if (params?.section_id) {
      query = query.eq('section_id', params.section_id);
    }
    if (params?.batch_id) {
      query = query.eq('batch_id', params.batch_id);
    }

    const { data, error } = await query;

    if (error) {
      console.warn('Supabase fetchTimetableEntries error:', error.message);
      return [];
    }

    if (!data) return [];

    return data.map((t: any): TimetableEntry => {
      const courseName =
        t.courses?.name ||
        t.course_name ||
        'Academic Course';
      const courseCode =
        t.courses?.code ||
        t.course_code ||
        'CS-100';
      const teacherName =
        t.teachers?.name ||
        t.teacher_name ||
        'Faculty Member';
      const teacherId = t.teachers?.id || t.teacher_id || 'tch-unknown';
      const classroomNumber =
        t.rooms?.room_number ||
        t.classroom_number ||
        t.room_number ||
        'Room 1';
      const building =
        t.rooms?.building ||
        t.building ||
        'Takbeer Block (CS & SE)';
      const department =
        t.departments?.name ||
        t.department_name ||
        'Computer Science';
      const semester =
        t.semesters?.name ||
        t.semester_name ||
        '1st';
      const section =
        t.sections?.name ||
        t.section_name ||
        'A';
      const batch =
        t.batches?.name ||
        t.batch_name ||
        'Fall 2026 – 2030';
      const creditHours =
        t.credit_hours ||
        t.courses?.credit_hours ||
        3;
      const type =
        (t.type as 'Lecture' | 'Lab' | 'Tutorial') ||
        (t.courses?.type as 'Lecture' | 'Lab' | 'Tutorial') ||
        'Lecture';

      return {
        id: t.id,
        day: t.day as DayOfWeek,
        courseName,
        courseCode,
        teacherName,
        teacherId,
        classroomNumber,
        building,
        startTime: t.start_time,
        endTime: t.end_time,
        department,
        semester,
        section,
        batch,
        type,
        creditHours
      };
    });
  } catch (err) {
    console.warn('Failed to fetch timetable entries from Supabase:', err);
    return [];
  }
}

// ----------------------------------------------------
// PROFILES
// ----------------------------------------------------

export async function fetchProfileById(userId: string): Promise<User | null> {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select(`
        id,
        first_name,
        last_name,
        full_name,
        roll_number,
        email,
        phone,
        bio,
        department_id,
        program_id,
        semester_id,
        section_id,
        batch_id,
        department,
        degree,
        program,
        semester,
        section,
        admission_batch,
        batch,
        admission_year,
        expected_graduation_year,
        avatar_color,
        departments ( id, name ),
        programs ( id, name ),
        semesters ( id, name ),
        sections ( id, name ),
        batches ( id, name )
      `)
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      console.warn('Supabase fetchProfileById error:', error.message);
      return null;
    }

    if (!data) return null;

    return mapProfileRecordToUser(data);
  } catch (err) {
    console.warn('Failed to fetch profile from Supabase:', err);
    return null;
  }
}

export async function updateSupabaseProfile(
  userId: string,
  updates: Partial<ProfileRecord>
): Promise<{ success: boolean; error?: string }> {
  try {
    const { error } = await supabase
      .from('profiles')
      .update({
        ...updates,
        updated_at: new Date().toISOString()
      })
      .eq('id', userId);

    if (error) {
      console.warn('Supabase updateProfile error:', error.message);
      return { success: false, error: error.message };
    }
    return { success: true };
  } catch (err: any) {
    console.warn('Failed to update profile in Supabase:', err);
    return { success: false, error: err.message || 'Update failed' };
  }
}

export function mapProfileRecordToUser(p: any): User {
  const firstName = p.first_name || (p.full_name ? p.full_name.split(' ')[0] : 'Student');
  const lastName = p.last_name || (p.full_name ? p.full_name.split(' ').slice(1).join(' ') : '');
  let departmentName = p.departments?.name || p.department || 'Computer Science';
  if (['Mathematics', 'Physics', 'Humanities'].includes(departmentName)) {
    departmentName = 'Computer Science';
  }
  const degreeName = p.programs?.name || p.degree || p.program || 'BS Computer Science';
  const semesterName = p.semesters?.name || p.semester || '1st';
  const sectionName = p.sections?.name || p.section || 'A';
  const batchName = p.batches?.name || p.admission_batch || p.batch || 'Fall 2026 – 2030';

  return {
    id: p.id,
    firstName,
    lastName,
    rollNumber: p.roll_number || '',
    email: p.email || '',
    department: departmentName,
    degree: degreeName,
    semester: semesterName,
    section: sectionName,
    admissionBatch: batchName,
    admissionYear: Number(p.admission_year) || 2026,
    expectedGraduationYear: Number(p.expected_graduation_year) || 2030,
    avatarColor: p.avatar_color || '#0F172A',
    phone: p.phone,
    bio: p.bio,
    departmentId: p.department_id || p.departments?.id,
    programId: p.program_id || p.programs?.id,
    semesterId: p.semester_id || p.semesters?.id,
    sectionId: p.section_id || p.sections?.id,
    batchId: p.batch_id || p.batches?.id
  };
}

// ----------------------------------------------------
// LOST & FOUND
// ----------------------------------------------------

export async function fetchLostFoundItems(): Promise<LostFoundItem[]> {
  try {
    const { data, error } = await supabase
      .from('lost_and_found')
      .select('*')
      .order('reported_at', { ascending: false });

    if (error) {
      console.warn('Supabase fetchLostFoundItems error:', error.message);
      return [];
    }

    if (!data) return [];

    return data.map((item: any): LostFoundItem => {
      let claimRecord = undefined;
      if (item.claimed_by || item.claimed_at || item.claim_record) {
        claimRecord = item.claim_record || {
          claimedBy: item.claimed_by || '',
          claimedByRoll: item.claimed_by_roll || '',
          claimedByEmail: item.claimed_by_email || '',
          claimNote: item.claim_note || '',
          contact: item.claim_contact || '',
          claimedAt: item.claimed_at || item.created_at || new Date().toISOString()
        };
      }

      return {
        id: item.id,
        type: item.type as 'lost' | 'found',
        itemName: item.item_name || item.title || 'Item',
        category: item.category || 'Other',
        description: item.description || '',
        location: item.location || '',
        room: item.room,
        date: item.date || item.reported_at?.split('T')[0] || new Date().toISOString().split('T')[0],
        approximateTime: item.approximate_time || '',
        imageUrl: item.image_url,
        contactMethod: item.contact_method,
        status: item.status || 'Lost',
        reportedBy: item.reported_by || 'Anonymous',
        reportedByEmail: item.reported_by_email || '',
        reportedAt: item.reported_at || item.created_at || new Date().toISOString(),
        claimRecord
      };
    });
  } catch (err) {
    console.warn('Failed to fetch lost & found from Supabase:', err);
    return [];
  }
}

export async function createLostFoundItem(
  item: Omit<LostFoundItem, 'id' | 'reportedAt' | 'status'> & { status?: LostFoundItem['status'] }
): Promise<{ success: boolean; data?: LostFoundItem; error?: string }> {
  try {
    const now = new Date().toISOString();
    const payload = {
      type: item.type,
      item_name: item.itemName,
      category: item.category,
      description: item.description,
      location: item.location,
      room: item.room,
      date: item.date,
      approximate_time: item.approximateTime,
      image_url: item.imageUrl,
      contact_method: item.contactMethod,
      status: item.status || (item.type === 'lost' ? 'Lost' : 'Found'),
      reported_by: item.reportedBy,
      reported_by_email: item.reportedByEmail,
      reported_at: now
    };

    const { data, error } = await supabase
      .from('lost_and_found')
      .insert([payload])
      .select()
      .single();

    if (error) {
      console.warn('Supabase createLostFoundItem error:', error.message);
      return { success: false, error: error.message };
    }

    return {
      success: true,
      data: {
        ...item,
        id: data.id,
        reportedAt: data.reported_at || now,
        status: data.status
      }
    };
  } catch (err: any) {
    console.warn('Failed to create lost found item in Supabase:', err);
    return { success: false, error: err.message || 'Creation failed' };
  }
}

export async function claimLostFoundItem(
  itemId: string,
  claim: {
    claimedBy: string;
    claimedByRoll: string;
    claimedByEmail: string;
    claimNote: string;
    contact: string;
    claimedAt: string;
  }
): Promise<{ success: boolean; error?: string }> {
  try {
    const { error } = await supabase
      .from('lost_and_found')
      .update({
        status: 'Claimed',
        claimed_by: claim.claimedBy,
        claimed_by_roll: claim.claimedByRoll,
        claimed_by_email: claim.claimedByEmail,
        claim_note: claim.claimNote,
        claim_contact: claim.contact,
        claimed_at: claim.claimedAt,
        claim_record: claim
      })
      .eq('id', itemId);

    if (error) {
      console.warn('Supabase claimLostFoundItem error:', error.message);
      return { success: false, error: error.message };
    }
    return { success: true };
  } catch (err: any) {
    console.warn('Failed to claim lost found item in Supabase:', err);
    return { success: false, error: err.message || 'Claim failed' };
  }
}

export async function updateLostFoundItemStatus(
  itemId: string,
  status: LostFoundItem['status']
): Promise<{ success: boolean; error?: string }> {
  try {
    const { error } = await supabase
      .from('lost_and_found')
      .update({ status })
      .eq('id', itemId);

    if (error) {
      console.warn('Supabase updateLostFoundItemStatus error:', error.message);
      return { success: false, error: error.message };
    }
    return { success: true };
  } catch (err: any) {
    console.warn('Failed to update item status in Supabase:', err);
    return { success: false, error: err.message || 'Status update failed' };
  }
}
