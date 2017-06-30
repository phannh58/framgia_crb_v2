class Permission < ApplicationRecord
  enum permission_type: %i(make_changes_and_manage_sharing
                           make_changes_to_events
                           see_all_event_details
                           see_only_free_or_busy_hide_details)
end
