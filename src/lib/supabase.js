import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const isSupabaseConfigured = Boolean(supabaseUrl && supabaseAnonKey);

export const supabase = isSupabaseConfigured
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

export async function fetchTicketCodes() {
  if (!supabase) {
    throw new Error("Supabase is not configured");
  }

  const { data, error } = await supabase
    .from("ticket_codes")
    .select("code,is_used,used_at,created_at")
    .order("created_at", { ascending: true });

  if (error) throw error;
  return data ?? [];
}

export async function fetchTicketCode(ticketCode) {
  if (!supabase) {
    throw new Error("Supabase is not configured");
  }

  const { data, error } = await supabase
    .from("ticket_codes")
    .select("code,is_used,used_at")
    .eq("code", ticketCode)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function useTicketCode(ticketCode) {
  if (!supabase) {
    throw new Error("Supabase is not configured");
  }

  const { data, error } = await supabase.rpc("use_ticket_code", {
    ticket_code_input: ticketCode,
  });

  if (error) throw error;
  return data?.[0] ?? { code: ticketCode, status: "invalid" };
}

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
