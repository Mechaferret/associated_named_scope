ActiveRecord::Schema.define(:version => 2) do
  create_table :users, :force => true do |t|
    t.column :name, :string
    t.column :active, :boolean
    t.column :status, :string
    t.timestamps
  end
  
  create_table :posts, :force => true do |t|
    t.column :name, :string
    t.column :user_id, :integer
    t.column :approved, :boolean
    t.column :publication_date, :datetime
  end
  
  create_table :addresses, :force => true do |t|
    t.column :addressable_id, :integer
    t.column :addressable_type, :string
    t.column :zip, :string
    t.column :lat, :float
    t.column :lng, :float
    t.column :radius, :float
  end
  
  create_table :venues, :force => true do |t|
    t.column :name, :string
    t.column :rating, :integer
  end
  
end