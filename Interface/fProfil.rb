require 'gtk3'
#require '../Interface/fDiff.rb'
#require '../Interface/fMenu.rb'
#require '../Interface/fPlay.rb'
require './TexteAfficher.rb'
require './Page.rb'
require './fModifierCompte.rb'



class FProfil < Page

	def initialize(monApp, header, anciennePage)

		super("Profil", monApp, :vertical, header,  anciennePage)
		self.hautPage.spacing = 220


		@gProfil = Gtk::ButtonBox.new(:vertical)
        @gProfil.spacing = 30
        
        @gProfil2 = Gtk::ButtonBox.new(:horizontal)
        @gProfil2.spacing = 100

		@pseudo = TexteAfficher.creer('Pseudo : ').gTexteAfficher
		@score = TexteAfficher.creer('Score').gTexteAfficher
		@modif =Gtk::Button.new(:label => 'Modifier mes informations', :use_underline => nil, :stock_id => nil)
        @deco = Gtk::Button.new(:label => 'Deconnexion', :use_underline => nil, :stock_id => nil)
        @menu = Gtk::Button.new(:label => 'Menu', :use_underline => nil, :stock_id => nil)

		@gProfil.add(@pseudo, :expand => true, :fill => false)
        @gProfil.add(@score, :expand => true, :fill => false)
       
        @gProfil.add(@gProfil2)
		@gProfil2.add(@modif, :expand => true, :fill => false)
		@gProfil2.add(@menu, :expand => true, :fill => false)
        @gProfil2.add(@deco, :expand => true, :fill => false)
        


		@modif.signal_connect('clicked') {
			self.supprimeMoi
            suivant = FModifC.new(@window, header, self)
            suivant.ajouteMoi
            @window.show_all  		
		}

		@menu.signal_connect('clicked') {
			self.supprimeMoi
            suivant = FMenu.new(@window, header, self)
            suivant.ajouteMoi
            @window.show_all  		
		}

		@deco.signal_connect('clicked') {}


		self.add(@gProfil)

	end
end

