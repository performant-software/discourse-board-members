const FKB_PRO_REGISTRATIONS = ["component:fkb-panel", "service:fkb-cache"];

export const DEFAULT_OUTLET = "discovery-list-container-top";

export const CONTROLS_OUTLET = "before-create-topic-button";

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

  return isFkbProActive(owner) ? CONTROLS_OUTLET : DEFAULT_OUTLET;
}

export function isControlsPlacement(owner) {
  return resolveOutlet(owner) === CONTROLS_OUTLET;
}