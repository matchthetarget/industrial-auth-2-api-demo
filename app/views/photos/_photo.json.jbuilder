json.extract! photo, :id, :image, :comments_count, :likes_count, :caption, :owner_id, :created_at, :updated_at
json.url photo_url(photo, format: :json)
json.owner do
  json.username photo.owner.username
end
json.comments do
  json.array! photo.comments, partial: "comments/comment", as: :comment
end
