defmodule Sim do
  @data "data.csv"
  @context "context.csv"

  def read_csv(data) do
    File.stream!(data)
    |> CSV.decode
    |> Enum.map(&(&1 |> elem(1)))
  end

  def get_metrics(user_id) do
    Enum.map(1..40, &(get_sim(user_id, &1)))
    |> Enum.zip(1..40)
  end

  def get_sim(u, v) do
    Enum.zip(get_user(u), get_user(v))
    |> Enum.filter(&(elem(&1, 0) != -1 && elem(&1, 1) != -1))
    |> (fn x -> numerator(x) / denominator(x) end).()
  end

  def get_user(user_id) do
    read_csv(@data)
    |> Enum.at(user_id)
    |> List.delete_at(0)
    |> Enum.map(fn x -> to_int(x) end)
  end

  def get_days(user_id) do
    read_csv(@context)
    |> Enum.at(user_id)
    |> Enum.with_index
    |> List.delete_at(0)
    |> Enum.map(&(elem(&1, 0) |> String.trim))
  end

  def movies_days(movies) do
    movies
    |> Enum.map(fn x -> {x, read_csv(@context) |> List.delete_at(0) |> Enum.map(fn y -> y |> Enum.at(x) end)} end)
  end

  def days_count(days) do
    days
    |> Enum.map(fn x -> {elem(x, 0), x |> elem(1) |> Enum.reduce({0, 0}, fn y, acc -> case y do
                                                              n when n in [" Sat", " Sun"] ->
                                                                {elem(acc, 0), elem(acc, 1) + 1}
                                                              n when n == " -" ->
                                                                {elem(acc, 0), elem(acc, 1)}
                                                              _ ->
                                                                {elem(acc, 0) + 1, elem(acc, 1)}
                                                                         end
                                                            end)} 
                end)
  end

  def filter_movies(movies) do
    movies
    |> movies_days()
    |> days_count()
    |> Enum.filter(fn x -> elem(elem(x, 1), 0) > elem(elem(x, 1), 1) end)
    |> Enum.map(&(elem(&1, 0)))
  end

  def to_int(str) do
    str
    |> String.trim
    |> String.to_integer
  end

  def sqrt_sum(x) do
    x
    |> Enum.map(&(:math.pow(&1, 2)))
    |> Enum.sum
    |> :math.sqrt
  end

  def numerator(users) do
    users
    |> Enum.map(&(elem(&1, 0)  * elem(&1, 1)))
    |> Enum.sum
  end

  def denominator(users) do
    sqrt_sum(Enum.map(users, &(elem(&1, 0)))) * sqrt_sum(Enum.map(users, &(elem(&1, 1))))
  end

  def avg_rating(user_id) do
    get_user(user_id)
    |> Enum.filter(&(&1 != -1))
    |> Enum.reduce({0, 0}, fn x, {sum, count} -> {sum + x, count + 1} end)
    |> (fn {x, y} -> x / y end).()
  end

end
