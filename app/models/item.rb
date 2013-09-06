class Item < ActiveRecord::Base
  belongs_to :user

  belongs_to :address
  accepts_nested_attributes_for :address, allow_destroy: true, reject_if: lambda{|address| address[:number_and_street].blank? }

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: lambda{|x| x[:url].blank?}

  has_many :categorizations
  has_many :categories, through: :categorizations

  has_many :comments, as: :commentable, dependent: :destroy

  validates :name,
    presence: true

  validates :address_id,
    presence: true

  validates :categories, 
    length:{ minimum: 1, message: "item needs at least one category"}
    

  def name=(value)
    write_attribute :name, value.capitalize
  end


  #searchable do 
  #  text :name, boost: 10
  #  text :description, boost: 7
  #  integer :address_id
  #end

  def self.item_search(query, address=nil, range=10)
    #self.search do
    #  fulltext query
    #  with(:address_id, Address.near(address, range).map{|x| x.id})
    #end
    Item.where("name @@ :q OR description @@ :q", q: "%#{query}%").where(address_id: Address.near(address, range).map{|x| x.id}.to_a)
  end

  # Find items in a certain radius of a location
  def self.near(address=nil, range=RANGE_CONSTANT)
    Item.where(address_id: Address.near(address, range).map{|x| x.id}.to_a)
  end

end
