require_relative 'backup'

class FilesBackup < Backup
  attr_reader :files_backup

  def initialize files_backup = '/etc', compress = true, encrypt = nil
    @files_backup = files_backup
    super compress: compress, encrypt: encrypt
  end

  def print_info
    puts "Run #{files_backup} backup to #{filepath}..."
  end

  def backup_type_filename
    files_backup.sub(/^\//, '').gsub('/', '_')
  end

  def path
    "#{Techinform::BACKUPS_LOCAL_PREFIX}/#{backup_type}/#{backup_type_filename}"
  end

  def backup_command
    "tar -c #{files_backup}"
  end
end