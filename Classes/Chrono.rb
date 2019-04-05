#====== La classe chrono représente un chronomètre conçu pour être utilisé en thread ( en parallèle du programme princpal pour chronomètrer une partie)

class Chrono
	
	#=Variables d'instance
	# @initial 	: mémorise le temps de départ obtenu avec Time.now.to_i pour pouvoir le soustraire plus tard
	# @start 	: boolean en false au lancement du chrono et passe en true lors du premier tosu de boucle.
	# @pause		: boolean met en pause le chrono
	# @chrono	: variable qui stockera le nombre de seconde actuel et qui servira à afficher.
	# @fin 		: boolean ture pour arrêter le chrono.

	attr_accessor :start
	attr_accessor :pause
	attr_accessor :chrono
	



	#initialise les variables à 0 et a false
	# @param void		//ne prend aucun paramètre
	# @return void		//ne renvoie rien
	def initialize()
		@initial=0
		@start=false
		@pause=false
		@chrono=0
		@fin=false
	end


	#lance le chrono qui se terminera uniquement en appelant la méthode fin()
	# @param void		//ne prend aucun paramètre
	# @return void		//ne renvoie rien
	def cStart
			
			while @fin != true
						if @start==false
							@initial=Time.now.to_i
							@start=true
						end
						if @pause != true
							if @chrono != Time.now.to_i - @initial
								@chrono=Time.now.to_i - @initial
								print self
							end
						end
			end
		
	end

	#change la valeur de la variable @pause en true ou en false mettant le chrono en pause ou le faisant repartir
	# @param void		//ne prend aucun paramètre
	# @return void		//ne renvoie rien
	def cPause()
		if @pause==true
			@pause=false
			@initial=Time.now.to_i-@chrono
		else 
			@pause=true
		end
	end

	#relance le chrono dans sa configuration initiale
	# @param void		//ne prend aucun paramètre
	# @return void		//ne renvoie rien
	def cRaz()
		@pause=false
		@start=false
	end

	#ajoute n seconde au chrono
	# @param n		//nombre de secondes à ajouter au chrono
	# @return void		//ne renvoie rien
	def cAjout(n)
		@chrono+=n
	end

	#met la variable @fin sur true ce qui à pour effet de mettre un terme au chrono
	# @param void		//ne prend aucun paramètre
	# @return void		//ne renvoie rien
	def cFin()
		@fin=true
	end

	#Traduction des secondes en heures/minutes/secondes
	# @param void		//ne prend aucun paramètre
	# @return temps	//Retourne le temps sous format h:m:s
	def to_s
	
			heures = @chrono/3600
			minutes = (@chrono - (heures*3600)) / 60
			secondes = @chrono - (heures*3600) - (minutes*60)

			h = heures < 10 ? "0" + heures.to_s : heures.to_s
			m = minutes < 10 ? "0" + minutes.to_s : minutes.to_s
			s = secondes < 10 ? "0" + secondes.to_s : secondes.to_s

			return h + ":" + m + ":" + s + "\n"
	end

end # Marqueur de fin de classe

#c=Chrono.new()

#thr=Thread.new{
#			c.start
 #}


#sleep(3)
#c.pause()
#sleep(3)
#c.pause()
#print "Saisi"
#s = gets
#sleep(3)
#print s
#sleep(3)
#c.raz()
#sleep(5)
