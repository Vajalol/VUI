# VUI

<p style="text-align: left;"><span style="font-family: tahoma, arial, helvetica, sans-serif; font-size: 24px;">Features</span></p>
<ul>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">Comprehensive World of Warcraft UI Enhancement Suite</span></li>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">Intuitive and powerful configuration menu</span></li>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">Modular architecture with intelligent module loading</span></li>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">Advanced performance optimization with adaptive caching</span></li>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">Comprehensive configuration and profile management</span></li>
</ul>
<p>&nbsp;</p>
<p><span style="font-family: tahoma, arial, helvetica, sans-serif; font-size: 24px;">Quick Start</span></p>
<ul>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">To open the configuration menu, type <span style="font-family: terminal, monaco, monospace;">/VUI</span>&nbsp;into your chat and hit enter&nbsp;</span></li>
</ul>
<p><span style="font-family: tahoma, arial, helvetica, sans-serif;">&nbsp;</span></p>
<p><span style="font-family: tahoma, arial, helvetica, sans-serif; font-size: 24px;">Issues</span></p>
<ul>
<li><span style="font-family: tahoma, arial, helvetica, sans-serif;">If you've discovered something that's clearly wrong, or if you get an error,&nbsp;<a href="https://github.com/Vajalol/VUI/issues/new/choose" target="_blank" rel="noopener noreferrer">post&nbsp;an&nbsp;Issue</a>.</span></li>
</ul>
<p><span style="font-family: tahoma, arial, helvetica, sans-serif;">&nbsp;</span></p>

## Add Custom Fonts and Textures to VUI

Open: `World of Warcraft/_retail_/Interface/AddOns/VUI/Media/`

Add your Texture file to: `Textures/`
Add your Font file to `Fonts/`

Edit File `Media\RegisterMediaLSM.lua`

**Adding Texture**

    LSM:Register("statusbar",  "YourTextureName",  [[Interface\Addons\VUI\Media\Textures\Status\YourTextureName.blp]])

**Adding Font**

    LSM:Register("font",  "YourFontName",  [[Interface\Addons\VUI\Media\Textures\Fonts\YourFontName.blp]])

## Acknowledgments

VUI is based on the SUI addon framework created by Syiana. We extend our gratitude to the original authors for their work, which serves as the foundation for VUI.
