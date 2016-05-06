require 'spec_helper'

describe 'aar::default' do

  describe package('apache2') do
    it { should be_installed }
  end

  describe service('apache2') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port('80') do
    it { should be_listening }
  end

  describe package('mysql-server') do
    it { should be_installed }
  end

  describe service('mysql') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port('3306') do
    it { should be_listening }
  end

  describe command('curl localhost') do
    its(:stdout) { should match /This is the log on page for Awesome Appliance/ }
  end
end
