require 'spec_helper'

describe Hyperctl do
  let(:hctl) { Hyperctl::Sysfs.new }

  describe '#status' do
    context '8 physical cores with HT enabled' do
      include_context "cpuinfo_8core_w_ht"

      text =<<EOS
cpu0 : enabled  - hypertheading: enabled
cpu1 : enabled  - hypertheading: enabled
cpu2 : enabled  - hypertheading: enabled
cpu3 : enabled  - hypertheading: enabled
cpu4 : enabled  - hypertheading: enabled
cpu5 : enabled  - hypertheading: enabled
cpu6 : enabled  - hypertheading: enabled
cpu7 : enabled  - hypertheading: enabled
cpu8 : enabled  - hypertheading: enabled
cpu9 : enabled  - hypertheading: enabled
cpu10: enabled  - hypertheading: enabled
cpu11: enabled  - hypertheading: enabled
cpu12: enabled  - hypertheading: enabled
cpu13: enabled  - hypertheading: enabled
cpu14: enabled  - hypertheading: enabled
cpu15: enabled  - hypertheading: enabled
EOS
      it do
        hctl.stubs(:cpu_info).returns(info)
        expect(Hyperctl.status(hctl)).to eq(text)
      end
    end # 8 physical cores with HT enabled

    context '12 physical cores with HT disabled' do
      include_context "cpuinfo_12core_wo_ht"
      text =<<EOS
cpu0 : enabled  - hypertheading: disabled
cpu1 : enabled  - hypertheading: disabled
cpu2 : enabled  - hypertheading: disabled
cpu3 : enabled  - hypertheading: disabled
cpu4 : enabled  - hypertheading: disabled
cpu5 : enabled  - hypertheading: disabled
cpu6 : enabled  - hypertheading: disabled
cpu7 : enabled  - hypertheading: disabled
cpu8 : enabled  - hypertheading: disabled
cpu9 : enabled  - hypertheading: disabled
cpu10: enabled  - hypertheading: disabled
cpu11: enabled  - hypertheading: disabled
cpu12: disabled - hypertheading: disabled
cpu13: disabled - hypertheading: disabled
cpu14: disabled - hypertheading: disabled
cpu15: disabled - hypertheading: disabled
cpu16: disabled - hypertheading: disabled
cpu17: disabled - hypertheading: disabled
cpu18: disabled - hypertheading: disabled
cpu19: disabled - hypertheading: disabled
cpu20: disabled - hypertheading: disabled
cpu21: disabled - hypertheading: disabled
cpu22: disabled - hypertheading: disabled
cpu23: disabled - hypertheading: disabled
EOS
      it do
        hctl.stubs(:cpu_info).returns(info)

        expect(Hyperctl.status(hctl)).to eq(text)
      end
    end # 12 physical cores with HT disabled
  end #status

  describe '#disable' do
    context '8 physical cores with HT enabled' do
      include_context "cpuinfo_8core_w_ht"

      it 'should turn cores off' do
        hctl.stubs(:cpu_info).returns(info)
        8.upto(15).each do |core_id|
          Hyperctl::Sysfs.expects(:disable_core).with(core_id).once
        end

        Hyperctl.disable(hctl)
      end
    end # 8 physical cores with HT enabled

    context '12 physical cores with HT disabled' do
      include_context "cpuinfo_12core_wo_ht"

      it 'should do nothing' do
        # all SMT cores are already disabled
        hctl.stubs(:cpu_info).returns(info)
        Hyperctl::Sysfs.expects(:disable_core).never

        Hyperctl.disable(hctl)
      end
    end # 12 physical cores with HT disabled
  end #disable

  describe '#enable' do
    context '8 physical cores with HT enabled' do
      include_context "cpuinfo_8core_w_ht"

      it 'should do nothing' do
        # all SMT cores are already enabled
        hctl.stubs(:cpu_info).returns(info)
        Hyperctl::Sysfs.expects(:enable_core).never

        Hyperctl.enable(hctl)
      end
    end # 8 physical cores with HT enabled

    context '12 physical cores with HT disabled' do
      include_context "cpuinfo_12core_wo_ht"

      it 'should turn cores on' do
        hctl.stubs(:cpu_info).returns(info)
        12.upto(23).each do |core_id|
          Hyperctl::Sysfs.expects(:enable_core).with(core_id).once
        end

        Hyperctl.enable(hctl)
      end
    end # 12 physical cores with HT disabled
  end #enable
end
