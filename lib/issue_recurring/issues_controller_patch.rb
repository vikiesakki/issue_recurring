module IssueRecurring
  module IssuesControllerPatch
    extend ActiveSupport::Concern

    included do
      include LoadIssueRecurrences

      before_action :load_issue_recurrences, only: [:show]
    end
  end
end
