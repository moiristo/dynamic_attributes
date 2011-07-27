ActiveRecord::Schema.define(:version => 0) do   
  create_table :dynamic_models, :force => true do |t|
    t.string :title
    t.text :dynamic_attributes
    t.text :extra    
  end  
  
  create_table :dynamic_nested_models, :force => true do |t|
    t.string :title
    t.text :dynamic_attributes   
    t.integer :dynamic_model_id
  end    
end