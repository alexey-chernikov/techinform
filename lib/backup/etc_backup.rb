require_relative 'backup'

class EtcBackup < Backup
  def print_info
    puts "Run etc backup to #{filepath}..."
  end

  def backup_command
    'tar -c /etc'
  end
end