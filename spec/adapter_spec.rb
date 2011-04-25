require 'dm-core'
require 'spec_helper'

require 'dm-core/spec/shared/adapter_spec'
require 'dm-do-adapter/spec/shared_spec'

require 'dm-migrations'
require 'dm-h2-adapter/spec/setup'

ENV['ADAPTER']          = 'h2'
ENV['ADAPTER_SUPPORTS'] = 'all'

describe 'DataMapper::Adapters::H2Adapter' do

  before :all do
    puts "hi"
    @adapter    = DataMapper::Spec.adapter
    @repository = DataMapper.repository(@adapter.name)
  end

  it_should_behave_like "An Adapter"
  it_should_behave_like "A DataObjects Adapter"

  describe "with 'h2' as adapter name" do
    subject { DataMapper::Adapters::H2Adapter.new(:default, { :adapter => 'h2' }) }
    it { subject.options[:adapter].should == 'h2' }
  end

  describe "with 'database' given as Symbol" do
    subject { DataMapper::Adapters::H2Adapter.new(:default, { :adapter => 'h2', :database => :name }) }
    it { subject.options[:path].should == 'name' }
  end

  describe "with 'path' given as Symbol" do
    subject { DataMapper::Adapters::H2Adapter.new(:default, { :adapter => 'h2', :path => :name }) }
    it { subject.options[:path].should == 'name' }
  end

  describe "with 'database' given as String" do
    subject { DataMapper::Adapters::H2Adapter.new(:default, { :adapter => 'h2', 'database' => :name }) }
    it { subject.options[:path].should == 'name' }
  end

  describe "with 'path' given as String" do
    subject { DataMapper::Adapters::H2Adapter.new(:default, { :adapter => 'h2', 'path' => :name }) }
    it { subject.options[:path].should == 'name' }
  end

  describe "with blank 'path' and 'database' given as Symbol" do
    subject { DataMapper::Adapters::H2Adapter.new(:default, { :adapter => 'h2', 'path' => '', :database => :name }) }
    it { subject.options[:path].should == 'name' }
  end

end
