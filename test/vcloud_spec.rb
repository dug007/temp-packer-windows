require_relative 'spec_helper'

describe 'box' do
  # this tests if rsync works from bin/test-box-vcloud.bat
  describe file('c:/vagrant/testdir/testfile.txt') do
    it { should be_file }
    it { should contain "Works" }
  end

  # check SSH
  describe service('OpenSSH Server') do
    it { should be_installed  }
    it { should be_enabled  }
    it { should be_running  }
    it { should have_start_mode("Automatic")  }
  end
  describe port(22) do
    it { should be_listening  }
  end

  describe service('VMware Tools') do
    it { should be_installed  }
    it { should be_enabled  }
    it { should be_running  }
    it { should have_start_mode("Automatic")  }
  end


  # check WinRM
  describe port(5985) do
    it { should be_listening  }
  end

  # check RDP
  describe port(3389) do
    it { should be_listening  }
  end
  describe windows_registry_key('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\fDenyTSConnections') do
    it { should exist  }
    it { should have_property('dword value', :type_dword)  }
    it { should have_value('0')  }
  end
  describe windows_registry_key('HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\UserAuthentication') do
    it { should exist  }
    it { should have_property('dword value', :type_dword)  }
    it { should have_value('0')  }
  end

  # check for 10 GBit vmxnet3 network adapter
  describe command('& "ipconfig" /all') do
      it { should return_stdout(/Description(\.| )*: vmxnet3/)  }
  end
end
