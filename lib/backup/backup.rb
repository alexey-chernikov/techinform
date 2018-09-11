require 'date'

class Backup
  DATE_FORMAT = '%Y-%d-%m-%H-%M'

  def initialize compress: true
    @compress = compress
    ensure_path
  end

  def compress?
    @compress
  end

  def backup_type
    self.class.to_s.gsub('Backup', '').downcase
  end

  def path
    "/backups/"
  end

  def ensure_path
    `mkdir -p #{path}`
  end

  def get_datetime_from_filename filename
    DateTime.strptime(filename.split('-')[2], DATE_FORMAT)
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


