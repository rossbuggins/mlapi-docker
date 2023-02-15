1. Update config/secrets.ini
1. Optional set api user and password in .env

```
docker-compose up
```

```
curl -H "Content-Type:application/json" -XPOST -d '{"username":"makeupauser", "password":"makeupapassword"}'
```

```
curl --location --request POST 'http://localhost:5000/api/v1/detect/object' \
--header 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2NzY0NzEwODEsIm5iZiI6MTY3NjQ3MTA4MSwianRpIjoiMDhkNGM3ZmYtOWY4OC00NDg0LTk4NDgtNmZlMjAxNzliNWUyIiwiZXhwIjoxNjc2NDc0NjgxLCJpZGVudGl0eSI6Im1ha2V1cGF1c2VyIiwiZnJlc2giOmZhbHNlLCJ0eXBlIjoiYWNjZXNzIn0.g5-oOimpf4mJ2Q91QwOkeOTqqHdzdaIpvuS4XnnNsbY' \
--header 'Content-Type: application/json' \
--data-raw '{"url":"https://images.pexels.com/photos/4148842/pexels-photo-4148842.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"}'

```