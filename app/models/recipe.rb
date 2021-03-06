class Recipe < ApplicationRecord
  require "open-uri"
  belongs_to :user
  has_many :instructions
  has_many :playlists
  scope :favorited, -> { where(favorite: true) }
  validates :genre, inclusion: ["pop", 'punk', 'rock', 'hiphop', 'chill', "indie_alt"]

  def self.scraper(recipe)
    # 1. We get the HTML page content
    @recipe = recipe
    html_content = URI.open(@recipe.url).read
    # 2. We build a Nokogiri document from this file
    doc = Nokogiri::HTML(html_content)
    @preptime = doc.search('.recipe-meta-item')[2].text.strip
    hour = @preptime.match(/(\d+) hr/)
    hour = hour[1].to_i * 60 if hour.present?
    min = @preptime.match(/(\d+) mins/)
    min = min.present? ? min[1].to_i : 0
    @url = @recipe.url
    @preptime = hour.present? ? hour + min : min
    @title = doc.search('.headline').text.strip
    @ingredients = doc.search('.ingredients-section').text.strip
    @steps = doc.search('.instructions-section').text.strip
    if doc.search('.lead-media img').present?
      @image = doc.search('.lead-media img').attribute("src").value
    else
      @image = doc.search('video').attribute('poster').value
    end
    @category = doc.search('.breadcrumbs__item')[2].text.strip
    # @image = if @image.present? ? @image : @image
    @recipe.title = @title
    @recipe.preptime = @preptime
    @recipe.ingredients = @ingredients
    @recipe.steps = @steps
    @recipe.url = @image
    @recipe.category = @category
    return @recipe
  end

  def percent_of(*)
    t = Timer.new
    t.start.to_f / @preptime.to_f * 100
  end
end
