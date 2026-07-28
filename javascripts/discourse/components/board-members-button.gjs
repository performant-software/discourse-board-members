import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { getOwner } from "@ember/owner";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { ajax } from "discourse/lib/ajax";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

const CACHE_TTL_MS = 60_000;
const groupCache = new Map();

function readCache(name) {
  const hit = groupCache.get(name);
  if (!hit) {
    return undefined;
  }
  if (Date.now() - hit.at > CACHE_TTL_MS) {
    groupCache.delete(name);
    return undefined;
  }
  return hit.group;
}

function writeCache(name, group) {
  groupCache.set(name, { group, at: Date.now() });
}

export default class BoardMembersButton extends Component {
  @service currentUser;
  @service router;

  @tracked group = null;

  get category() {
    const fromOutlet = this.args.outletArgs?.category ?? this.args.category;
    if (fromOutlet) {
      return fromOutlet;
    }

    try {
      return getOwner(this).lookup("service:discovery")?.category ?? null;
    } catch {
      return null;
    }
  }

  get groupName() {
    const slug = this.category?.slug;
    if (!slug) {
      return null;
    }

    return `${settings.group_name_prefix}${slug}`;
  }

  get canManage() {
    if (!this.group) {
      return false;
    }
    if (this.group.is_group_owner) {
      return true;
    }
    return this.currentUser?.staff;
  }

  get label() {
    const count = this.group?.user_count;
    if (typeof count === "number") {
      return i18n(themePrefix("manage_members_with_count"), { count });
    }
    return i18n(themePrefix("manage_members"));
  }

  get manageUrl() {
    return `/g/${this.groupName}`;
  }

  @action
  async loadGroup() {
    const name = this.groupName;

    if (!name || !this.currentUser) {
      this.group = null;
      return;
    }

    const cached = readCache(name);
    if (cached !== undefined) {
      this.group = cached;
      return;
    }

    let group = null;
    try {
      const result = await ajax(`/g/${name}.json`);
      group = result?.group ?? null;
    } catch {
      // 404 (no such group) or 403 (not visible to this user). Either way
      // there's nothing to manage, so stay quiet.
      group = null;
    }

    writeCache(name, group);

    if (!this.isDestroying && !this.isDestroyed) {
      this.group = group;
    }
  }

  @action
  goToMembers(event) {
    // Let modified clicks and middle clicks open a new tab as normal.
    if (
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey ||
      event.button !== 0
    ) {
      return;
    }

    event.preventDefault();
    groupCache.delete(this.groupName);
    this.router.transitionTo("group", this.groupName);
  }

  <template>
    {{#if this.groupName}}
      <div
        class="board-members"
        {{didInsert this.loadGroup}}
        {{didUpdate this.loadGroup this.groupName}}
      >
        {{#if this.canManage}}
          <a
            class="btn btn-default board-members__button"
            href={{this.manageUrl}}
            {{on "click" this.goToMembers}}
          >
            {{icon "users"}}
            <span class="d-button-label">{{this.label}}</span>
          </a>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
