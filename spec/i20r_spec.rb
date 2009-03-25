require File.join(File.dirname(__FILE__), "..", "lib", "i20r")
require "mocha"
require "spec"

# use mocha for mocking instead of
# Rspec's own mock framework
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

describe "I20r" do
  before do
    @i20r = I20r.new
  end

  describe "converting file paths to message prefixes" do
    
    it "should correctly work from app root for views" do
      @i20r.file_path_to_message_prefix("app/views/users/new.html.erb").should == "users.new"
    end

    it "should correctly work from app root for helpers" do
      @i20r.file_path_to_message_prefix("app/helpers/users_helper.rb").should == "users_helper"
    end

    it "should correctly work from app root for controllers" do
      @i20r.file_path_to_message_prefix("app/controllers/users_controller.rb").should == "users_controller"
    end

    it "should correctly work from app root for models" do
      @i20r.file_path_to_message_prefix("app/models/user.rb").should == "user"
    end
    
    it "should correctly work from app root for deep dir. structures" do
      @i20r.file_path_to_message_prefix("app/views/member/session/users/new.html.erb").should == "member.session.users.new"
    end
    
    it "should raise if no app subdirectory is found on the path" do
      path = "projects/doodle.rb"
      File.stubs(:expand_path).returns(path)
      lambda { @i20r.file_path_to_message_prefix(path) }.should raise_error(AppFolderNotFound)
    end
  end

  describe "turning plain messages into i18n message strings" do
    
    it "should downcase a single word" do
      @i20r.get_i18n_message_string("Name", "users.new").should == "users.new.name"
    end

    it "should replace spaces with underscores" do
      @i20r.get_i18n_message_string("New name", "users.index").should == "users.index.new_name"
    end
    
  end
  
  describe "message text replacement" do
    it "should replace words that are content in tags" do
      plain = %(<label for="user-name">Name</label>)
      i18ned = %(<label for="user-name"><%= I18n.t("users.new.name") %></label>)
      @i20r.replace_non_i18_messages(plain, "users.new").should == i18ned        
    end
    
    it "should replace a title in a link_to helper" do
      plain = %(<p class="highlighted"><%= link_to 'New user', new_user_path %></p>)
      i18ned = %(<p class="highlighted"><%= link_to I18n.t("users.index.new_user"), new_user_path %></p>)
      @i20r.replace_non_i18_messages(plain, "users.index").should == i18ned
    end
    
  end

  describe "in files" do
    before do
      @file_path = '/app/views/users/new.html.erb'
      message_prefix = "users.new"
      @i20r.expects(:file_path_to_message_prefix).with(@file_path).returns(message_prefix)

      @plain_snippet = <<-EOS
        <label for="user-name">Name</label>
        <input type="text" id="user-name" name="user[name]" />
      EOS
      @i18ned_snippet = <<-EOS
        <label for="user-name"><%= I18n.t("#{message_prefix}.name") %></label>
        <input type="text" id="user-name" name="user[name]" />
      EOS

      @i20r.expects(:get_content_from).with(@file_path).returns(@plain_snippet)
      @i20r.expects(:write_content_to).with(@file_path, @i18ned_snippet).returns(true)
    end
    
    it "should correctly replace plain texts with I18n-ed messages" do
      # @i20r.replace_non_i18_messages(@plain_snippet).should == @i18ned_snippet
      @i20r.write_i18ned_file(@file_path)
    end
  end

end