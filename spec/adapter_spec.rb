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
    @adapter    = DataMapper::Spec.adapter
    @repository = DataMapper.repository(@adapter.name)
    @h2 = defined?(DataMapper::Adapters::H2Adapter)    && @adapter.kind_of?(DataMapper::Adapters::H2Adapter)
  end

#  it_should_behave_like "An Adapter"
#  it_should_behave_like "A DataObjects Adapter"
  describe '#create' do
    describe 'serial properties' do
      before :all do
        class ::Article
          include DataMapper::Resource

          property :id, Serial

          auto_migrate!
        end

        reset_log

        Article.create
      end

      it 'should not send NULL values' do
        statement = if @h2
          /\AINSERT INTO `articles` \(\) VALUES \(\)\z/
        elsif @oracle
          /\AINSERT INTO "ARTICLES" \("ID"\) VALUES \(DEFAULT\) RETURNING "ID"/
        elsif supports_default_values? && supports_returning?
          /\AINSERT INTO "articles" DEFAULT VALUES RETURNING \"id\"\z/
        elsif supports_default_values?
          /\AINSERT INTO "articles" DEFAULT VALUES\z/
        else
          /\AINSERT INTO "articles" \(\) VALUES \(\)\z/
        end

        puts "================="
        puts statement
        puts "================="
        log_output.first.should =~ statement
      end

    end
  end

=begin
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
=end
end
