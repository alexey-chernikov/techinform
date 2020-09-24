def bzip2
  @bzip2 ||= (system('which lbzip2 > /dev/null') ? 'lbzip2' : 'bzip2')
end

def bunzip2
  @bunzip2 ||= (system('which lbunzip2 > /dev/null') ? 'lbunzip2' : 'bunzip2')
end
