require 'helper'

class TestDynamicAttributes < Test::Unit::TestCase
  load_schema
  
  def setup
    DynamicModel.dynamic_attribute_field = :dynamic_attributes
    DynamicModel.dynamic_attribute_prefix = 'field_'
    DynamicModel.destroy_dynamic_attribute_for_nil = false  
        
    @dynamic_model = DynamicModel.create(:title => "A dynamic model")  
  end
  
  def test_should_persist_nothing_by_default
    assert_equal [], @dynamic_model.persisting_dynamic_attributes
  end
  
  def test_should_create_manual_dynamic_attribute
    @dynamic_model.field_test = 'hello'
    assert_equal 'hello', @dynamic_model.field_test
    assert @dynamic_model.persisting_dynamic_attributes.include?('field_test')
    assert @dynamic_model.dynamic_attributes.keys.include?('field_test')
    assert @dynamic_model.has_dynamic_attribute?(:field_test)    
  end
  
  def test_should_create_dynamic_attributes_for_hash
    assert dynamic_model = DynamicModel.create(:title => 'Title', :field_test1 => 'Hello', :field_test2 => 'World')
    assert dynamic_model.persisting_dynamic_attributes.include?('field_test1')
    assert dynamic_model.persisting_dynamic_attributes.include?('field_test2')    
    assert_equal 'Hello', dynamic_model.field_test1
    assert_equal 'World', dynamic_model.field_test2  
    assert dynamic_model.has_dynamic_attribute?(:field_test1)
    assert dynamic_model.has_dynamic_attribute?(:field_test2)                
  end
  
  def test_should_update_attributes
    @dynamic_model.update_attributes(:title => 'Title', :field_test1 => 'Hello', :field_test2 => 'World')
    assert @dynamic_model.persisting_dynamic_attributes.include?('field_test1')
    assert @dynamic_model.persisting_dynamic_attributes.include?('field_test2')    
    assert_equal 'Hello', @dynamic_model.field_test1
    assert_equal 'World', @dynamic_model.field_test2
    
    @dynamic_model.reload
    assert_equal 'Hello', @dynamic_model.field_test1
    assert_equal 'World', @dynamic_model.field_test2  
    
    assert @dynamic_model.has_dynamic_attribute?(:field_test1)    
    assert @dynamic_model.has_dynamic_attribute?(:field_test2)          
  end
  
  def test_should_load_dynamic_attributes_after_find
    DynamicModel.update_all("dynamic_attributes = '---\nfield_test: Hi!\n'", :id => @dynamic_model.id)    
    dynamic_model = DynamicModel.find(@dynamic_model.id)
    assert_equal 'Hi!', dynamic_model.field_test
    
    assert dynamic_model.has_dynamic_attribute?(:field_test)    
  end
  
  def test_should_set_dynamic_attribute_to_nil_if_configured
    assert @dynamic_model.update_attribute(:field_test,nil)
    assert_nil @dynamic_model.field_test
    assert @dynamic_model.persisting_dynamic_attributes.include?('field_test')    
    assert @dynamic_model.dynamic_attributes.include?('field_test')
    assert @dynamic_model.has_dynamic_attribute?(:field_test)    
    
    DynamicModel.destroy_dynamic_attribute_for_nil = true
    assert @dynamic_model.update_attribute(:field_test,nil)
    assert !@dynamic_model.persisting_dynamic_attributes.include?('field_test')  
    assert !@dynamic_model.dynamic_attributes.include?('field_test')    
    assert !@dynamic_model.respond_to?('field_test=')
    assert !@dynamic_model.has_dynamic_attribute?(:field_test)    
  end
  
  def test_should_allow_different_prefix
    DynamicModel.dynamic_attribute_prefix = 'what_'
    
    @dynamic_model.what_test = 'hello'
    assert_equal 'hello', @dynamic_model.what_test
    assert @dynamic_model.persisting_dynamic_attributes.include?('what_test')
    assert @dynamic_model.dynamic_attributes.keys.include?('what_test')
    assert @dynamic_model.has_dynamic_attribute?(:what_test)
    assert !@dynamic_model.has_dynamic_attribute?(:field_test)
            
    assert_raises NoMethodError do
      @dynamic_model.field_test = 'Fail'
    end
  end
  
  def test_should_allow_different_serialization_field
    DynamicModel.dynamic_attribute_field = 'extra'
    @dynamic_model.update_attributes(:title => 'Title', :field_test1 => 'Hello', :field_test2 => 'World')
    assert_equal({}, @dynamic_model.dynamic_attributes || {})
    assert_equal({"field_test1"=>"Hello", "field_test2"=>"World"}, @dynamic_model.extra)
  end
  
  def test_should_set_nested_dynamic_attributes
    @dynamic_model.update_attributes(:dynamic_nested_models_attributes => { '0'=> { :title => 'A nested dynamic model', :field_test => 'Hello', :field_test2 => 'World' } })
    assert DynamicNestedModel.any?
    
    nested_model = @dynamic_model.dynamic_nested_models.first
    nested_model.has_dynamic_attribute?(:field_test)
    nested_model.has_dynamic_attribute?(:field_test2)      
    assert_equal 'A nested dynamic model', nested_model.title
    assert_equal 'Hello', nested_model.field_test
    assert_equal 'World', nested_model.field_test2            
  end
  
end
