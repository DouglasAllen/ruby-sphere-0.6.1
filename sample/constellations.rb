#
# constellations.rb: locations of constellations
#
# $Id: constellations.rb,v 1.2 2005/06/18 00:52:41 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

$:.unshift(File.join(File.expand_path(".."), "lib"))
require 'sphere'

module Sphere
  # from Rika Nenpyo (Chronological Scientific Tables 2003), ed. National Astronomical Observatory of Japan
  Constellations = {
    'UMi' => [ 'Ursa Minor',             '15 40'.hms_to_rad, +78.to_rad ],
    'Cep' => [ 'Cepheus',                '22  0'.hms_to_rad, +70.to_rad ],
    'Cam' => [ 'Camelopardalis',         ' 5 40'.hms_to_rad, +70.to_rad ],
    'Dra' => [ 'Draco',                  '17  0'.hms_to_rad, +60.to_rad ],
    'Cas' => [ 'Cassiopeia',             ' 1  0'.hms_to_rad, +60.to_rad ],
    'UMa' => [ 'Ursa Major',             '11  0'.hms_to_rad, +58.to_rad ],   
    'Lyn' => [ 'Lynx',                   ' 7 50'.hms_to_rad, +45.to_rad ],
    'Lac' => [ 'Lacerta',                '22 25'.hms_to_rad, +43.to_rad ],
    'Cyg' => [ 'Cygnus',                 '20 30'.hms_to_rad, +43.to_rad ],
    'Aur' => [ 'Auriga',                 ' 6  0'.hms_to_rad, +42.to_rad ],  
    'Per' => [ 'Perseus',                ' 3 20'.hms_to_rad, +42.to_rad ],
    'CVn' => [ 'Canes Venatici',         '13  0'.hms_to_rad, +40.to_rad ],
    'And' => [ 'Andromeda',              ' 0 40'.hms_to_rad, +38.to_rad ],
    'Lyr' => [ 'Lyra',                   '18 45'.hms_to_rad, +36.to_rad ],
    'LMi' => [ 'Leo Minor',              '10 20'.hms_to_rad, +33.to_rad ],
    'Tri' => [ 'Triangulum',             ' 2  0'.hms_to_rad, +32.to_rad ],
    'Her' => [ 'Hercules',               '17 10'.hms_to_rad, +27.to_rad ],
    'Vul' => [ 'Vulpecula',              '20 10'.hms_to_rad, +25.to_rad ],
    'Com' => [ 'Com Berenices',          '12 40'.hms_to_rad, +23.to_rad ],
    'Gem' => [ 'Gemini',                 ' 7  0'.hms_to_rad, +22.to_rad ],
    'Cnc' => [ 'Cancer',                 ' 8 30'.hms_to_rad, +20.to_rad ],
    'Ari' => [ 'Aries',                  ' 2 30'.hms_to_rad, +20.to_rad ],
    'Sge' => [ 'Sagitta',                '19 40'.hms_to_rad, +18.to_rad ],    
    'Tau' => [ 'Taurus',                 ' 4 30'.hms_to_rad, +18.to_rad ],
    'Peg' => [ 'Pegasus',                '22 30'.hms_to_rad, +17.to_rad ],
    'Leo' => [ 'Leo',                    '10 30'.hms_to_rad, +15.to_rad ], 
    'Del' => [ 'Delphinus',              '20 35'.hms_to_rad, +12.to_rad ],
    'Psc' => [ 'Pisces',                 ' 0 20'.hms_to_rad, +10.to_rad ],
    'Ser(N)' => [ 'Serpens (North)',     '15 35'.hms_to_rad,  +8.to_rad ],
    'Equ' => [ 'Equuleus',               '21 10'.hms_to_rad,  +6.to_rad ],
    'CMi' => [ 'Canis Minor',            ' 7 30'.hms_to_rad,  +6.to_rad ],
    'Ori' => [ 'Orion',                  ' 5 20'.hms_to_rad,  +3.to_rad ],
    'Aql' => [ 'Aquila',                 '19 30'.hms_to_rad,  +2.to_rad ],        
    
    'Sex' => [ 'Sextans',                '10 10'.hms_to_rad,  -1.to_rad ],
    'Vir' => [ 'Virgo',                  '13 20'.hms_to_rad,  -2.to_rad ],
    'Mon' => [ 'Monoceros',              ' 7  0'.hms_to_rad,  -3.to_rad ],
    'Oph' => [ 'Ophiuchus',              '17 10'.hms_to_rad,  -4.to_rad ],
    'Ser(S)' => [ 'Serpens (South)',     '18  0'.hms_to_rad,  -5.to_rad ],
    'Sct' => [ 'Scutum',                 '18 30'.hms_to_rad, -10.to_rad ],
    'Cet' => [ 'Cetus',                  ' 1 45'.hms_to_rad, -12.to_rad ],
    'Aqr' => [ 'Aquarius',               '22 20'.hms_to_rad, -13.to_rad ],
    'Lib' => [ 'Libra',                  '15 10'.hms_to_rad, -14.to_rad ],
    'Crt' => [ 'Crater',                 '11 20'.hms_to_rad, -15.to_rad ],
    'Crv' => [ 'Corvus',                 '12 20'.hms_to_rad, -18.to_rad ],
    'CrB' => [ 'Corona Borealis',        '12 20'.hms_to_rad, -18.to_rad ],
    'Cap' => [ 'Capricornus',            '20 50'.hms_to_rad, -20.to_rad ],    
    'Boo' => [ 'Bootes',                 '14 35'.hms_to_rad, -20.to_rad ],
    'Hya' => [ 'Hydra',                  '10 30'.hms_to_rad, -20.to_rad ],
    'Lep' => [ 'Lepus',                  ' 5 25'.hms_to_rad, -20.to_rad ],
    'CMa' => [ 'Canis Major',            ' 6 40'.hms_to_rad, -24.to_rad ],
    'Sgr' => [ 'Sagittarius',            '19  0'.hms_to_rad, -25.to_rad ],
    'Sco' => [ 'Scorpius',               '16 20'.hms_to_rad, -26.to_rad ],
    'Pyx' => [ 'Pyxis',                  ' 8 50'.hms_to_rad, -28.to_rad ],
    'Eri' => [ 'Eridanus',               ' 3 50'.hms_to_rad, -30.to_rad ],
    'PsA' => [ 'Piscis Austrinus',       '22  0'.hms_to_rad, -32.to_rad ],
    'Pup' => [ 'Puppis',                 ' 7 40'.hms_to_rad, -32.to_rad ],
    'For' => [ 'Fornax',                 ' 2 25'.hms_to_rad, -33.to_rad ],
    'Col' => [ 'Columba',                ' 5 40'.hms_to_rad, -34.to_rad ],
    'Ant' => [ 'Antlia',                 '10  0'.hms_to_rad, -35.to_rad ],
    'Scl' => [ 'Sculptor',               ' 0 30'.hms_to_rad, -35.to_rad ],
    'Mic' => [ 'Microscopium',           '20 50'.hms_to_rad, -37.to_rad ],
    'Cae' => [ 'Caelum',                 ' 4 50'.hms_to_rad, -38.to_rad ],
    'Lup' => [ 'Lupus',                  '15  0'.hms_to_rad, -40.to_rad ],
    'CrA' => [ 'Corona Australis',       '18 30'.hms_to_rad, -41.to_rad ],
    'Vel' => [ 'Vela',                   ' 9 30'.hms_to_rad, -45.to_rad ],
    'Gru' => [ 'Grus',                   '22 20'.hms_to_rad, -47.to_rad ],
    'Cen' => [ 'Centaurus',              '13 20'.hms_to_rad, -47.to_rad ],
    'Phe' => [ 'Phoenix',                ' 1  0'.hms_to_rad, -48.to_rad ],
    'Nor' => [ 'Norma',                  '16  0'.hms_to_rad, -50.to_rad ],
    'Tel' => [ 'Telescopium',            '19  0'.hms_to_rad, -52.to_rad ],
    'Pic' => [ 'Pictor',                 ' 5 30'.hms_to_rad, -52.to_rad ],
    'Hor' => [ 'Horologium',             ' 3 20'.hms_to_rad, -52.to_rad ],
    'Ara' => [ 'Ara',                    '17 10'.hms_to_rad, -55.to_rad ],
    'Ind' => [ 'Indus',                  '21 20'.hms_to_rad, -58.to_rad ],
    'Cru' => [ 'Crux',                   '12 20'.hms_to_rad, -60.to_rad ],
    'Dor' => [ 'Dorado',                 ' 5  0'.hms_to_rad, -60.to_rad ],
    'Car' => [ 'Carina',                 ' 8 40'.hms_to_rad, -62.to_rad ],
    'Cir' => [ 'Circinus',               '14 50'.hms_to_rad, -63.to_rad ],
    'Ret' => [ 'Reticulum',              ' 3 50'.hms_to_rad, -63.to_rad ],
    'Pav' => [ 'Pavo',                   '19 10'.hms_to_rad, -65.to_rad ],
    'TrA' => [ 'Triangulum Australe',    '15 40'.hms_to_rad, -65.to_rad ],    
    'Tuc' => [ 'Tucana',                 '23 45'.hms_to_rad, -68.to_rad ],
    'Vol' => [ 'Volans',                 ' 7 40'.hms_to_rad, -69.to_rad ],
    'Mus' => [ 'Musca',                  '12 30'.hms_to_rad, -70.to_rad ],
    'Hyi' => [ 'Hydrus',                 ' 2 40'.hms_to_rad, -72.to_rad ],
    'Aps' => [ 'Apus',                   '16  0'.hms_to_rad, -76.to_rad ],
    'Men' => [ 'Mensa',                  ' 5 40'.hms_to_rad, -77.to_rad ],
    'Cha' => [ 'Chamaeleon',             '10 40'.hms_to_rad, -78.to_rad ],
    'Oct' => [ 'Octans',                 '21  0'.hms_to_rad, -87.to_rad ],
  }
  Ecliptics = %w( Vir Leo Gem Cnc Tau Ari Psc Aqr Cap Sgr Sco Lib )
end

if __FILE__ == $PROGRAM_NAME
	
	include Sphere
	p Ecliptics
	p Constellations.keys
	
end
	