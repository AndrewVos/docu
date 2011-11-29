$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../../lib")))
require "docu"

require "minitest/pride"
require "minitest/autorun"
require "minitest/spec"

module Docu
  class SpyKernel
    attr_accessor :output, :exit_status

    def puts(*a)
      @output ||= []
      a.each do |i|
        @output << i
      end
    end

    def exit status
      @exit_status = status
    end
  end

  describe ExecutesExamples do
    after do
      File.delete("TEST_README.md") if File.exist?("TEST_README.md")
      File.delete("TEST_README.md.docu") if File.exist?("TEST_README.md.docu")
    end

    let :kernel do
      SpyKernel.new
    end

    it "writes out some text" do
      File.open("TEST_README.md.docu", "w") do |file|
        file.puts
      end
      Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
      kernel.output.must_include "Executing Examples"
    end

    describe "one failing example and one passing example" do
      before do
        File.open("TEST_README.md.docu", "w") do |file|
          file.puts ":example:"
          file.puts "1 + 1"
          file.puts "#=> 23"
          file.puts ":end:"

          file.puts ":example:"
          file.puts "1 + 1"
          file.puts "#=> 2"
          file.puts ":end:"
        end
      end

      it "mentions failure and success" do
        Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
        kernel.output.must_include "1 example(s) failed, 1 example(s) passed"
      end

      it "outputs errors" do
        Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
        kernel.output.must_include "Assertion does not match example. Expected \"2\" to equal \"23\""
      end

      it "does not write the file" do
        Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
        File.exist?("TEST_README.md").must_equal false
      end

      it "exits with non-zero exit status" do
        Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
        kernel.exit_status.must_equal 1
      end
    end

    describe "one passing example" do
      before do
        File.open("TEST_README.md.docu", "w") do |file|
          file.puts ":example:"
          file.puts "1 + 1"
          file.puts "#=> 2"
          file.puts ":end:"
        end
      end

      it "writes out the file removing all :example: and :end: markers" do
        Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
        File.exist?("TEST_README.md").must_equal true
        contents = File.read("TEST_README.md").to_s
        contents.must_equal "1 + 1\n#=> 2\n"
      end
    end

    describe "one example" do
      describe "two passing assertions" do
        it "executes both assertions" do
          File.open("TEST_README.md.docu", "w") do |file|
            file.puts ":example:"
            file.puts "x = 1"
            file.puts "#=> 1"
            file.puts "x + 2"
            file.puts "#=> 3"
            file.puts ":end:"
          end
          Docu::ExecutesExamples.new(kernel).execute("TEST_README.md.docu")
          File.exist?("TEST_README.md").must_equal true
        end
      end
    end
  end
end
