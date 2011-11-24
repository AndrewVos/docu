$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../../lib")))
require "minitest/pride"
require "minitest/autorun"
require "minitest/spec"
require "rake"
require "docu/rake/task"

module Docu
  module Rake
    describe Task do
      before do
        File.delete "TEST-README.md.docu" if File.exist? "TEST-README.md.docu"
        File.delete "TEST-README.md" if File.exist? "TEST-README.md"
      end

      it "has a default name" do
        Task.new.name.must_equal :docu
      end

      it "can have any name" do
        Task.new(:execute_scripts).name.must_equal :execute_scripts
      end

      it "yields self" do
        yielded_task = nil
        task = Task.new do |t|
          yielded_task = t
        end
        yielded_task.must_equal task
      end

      it "executes documentation" do
        task = Task.new(:docu_test)
        task.file = "TEST-README.md.docu"
        File.open("TEST-README.md.docu", "w") { |f| f.write("example") }
        ::Rake::Task[:docu_test].invoke
        File.exist?("TEST-README.md").must_equal true
      end
    end
  end
end
