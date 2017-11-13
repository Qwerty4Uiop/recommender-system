defmodule Rating do
  require Sim
  @host "https://cit-home1.herokuapp.com/api/rs_homework_1"
  @request_headers ["User-Agent": "My Awesome App", "Content-Type": "application/json"]

  def get_ratings(user_id) do
    Sim.get_user(user_id)
    |> Enum.with_index(0)
    |> Enum.filter(&(elem(&1, 0) == -1))
    |> Enum.map(&({"movie " <> (((&1 |> elem(1)) + 1) |> to_string), rating(user_id, &1 |> elem(1))}))
    |> Map.new 
    |> (fn x -> Map.new |> Map.put("user", user_id) |> Map.put("1", x) end).()
    |> Map.put("2", recommendation(user_id))
  end

  def rating(user_id, film_id) do
    Sim.avg_rating(user_id) + numerator(user_id, film_id) / denominator(user_id, film_id)
  end

  def get_neighbors(user_id) do
    Sim.get_metrics(user_id)
    |> Enum.sort(&(elem(&1, 0) > elem(&2, 0)))
    |> Enum.take(6)
    |> List.delete_at(0)
    |> Enum.map(&({&1, Sim.get_user(elem(&1, 1))}))
  end

  def numerator(user_id, film_id) do
    get_neighbors(user_id)
    |> filter_neighbors(film_id)
    |> Enum.map(fn x -> (x
                        |> elem(0)
                        |> elem(0)) * ((x
                                      |> elem(1)
                                      |> Enum.at(film_id)) - (x |> elem(0) |> elem(1) |> Sim.avg_rating)) end)
    |> Enum.sum
  end

  def denominator(user_id, film_id) do
    get_neighbors(user_id)
    |> filter_neighbors(film_id)
    |> Enum.map(&(&1 |> elem(0) |> elem(0) |> abs))
    |> Enum.sum
  end

  def filter_neighbors(neighbors, film_id) do
    neighbors
    |> Enum.filter(&((&1 |> elem(1) |> Enum.at(film_id)) != -1))
  end

  def recommendation(user_id) do
    (Sim.get_user(user_id)
    |> Enum.with_index(0)
    |> Enum.filter(&(elem(&1, 0) == -1))
    |> Enum.map(&(elem(&1, 1)))
    |> Sim.filter_movies
    |> Enum.max_by(&(rating(user_id, &1)))) + 1
    |> (fn x -> Map.new |> Map.put("movie " <> to_string(x), rating(user_id, x - 1)) end).()
  end

  def send_request(user_id) do
    HTTPotion.start
    HTTPotion.post(@host, [body: Poison.encode!(get_ratings(user_id)), headers: @request_headers])
  end

end
