require 'test_helper'

class TeachTest < ActiveSupport::TestCase
  def setup
    @teach = Fabricate(:teach)
  end
  
  test 'create' do
    assert_difference 'Teach.count' do
      @teach = Teach.create(Fabricate.attributes_for(:teach))
    end
  end
  
  test 'update' do
    assert_difference 'Version.count' do
      assert_no_difference 'Teach.count' do
        assert @teach.update_attributes(start: Date.tomorrow)
      end
    end
    
    assert_equal Date.tomorrow, @teach.reload.start
  end
  
  test 'destroy' do
    assert_difference 'Version.count' do
      assert_difference('Teach.count', -1) { @teach.destroy }
    end
  end
  
  test 'validates blank attributes' do
    @teach.start = ''
    @teach.finish = nil
    @teach.course_id = nil
    
    assert @teach.invalid?
    assert_equal 3, @teach.errors.size
    assert_equal [error_message_from_model(@teach, :start, :blank)],
      @teach.errors[:start]
    assert_equal [error_message_from_model(@teach, :finish, :blank)],
      @teach.errors[:finish]
    assert_equal [error_message_from_model(@teach, :course_id, :blank)],
      @teach.errors[:course_id]
  end
  
  test 'validates well formated attributes' do
    @teach.start = '13/13/13'
    @teach.finish = '13/13/13'
    
    assert @teach.invalid?
    assert_equal 4, @teach.errors.size
    assert_equal [
      error_message_from_model(@teach, :start, :blank),
      I18n.t('errors.messages.invalid_date')
    ].sort, @teach.errors[:start].sort
    assert_equal [
      error_message_from_model(@teach, :finish, :blank),
      I18n.t('errors.messages.invalid_date')
    ].sort, @teach.errors[:finish].sort
  end
  
  test 'validates attributes boundaries' do
    @teach.finish = @teach.start
    
    assert @teach.invalid?
    assert_equal 1, @teach.errors.size
    assert_equal [
      I18n.t('errors.messages.after', restriction: I18n.l(@teach.start))
    ], @teach.errors[:finish]
  end
end
