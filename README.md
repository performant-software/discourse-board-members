# Board Members

This Discourse theme component allows group moderators to manage the list of board members via a button in the board UI instead of having to navigate to the group settings menu.

To connect a group to a board, the group must have the same slug as the board (minus whatever value, if any, you choose for the Group Name Prefix option).

## FKB Pro

This component supports the built-in themes as of August 2026, as well as FKB Pro.

FKB Pro is detected automatically. When it is active and the Plugin Outlet setting is left at `auto`, the button renders into `before-create-topic-button` so it sits in the category navigation controls immediately left of New Topic, sharing that row at a matching width. On mobile, where FKB Pro turns those controls into a floating action stack, it follows the theme and becomes icon-only.

Without FKB Pro the button renders above the topic list as before. Set Plugin Outlet to an explicit outlet name to override any of this.
