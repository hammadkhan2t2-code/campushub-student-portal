/**
 * Centralized Program-to-Prefix mapping and Roll Number formatting.
 * 
 * Configured mappings:
 * - Computer Science → BSCS
 * - Artificial Intelligence → BSAI
 * - Software Engineering → BSSE
 * 
 * Easily extensible for administrators and developers to register additional
 * academic programs and prefixes.
 */

export interface ProgramPrefixRule {
  programName: string;
  prefix: string;
  department: string;
}

export const PROGRAM_PREFIX_MAPPINGS: Record<string, string> = {
  // Degree / Program Names
  'BS Computer Science': 'BSCS',
  'BS Artificial Intelligence': 'BSAI',
  'BS Software Engineering': 'BSSE',

  // Department Names (fallback)
  'Computer Science': 'BSCS',
  'Artificial Intelligence': 'BSAI',
  'Software Engineering': 'BSSE',

  // Short Codes / Aliases
  'CS': 'BSCS',
  'AI': 'BSAI',
  'SE': 'BSSE'
};

export const DEFAULT_PROGRAM_PREFIX = 'BSCS';

/**
 * Returns the standardized program prefix for a given degree or department.
 */
export function getProgramPrefix(degreeOrDept?: string): string {
  if (!degreeOrDept) return DEFAULT_PROGRAM_PREFIX;
  const trimmed = degreeOrDept.trim();
  
  if (PROGRAM_PREFIX_MAPPINGS[trimmed]) {
    return PROGRAM_PREFIX_MAPPINGS[trimmed];
  }

  // Case-insensitive / fuzzy match
  const lower = trimmed.toLowerCase();
  if (lower.includes('artificial') || lower.includes('ai')) return 'BSAI';
  if (lower.includes('software') || lower.includes('se')) return 'BSSE';
  if (lower.includes('computer') || lower.includes('cs')) return 'BSCS';

  return DEFAULT_PROGRAM_PREFIX;
}

/**
 * Strips any program prefix (e.g. BSCS, BSAI, BSSE, CS, BCS, etc.) and delimiters
 * from a roll number string, extracting ONLY the user's specific roll-number portion (e.g. "25-048").
 */
export function extractRollNumberSuffix(rawRoll?: string): string {
  if (!rawRoll) return '';
  let clean = rawRoll.trim();

  // Strip known prefix codes if present at the beginning (e.g., BSCS-, BSAI-, BSSE-, CS-, etc.)
  clean = clean.replace(/^(BSCS|BSAI|BSSE|BCS|BSE|BAI|CS|AI|SE)[-\s_]*/i, '');
  
  // Clean up any leading symbols or spaces
  clean = clean.replace(/^[-_\s]+/, '');
  return clean;
}

/**
 * Formats a roll number using the university's consistent program-specific prefix system.
 * Format: "BSCS-25-048" (or "BSAI-25-048", "BSSE-25-048")
 * 
 * If the input already contains a suffix (or old prefix), it normalizes to the 
 * selected program's prefix.
 */
export function formatRollNumber(
  rawRoll?: string,
  degreeOrDept?: string
): string {
  if (!rawRoll) return '';
  const prefix = getProgramPrefix(degreeOrDept);
  const suffix = extractRollNumberSuffix(rawRoll);

  if (!suffix) {
    return `${prefix}-${rawRoll.trim()}`;
  }

  return `${prefix}-${suffix}`;
}

/**
 * Helper to format a user object's roll number using their registered program.
 */
export function formatUserRollNumber(user?: {
  rollNumber?: string;
  degree?: string;
  department?: string;
} | null): string {
  if (!user || !user.rollNumber) return '';
  return formatRollNumber(user.rollNumber, user.degree || user.department);
}
