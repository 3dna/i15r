require "rubygems"
require 'optparse'
require "ostruct"
require "ruby-debug"

class AppFolderNotFound < Exception; end

class I15r

  def parse_options(args)
    @options = OpenStruct.new
    @options.prefix = nil
    opts = OptionParser.new do |opts|
      opts.on("--prefix PREFIX",
              "apply PREFIX to generated I18n messages instead of deriving it from the path") do |prefix|
        @options.prefix = prefix
      end
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end

    opts.on_tail("--version", "Show version") do
      puts "0.0.1"
      exit
    end

    opts.parse!(args)
    # @options
  end

  def prefix
    @options.prefix
  end

  def file_path_to_message_prefix(file)
    segments = File.expand_path(file).split('/').select { |segment| !segment.empty? }
    subdir = %w(views helpers controllers models).find do |app_subdir|
       segments.index(app_subdir)
    end
    if subdir.nil?
      raise AppFolderNotFound, "No app. subfolders were found to determine prefix. Path is #{File.expand_path(file)}"
    end
    first_segment_index = segments.index(subdir) + 1
    file_name_without_extensions = segments.last.split('.')[0..0]
    path_segments = segments.slice(first_segment_index...-1)
    (path_segments + file_name_without_extensions).join('.')
  end

  def get_i18n_message_string(text, prefix)
    text = text.strip.downcase.gsub(/\s/, '_').gsub(/[\W]/, '')
    "#{prefix}.#{text}"
  end

  def get_content_from(file)
    f = open(File.expand_path(file), "r")
    content = f.read()
    f.close()
    content
  end

  def write_content_to(file, new_content)
    f = open(File.expand_path(file), "w")
    f.write(new_content)
    f.close()
  end

  def write_i18ned_file(file)
    text = get_content_from(file)
    prefix = self.prefix || file_path_to_message_prefix(file)
    i18ned_text = replace_non_i18_messages(text, prefix)
    write_content_to(file, i18ned_text)
  end

  def replace_in_rails_helpers(text, prefix)
    text.gsub!(/<%=\s*link_to\s+['"](.*)['"]\s*/) do |match|
      i18n_string = get_i18n_message_string($1, prefix)
      %(<%= link_to I18n.t("#{i18n_string}"))
    end
  end

  def replace_in_tag_content(text, prefix)
    text = text.gsub!(/>(\s*)(\w[\s\w:'"!?\.]+)\s*</) do |match|
      i18n_string = get_i18n_message_string($2, prefix)
      # readding leading ws and ending punctuation (and ws)
      # (there must be a way to put this into the regex,
      # I just did not find it.)
      leading_whitespace = $1
      ending_punctuation = $2[/([?.!:\s]*)$/, 1]
      %(>#{leading_whitespace}<%= I18n.t("#{i18n_string}") %>#{ending_punctuation.to_s}<)
    end
  end

  def replace_non_i18_messages(text, prefix)
    #TODO: that's not very nice since it relies on
    # the replace methods (e.g replace_in_tag_content)
    # being destructive (banged)
    replace_in_tag_content(text, prefix)
    replace_in_rails_helpers(text, prefix)
    text
  end

end

if __FILE__ == $0
  @i15r = I15r.new
  @i15r.parse_options(ARGV)
  @i15r.write_i18ned_file(ARGV[-1])
end