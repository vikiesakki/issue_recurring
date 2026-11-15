# Redmine >= 6 (Rails >= 7.2, Zeitwerk only): plugin's lib/ is autoloaded and
# init.rb is evaluated inside a to_prepare block, so patches are (re)applied
# after each code reload. include()/prepend() are idempotent.
# NOTE: remove schema patches when https://www.redmine.org/issues/37803 is fixed
ActiveRecord::ConnectionAdapters::AbstractAdapter
  .include IssueRecurring::SchemaStatementsPatch
ActiveRecord::Schema.prepend IssueRecurring::SchemaPatch
ActiveRecord::SchemaDumper.prepend IssueRecurring::SchemaDumperPatch

Issue.include IssueRecurring::IssuePatch
# Helper module has to be patched before Controller is loaded. Loading
# Controller causes Helper module to be loaded and included. Any subsequent
# inclusions (i.e. change in ancestor chain) in Helper module won't be
# reflected in Controller's ancestor structure.
IssuesHelper.include IssueRecurring::IssuesHelperPatch
IssuesController.include IssueRecurring::IssuesControllerPatch

Project.include IssueRecurring::ProjectPatch

SettingsHelper.include IssueRecurring::SettingsHelperPatch
SettingsController.include IssueRecurring::SettingsControllerPatch

IssueRecurring::IssueRecurrencesViewListener

Redmine::Plugin.register :issue_recurring do
  name 'Issue recurring plugin'
  author 'cryptogopher'
  description 'Schedule Redmine issue recurrence based on multiple conditions'
  version '1.8'
  requires_redmine version_or_higher: '6.0.0'
  url 'https://github.com/cryptogopher/issue_recurring'
  author_url 'https://github.com/cryptogopher'

  project_module :issue_recurring do
    permission :view_issue_recurrences,
      {:issue_recurrences => [:index]},
      read: true
    permission :manage_issue_recurrences,
      {:issue_recurrences => [:new, :create, :edit, :update, :destroy]},
      require: :loggedin
  end
  menu :project_menu, :issue_recurrences,
    {:controller => 'issue_recurrences', :action => 'index'},
    :caption => :issue_recurrences_menu_caption,
    :after => :issues, :param => :project_id

  settings default: {
    author_login: nil,
    keep_assignee: false,
    journal_mode: :never,
    copy_recurrences: false,
    ahead_multiplier: 0,
    ahead_mode: :days
  }, partial: 'settings/issue_recurrences'
end
