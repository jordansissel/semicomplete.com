#!/usr/bin/env ruby

require "clamp"
require "time"
require "fileutils"

class Importer < Clamp::Command
  option "--output", "DIRECTORY", "Where to write the results"
  parameter "PATHS ...", "The paths to import.", :attribute_name => :paths

  def execute
    paths.each { |path| import(path, output) }
  end

  def import(path, destination)
    puts path
    input = File.new(path, "r")

    subject = input.readline
    metadata = {}
    while true
      line = input.readline.chomp
      break if line == ""
      key, value = line.split(" ", 2)

      if key == "#mdate"
        p value
        value = Time.parse(value)
      end
      metadata[key] = value
    end

    # If no #mdate found, use file timestamp
    metadata["#mdate"] = input.stat.mtime if metadata["#mdate"].nil?

    output_dir = File.join(destination, File.dirname(path))
    output_dir.tap { |x| FileUtils.mkdir_p(x) unless File.directory?(x) }
    output = File.new(File.join(destination, path).sub(/\.txt$/, ".html"), "w")

    output.puts('+++')
    output.puts("# Imported from original pyblosxom .txt format at #{Time.now}")
    output.puts("date = #{metadata["#mdate"].iso8601.inspect}")
    output.puts("title = #{subject.inspect}")
    output.puts("# Marked a draft because frankly my old writing may not be worth surfacing again.")
    output.puts("# I made bad word choices and had some strong-and-closed opinions years ago.")
    output.puts("# We learn over time, eh? :)")
    output.puts('draft = true')

    output.puts('type = "blog"')
    output.puts('categories = [ "blog" ]')
    metadata["#tags"].tap do |tags|
      p :tags => tags
      output.puts("tags = " + tags.split(/\s*,\s*/).inspect) unless tags.nil?
    end
    output.puts('+++')
    output.puts
    output.puts(input.read)
  rescue EOFError
    puts "Failed to parse entry, got EOF early: #{path}"
    File.unlink(output.path) if output
  ensure
    input.close
    output.close unless output.nil?
  end
end

Importer.run
