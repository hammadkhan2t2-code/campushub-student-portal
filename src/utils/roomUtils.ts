/**
 * Utility to format and normalize classroom and room venue strings,
 * preventing duplicate "Room" prefixes while preserving actual room/lab names.
 *
 * Examples:
 * - "Room Room 1" -> "Room 1"
 * - "Room Room 204" -> "Room 204"
 * - "Room Lab 2" -> "Lab 2"
 * - "Room 1" -> "Room 1"
 * - "Lab 2" -> "Lab 2"
 * - "DIP Lab" -> "DIP Lab"
 * - "Stats Deptt" -> "Stats Deptt"
 * - "204" -> "Room 204"
 */
export function formatRoomDisplay(roomStr?: string | null): string {
  if (!roomStr) return '';
  let str = roomStr.trim();

  // Strip duplicate "Room" prefixes (e.g. "Room Room 1" or "Room  Room 204")
  while (/^Room\s+Room\b/i.test(str)) {
    str = str.replace(/^Room\s+/i, '');
  }

  // If prefixed with "Room" followed by non-room venues like "Lab", "DIP", "Stats", "Auditorium", "Hall"
  if (/^Room\s+(Lab|DIP|Stats|Auditorium|Deptt|Hall)\b/i.test(str)) {
    str = str.replace(/^Room\s+/i, '');
  }

  // If it's a bare number or room code like "204" or "1", add "Room "
  if (/^\d+[A-Za-z]?$/.test(str)) {
    return `Room ${str}`;
  }

  return str;
}
