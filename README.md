# Running
```
$ mix deps.get
$ iex -S mix
iex> Rating.send_request(user_id)
```

# Second task algorithm
For every movie that a given user did not watch, I determine when it was watched more often: on weekdays or on weekends. Movies that were watched more often on weekends are deleted from possible ones. The remaining ones are chosen by the one with the highest rating.

Source code: /lib/rating.ex, /lib/sim.ex