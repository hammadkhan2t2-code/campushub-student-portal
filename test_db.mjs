import { createClient } from "@supabase/supabase-js";

const url = process.env.VITE_SUPABASE_URL;
const key = process.env.VITE_SUPABASE_ANON_KEY;

console.log("Supabase URL:", url ? url.substring(0, 30) + "..." : "missing");
console.log("Key exists:", !!key);

const supabase = createClient(url, key, {
  auth: { persistSession: false }
});

async function run() {
  const tables = [
    "departments",
    "programs",
    "semesters",
    "sections",
    "batches",
    "teachers",
    "rooms",
    "courses",
    "timetable_entries",
    "profiles",
    "lost_and_found"
  ];
  for (const t of tables) {
    try {
      const res = await supabase.from(t).select("*", { count: "exact" }).limit(3);
      if (res.error) {
        console.log(`Table ${t}: Error -> ${res.error.message} (${res.error.code})`);
      } else {
        console.log(`Table ${t}: Total Count = ${res.count}`);
        if (res.data && res.data.length > 0) {
          console.log(`  Sample 1st item:`, JSON.stringify(res.data[0]));
        }
      }
    } catch (e) {
      console.log(`Table ${t}: Exception -> ${e.message}`);
    }
  }
}

run().then(() => {
  console.log("Completed Supabase audit.");
  process.exit(0);
}).catch(err => {
  console.error("Run error:", err);
  process.exit(1);
});
