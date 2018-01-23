json.array!(@search_result) do |result|
  json.word result[0]
  json.freq result[1]['term_freq'] 
end