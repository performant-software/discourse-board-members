const FKB_PRO_REGISTRATIONS = ["component:fkb-panel", "service:fkb-cache"];

export const DEFAULT_OUTLET = "discovery-list-container-top";
export const NAV_OUTLET = "discovery-navigation-bar-above";

const detectionCache = new WeakMap();

export function isFkbProActive(owner) {
  if (!owner) {
    return false;
  }

  if (detectionCache.has(owner)) {
    return detectionCache.get(owner);
  }

  const active = FKB_PRO_REGISTRATIONS.some((name) => {
    try {
      return !!owner.resolveRegistration?.(name);
    } catch {
      return false;
    }
  });

  detectionCache.set(owner, active);
  return active;
}

export function resolveOutlet(owner) {
  const configured = (settings.plugin_outlet || "").trim();

  if (configured && configured !== "auto") {
    return configured;
  }

  return isFkbProActive(owner) ? NAV_OUTLET : DEFAULT_OUTLET;
}

// True when the button ends up in the navigation column rather than above the
// topic list, either because FKB Pro is active or because the outlet was set by
// hand. The two placements need different styling.
export function isNavPlacement(owner) {
  return resolveOutlet(owner) === NAV_OUTLET;
}