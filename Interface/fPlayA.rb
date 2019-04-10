require 'gtk3'
require './Classes/Page.rb'

require './Classes/Grille.rb'
require './Classes/Aide.rb'
require './Classes/boutonGrilleA.rb'
require './Classes/Chrono.rb'
require './Classes/ChronoInverse.rb'
require './Classes/boutonAide.rb'
require './Classes/boutonAideVerif.rb'
require './Classes/boutonAideHerbe.rb'
require './Classes/boutonAideTente.rb'
require './Interface/fFin.rb'
require './Classes/Score.rb'

class FPlayA < Page


		

	def initialize(monApp, header, anciennePage, unJoueur, uneSaison, nbGrille)

		super(monApp, :vertical, header,  anciennePage, unJoueur)

		@nbAidesUtilises = 0

        case uneSaison
			when "Printemps" then
				@saison = 1
			when "Ete" then
				@saison = 2
			when "Automne" then
				@saison = 3
			when "Hiver" then
				@saison = 4
   		end

   		@nbFeuilles = unJoueur.nbAides

        tabGrille = unJoueur.commencerAventure(@saison, nbGrille)
        puts tabGrille.at(0)
        puts tabGrille.at(1)
        puts tabGrille.at(2)

        @nbFeuilles = unJoueur.nbAides


    	@gHelp = Gtk::ButtonBox.new(:vertical)

    	@boxFeuilles=Gtk::ButtonBox.new(:horizontal)
			@boxFeuilles.spacing=1
			@img =(Gtk::Image.new(:file =>"./Assets/feuille.png"))
			@profil = Gtk::Label.new().set_markup("<span foreground=\"#EF2929\" font-desc=\"Courier New bold 15\"> #{@nbFeuilles.to_s}</span>")
			@boxFeuilles.add(@img)
			@boxFeuilles.add(@profil, :expand => true, :fill => false)

		@chrono = ChronoInverse.new(360)
		@gHelp.add(@boxFeuilles)
		

		thr=Thread.new do
			#sleep(2)
			@chrono.cStart


			if (@chrono.fin == true)
				
				self.supprimeMoi
	   	   		menu = FFin.new(@window, @header, self, unJoueur, "perdu")
	   		   	menu.ajouteMoi
	  	 	   	@window.show_all
	  	    end
 		end				
		
        @frame = Gtk::Table.new(1,1,false)

        @gChrono = Gtk::ButtonBox.new(:vertical)
        @gChrono.add(@chrono.lChrono) 

        @box = Gtk::ButtonBox.new(:horizontal)

	   grilleDeJeu = Grille.creer(tabGrille.at(1), tabGrille.at(2))

	   taille = grilleDeJeu.taille()

        @grille = Gtk::Table.new(taille, taille, false)



		@boutonGrille = [[]]

	# Mise en place des indicateurs de la grille de jeu

		for i in (0..taille-1)
			for j in (0..taille-1)
				lId = Gtk::Label.new(grilleDeJeu.nbTentesLigne[j].to_s)
				@grille.attach(lId, j+1,j+2, 0,1)
			end
			lId2 = Gtk::Label.new(grilleDeJeu.nbTentesColonne[i].to_s)
			@grille.attach(lId2,0,1, i+1,i+2)
		end

	# Création de la grille de jeu.
	# Mise en place d'une matrice composant tous les boutons

		for i in (0..taille-1)
			temp=[]
			for j in (0..taille-1)
					vEtat = grilleDeJeu.grilleJ[i][j].etat
					temp[j] = BoutonGrilleA.new("./Assets/#{uneSaison}")
					temp[j].mCoord(i,j)
					temp[j].chgEtat(vEtat)
					@grille.attach(temp[j].bouton, i+1, i+2, j+1,j+2)
			end
			@boutonGrille[i] = temp
		end

	# Appel de l'evenement bouton "cliqué", et modification du bouton cliqué
		if(!@chrono.pause)
			@boutonGrille.each{|k|
				k.each{|l|
					l.bouton.signal_connect("clicked"){
						if @aide != nil
							if @aide.instance_of? Case
								@boutonGrille[@aide.i][@aide.j].chgEtat(grilleDeJeu.grilleJ[@aide.i][@aide.j].etat)
							else
								for i in (0..taille-1)
									@boutonGrille[@aide][i].chgEtat(grilleDeJeu.grilleJ[@aide][i].etat)
									@boutonGrille[i][@aide].chgEtat(grilleDeJeu.grilleJ[i][@aide].etat)
								end
							end
							@lableAide.set_markup('')

							@aide = nil
						end
			        	grilleDeJeu.grilleJ[l.coordI][l.coordJ].jouerCase()
						@boutonGrille[l.coordI][l.coordJ].chgEtat(grilleDeJeu.grilleJ[l.coordI][l.coordJ].etat)
						grilleDeJeu.enregistrerFichier(unJoueur.pseudo, nil)
						
						if (grilleDeJeu.observateur())
							unJoueur.finirLaPartie(tabGrille.at(0))
							@chrono.cFin
							@chrono.cRaz
							sleep(1)
							self.supprimeMoi
				  	        	menu = FFin.new(@window, @header, self, unJoueur, "gagner")
				  	        	menu.ajouteMoi
				  	        	@window.show_all
						end

					}
				}
			}
		end


		@header.btnMenu.signal_connect('clicked') {
			# @chrono.cFin
			# @chrono.cRaz
	        self.supprimeMoi
	        menu = FMenu.new(@window, @header, self, unJoueur)
	        menu.ajouteMoi
	        @window.show_all
    	}

		@boxAide = Gtk::ButtonBox.new(:vertical)

		@lableAide = Gtk::Label.new()

		@boxAide.add(@lableAide)

		@b1 = BoutonAideHerbe.new("Aide Herbe : 2 feuilles", true)
		@b2 = BoutonAideTente.new("Aide Tente : 3 feuilles", true)
		@b3 = BoutonAideVerif.new("Verification : 5 feuilles", true)
		

		@boxAide.add(@b1.bouton)
		@boxAide.add(@b2.bouton)
		@boxAide.add(@b3.bouton)

		@b1.bouton.signal_connect('clicked'){
			tempo = @nbFeuilles - @b1.prix
			if @aide != nil
				if @aide.instance_of? Case
					@boutonGrille[@aide.i][@aide.j].chgEtat(grilleDeJeu.grilleJ[@aide.i][@aide.j].etat)
				else
					for i in (0..taille-1)
						@boutonGrille[@aide][i].chgEtat(grilleDeJeu.grilleJ[@aide][i].etat)
						@boutonGrille[i][@aide].chgEtat(grilleDeJeu.grilleJ[i][@aide].etat)
					end
				end

				@aide = nil
			end
			if(tempo >= 0)
				@nbFeuilles = tempo
			
				@profil.set_markup("<span foreground=\"#EF2929\" font-desc=\"Courier New bold 15\"> #{@nbFeuilles}</span>")
				
				@aide = @b1.aide(grilleDeJeu, @lableAide, unJoueur, @boutonGrille)
				@nbAidesUtilises+=1
			else
				@lableAide.set_markup("<span foreground=\"#FFFFFF\" font-desc=\"Courier New bold 11\">Vous ne pouvez plus utiliser cette aide</span>")
			end
		}

		@b2.bouton.signal_connect('clicked') {
			tempo = @nbFeuilles - @b2.prix
			if @aide != nil
				if @aide.instance_of? Case
					@boutonGrille[@aide.i][@aide.j].chgEtat(grilleDeJeu.grilleJ[@aide.i][@aide.j].etat)
				else
					for i in (0..taille-1)
						@boutonGrille[@aide][i].chgEtat(grilleDeJeu.grilleJ[@aide][i].etat)
						@boutonGrille[i][@aide].chgEtat(grilleDeJeu.grilleJ[i][@aide].etat)
					end
				end

				@aide = nil
			end
			if(tempo >= 0)

				@nbFeuilles = tempo
			
				@profil.set_markup("<span foreground=\"#EF2929\" font-desc=\"Courier New bold 15\"> #{@nbFeuilles}</span>")
				
				@aide = @b2.aide(grilleDeJeu, @lableAide, unJoueur, @boutonGrille)
				@nbAidesUtilises+=1
			else
				@lableAide.set_markup("<span foreground=\"#FFFFFF\" font-desc=\"Courier New bold 11\">Vous ne pouvez plus utiliser cette aide</span>")
			end
        }

		@b3.bouton.signal_connect('clicked') {
			tempo = @nbFeuilles - @b3.prix
			if @aide != nil
				if @aide.instance_of? Case
					@boutonGrille[@aide.i][@aide.j].chgEtat(grilleDeJeu.grilleJ[@aide.i][@aide.j].etat)
				else
					for i in (0..taille-1)
						@boutonGrille[@aide][i].chgEtat(grilleDeJeu.grilleJ[@aide][i].etat)
						@boutonGrille[i][@aide].chgEtat(grilleDeJeu.grilleJ[i][@aide].etat)
					end
				end

				@aide = nil
			end
			if(tempo >= 0)
				@nbFeuilles = tempo
			
				@profil.set_markup("<span foreground=\"#EF2929\" font-desc=\"Courier New bold 15\"> #{@nbFeuilles}</span>")
				@aide = @b3.aide(grilleDeJeu, @lableAide, unJoueur, @boutonGrille)
				@nbAidesUtilises+=1
			else
				@lableAide.set_markup("<span foreground=\"#FFFFFF\" font-desc=\"Courier New bold 11\">Vous ne pouvez plus utiliser cette aide</span>")
			end
        }				

		@gHelp.add(@boxAide)

		@bPause = Gtk::Button.new()
		@bPause.set_relief(:none)
		@pause=(Gtk::Image.new(:file =>"./Assets/pause.png"))
		@bPause.set_image(@pause)
		@gChrono.add(@bPause)



		@bPause.signal_connect('clicked') {
			@chrono.cPause
			
			if(@chrono.pause)
				@boutonGrille.each{|k|
					k.each{|l|
						l.clic=false
						l.bouton.set_opacity(0.0)
					}
				}
				@pause=(Gtk::Image.new(:file =>"./Assets/Play.png"))
				@bPause.set_image(@pause)

				@b1.cliquable = false
				@b2.cliquable = false
				@b3.cliquable = false
			else
				@boutonGrille.each{|k|
					k.each{|l|
						l.clic=true
						l.bouton.set_opacity(1.0)
					}
				} 
				@pause=(Gtk::Image.new(:file =>"./Assets/pause.png"))
				@bPause.set_image(@pause)

				@b1.cliquable = true
				@b2.cliquable = true
				@b3.cliquable = true
			end
        }

		@gHelp.spacing=70

		@box.add(@gChrono)
		@box.add(@grille)
		@box.add(@gHelp)

		@frame.attach(@box,0,1,0,1)

		@bg=(Gtk::Image.new(:file =>"./Assets/ImgGame.jpg"))
        @frame.attach(@bg,0,1,0,1)

        self.add(@frame)
    end

end
