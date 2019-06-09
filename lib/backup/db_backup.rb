require_relative 'backup'

class DbBackup < Backup
  attr_reader :password, :user, :database, :host

  def initialize user: nil, database: nil, password: nil, compress: true, host: nil, encrypt: nil
    super compress: compress, encrypt: encrypt
    user = ENV['USER'] if user.nil?
    password = ENV['PASSWORD'] if password.nil?
    @password, @user, @database, @host = password, user, database, host
    ensure_path unless database.nil?
  end

  def filename
    "#{backup_type}-#{database}-#{DateTime.now.strftime(DATE_FORMAT)}.#{filename_extension('sql')}"
  end

  def path
    "#{Techinform::BACKUPS_LOCAL_PREFIX}/#{backup_type}/#{database}"
  end

  def restore_path
    "#{Techinform::BACKUPS_ALL_PREFIX}/backups/#{backup_type}/#{database}"
  end
end