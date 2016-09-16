require 'sinatra'
require 'sinatra/reloader'
require './hangman_errors.rb'

enable :sessions

Words = File.open("5desk.txt").readlines

get '/' do
	if session[:game_over] == true || session[:correct_word] == nil
		redirect to '/newgame'
	end
	check_game_status
	erb :index
end

post '/' do
	@curr_guess = params['guess']
	@@error_message = ""
	begin 
		check_valid_length(@curr_guess)
		check_if_repeat(@curr_guess)
	rescue TooManyLetters
		@@error_message = "Only 1 letter!"
		redirect to "/"
	rescue AlreadyGuessed
		@@error_message = "You've already guessed that!"
		redirect to "/"
	else
		register_guess
	end	
	redirect to "/"
end

get '/newgame' do
	set_up_new_game
	redirect to "/"
end

helpers do 
	def set_up_new_game
		@@error_message = ""
		session[:guesses_left] = 7
		session[:game_over] = false
		session[:guesses] = []
		session[:guess] = session[:guesses][-1]
		session[:correct_word] = Words.sample.downcase.chomp
		session[:guessed_so_far] = []
		for i in 0...session[:correct_word].length
			session[:guessed_so_far][i] = "_"
		end
		p session[:guessed_so_far]
	end

	def check_if_empty
		session[:guessed_so_far].each_char do |c|
			if c != "_"
				return false
			end
		end
		true
	end

	def check_guess(guess)
		@curr_word = session[:guessed_so_far]
		@word = session[:correct_word]
		@word.each_char.with_index do |letter,index|
			if letter == guess
				@curr_word[index] = letter
			end
		end
		@curr_word
	end

	def check_valid_length(guess)
		raise TooManyLetters if guess.length > 1
	end

	def check_if_repeat(guess)
		raise AlreadyGuessed if session[:guesses].include?(guess)
	end

	def register_guess
		session[:guesses_left] -= 1
		session[:guesses] << @curr_guess 
		session[:guess] = session[:guesses][-1]
		session[:guessed_so_far] = check_guess(session[:guess])
		puts session[:guessed_so_far]
		puts session[:correct_word]
	end

	def check_win
		return true if session[:guessed_so_far].join("") == session[:correct_word]
	end

	def check_game_status
		if session[:guesses_left] == 0 || check_win
			session[:game_over] = true
		end
	end

end