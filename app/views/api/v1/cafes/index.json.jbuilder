# this is an example on how to use JBuilder
json.array! @cafes do |cafe|
  json.extract! cafe, :id, :title
end
