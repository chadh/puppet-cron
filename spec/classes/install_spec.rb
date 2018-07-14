require 'spec_helper'

describe 'rsg_cron::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) {
        if not os_facts['os'].is_a?(Hash)
          os_facts['os'] = {}
        end

        case os
        when 'solaris-11-i86pc'
          os_facts['os']['family'] = 'Solaris'
        when 'freebsd-11-amd64'
          os_facts['os']['family'] = 'FreeBSD'
        when 'centos-7-x86_64'
          os_facts['os']['family'] = 'RedHat'
        end

        os_facts
      }

      it { is_expected.to compile }

      if os == 'solaris-11-i86pc' or os == 'freebsd-11-amd64'
        it { is_expected.not_to contain_file('/usr/local/sbin/purge_cron.sh') }
      else
        it { is_expected.to contain_file('/usr/local/sbin/purge_cron.sh') }
      end

      if os == 'freebsd-11-amd64'
        it { is_expected.not_to contain_package('cron') }
      elsif os == 'solaris-11-i86pc'
        it { is_expected.to contain_package('SUNWcs') }
      elsif os == 'centos-7-x86_64'
        it { is_expected.to contain_package('cronie') }
      end
    end
  end
end
