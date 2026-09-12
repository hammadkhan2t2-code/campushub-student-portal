/**
 * Centralized Contact & Assistance Configuration for Lost & Found Desk.
 * 
 * In accordance with university instructions, fictional phone numbers and 
 * department contact numbers have been removed and replaced with:
 * "Contact Your CR"
 * 
 * This module is structured so that actual Class Representative (CR) contact
 * numbers can easily be added in the future without redesigning the UI.
 */

export interface CRContactEntry {
  name?: string;
  phone?: string;
  email?: string;
}

export interface DepartmentCRInfo {
  department: string;
  sectionA?: CRContactEntry;
  sectionB?: CRContactEntry;
  generalNote?: string;
}

export interface LostFoundContactConfig {
  instruction: string;
  subInstruction: string;
  detailedMessage: string;
  // Easily extendable record for future CR contact numbers
  departmentCRs: Record<string, DepartmentCRInfo>;
}

export const LOST_FOUND_CONTACT_CONFIG: LostFoundContactConfig = {
  instruction: 'Contact Your CR',
  subInstruction: 'Class Representative Coordination',
  detailedMessage:
    'For any assistance regarding a lost or found item, claiming belongings, or coordinating a handover, please Contact Your CR. Official Class Representative contact numbers will be updated here.',
  departmentCRs: {
    'Computer Science': {
      department: 'Computer Science',
      generalNote: 'Contact your respective Class Representative for Section A or Section B.'
    },
    'Software Engineering': {
      department: 'Software Engineering',
      generalNote: 'Contact your respective Class Representative for Section A or Section B.'
    },
    'Artificial Intelligence': {
      department: 'Artificial Intelligence',
      generalNote: 'Contact your respective Class Representative for Section A or Section B.'
    }
  }
};

/**
 * Returns a clean, standardized contact string for lost & found items.
 * If a custom deposit location is provided (e.g. "Security Counter"), it appends the CR instruction.
 * Otherwise, it always defaults to "Contact Your CR".
 */
export function getLostFoundContactDisplay(contactMethod?: string): string {
  if (!contactMethod) return LOST_FOUND_CONTACT_CONFIG.instruction;
  
  // If contactMethod contains any phone numbers or fake contact data, sanitize it
  const hasPhonePattern = /(\+92|03\d{2}|\b\d{7,11}\b|whatsapp)/i.test(contactMethod);
  if (hasPhonePattern) {
    return LOST_FOUND_CONTACT_CONFIG.instruction;
  }

  return contactMethod;
}
