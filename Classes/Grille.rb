require_relative 'Case.rb'



#====== La classe grille contient des informations relatives à une grille, ainsi qu'une grille actuelle et la grille correspondante finale
class Grille

	#=Variables d'instance
	# @taille			: La taille de la grille
	# @difficulte			: La difficulte de la grille
	# @numero			: Le numéro de la grilleF
	# @grilleJ			: La grille que le joueur doit compléter
	# @grilleF			: La grille finale
	# @nbTentesLigne		: Le nombre de tentes pour chaque ligne
	# @nbTentesColonne		: Le nombre de tentes pour chaque colonne


	attr_reader :taille
	attr_reader :difficulte
	attr_reader :numero
	attr_reader :grilleJ
	attr_reader :grilleF
	attr_reader :nbTentesLigne
	attr_reader :nbTentesColonne
	attr_reader :chrono

	attr_writer :grilleJ



	#Créé une grille avec une difficulté et un numéro
	# @param diff		//difficulté de grille
	# @param num		//numéro de grille
	# @return void		//ne renvoie rien
	def Grille.creer(diff, num, temps)
		new(diff, num, temps)
	end



	#Créé une grille avec un niveau de difficulté
	# @param diff		//difficulté de grille
	# @return void		//ne renvoie rien
	def Grille.creerD(diff)
		Grille.creer(diff, rand(diff.include?("Difficile") ? 300:400), 0)
	end

	private_class_method:new



	#Méthode d'initialisation
	# @param diff		//difficulté de grille
	# @param num		//numéro de grille
	# @return void		//ne renvoie rien
  	def initialize (diff, num, temps)
    	@difficulte, @numero = diff, num

		#Récupération de la grille à partir du fichier
		ligneGrille = IO.readlines("./Ressources/Grilles#{@difficulte}s.txt")[@numero - 1]

		#Séparation des éléments de la grille dans un tableau
		grilleFich = ligneGrille.split(';')

		#Récupération de la taille de la grille
	  	@taille = grilleFich.shift.to_i
	  	grilleFich.shift

		#Récupération du nombre de tentes par colonne de la grille
		@nbTentesColonne = grilleFich.pop
		@nbTentesColonne = @nbTentesColonne.split(//)
		@nbTentesColonne.pop
		@nbTentesColonne = @nbTentesColonne.map(&:to_i)

		#Récupération des cases de la grille et du nombre de tentes par ligne
		@grilleJ = []
		@grilleF = []
		@nbTentesLigne = []

		i = 0
		grilleFich.each() do |l|
			@nbTentesLigne << l.split(':').last.to_i
			ligne = l.delete "0-9:"

			ligneCasesF = []
			ligneCasesJ = []

			j = 0
			ligne.each_char do |c|
				ligneCasesF << Case.creer(i, j, c == '_' ? 'H': c)
				ligneCasesJ << Case.creer(i, j, c == 'A' ? 'A': 'V')
				j += 1
			end
			@grilleF<<ligneCasesF
			@grilleJ<<ligneCasesJ
			i += 1
	 	end
	 	@chrono = temps
	end





	#Affiche la grille de jeu (sans le nombre de tentes)
	# @param grille	//Grille de jeu
	# @return void		//ne renvoie rien
	def  afficherGrille (grille)
		grille.each do |ligne|
			 print "\n"
			 ligne.each do |c|
				 print c
			 end
		end
		print "\n"
	end




	#Enregistre la grille dans un fichier en transformant les informations concernant l'état des cases en char
	# @param nomJoueur	//Le nom du joueur
	# @param chrono		//le temps du chrono en cours
	# @return void		//ne renvoie rien
  	def enregistrerFichier(nomJoueur, chrono)
    		ligne = []
		ligne<<@numero<<@difficulte<<chrono<<nomJoueur

		for i in 0..(@taille-1)
			ligneGrille = ""
			ligneTemp = ""
			@grilleJ[i].each do |uneCase|
				case uneCase.etat
			      when 0 then
			        c='V'
			      when 1 then
			        c = 'T'
			      when 2 then
			        c = 'A'
			      when 3 then
			        c = 'H'
			    end
				ligneTemp = ligneTemp + c
			end

			ligneGrille = ligneGrille + ligneTemp.to_s
			ligne<<ligneGrille.to_s
		end

		ligne = ligne.join(';')

		fichier =File.open("./Ressources/Sauvegarde.txt", File::CREAT|File::RDWR)
		fichier.each_line do |l|
			if l.include?(nomJoueur) then
				break
			end
		end
		fichier.puts(ligne)
		fichier.close

  end



  #Charge une grille sauvegardée lors d'une partie
  # @param nomJoueur	//Le nom du joueur
  # @return grille	//retourn la grille voulue si elle existe
  def Grille.charger (nomJoueur)

	lFich = ""
	trouve = false

	fichier =File.open("./Ressources/Sauvegarde.txt", "r")
		fichier.each_line do |l|
			if l.include?(nomJoueur) then
				lFich = l
				if trouve then
					break
				end
				trouve = true
			end
		end
	if trouve then
		lFich = lFich.chomp
	  	grilleFich = lFich.split(';')
		num = grilleFich.shift
		diff = grilleFich.shift
		temps = grilleFich.shift.to_i
		grilleFich.shift

		grille = Grille.creer(diff, num.to_i, temps)
	  	grille.grilleJ = []

	  	i = 0
	  	grilleFich.each do |ligne|
	  		j = 0
	  		ligneCasesJ = []
	  		ligne.each_char do |c|
	  			ligneCasesJ << Case.creer(i, j, c )
	  			j += 1
	  		end
	  		grille.grilleJ<<ligneCasesJ
	  		i += 1
	  	end

	  	return grille
	end
	return nil
  end


  #Parcours horizontal par case de la grille
  # @param void		//ne prend aucun paramètre
  # @return void	//ne renvoie rien
  def parcourirH ()
  	self.parcourirL {|ligne|
  		ligne.each do |uneCase|
  			yield uneCase
  		end
  	}
  end


  #Parcours par ligne de la grille
  # @param void		//ne prend aucun paramètre
  # @return void	//ne renvoie rien
  def parcourirL ()
  	@grilleJ.each do |ligne|
  			yield ligne
  	end
  end


  #Parcours par colonne de la grille
  # @param void		//ne prend aucun paramètre
  # @return void	//ne renvoie rien
  def parcourirC ()
  	grilleTournee = []

  	for i in 0..(@taille-1)
  		colonne = []
  		for j in 0..(@taille-1)
  			colonne<<@grilleJ[j][i]
  		end
  		grilleTournee<<colonne
  	end

  	grilleTournee.each do |ligne|
  		yield ligne
  	end
  end


	#Observateur pour savoir si l'utilisateur a gagné
	# @param void		//ne prend aucun paramètre
	# @return true		//si l'utilisateur à gagné
	# @return false	//si l'utilisateur n'a pas gagné
	def observateur()

	  for i in 0..(taille-1)
	    for j in 0..(taille-1)
	      if ( grilleJ[i][j].etat != grilleF[i][j].etat )
	        return false
	      end
	    end
	  end
	    return true


	end

end
