module IssueRecurring
  # NOTE: remove when https://www.redmine.org/issues/37803 is fixed
  module SchemaPatch
    def define(info, &block)
      super

      connection_pool.with_connection do |connection|
        info.except(:version).each do |id, v|
          connection.assume_plugin_migrated_upto_version(id, v)
        end
      end
    end
  end
end
