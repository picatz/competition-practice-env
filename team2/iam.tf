resource "google_project_iam_member" "project" {
  count  = "${length(var.team_members)}"
  role   = "roles/compute.osAdminLogin"
  member = "user:${var.team_members[count.index]}"
}
