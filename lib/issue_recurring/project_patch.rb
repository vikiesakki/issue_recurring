module IssueRecurring
  module ProjectPatch
    extend ActiveSupport::Concern

    included do
      has_many :recurrences, class_name: 'IssueRecurrence', dependent: :destroy,
        through: :issues
    end
  end
end
