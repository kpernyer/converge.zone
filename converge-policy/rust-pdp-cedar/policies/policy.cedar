// Cedar policy: mirrors the SQL join as declarative checks.
// We avoid custom time functions by passing numeric minutes in context/profiles.

permit(principal, action in [Action::"open"], resource)
when {
  // principal.profiles is a list of records with fields: id, vf_min, vt_min
  // context.now_min is current time in minutes, e.g., HH*60 + MM
  exists p in principal.profiles {
    context.now_min >= p.vf_min &&
    context.now_min <= p.vt_min &&

    // context.policies is a list of records (profile_id, area_id, schedule_id, modifiers[])
    exists pol in context.policies {
      pol.profile_id == p.id &&
      pol.area_id == resource.area_id &&
      pol.schedule_id in context.allowed_schedule_ids &&
      context.required_modifier in pol.modifiers
    }
  }
};
