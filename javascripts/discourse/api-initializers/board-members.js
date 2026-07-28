import { apiInitializer } from "discourse/lib/api";
import BoardMembersButton from "../components/board-members-button";

export default apiInitializer((api) => {
  const outlet = settings.plugin_outlet || "discovery-list-container-top";
  api.renderInOutlet(outlet, BoardMembersButton);
});
