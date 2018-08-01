require 'spec_helper'

describe 'cron::entry' do
  jobname = 'jobname'
  cronfile = "/etc/cron.d/pup_#{jobname}.cron"
  command = '/bin/false'
  let(:title) { jobname }
  let(:params) do
    {
      'command' => command,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        unless os_facts['os'].is_a?(Hash)
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
      end

      it { is_expected.to compile }

      if ['solaris-11-i86pc', 'freebsd-11-amd64'].include?(os)
        context 'with default params' do
          it { is_expected.to contain_cron('pup_jobname') }
        end
      else
        context 'with default params' do
          it do
            is_expected.to contain_file(cronfile) \
              .with_content("* * * * * root #{command}\n")
          end
        end

        context 'with persistent param true' do
          let(:params) do
            super().merge(
              'persistent' => true,
            )
          end

          it { is_expected.to contain_file("/etc/cron.d/persistent_#{jobname}.cron") }
        end

        context 'with special paramter' do
          let(:params) do
            super().merge(
              'special' => '@reboot',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("@reboot root #{command}\n")
          end
        end

        context 'with special param and non-special param' do
          let(:params) do
            super().merge(
              'special' => '@monthly',
              'minute' => '0',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("@monthly root #{command}\n")
          end
        end

        # These tests should pass
        context 'with asterisk time param' do
          let(:params) do
            super().merge(
              'minute'  => '*',
              'hour'    => '*',
              'day'     => '*',
              'month'   => '*',
              'weekday' => '*',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("* * * * * root #{command}\n")
          end
        end

        context 'with single Integer time param (min)' do
          let(:params) do
            super().merge(
              'minute'  => 0,
              'hour'    => 0,
              'day'     => 1,
              'month'   => 1,
              'weekday' => 0,
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("0 0 1 1 0 root #{command}\n")
          end
        end

        context 'with single Integer time param (max)' do
          let(:params) do
            super().merge(
              'minute'  => 59,
              'hour'    => 23,
              'day'     => 31,
              'month'   => 12,
              'weekday' => 7,
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("59 23 31 12 7 root #{command}\n")
          end
        end

        context 'with stringified Integer time param (min)' do
          let(:params) do
            super().merge(
              'minute'  => '0',
              'hour'    => '0',
              'day'     => '1',
              'month'   => '1',
              'weekday' => '0',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("0 0 1 1 0 root #{command}\n")
          end
        end

        context 'with stringified Integer time param (max)' do
          let(:params) do
            super().merge(
              'minute'  => '59',
              'hour'    => '23',
              'day'     => '31',
              'month'   => '12',
              'weekday' => '7',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("59 23 31 12 7 root #{command}\n")
          end
        end

        context 'with Integer Array time param' do
          let(:params) do
            super().merge(
              'minute'  => [0, 30, 59],
              'hour'    => [0, 6, 23],
              'day'     => [1, 15, 31],
              'month'   => [1, 6, 12],
              'weekday' => [0, 3, 7],
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("0,30,59 0,6,23 1,15,31 1,6,12 0,3,7 root #{command}\n")
          end
        end

        context 'with String steps on time param' do
          let(:params) do
            super().merge(
              'minute'  => '0-59/59',
              'hour'    => '0-23/23',
              'day'     => '1-31/31',
              'month'   => '1-12/12',
              'weekday' => '1-7/7',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("0-59/59 0-23/23 1-31/31 1-12/12 1-7/7 root #{command}\n")
          end
        end

        context 'with String range time param' do
          let(:params) do
            super().merge(
              'minute'  => '0-59',
              'hour'    => '0-23',
              'day'     => '1-31',
              'month'   => '1-12',
              'weekday' => '0-7',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("0-59 0-23 1-31 1-12 0-7 root #{command}\n")
          end
        end

        context 'with String multiple ranges' do
          let(:params) do
            super().merge(
              'minute'  => '0-5,10,40-59',
              'hour'    => '0-4,10,21-23',
              'day'     => '1-5,10,25-31',
              'month'   => '1-3,10,11-12',
              'weekday' => '0-2,5,6-7',
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("0-5,10,40-59 0-4,10,21-23 1-5,10,25-31 1-3,10,11-12 0-2,5,6-7 root #{command}\n")
          end
        end

        context 'with environment hash' do
          let(:params) do
            super().merge(
              'environment' => {
                'PATH' => '/bin:/sbin:/usr/bin',
                'MAILTO' => '',
              },
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("PATH=/bin:/sbin:/usr/bin\nMAILTO=\n* * * * * root #{command}\n")
          end
        end

        context 'with environment array' do
          let(:params) do
            super().merge(
              'environment' => ['# environment', 'PATH = /bin:/sbin:/usr/bin', 'MAILTO='],
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("# environment\nPATH = /bin:/sbin:/usr/bin\nMAILTO=\n* * * * * root #{command}\n")
          end
        end

        context 'with environment string' do
          let(:params) do
            super().merge(
              'environment' => "# environment\nPATH = /bin:/sbin:/usr/bin\nMAILTO=\n",
            )
          end

          it do
            is_expected.to contain_file(cronfile) \
              .with_content("# environment\nPATH = /bin:/sbin:/usr/bin\nMAILTO=\n* * * * * root #{command}\n")
          end
        end

        #
        # Failing tests
        #
        context 'with single Integer time param (day,min-1)' do
          let(:params) do
            super().merge(
              'day' => 0,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single Integer time param (month,min-1)' do
          let(:params) do
            super().merge(
              'month' => 0,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single Integer time param (minute,max+1)' do
          let(:params) do
            super().merge(
              'minute' => 60,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single Integer time param (hour,max+1)' do
          let(:params) do
            super().merge(
              'hour' => 24,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single Integer time param (day,max+1)' do
          let(:params) do
            super().merge(
              'day' => 32,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single Integer time param (month,max+1)' do
          let(:params) do
            super().merge(
              'month' => 13,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single Integer time param (weekday,max+1)' do
          let(:params) do
            super().merge(
              'weekday' => 8,
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (day,min-1)' do
          let(:params) do
            super().merge(
              'day' => '0',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (month,min-1)' do
          let(:params) do
            super().merge(
              'month' => '0',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (minute,max+1)' do
          let(:params) do
            super().merge(
              'minute' => '60',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (hour,max+1)' do
          let(:params) do
            super().merge(
              'hour' => '24',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (day,max+1)' do
          let(:params) do
            super().merge(
              'day' => '32',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (month,max+1)' do
          let(:params) do
            super().merge(
              'month' => '13',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with single stringified Integer time param (weekday,max+1)' do
          let(:params) do
            super().merge(
              'weekday' => '8',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and steps on time param (minute,max+1)' do
          let(:params) do
            super().merge(
              'minute' => '0-60/59',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and max+1 steps on time param (minute)' do
          let(:params) do
            super().merge(
              'minute' => '0-59/60',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and steps on time param (hour,max+1)' do
          let(:params) do
            super().merge(
              'hour' => '0-24/23',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and max+1 steps on time param (hour)' do
          let(:params) do
            super().merge(
              'hour' => '0-23/24',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and steps on time param (day,max+1)' do
          let(:params) do
            super().merge(
              'day' => '1-32/31',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and max+1 steps on time param (day)' do
          let(:params) do
            super().merge(
              'day' => '1-31/32',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and steps on time param (month,max+1)' do
          let(:params) do
            super().merge(
              'month' => '1-13/12',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and max+1 steps on time param (month)' do
          let(:params) do
            super().merge(
              'month' => '1-12/13',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and steps on time param (weekday,max+1)' do
          let(:params) do
            super().merge(
              'weekday' => '1-8/7',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range and max+1 steps on time param (weekday)' do
          let(:params) do
            super().merge(
              'weekday' => '1-7/8',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with zero-padded time param (minute)' do
          let(:params) do
            super().merge(
              'minute' => '00',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with zero-padded time param (hour)' do
          let(:params) do
            super().merge(
              'hour' => '00',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with zero-padded time param (day)' do
          let(:params) do
            super().merge(
              'day' => '01',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with zero-padded time param (month)' do
          let(:params) do
            super().merge(
              'month' => '01',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with zero-padded time param (weekday)' do
          let(:params) do
            super().merge(
              'weekday' => '00',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with non-numeric String time param (minute)' do
          let(:params) do
            super().merge(
              'minute' => 'x',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with non-numeric String time param (hour)' do
          let(:params) do
            super().merge(
              'hour' => 'x',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with non-numeric String time param (day)' do
          let(:params) do
            super().merge(
              'day' => 'x',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with non-numeric String time param (month)' do
          let(:params) do
            super().merge(
              'month' => 'x',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with non-numeric String time param (weekday)' do
          let(:params) do
            super().merge(
              'weekday' => 'x',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end

        context 'with String range missing first value time param (minute)' do
          let(:params) do
            super().merge(
              'minute' => '-59',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end
        context 'with String range missing first value time param (hour)' do
          let(:params) do
            super().merge(
              'hour' => '-23',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end
        context 'with String range missing first value time param (day)' do
          let(:params) do
            super().merge(
              'day' => '-31',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end
        context 'with String range missing first value time param (month)' do
          let(:params) do
            super().merge(
              'month' => '-12',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end
        context 'with String range missing first value time param (weekday)' do
          let(:params) do
            super().merge(
              'weekday' => '-7',
            )
          end

          it do
            is_expected.to raise_error(Puppet::PreformattedError)
          end
        end
      end
    end
  end
end
