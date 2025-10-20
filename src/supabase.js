import { createClient } from "@supabase/supabase-js";

const supabaseUrl = "https://ypeoqeicujzkjhjidaof.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwZW9xZWljdWp6a2poamlkYW9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5NzY3NjcsImV4cCI6MjA3NjU1Mjc2N30.w4_mXuc7-JmnN2JhE9_zCQmxUNb0-TXrdOEPBidaCY8";

export const supabase = createClient(supabaseUrl, supabaseKey);
