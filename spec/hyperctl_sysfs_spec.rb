require 'spec_helper'
# pp must be required before fakefs
# see: https://github.com/defunkt/fakefs/issues/99
require 'pp'
require 'fakefs/spec_helpers'

describe Hyperctl::Sysfs do
  let(:hctl) { Hyperctl::Sysfs.new }
  include FakeFS::SpecHelpers

  context 'on a 8 physical core w/ HT enabled system' do
    include_context "sysfs_8core_w_ht"
    include_context "cpuinfo_8core_w_ht"

    context 'fakefs sanity checks' do
      it { expect(File.exists?(sysfs('cpu1', 'online'))).to be true }
      it { expect(File.exists?(sysfs('cpu1', 'topology/thread_siblings_list'))).to be true }
      it { expect(sysfs('cpu1', 'topology/thread_siblings_list')).to contain(/1,9/) }
    end

    describe '#new' do
      it 'finds all the cores' do
        expect(hctl.cpu_info).to eq(info)
      end
    end

    describe '#disable_core' do
      it 'disbles core_id 15' do
        Hyperctl::Sysfs.disable_core(15)

        expect(sysfs('cpu15', 'online')).to contain(/^0$/)
      end
    end

    context '#cores' do
      it 'lists all cores' do
        expect(hctl.cores).to eq((0 .. 15).to_a)
      end
    end

    context '#online_cores' do
      it 'lists all enabled cores' do
        expect(hctl.online_cores).to eq((0 .. 15).to_a)
      end
    end

    context '#offline_cores' do
      it 'lists all disabled cores' do
        expect(hctl.offline_cores).to eq []
      end
    end

    context '#sibling_cores' do
      it 'lists all smt cores' do
        expect(hctl.sibling_cores).to eq((8 .. 15).to_a)
      end
    end

    context '#all_cores_enabled?' do
      it 'returns true' do
        expect(hctl.all_cores_enabled?).to be true
      end
    end

    context '#all_siblings_disabled?' do
      it 'returns false' do
        expect(hctl.all_siblings_disabled?).to be false
      end
    end

    context '#enable_core' do
      it 'enables core_id 15' do
        Hyperctl::Sysfs.enable_core(15)

        expect(sysfs('cpu15', 'online')).to contain(/^1$/)
      end
    end
  end # on a 8 physical core w/ HT enabled system

  context 'on a 12 physical core w/ HT diabled system' do
    include_context "sysfs_12core_wo_ht"
    include_context "cpuinfo_12core_wo_ht"

    context 'fakefs sanity checks' do
      it { expect(File.exists?(sysfs('cpu0', 'online'))).to be false }
      it { expect(File.exists?(sysfs('cpu0', 'topology/thread_siblings_list'))).to be true }

      it { expect(File.exists?(sysfs('cpu1', 'online'))).to be true }
      it { expect(File.exists?(sysfs('cpu1', 'topology/thread_siblings_list'))).to be true }

      it { expect(File.exists?(sysfs('cpu23', 'online'))).to be true }
      it { expect(File.exists?(sysfs('cpu23', 'topology/thread_siblings_list'))).to be false }
    end

    context '#new' do
      it 'finds all the cores' do
        hctl =  Hyperctl::Sysfs.new
        expect(hctl.cpu_info).to eq(info)
      end
    end

    context '#disable_core' do
      it 'disbles core_id 15' do
        Hyperctl::Sysfs.disable_core(15)

        expect(sysfs('cpu15', 'online')).to contain(/^0$/)
      end
    end

    context '#cores' do
      it 'lists all cores' do
        expect(hctl.cores).to eq((0 .. 23).to_a)
      end
    end

    context '#online_cores' do
      it 'lists all enabled cores' do
        expect(hctl.online_cores).to eq((0 .. 11).to_a)
      end
    end

    context '#offline_cores' do
      it 'lists all disabled cores' do
        expect(hctl.offline_cores).to eq((12 .. 23).to_a)
      end
    end

    context '#sibling_cores' do
      it 'lists all smt cores' do
        expect(hctl.sibling_cores).to eq []
      end
    end

    context '#all_cores_enabled?' do
      it 'returns false' do
        expect(hctl.all_cores_enabled?).to be false
      end
    end

    context '#all_siblings_disabled?' do
      it 'returns true' do
        expect(hctl.all_siblings_disabled?).to be true
      end
    end

    context '#enable_core' do
      it 'enables core_id 15' do
        Hyperctl::Sysfs.enable_core(15)

        expect(sysfs('cpu15', 'online')).to contain(/^1$/)
      end
    end
  end # on a 12 physical core w/ HT disabled system
end
