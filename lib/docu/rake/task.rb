$:.unshift(File.dirname(__FILE__) + '/../../')

require "rake"
require "rake/tasklib"
require "docu"

module Docu
  module Rake
    class Task < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      attr_accessor :name, :file

      def initialize(*args)
        @name = args.shift || :docu
        desc "Execute examples in documentation"  unless ::Rake.application.last_comment
        yield self if block_given?
        task name do
          ExecutesExamples.new.execute(file)
        end
      end
    end
  end
end
