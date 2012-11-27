require 'win32/registry'
confine :kernel => :windows

KEY_WOW64_64KEY = 0x100  
KEY_WOW64_32KEY = 0x200

def value_exists?(path,key)
  reg_type = Win32::Registry::KEY_READ | KEY_WOW64_64KEY #| KEY_WOW64_32KEY - testing on 64bit only
  begin
    Win32::Registry::HKEY_LOCAL_MACHINE.open(path, reg_type) {|reg| regkey = reg[key]}
  rescue
      return false
  end
end

if   (value_exists?("SYSTEM\\CurrentControlSet\\Control\\Session Manager\\",'PendingFileRenameOperations')) or
     (value_exists?("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\",'RebootPending')) or
     (value_exists?("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update",'RebootRequired'))
  bool_reboot=1
else
  bool_reboot=0 
end
  
Facter.add(:ise_reboot_state) { setcode { bool_reboot } }