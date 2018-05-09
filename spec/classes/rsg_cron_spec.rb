require 'spec_helper'

describe 'rsg_cron' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      if os == 'solaris-11-i86pc'
        it { is_expected.not_to contain_file('/usr/local/sbin/purge_cron.sh') }
      else
        it { is_expected.to contain_file('/usr/local/sbin/purge_cron.sh') }
      end
    end
  end
end
