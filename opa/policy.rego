package access
default allow = false

allow {
  some p
  p := input.principal.profiles[_]
  input.context.now_min >= p.vf_min
  input.context.now_min <= p.vt_min

  some pol
  pol := input.context.policies[_]
  pol.profile_id == p.id
  pol.area_id    == input.resource.area_id

  some s
  s := input.context.allowed_schedule_ids[_]
  pol.schedule_id == s

  some m
  m := pol.modifiers[_]
  m == input.context.required_modifier
}
