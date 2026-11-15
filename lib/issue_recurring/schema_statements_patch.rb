module IssueRecurring
  # NOTE: remove when https://www.redmine.org/issues/37803 is fixed
  module SchemaStatementsPatch
    def assume_plugin_migrated_upto_version(plugin_id, version)
      plugin = Redmine::Plugin.find(plugin_id)
      version = version.to_i

      migrated = Redmine::Plugin::Migrator.get_all_versions(plugin)
      versions = plugin.migrations
      inserting = (versions - migrated).select { |v| v <= version }
      if inserting.any?
        pool.schema_migration.create_table
        execute insert_versions_sql(inserting.map! { |v| "#{v}-#{plugin_id}" })
      end
    rescue Redmine::PluginNotFound
      # Schema may reference plugins that are not installed - ignore them
    end
  end
end
