import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const isSupabaseConfigured = Boolean(supabaseUrl && supabaseAnonKey);

export const supabase = isSupabaseConfigured
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

export async function recordTicketInput({ ticketCode, status }) {
  if (!supabase) return;

  const { error } = await supabase.from("ticket_input_logs").insert({
    ticket_code: ticketCode,
    status,
  });

  if (error) {
    console.warn("Failed to record ticket input", error);
  }
}
