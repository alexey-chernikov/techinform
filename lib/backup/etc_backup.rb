require_relative 'backup'

class EtcBackup < Backup
  def run
    puts "Run etc backup to #{filepath}..."
    output = `tar -c /etc #{"| bzip2" if compress?} > #{filepath}`
    puts output unless output.empty?
  end
end