require 'date'
require_relative '../techinform/defaults'
require 'highline'

class Backup
  attr_reader :dry_run
  DATE_FORMAT = '%Y-%m-%d-%H-%M'

  def initialize(compress: true, encrypt: nil, dry_run: true)
    @compress = compress
    @encrypt = encrypt.nil? ? !ENV['GPGKEY'].nil? : encrypt
    @dry_run = dry_run
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

  def backup_type_filename
    backup_type
  end

  def filename
    "#{backup_type_filename}-#{DateTime.now.strftime(DATE_FORMAT)}.#{filename_extension}"
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
    puts '--- test ' + filename
    DateTime.strptime(filename.split('.').first.split('-')[-5..-1].join('-'), DATE_FORMAT)
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

  def clean_files(prefix = 'local')
    puts(dry_run ? 'Performing dry run' : '!!!! Cleaning backups !!!!')
    if prefix =~ /^\//
      process_clean_files(prefix)
    else
      # Process each backup type
      Dir["#{Techinform::BACKUPS_PREFIX}/#{prefix}/backups/*"].each do |type|
        puts "Type: #{type}"
        # Get all backup name
        Dir["#{type}/*"].each do |path|
          process_clean_files(path)
        end
      end
    end
  end

  def process_clean_files(path)
    puts "Process files in path #{path}"
    # Get all files
    mark_files = mark_file_to_delete(path)
    mark_files.each do |file, delete|
      puts "#{file} #{"*" if delete}"
    end
    show_statistics(mark_files)
    unless dry_run
      return unless HighLine.new.agree "Delete #{mark_files.select{|file, delete| delete}.keys.size} files - Are you sure? (yes/no)"
      # Actually delete files
      mark_files.select{|file, delete| delete}.keys.each do |file|
        result = `rm #{file}`
        puts result unless result.empty?
      end
    end
  end

  def show_statistics(mark_files)
    files_to_delete, files_to_store, size_to_delete, size_to_store  = 0, 0, 0, 0
    mark_files.each do |file, is_delete|
      if is_delete
        files_to_delete += 1
        size_to_delete += File.size(file)
      else
        files_to_store += 1
        size_to_store += File.size(file)
      end
    end
    puts "\u{1f480} Files to delete - #{files_to_delete}, files size - #{human_filesize(size_to_delete)} \u{1f480}"
    puts "Files to store - #{files_to_store}, files size - #{human_filesize(size_to_store)}"
  end

  # Mark files to delete
  # { 'filenpath' => true, 'filepath2' => false }
  # true - delete file, false - do not delete
  def mark_file_to_delete(path)
    result = {}
    months_taken = []
    days_taken = []
    Dir["#{path}/*"].sort.each do |file|
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
      else
        result[file] = false
      end
    end
    return result
  end

  def human_filesize(size)
    {
        ' B'  => 1024,
        ' KB' => 1024 * 1024,
        ' MB' => 1024 * 1024 * 1024,
        ' GB' => 1024 * 1024 * 1024 * 1024,
        ' TB' => 1024 * 1024 * 1024 * 1024 * 1024
    }.each_pair { |e, s| return "#{(size.to_f / (s / 1024)).round(2)}#{e}" if size < s }
  end
end


