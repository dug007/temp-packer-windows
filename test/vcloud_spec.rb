require_relative 'spec_helper'

describe 'box' do
  describe file('c:/vagrant/testdir/testfile.txt') do
    it { should be_file }
    it { should contain "Works" }
  end

  describe service('OpenSSH Server') do
    it { should be_installed  }
    it { should be_enabled  }
    it { should be_running  }
    it { should have_start_mode("Automatic")  }
  end

  describe service('VMware Tools') do
    it { should be_installed  }
    it { should be_enabled  }
    it { should be_running  }
    it { should have_start_mode("Automatic")  }
  end

  describe port(22) do
    it { should be_listening  }
  end

  describe port(3389) do
    it { should be_listening  }
  end

  describe port(5985) do
    it { should be_listening  }
  end

  # check for 10 GBit vmxnet3 network adapter
  describe command('& "ipconfig" /all') do
      it { should return_stdout(/Description(\.| )*: vmxnet3/)  }
  end
end
