module Techinform
  BACKUPS_PREFIX = '/backups'
  BACKUPS_LOCAL_PREFIX = "#{BACKUPS_PREFIX}/local"

  def self.backups_syncing_location(server, type)
    "#{BACKUPS_PREFIX}/#{server}/#{type}"
  end
end