require 'date'
require_relative '../techinform/defaults'
require 'highline'

class Backup
  DATE_FORMAT = '%Y-%m-%d-%H-%M'

  def initialize compress: true, encrypt: nil
    @compress = compress
    @encrypt = encrypt.nil? ? !ENV['GPGKEY'].nil? : encrypt
    raise "GPGKEY environment variable should be specified for encryption" if encrypt? && ENV['GPGKEY'].nil?
    ensure_path
  end

  def compress?
    @compress
  end

  def encrypt?
    @encrypt
  end

  def debug?
    ENV['DEBUG'] == 'true'
  end

  def backup_type
    self.class.to_s.gsub('Backup', '').downcase
  end

  def filename
    "#{backup_type}-#{DateTime.now.strftime(DATE_FORMAT)}.#{filename_extension}"
  end

  def filename_extension(base = 'tar')
    if encrypt?
      "#{base}.gpg"
    else
      if compress?
        "#{base}.bz2"
      else
        base
      end
    end
  end

  # Main pipe, which generates data for backup
  def backup_command
    "echo Just text to backup"
  end

  def encrypt_compress_pipe_command
    if encrypt?
      "| gpg2 --encrypt #{"--compress-algo=bzip2" if compress?} --recipient=#{ENV['GPGKEY']}"
    else
      "| bzip2" if compress?
    end
  end

  def output_command
    "> #{filepath}"
  end

  def path
    "#{Techinform::BACKUPS_LOCAL_PREFIX}/#{backup_type}"
  end

  def filepath
    "#{path}/#{filename}"
  end

  def ensure_path
    `mkdir -p #{path}`
  end

  def get_datetime_from_filename filename
    puts 'Filename: ' + filename.split('.').first.split('-')[2..6].join('-')
    DateTime.strptime(filename.split('.').first.split('-')[2..6].join('-'), DATE_FORMAT)
  end

  def print_info
    puts "Run backup to #{filepath}..."
  end

  def run
    print_info
    command = "#{backup_command} #{encrypt_compress_pipe_command} #{output_command}"
    puts "Command: #{command}" if debug?
    output = `#{command}`
    puts output unless output.empty?
  end

  # Change it in child class
  def minimum_backup_size
    50
  end

  # It worth to redefine that method to better check backup integrity
  # Return true if everything ok
  def verify_backup
    File.size(filepath) > minimum_backup_size
  end

  def clean_files(prefix = 'local', dry_run = true)
    puts(dry_run ? 'Performing dry run' : '!!!! Cleaning backups !!!!')
    result = {} # true - delete file, false - do not delete
    months_taken = []
    days_taken = []
    # Process each backup type
    Dir["#{Techinform::BACKUPS_PREFIX}/#{prefix}/*"].each do |type|
      puts "Type: #{type}"
      # Get all backup name
      Dir["#{type}/*"].each do |name|
        puts "Name: #{name}"
        # Get all files
        Dir["#{name}/*"].sort.each do |file|
          datetime = get_datetime_from_filename(file)
          day_id = datetime.strftime('%Y-%m-%d')
          month_id = datetime.strftime('%Y-%m')
          if datetime < (DateTime.now << 2)     # 2 month ago
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
          end
        end
        result.each do |file, delete|
          puts "#{file} #{"*" if delete}"
        end
        unless dry_run
          return unless HighLine.new.agree "Delete #{result.select{|file, delete| delete}.keys.size} files - Are you sure? (yes/no)"
          # Actually delete files
          result.select{|file, delete| delete}.keys.each do |file|
            puts `rm #{file}`
          end
        end
      end
    end

  end
end


