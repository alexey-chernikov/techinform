module Techinform
  BACKUPS_PREFIX = '/backups'

  def self.backups_syncing_location(server, type)
    "#{BACKUPS_PREFIX}/#{server}/#{type}"
  end
end