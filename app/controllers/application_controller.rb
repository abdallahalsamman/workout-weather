class ApplicationController < ActionController::Base
  include HeatIndex

  def home
  end

  def get_weather_by_position
    response = RestClient.get "https://api.openweathermap.org/data/2.5/forecast?lat=#{params['latitude']}&lon=#{params['longitude']}&appid=#{ENV['OPENWEATHERMAP_APPID']}", {accept: :json}
    json_parsed_response = JSON.parse(response.body)

    ideal_temperature = 291 # kelvin
    weather_sorted = sort_weather_by_nearest_to_ideal(json_parsed_response["list"], ideal_temperature)

    render :json => weather_sorted
  end
  
  def sort_weather_by_nearest_to_ideal(list, ideal)
    # function orderByClosest(list, num) {
    #   // temporary array holds objects with position and sort-value
    #   var mapped = list.map(function (el, i) {
    #     return { index: i, value: Math.abs(el - num) };
    #   });

    #   // sorting the mapped array containing the reduced values
    #   mapped.sort(function (a, b) {
    #     return a.value - b.value;
    #   });

    #   // return the resulting order
    #   return mapped.map(function (el) {
    #     return list[el.index];
    #   });
    # }

    mapped = list.map.with_index { |value, i| 
      { index: i, value: (value["main"]["temp"] - ideal).abs }
    }

    mapped = mapped.sort { |a, b|
      a[:value] - b[:value]
    }

    mapped.map { |el| list[el[:index]] }
  end
  
end
