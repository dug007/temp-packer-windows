require_relative 'spec_helper'

describe 'box' do
  describe file('c:/vagrant/testdir/testfile.txt') do
    it { should be_file }
    its(:content) { should match /Works/ }
  end

end
