# encoding: UTF-8

require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe I15R::PatternMatchers::Haml::TagContentMatcher do
  it "should replace /-s with an _" do
    plain = %(%p Do not close/reload while loading)
    i18ned = %(%p= I18n.t("users.new.do_not_close_reload_while_loading"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should not replace an implict div with an assigned class" do
    plain = %(        .field)
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == plain
  end

  it "should not replace a line with just an hmtl tag and no text" do
    plain = "%p"
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == plain
  end

  it "should not include the %tag in the generated message string" do
    plain = "%h2 Resend unlock instructions"
    i18ned = %(%h2= I18n.t("users.new.resend_unlock_instructions"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should suppress ( and ) in the generated I18n message string" do
    plain = "%i (we need your current password to confirm your changes)"
    i18ned = %(%i= I18n.t("users.new.we_need_your_current_password_to_confirm_your_changes"))
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
  end

  it "should not convert Ruby code to be evaluated" do
    plain = "= yield"
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == plain
  end

  it "should not convert comments" do
    plain = "/ Do not remove the next line"
    I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == plain
  end

  describe "when text has non-english characters" do
    it "should replace a tag's content where the tag is an implicit div" do
      plain = %(#form_head Türkçe)
      i18ned = %(#form_head= I18n.t("users.edit.türkçe"))
      I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.edit").should == i18ned
    end

    it "should replace a tag's content where the tag is an explicit one" do
      plain = %(%p Egy, kettő, három, négy, öt.)
      i18ned = %(%p= I18n.t("users.show.egy_kettő_három_négy_öt"))
      I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.show").should == i18ned
    end

  #1.8fail
    it "should replace a tag's content which is simple text all by itself on a line" do
      plain = %(Türkçe)
      i18ned = %(= I18n.t("users.new.türkçe"))
      I15R::PatternMatchers::Haml::TagContentMatcher.run(plain, "users.new").should == i18ned
    end
  end
end
