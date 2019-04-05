require 'gtk3'

require './fDiff.rb'
#require '../Interface/fMenu.rb'
require './fPlay.rb'
require './Page.rb'
require './fAventure.rb'


# Fichier: fGameMode.rb
# Auteur: Marchand Killian
# Description:
# => Menu des modes de jeu
# => C'est ici qu'est regroupé les composants du menu des modes de jeu
# => Ici nous gerons ainsi les évenements lié aux boutons, qui permet d'appeler la page suivante ou bien précédente ainsi que la construction la page.

class FGM < Page

	def initialize(monApp, header, anciennePage, unJoueur)

		super(monApp, :vertical, header,  anciennePage, unJoueur)

		@frame = Gtk::Table.new(1,1,false)

		@butons = Gtk::ButtonBox.new(:horizontal)
    	@butons.layout = :spread

		@classic = Gtk::Button.new(:label => 'Classique', :use_underline => nil)
		@adven = Gtk::Button.new(:label => 'Aventure', :use_underline => nil)
		@comp = Gtk::Button.new(:label => 'Compétition', :use_underline => nil)

		@butons.add(@classic, :expand => true, :fill => false)
		@butons.add(@adven, :expand => true, :fill => false)
		@butons.add(@comp, :expand => true, :fill => false)

			@header.btnMenu.signal_connect('clicked') {
		        self.supprimeMoi
		        menu = FMenu.new(@window, @header, self, unJoueur)
		        menu.ajouteMoi
		        @window.show_all
		    }

		@classic.signal_connect('clicked') {
			self.supprimeMoi
			suivant = FDiff.new(@window, header, self, unJoueur)
			suivant.ajouteMoi
      		@window.show_all
		}

		@adven.signal_connect('clicked') {
			self.supprimeMoi
			suivant = FAventure.new(@window, header, self, unJoueur)
			suivant.ajouteMoi
      		@window.show_all
		}

		@comp.signal_connect('clicked') {
			self.supprimeMoi
			suivant=FPlay.new(@window, header, self, unJoueur, getLevel(), true)
			suivant.ajouteMoi
			@window.show_all
		}
		@frame.attach(@butons,0,1,0,1)

		@bg=(Gtk::Image.new(:file =>"../Assets/ImgPresentation2.jpg"))
        @frame.attach(@bg,0,1,0,1)

        self.add(@frame)
	end

	def getLevel()
		i=rand(2)
		diff=["GrillesFaciles", "GrillesMoyennes", "GrillesDifficiles"]

		return diff[i]
	end
end
