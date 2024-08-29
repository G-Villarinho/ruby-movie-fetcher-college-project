require 'httparty'

class Movie
  attr_reader :title, :year, :imdb_rating

  def initialize(title, year, imdb_rating)
    @title = title
    @year = year
    @imdb_rating = imdb_rating
  end

  def to_s
    "Título: #{@title}, Ano: #{@year}, Nota IMDb: #{@imdb_rating}"
  end
end

class MovieFetcher
  API_URL = "http://www.omdbapi.com/"

  def initialize(api_key)
    @api_key = api_key
  end

  def fetch_movies(search_term, type = 'movie', page = 1)
    query_params = { s: search_term, apikey: @api_key, type: type, page: page }
    response = HTTParty.get(API_URL, query: query_params)
    return [] unless response.parsed_response["Response"] == "True"

    response.parsed_response["Search"].map do |movie_data|
      movie_details = fetch_movie_details(movie_data['imdbID'])
      Movie.new(movie_data['Title'], movie_data['Year'], movie_details['imdbRating'])
    end
  end

  private

  def fetch_movie_details(imdb_id)
    HTTParty.get(API_URL, query: { i: imdb_id, apikey: @api_key }).parsed_response
  end
end

def main
  api_key = "INSIRA_AQUI_API_KEY"
  movie_fetcher = MovieFetcher.new(api_key)
  
  print "Insira uma palavra chave: "
  search_term = gets.chomp
  print "Insira o tipo\n1 - filme\n2 - serie\nPressione enter para o padrão 'filme': "
  type = { '1' => "movie", '2' => "series" }[gets.chomp] || "movie"

  page = 1

  loop do
    movies = movie_fetcher.fetch_movies(search_term, type, page)
    puts movies.any? ? "\nPágina #{page} - Filmes encontrados:\n#{movies.join("\n")}" : "Nenhum filme encontrado nessa página!"

    print "\nQuer ver outra página? (n para próxima, p para anterior, q para sair): "
    case gets.chomp.downcase
    when 'n' then page += 1
    when 'p' then page -= 1 if page > 1
    when 'q' then break
    else puts "Entrada inválida, por favor insira 'n', 'p', ou 'q'."
    end
  end
end

main
