WK_Characterizer_Perl
=====================

Creates [Characterizer](http://kanjilish.mozdev.org/) xml files from the [WaniKani](http://www.wanikani.com/) api.  
  
Instructions:  
- [Install the addon](https://addons.mozilla.org/en-US/firefox/addon/7208)  
- If you're on Windows, [install perl](http://strawberryperl.com/) *(I'm looking into ways to build an exe)*  
- Save characterizer.pl to your computer and open the folder it's in  
- Open a terminal or cmd window *(shift+right click, 'open a command window here')* and type `cpan -i Modern::Perl JSON LWP File::Slurp`  
- Now type [`perl characterizer.pl [your api key]`](http://www.wanikani.com/api)  
- `wanikani.xml` should have been created. Copy this to the kanjilish folder in your Firefox profile *(`%APPDATA%\Mozilla\Firefox\Profiles\[your profile]\extensions\kanjilish@jay.starkey\` in windows)*  
- Restart Firefox.
