require 'test_helper'

class SimpleAuditHelperTest < ActionView::TestCase
  
  include SimpleAudit::Helper

  test "should create an audit trail" do
    person = Person.create(:name => "Mihai Tarnovan", :email => "mihai.tarnovan@cubus.ro", :address => Address.new(:line_1 => "M. Viteazu nr. 11 sc. C ap.32"))
    change_log = person.audits.last.change_log
    oup = render_audits( person )
    assert_match( change_log[:name], oup )
    assert_match( change_log[:address][:line_1], oup )
  end
end