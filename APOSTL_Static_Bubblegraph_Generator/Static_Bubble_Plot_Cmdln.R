###################################################################################################
# R-code: APOSTL Global Variables
# Author: Brent Kuenzi
################################## Dependencies ###################################################
library(dplyr); library(tidyr); library(ggplot2); library(ggrepel)
colors <- c("AirForceblue"="#5D8AA8","Aliceblue"="#F0F8FF","Alizarincrimson"="#E32636","Almond"="#EFDECD","Amaranth"="#E52B50","Amber"="#FFBF00","Americanrose"="#FF033E","Amethyst"="#9966CC","AndroidGreen"="#A4C639","Antiflashwhite"="#F2F3F4","Antiquebrass"="#CD9575","Antiquefuchsia"="#915C83","Antiquewhite"="#FAEBD7","Ao"="#008000","Applegreen"="#8DB600","Apricot"="#FBCEB1","Aqua"="#00FFFF","Aquamarine"="#7FFFD4","Armygreen"="#4B5320","Arsenic"="#3B444B","Arylideyellow"="#E9D66B","Ashgray"="#B2BEB5","Asparagus"="#87A96B","Atomictangerine"="#FF9966","Auburn"="#A52A2A","Aureolin"="#FDEE00","AuroMetalSaurus"="#6E7F80","Awesome"="#FF2052","Azure"="#007FFF","Azuremist"="#F0FFFF","Babyblue"="#89CFF0","Babyblueeyes"="#A1CAF1","Babypink"="#F4C2C2","BallBlue"="#21ABCD","BananaMania"="#FAE7B5","Bananayellow"="#FFE135","Battleshipgray"="#848482","Bazaar"="#98777B","Beaublue"="#BCD4E6","Beaver"="#9F8170","Beige"="#F5F5DC","Bisque"="#FFE4C4","Bistre"="#3D2B1F","Bittersweet"="#FE6F5E","Obsidian"="#000000","Onyx"="#000000","LostSoul"="#000000","Midnight"="#000000","RollingBlackout"="#000000","SleepingPanther"="#000000","VoidbyArmani"="#000000","BlanchedAlmond"="#FFEBCD","BleudeFrance"="#318CE7","BlizzardBlue"="#ACE5EE","Blond"="#FAF0BE","Blue"="#0000FF","BlueBell"="#A2A2D0","BlueGray"="#6699CC","Bluegreen"="#00DDDD","Blueviolet"="#8A2BE2","Blush"="#DE5D83","Bole"="#79443B","Bondiblue"="#0095B6","BostonUniversityRed"="#CC0000","Brandeisblue"="#0070FF","Brass"="#B5A642","Brickred"="#CB4154","Brightcerulean"="#1DACD6","Brightgreen"="#66FF00","Brightlavender"="#BF94E4","Brightmaroon"="#C32148","Brightpink"="#FF007F","Brightturquoise"="#08E8DE","Brightube"="#D19FE8","Brilliantlavender"="#F4BBFF","Brilliantrose"="#FF55A3","Brinkpink"="#FB607F","Britishracinggreen"="#004225","Bronze"="#CD7F32","Brown"="#964B00","Bubblegum"="#FFC1CC","Bubbles"="#E7FEFF","Buff"="#F0DC82","Bulgarianrose"="#480607","Burgundy"="#800020","Burlywood"="#DEB887","Burntorange"="#CC5500","Burntsienna"="#E97451","Burntumber"="#8A3324","Byzantine"="#BD33A4","Byzantium"="#702963","Cadet"="#536872","Cadetblue"="#5F9EA0","Cadetgray"="#91A3B0","CadmiumGreen"="#006B3C","CadmiumOrange"="#ED872D","CadmiumRed"="#E30022","CadmiumYellow"="#FFF600","CalPolyPomonagreen"="#1E4D2B","CambridgeBlue"="#A3C1AD","Camel"="#C19A6B","Camouflagegreen"="#78866B","Canaryyellow"="#FFEF00","Candyapplered"="#FF0800","Candypink"="#E4717A","Capri"="#00BFFF","Caputmortuum"="#592720","Cardinal"="#C41E3A","Caribbeangreen"="#00CC99","Carmine"="#960018","Carminepink"="#EB4C42","Carminered"="#FF0038","Carnationpink"="#FFA6C9","Carnelian"="#B31B1B","Carolinablue"="#99BADD","Carrotorange"="#ED9121","Ceil"="#92A1CF","Celadon"="#ACE1AF","Celestialblue"="#4997D0","Cerise"="#DE3163","Cerisepink"="#EC3B83","Cerulean"="#007BA7","Ceruleanblue"="#2A52BE","CGBlue"="#007AA5","CGRed"="#E03C31","Chamoisee"="#A0785A","Champagne"="#F7E7CE","Charcoal"="#36454F","Chartreuse"="#DFFF00","Cherryblossompink"="#FFB7C5","Chestnut"="#CD5C5C","Chocolate"="#7B3F00","Chromeyellow"="#FFA700","Cinereous"="#98817B","Cinnabar"="#E34234","Cinnamon"="#D2691E","Citrine"="#E4D00A","Classicrose"="#FBCCE7","Cobalt"="#0047AB","Coffee"="#C86428","Columbiablue"="#9BDDFF","Coolblack"="#002E63","Coolgray"="#8C92AC","Copper"="#B87333","Copperrose"="#996666","Coquelicot"="#FF3800","Coral"="#FF7F50","Coralpink"="#F88379","Coralred"="#FF4040","Cordovan"="#893F45","Corn"="#FBEC5D","Cornflowerblue"="#6495ED","Cornsilk"="#FFF8DC","Cosmiclatte"="#FFF8E7","Cottoncandy"="#FFBCD9","Cream"="#FFFDD0","Crimson"="#DC143C","Crimsonglory"="#BE0032","Cyan"="#00B7EB","Daffodil"="#FFFF31","Dandelion"="#F0E130","Darkblue"="#00008B","Darkbrown"="#654321","Darkbyzantium"="#5D3954","Darkcandyapplered"="#A40000","Darkcerulean"="#08457E","Darkchampagne"="#C2B280","Darkchestnut"="#986960","Darkcoral"="#CD5B45","Darkcyan"="#008B8B","Darkelectricblue"="#536878","Darkgoldenrod"="#B8860B","Darkgray"="#A9A9A9","Darkgreen"="#013220","Darkjunglegreen"="#1A2421","Darkkhaki"="#BDB76B","Darklava"="#483C32","Darklavender"="#734F96","Darkmagenta"="#8B008B","Darkmidnightblue"="#003366","Darkolivegreen"="#556B2F","Darkorange"="#FF8C00","Darkorchid"="#9932CC","Darkpastelblue"="#779ECB","Darkpastelgreen"="#03C03C","Darkpastelpurple"="#966FD6","Darkpastelred"="#C23B22","Darkpink"="#E75480","Darkpowderblue"="#003399","Darkraspberry"="#872657","Darkred"="#8B0000","Darksalmon"="#E9967A","Darkscarlet"="#560319","Darkseagreen"="#8FBC8F","Darksienna"="#3C1414","Darkslateblue"="#483D8B","Darkslategray"="#2F4F4F","Darkspringgreen"="#177245","Darktan"="#918151","Darktangerine"="#FFA812","Darkterracotta"="#CC4E5C","Darkturquoise"="#00CED1","Darkviolet"="#9400D3","Dartmouthgreen"="#00693E","Davy'sgray"="#555555","Debianred"="#D70A53","Deepcarmine"="#A9203E","Deepcarminepink"="#EF3038","Deepcarrotorange"="#E9692C","Deepcerise"="#DA3287","Deepchampagne"="#FAD6A5","Deepchestnut"="#B94E48","Deepfuchsia"="#C154C1","Deepjunglegreen"="#004B49","Deeplilac"="#9955BB","Deepmagenta"="#CC00CC","Deeppeach"="#FFCBA4","Deeppink"="#FF1493","Deepsaffron"="#FF9933","Denim"="#1560BD","Desertsand"="#EDC9AF","Dimgray"="#696969","Dodgerblue"="#1E90FF","Dogwoodrose"="#D71868","Dollarbill"="#85BB65","Drab"="#967117","Dukeblue"="#00009C","Earthyellow"="#E1A95F","Eggplant"="#614051","Eggshell"="#F0EAD6","Egyptianblue"="#1034A6","Electricblue"="#7DF9FF","Electriccrimson"="#FF003F","Electricgreen"="#00FE00","Electricindigo"="#6F00FF","Electriclime"="#CCFF00","Electricpurple"="#BF00FF","Electricultramarine"="#3F00FF","Electricviolet"="#8F00FF","Electricyellow"="#FFFE00","Emerald"="#50C878","Etonblue"="#96C8A2","Falured"="#801818","Fandango"="#B53389","Fashionfuchsia"="#F400A1","Fawn"="#E5AA70","Feldgrau"="#4D5D53","Ferngreen"="#4F7942","FerrariRed"="#FF2800","Fielddrab"="#6C541E","Firebrick"="#B22222","Fireenginered"="#CE2029","Flame"="#E25822","Flamingopink"="#FC8EAC","Flavescent"="#F7E98E","Flax"="#EEDC82","Floralwhite"="#FFFAF0","Folly"="#FF004F","Forestgreen"="#014421","Frenchbeige"="#A67B5B","Frenchblue"="#0072BB","Frenchlilac"="#86608E","Frenchrose"="#F64A8A","Fuchsia"="#FF00FF","Fuchsiapink"="#FF77FF","Fulvous"="#E48400","FuzzyWuzzy"="#CC6666","Gainsboro"="#DCDCDC","Gamboge"="#E49B0F","Ghostwhite"="#F8F8FF","Ginger"="#B06500","Glaucous"="#6082B6","Gold"="#D4AF37","Goldenbrown"="#996515","Goldenpoppy"="#FCC200","Goldenrod"="#DAA520","Goldenyellow"="#FFDF00","GrannySmithApple"="#A8E4A0","Gray"="#808080","Grayasparagus"="#465945","Green"="#00FF00","Greenyellow"="#ADFF2F","Grullo"="#A99A86","Guppiegreen"="#00FF7F","Halayaube"="#663854","Hanblue"="#446CCF","Hanpurple"="#5218FA","Harlequin"="#3FFF00","Harvardcrimson"="#C90016","HarvestGold"="#DA9100","Heliotrope"="#DF73FF","Honeydew"="#F0FFF0","Hooker'sgreen"="#007000","Hotmagenta"="#FF1DCE","Hotpink"="#FF69B4","Huntergreen"="#355E3B","Iceberg"="#71A6D2","Icterine"="#FCF75E","Inchworm"="#B2EC5D","Indiagreen"="#138808","Indianyellow"="#E3A857","Indigo"="#00416A","InternationalKleinBlue"="#002FA7","Internationalorange"="#FF4F00","Iris"="#5A4FCF","Isabelline"="#F4F0EC","Islamicgreen"="#009000","Ivory"="#FFFFF0","Jade"="#00A86B","Jasmine"="#F8DE7E","Jasper"="#D73B3E","Jazzberryjam"="#A50B5E","Jonquil"="#FADA5E","Junebud"="#BDDA57","Junglegreen"="#29AB87","Kellygreen"="#4CBB17","Khaki"="#C3B091","KUCrimson"="#E8000D","Languidlavender"="#D6CADD","Lapislazuli"="#26619C","LaSalleGreen"="#087830","LaserLemon"="#FEFE22","Lava"="#CF1020","Lavender"="#B57EDC","Lavenderblue"="#CCCCFF","Lavenderblush"="#FFF0F5","Lavendergray"="#C4C3D0","Lavenderindigo"="#9457EB","Lavendermagenta"="#EE82EE","Lavendermist"="#E6E6FA","Lavenderpink"="#FBAED2","Lavenderpurple"="#967BB6","Lavenderrose"="#FBA0E3","Lawngreen"="#7CFC00","Lemon"="#FFF700","Lemonchiffon"="#FFFACD","Lightapricot"="#FDD5B1","Lightblue"="#ADD8E6","Lightbrown"="#B5651D","Lightcarminepink"="#E66771","Lightcoral"="#F08080","Lightcornflowerblue"="#93CCEA","LightCrimson"="#F56991","Lightcyan"="#E0FFFF","Lightfuchsiapink"="#F984EF","Lightgoldenrodyellow"="#FAFAD2","Lightgray"="#D3D3D3","Lightgreen"="#90EE90","Lightkhaki"="#F0E68C","Lightmauve"="#DCD0FF","Lightpastelpurple"="#B19CD9","Lightpink"="#FFB6C1","Lightsalmon"="#FFA07A","Lightsalmonpink"="#FF9999","Lightseagreen"="#20B2AA","Lightskyblue"="#87CEFA","Lightslategray"="#778899","Lighttaupe"="#B38B6D","LightThulianpink"="#E68FAC","Lightyellow"="#FFFFED","Lilac"="#C8A2C8","Lime"="#BFFF00","Limegreen"="#32CD32","Lincolngreen"="#195905","Linen"="#FAF0E6","Liver"="#534B4F","Lust"="#E62020","Magenta"="#CA1F7B","Magicmint"="#AAF0D1","Magnolia"="#F8F4FF","Mahogany"="#C04000","MajorelleBlue"="#6050DC","Malachite"="#0BDA51","Manatee"="#979AAA","MangoTango"="#FF8243","Maroon"="#800000","Mauve"="#E0B0FF","Mauvelous"="#EF98AA","Mauvetaupe"="#915F6D","Mayablue"="#73C2FB","Meatbrown"="#E5B73B","Mediumaquamarine"="#66DDAA","Mediumblue"="#0000CD","Mediumcandyapplered"="#E2062C","Mediumcarmine"="#AF4035","Mediumchampagne"="#F3E5AB","Mediumelectricblue"="#035096","Mediumjunglegreen"="#1C352D","Mediumlavendermagenta"="#DDA0DD","Mediumorchid"="#BA55D3","MediumPersianblue"="#0067A5","Mediumpurple"="#9370DB","Mediumredviolet"="#BB3385","Mediumseagreen"="#3CB371","Mediumslateblue"="#7B68EE","Mediumspringbud"="#C9DC87","Mediumspringgreen"="#00FA9A","Mediumtaupe"="#674C47","Mediumtealblue"="#0054B4","Mediumturquoise"="#48D1CC","Mediumvioletred"="#C71585","Melon"="#FDBCB4","Midnightblue"="#191970","Midnightgreen"="#004953","Mikadoyellow"="#FFC40C","Mint"="#3EB489","Mintcream"="#F5FFFA","Mintgreen"="#98FF98","Mistyrose"="#FFE4E1","Moonstoneblue"="#73A9C2","Mordantred19"="#AE0C00","Mossgreen"="#ADDFAD","MountainMeadow"="#30BA8F","Mountbattenpink"="#997A8D","MSUGreen"="#18453B","Mulberry"="#C54B8C","Mustard"="#FFDB58","Myrtle"="#21421E","Nadeshikopink"="#F6ADC6","Napiergreen"="#2A8000","Navajowhite"="#FFDEAD","Navy"="#000080","NeonCarrot"="#FFA343","Neonfuchsia"="#FE59C2","Neongreen"="#39FF14","Nonphotoblue"="#A4DDED","OceanBoatBlue"="#0077BE","Ochre"="#CC7722","Oldgold"="#CFB53B","Oldlace"="#FDF5E6","Oldlavender"="#796878","Oldmauve"="#673147","Oldrose"="#C08081","Olive"="#808000","OliveDrab"="#6B8E23","OliveDrab7"="#3C341F","Olivine"="#9AB973","Operamauve"="#B784A7","Orange"="#FF7F00","Orangepeel"="#FF9F00","Orangered"="#FF4500","Orchid"="#DA70D6","OUCrimsonRed"="#990000","OuterSpace"="#414A4C","OutrageousOrange"="#FF6E4A","OxfordBlue"="#002147","Pakistangreen"="#006600","Palatinateblue"="#273BE2","Palatinatepurple"="#682860","Paleblue"="#AFEEEE","Palebrown"="#987654","Palecerulean"="#9BC4E2","Palechestnut"="#DDADAF","Palecopper"="#DA8A67","Palecornflowerblue"="#ABCDEF","Palegold"="#E6BE8A","Palegoldenrod"="#EEE8AA","Palegreen"="#98FB98","Palemagenta"="#F984E5","Palepink"="#FADADD","Paleredviolet"="#DB7093","Palerobineggblue"="#96DED1","Palesilver"="#C9C0BB","Palespringbud"="#ECEBBD","Paletaupe"="#BC987E","Pansypurple"="#78184A","Papayawhip"="#FFEFD5","Pastelblue"="#AEC6CF","Pastelbrown"="#836953","Pastelgray"="#CFCFC4","Pastelgreen"="#77DD77","Pastelmagenta"="#F49AC2","Pastelorange"="#FFB347","Pastelpink"="#FFD1DC","Pastelpurple"="#B39EB5","Pastelred"="#FF6961","Pastelviolet"="#CB99C9","Pastelyellow"="#FDFD96","Patriarch"="#800080","Payne'sgray"="#40404F","Peach"="#FFE5B4","Peachorange"="#FFCC99","Peachpuff"="#FFDAB9","Peachyellow"="#FADFAD","Pear"="#D1E231","PearlAqua"="#88D8C0","Peridot"="#E6E200","Persianblue"="#1C39BB","Persiangreen"="#00A693","Persianindigo"="#32127A","Persianorange"="#D99058","Persianpink"="#F77FBE","Persianplum"="#701C1C","Persianred"="#CC3333","Persianrose"="#FE28A2","Persimmon"="#EC5800","Phlox"="#DF00FF","Phthaloblue"="#000F89","Phthalogreen"="#123524","Piggypink"="#FDDDE6","Pinegreen"="#01796F","Pink"="#FFC0CB","Pinkpearl"="#E7ACCF","PinkSherbet"="#F78FA7","Pistachio"="#93C572","Platinum"="#E5E4E2","Plum"="#8E4585","PortlandOrange"="#FF5A36","Powderblue"="#B0E0E6","Princetonorange"="#FF8F00","Prussianblue"="#003153","Puce"="#CC8899","Pumpkin"="#FF7518","Purple"="#9F00C5","PurpleHeart"="#69359C","Purplemountainmajesty"="#9678B6","Purplepizzazz"="#FE4EDA","Purpletaupe"="#50404D","Quartz"="#51484F","RadicalRed"="#FF355E","Raspberry"="#E30B5D","Raspberrypink"="#E25098","Raspberryrose"="#B3446C","Rawumber"="#826644","Razzledazzlerose"="#FF33CC","Razzmatazz"="#E3256B","Red"="#FF0000","Redwood"="#AB4E52","Regalia"="#522D80","Richblack"="#004040","Richbrilliantlavender"="#F1A7FE","Richcarmine"="#D70040","Richelectricblue"="#0892D0","Richlavender"="#A76BCF","Richlilac"="#B666D2","Richmaroon"="#B03060","Riflegreen"="#414833","Robineggblue"="#00CCCC","Rosebonbon"="#F9429E","Roseebony"="#674846","Rosegold"="#B76E79","Rosepink"="#FF66CC","Rosequartz"="#AA98A9","Rosetaupe"="#905D5D","Rosewood"="#65000B","Rossocorsa"="#D40000","Rosybrown"="#BC8F8F","Royalazure"="#0038A8","Royalblue"="#002366","Royalfuchsia"="#CA2C92","Royalpurple"="#7851A9","Ruby"="#E0115F","Ruddy"="#FF0028","Ruddybrown"="#BB6528","Ruddypink"="#E18E96","Rufous"="#A81C07","Russet"="#80461B","Rust"="#B7410E","SacramentoStategreen"="#00563F","Saddlebrown"="#8B4513","Safetyorange"="#FF6700","Saffron"="#F4C430","Salmon"="#FF8C69","Salmonpink"="#FF91A4","Sandstorm"="#ECD540","Sandybrown"="#F4A460","Sangria"="#92000A","Sapgreen"="#507D2A","Sapphire"="#082567","Satinsheengold"="#CBA135","Scarlet"="#FF2400","Schoolbusyellow"="#FFD800","Screamin'Green"="#76FF7A","Seagreen"="#2E8B57","Sealbrown"="#321414","Seashell"="#FFF5EE","Selectiveyellow"="#FFBA00","Sepia"="#704214","Shadow"="#8A795D","Shamrockgreen"="#009E60","Shockingpink"="#FC0FC0","Sienna"="#882D17","Silver"="#C0C0C0","Sinopia"="#CB410B","Skobeloff"="#007474","Skyblue"="#87CEEB","Skymagenta"="#CF71AF","Slateblue"="#6A5ACD","Slategray"="#708090","Smokeytopaz"="#933D41","Smokyblack"="#100C08","Snow"="#FFFAFA","SpiroDiscoBall"="#0FC0FC","Splashedwhite"="#FEFDFF","Springbud"="#A7FC00","Steelblue"="#4682B4","St.Patrick'sblue"="#23297A","Straw"="#E4D96F","Sunglow"="#FFCC33","Tan"="#D2B48C","Tangelo"="#F94D00","Tangerine"="#F28500","Tangerineyellow"="#FFCC00","Taupegray"="#8B8589","Teagreen"="#D0F0C0","Teal"="#008080","Tealblue"="#367588","Tealgreen"="#006D5B","Tenné"="#CD5700","Terracotta"="#E2725B","Thistle"="#D8BFD8","Thulianpink"="#DE6FA1","TickleMePink"="#FC89AC","TiffanyBlue"="#0ABAB5","Tiger'seye"="#E08D3C","Timberwolf"="#DBD7D2","Titaniumyellow"="#EEE600","Tomato"="#FF6347","Toolbox"="#746CC0","Topaz"="#FFC87C","Tractorred"="#FD0E35","Tropicalrainforest"="#00755E","TrueBlue"="#0073CF","TuftsBlue"="#417DC1","Tumbleweed"="#DEAA88","Turkishrose"="#B57281","Turquoise"="#30D5C8","Turquoiseblue"="#00FFEF","Turquoisegreen"="#A0D6B4","Tuscanred"="#66424D","Twilightlavender"="#8A496B","Tyrianpurple"="#66023C","UAblue"="#0033AA","UAred"="#D9004C","Ube"="#8878C3","UCLABlue"="#536895","UCLAGold"="#FFB300","UFOGreen"="#3CD070","Ultramarine"="#120A8F","Ultramarineblue"="#4166F5","Ultrapink"="#FF6FFF","Umber"="#635147","UnitedNationsblue"="#5B92E5","UniversityofCaliforniaGold"="#B78727","UnmellowYellow"="#FFFF66","UPMaroon"="#7B1113","Upsdellred"="#AE2029","Urobilin"="#E1AD21","UtahCrimson"="#D3003F","Vegasgold"="#C5B358","Venetianred"="#C80815","Verdigris"="#43B3AE","Veronica"="#A020F0","Violet"="#7F00FF","Viridian"="#40826D","Vividauburn"="#922724","Vividburgundy"="#9F1D35","Vividcerise"="#DA1D81","Vividtangerine"="#FFA089","Vividviolet"="#9F00FF","Warmblack"="#004242","Wenge"="#645452","Wheat"="#F5DEB3","White"="#FFFFFF","Whitesmoke"="#F5F5F5","Wildblueyonder"="#A2ADD0","WildStrawberry"="#FF43A4","WildWatermelon"="#FC6C85","Wine"="#722F37","Wisteria"="#C9A0DC","Xanadu"="#738678","YaleBlue"="#0F4D92","Yellow"="#FFFF00","Yellowgreen"="#9ACD32","YellowOrange"="#FFEF02","Zaffre"="#0014A8","Zinnwalditebrown"="#2C1608")
################################# Read in Data ####################################################
## REQUIRED INPUTS ##
# 1) listfile (filename)
#listfile <- "EGFR_list.txt"
# 2) Prey File (filename)
#preyfile <- "EGFR_prey.txt"
# 3) crapome File (filename or FALSE)
#crapfile <- "EGFR_crap.txt"
# 4) Inter File (filename)
#interfile <- "inter.txt"
# 5) X axis ("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAFScore")
#input.main.x <- "ln(NSAF)"
# 6) Y axis ("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAFScore")
#input.main.y <- "log2(FoldChange)"
# 7) Bubble Size ("ln(NSAF)","SpecSum", "log2(FoldChange)", "SaintScore", "logOddsScore","NSAFScore")
#input.main.size <- "SpecSum"
# 8) Coloring ("fixed" or "crapome")
#input.main.color <- "crapome"
# 9) Saint Score Cutoff (0 - 1)
#input.SS_cutoff <- 0.8
# 10) Fold change Cutoff (-inf - inf)
#input.FC_cutoff <- 0
# 11) NSAF Score Cutoff (-inf - inf)
#input.NS_cutoff <- 0
# 12) Plotting Theme ("Default","b/w","minimal","classic","dark","linedraw")
#input.plot_theme <- "Default"
# 13) Bubble Labels ("none",">cutoff","all")
#input.bubble_label <- ">cutoff"
# 14) Label Color ("white","black")
#input.label_color <- "black"
# 15) Bubble Color (colors listed above)
#input.bubble_color <- colors[["Alizarin crimson"]]
# 16) Bubble outline color ("white","black")
#input.outline_color <- "black"
# 17) CRAPome Filtered Bubble Color (colors listed above)
#input.filt_color <- colors[["Tan"]]
# 18) Bubble scale ((0-100),(0-100))  # SECOND NUMBER MUST BE LARGER THAN OR EQUAL TO THE FIRST
#input.plot_scale <- c(0,10)
# 19) File Type (".pdf",".png",".tif",".svg",".eps",".jpg")
#input.file_type <- ".png"

################################################################################
# Define merge function and calculate crapome %
merge_files <- function(SAINT_DF, prey_DF, crapome=FALSE) {
  SAINT <- read.table(SAINT_DF, sep='\t', header=TRUE)
  prey <- read.table(prey_DF, sep='\t', header=FALSE); colnames(prey) <- c("Prey", "Length", "PreyGene")
  DF <- merge(SAINT,prey)
  
  if(crapome!=FALSE) {
    crapome <- read.table(crapome, sep='\t', header=TRUE)
    colnames(crapome) <- c("Prey", "Symbol", "Num.of.Exp", "Ave.SC", "Max.SC")
    DF1 <- merge(DF, crapome); as.character(DF1$Num.of.Exp); DF1$Symbol <- NULL;
    DF1$Ave.SC <- NULL; DF1$Max.SC <- NULL #remove unnecessary columns
    DF1$Num.of.Exp <- sub("^$", "0 / 1", DF1$Num.of.Exp ) #replace blank values with 0 / 1
    DF <- DF1 %>% separate(Num.of.Exp, c("NumExp", "TotalExp"), " / ") #split into 2 columns
    DF$CrapomePCT <- round(100 - (as.integer(DF$NumExp) / as.integer(DF$TotalExp) * 100), digits=2) #calculate crapome %
    
  }
  DF$FoldChange <- round(log2(DF$FoldChange),digits=2)
  colnames(DF)[(colnames(DF)=="FoldChange")] <- "log2(FoldChange)"
  
  DF$SAF <- DF$AvgSpec / DF$Length
  by_bait <-  DF %>% group_by(Bait) %>% mutate("NSAF" = SAF/sum(SAF))
  by_bait$SAF <- NULL
  return(by_bait[!duplicated(by_bait),])
}
################################################################################
bubblebeam <- function(main.data,main.exclude,main.x,main.y,main.size,main.color,SS_cutoff,FC_cutoff,NS_cutoff,
                       plot_theme,bubble_label,label_color,bubble_color,
                       outline_color,filt_color,plot_scale, file_type){
  str_x=paste0(main.x)
  str_y=paste0(main.y)
  str_color=paste0(main.color)
  str_size=paste0(main.size)
  str_cutoff= paste0(SS_cutoff)
  str_label= bubble_label
  scl_size = plot_scale
  main.data2 <- main.data[!(main.data$PreyGene %in% main.exclude),]
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="log2(FoldChange)")] >= FC_cutoff)
  main.data2 <- subset(main.data2, main.data2[(colnames(main.data2)=="NSAFScore")] >= NS_cutoff)
  
  c <- subset(main.data2, SaintScore>=as.numeric(str_cutoff), select = c(str_x,str_y,"Bait","PreyGene",str_size))
  colnames(c) <- c("x","y","Bait","PreyGene","size")
  p <- ggplot(data=c, x=x, y=y,size=size)+ geom_point(data=c, aes(x=x, y=y,size=size), fill=bubble_color,color=outline_color,pch=21) + scale_size(range=scl_size)
  p <- p + labs(x=str_x, y=str_y, size=str_size) + scale_size(range=scl_size)
  if(length(levels(c$Bait) > 1)) {p <- p + facet_wrap(~Bait)}
  if(str_label== 'all' & length(c$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=c, aes(x=x,y=y,label=PreyGene),
                                                                                         segment.color="black",force=1, fontface='bold',
                                                                                         box.padding=unit(0.25,'lines'), 
                                                                                         point.padding=unit(0.25,'lines'),
                                                                                         max.iter=1e4, segment.size=0.5)}
  if(plot_theme== "classic") {p <- p + theme_classic()}
  if(plot_theme== "b/w") {p <- p + theme_bw()}
  if(plot_theme== "minimal") {p <- p + theme_minimal()}
  if(plot_theme== "dark") {p <- p + theme_dark()}
  if(plot_theme== "linedraw") {p <- p + theme_linedraw()}
  
  
  
  if(str_color=="crapome") {
    a <- subset(main.data2, CrapomePCT <80 & SaintScore >=as.numeric(str_cutoff), select = c(str_x,str_y,"Bait","PreyGene",str_size,"CrapomePCT"))
    b <- subset(main.data2, CrapomePCT >=80 & SaintScore >=as.numeric(str_cutoff), select = c(str_x,str_y,"Bait","PreyGene",str_size,"CrapomePCT"))
    colnames(a) <- c("x","y","Bait","PreyGene","size", "CrapomePCT")
    colnames(b) <- c("x","y","Bait","PreyGene","size","CrapomePCT")
    p <- ggplot(data=a, x=x, y=y,size=size) + geom_point(data=a,aes(x=x,y=y,size=size),fill=filt_color,pch=21,color=outline_color) +
      scale_size(range=scl_size)
    if(length(levels(a$Bait) > 1)) {p <- p + facet_wrap(~Bait)}
    if(str_label== "all" & length(a$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=a, aes(x=x,y=y,label=PreyGene),
                                                                                           segment.color=label_color,force=1, fontface='bold',
                                                                                           box.padding=unit(0.25,'lines'), 
                                                                                           point.padding=unit(0.25,'lines'),
                                                                                           color=label_color,
                                                                                           max.iter=1e4, segment.size=0.5)}
    
    p <- p + geom_point(data=b, aes(x=x, y=y, size=size, fill=CrapomePCT),color=outline_color,pch=21) + 
      scale_fill_gradient(limits=c(80, 100), low=filt_color, high=bubble_color) + 
      labs(colour="CRAPome Probability \nof Specific Interaction (%)", x=str_x, y=str_y,size=str_size)
    if(str_label== '>cutoff' & length(b$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=b, aes(x=x,y=y,label=PreyGene),
                                                                                               segment.color=label_color,force=1, fontface='bold',
                                                                                               box.padding=unit(0.25,'lines'), 
                                                                                               point.padding=unit(0.25,'lines'),
                                                                                               color=label_color,
                                                                                               max.iter=1e4, segment.size=0.5)}
    if(str_label== 'all' & length(b$x)>=1) {set.seed=42; p <- p + ggrepel::geom_text_repel(data=b, aes(x=x,y=y,label=PreyGene),
                                                                                           segment.color=label_color,force=1, fontface='bold',
                                                                                           box.padding=unit(0.25,'lines'), 
                                                                                           point.padding=unit(0.25,'lines'),
                                                                                           color=label_color,
                                                                                           max.iter=1e4, segment.size=0.5)}
    if(plot_theme== "classic") {p <- p + theme_classic()}
    if(plot_theme== "b/w") {p <- p + theme_bw()}
    if(plot_theme== "minimal") {p <- p + theme_minimal()}
    if(plot_theme== "dark") {p <- p + theme_dark()}
    if(plot_theme== "linedraw") {p <- p + theme_linedraw()}
  }
  p <- p + theme(axis.title.y = element_text(size=rel(1.5),face="bold"),
                 axis.title.x = element_text(size=rel(1.5),face="bold"),
                 axis.text.x = element_text(size=rel(1.5),face="bold"),
                 axis.text.y = element_text(size=rel(1.5),face="bold"),
                 strip.text.x = element_text(size=rel(1.5),face="bold"),
                 legend.text = element_text(face="bold"),
                 legend.title = element_text(face="bold"))
  if(file_type == ".png"){png(paste("BubbleGraph",file_type,sep="")); print(p); dev.off()}
  if(file_type == ".pdf"){pdf(paste("BubbleGraph",file_type,sep="")); print(p); dev.off()}
  if(file_type == ".tif"){tiff(paste("BubbleGraph",file_type,sep="")); print(p); dev.off()}
  if(file_type == ".jpg"){jpeg(paste("BubbleGraph",file_type,sep="")); print(p); dev.off()}
  if(file_type == ".svg"){svg(paste("BubbleGraph",file_type,sep="")); print(p); dev.off()}
  if(file_type == ".eps"){postscript(paste("BubbleGraph",file_type,sep="")); print(p); dev.off()}
}
################################################################################
args <- commandArgs(trailingOnly = TRUE)
working <- as.data.frame(merge_files(args[1], args[2], args[3]))
inter_df <- read.table(args[4], sep='\t', header=FALSE)
working$temp <- strsplit(as.character(working$ctrlCounts),"[|]")
cnt <- 0
for(i in working$temp){
  cnt <- cnt+1
  working$ctrl_mean[cnt] <- mean(as.numeric(unlist(i)))
  working$ctrl_number[cnt] <- length(i)}
working$ctrl_SAF <- working$ctrl_mean / working$Length
main.data <-  working %>% group_by(Bait) %>% mutate("control_NSAF" = ctrl_SAF/sum(ctrl_SAF))
ctrl_SAF_constant <- 1/mean(main.data$ctrl_SAF)
# add ctrl_SAF_constant to prevent dividing by 0
cnt <- 0
for(i in main.data$control_NSAF){
  cnt <- cnt + 1
  main.data$nsafScore[cnt] <- ((main.data$NSAF[cnt])+ctrl_SAF_constant)/((i/main.data$ctrl_number[cnt])+ctrl_SAF_constant)
}
main.data$NSAF <- log(main.data$NSAF)
main.data$nsafScore <- log(main.data$nsafScore)
main.data <- filter(main.data, NSAF > -Inf)
colnames(main.data)[colnames(main.data)=="NSAF"] <- "ln(NSAF)"
colnames(main.data)[colnames(main.data)=="nsafScore"] <- "NSAFScore"
main.data$SAF <- NULL; main.data$ctrl_SAF <- NULL
main.data$control_NSAF <- NULL; main.data$temp <- NULL
main.data$ctrl_mean <- NULL
################################################################################
if (args[7] == "fixed"){
	input.main.size <- "SpecSum"
	input.plot_scale <- c(2,2)
} else {
	input.main.size <- args[7]
	input.plot_scale <- c(0,10)
}
input.bubble_color <- colors[[args[15]]]
input.filt_color <- colors[[args[17]]]
bubblebeam(main.data = main.data, main.exclude = FALSE,main.x = args[5],
                 main.y = args[6],main.size = input.main.size,main.color = args[8],
                 SS_cutoff = args[9],FC_cutoff = args[10],
                 NS_cutoff = args[11], plot_theme = args[12],
                 bubble_label = args[13],label_color = args[14],
                 bubble_color = input.bubble_color, outline_color = args[16],
                 filt_color = input.filt_color, plot_scale = input.plot_scale, 
                 file_type = ".png")
################################################################################


