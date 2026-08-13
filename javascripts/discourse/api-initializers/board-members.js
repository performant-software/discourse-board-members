import { apiInitializer } from "discourse/lib/api";
import BoardMembersButton from "../components/board-members-button";
import { resolveOutlet } from "../lib/fkb-pro-support";

export default apiInitializer((api) => {
  const owner = api.container?.owner ?? api.container;
  api.renderInOutlet(resolveOutlet(owner), BoardMembersButton);
});
