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

  def filepath
    "#{path}/#{filename}"
  end

  def ensure_path
    `mkdir -p #{path}`
  end

  def clean_files
    result = {} # true - delete file, false - do not delete
    months_taken = []
    days_taken = []
    files = Dir.entries(path) - ['.', '..']
    files.each do |file|
      datetime = get_datetime_from_filename(file)
      day_id = datetime.strftime('%Y-%m-%d')
      month_id = datetime.strftime('%Y-%m')
      if datetime < (DateTime.now << 2)     # 1 month ago
        if datetime.day == 1 && !(months_taken.include? month_id)
          result[file] = false
          months_taken << month_id
        else
          result[file] = true
        end
      elsif datetime < DateTime.now - 14 # 2 weeks ago
        if [1, 7, 14, 21].include?(datetime.day) && !(days_taken.include?(day_id))
          result[file] = false
          days_taken << day_id
        else
          result[file] = true
        end
      elsif days_taken.includ
      end
    end
  end
end