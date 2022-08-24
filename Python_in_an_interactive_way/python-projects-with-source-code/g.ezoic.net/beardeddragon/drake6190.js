if(typeof __ez!="undefined"){__ez.vf=__ez.vf||{};__ez.vf.storeURL="/detroitchicago/vpp.gif";__ez.vf.determineVideoPlayer=function(vid){if(vid instanceof HTMLVideoElement==false){return '';}
for(var i=0;i<__ez.vf.videoPlayers.length;i++){if(__ez.vf.videoPlayers[i].isOfType(vid)){return __ez.vf.videoPlayers[i].name;}}
return 'unknown';};__ez.vf.getBaseURL=function(){if(window.hasOwnProperty("ezIntType")&&window.ezIntType==="wp"){return "https://g.ezoic.net";}else{return window.location.protocol+"//"+document.location.hostname;}};__ez.vf.sendVideoPlayerPixel=function(player,vid_src){if(typeof _ezaq==='undefined'){return;}
let data={};data.url=_ezaq["url"];data.pageview_id=_ezaq["page_view_id"];data.template_id=_ezaq["template_id"];data.player_name=player;data.domain_id=_ezaq["domain_id"];data.media_src=vid_src;var img=new Image();img.src=__ez.vf.getBaseURL()+__ez.vf.storeURL+"?e="+encodeURIComponent(JSON.stringify([data]));};class EzVideoPlayerDeterminer{isOfType(vid){return false;}
constructor(name,typeCheckFunc){this.name=name;this.isOfType=typeCheckFunc;}}
__ez.vf.videoPlayers=[new EzVideoPlayerDeterminer("plyr",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return typeof v.plyr==="object";}),new EzVideoPlayerDeterminer("jwplayer",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.classList.contains("jw-video");}),new EzVideoPlayerDeterminer("jplayer",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.id.startsWith("jp_video_");}),new EzVideoPlayerDeterminer("vdo.ai",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.id.startsWith("vdo_ai_");}),new EzVideoPlayerDeterminer("mediaelement",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.parentElement.tagName==='MEDIAELEMENTWRAPPER';}),new EzVideoPlayerDeterminer("flowplayer",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.classList.contains("fp-engine");}),new EzVideoPlayerDeterminer("avantisvideo",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return typeof v.av_evtsadded==='boolean';}),new EzVideoPlayerDeterminer("ezoicvideo",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.id.startsWith("ez-video-");}),new EzVideoPlayerDeterminer("ezcnx-outstream",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.closest("cnx")!==null&&typeof __ez.cnxPlayer!=='undefined'&&__ez.cnxPlayer.getPlayerType()===cnx.configEnums.PlayerTypesEnum.OutStream;}),new EzVideoPlayerDeterminer("ezcnx-instream",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.closest("cnx")!==null&&typeof __ez.cnxPlayer!=='undefined'&&__ez.cnxPlayer.getPlayerType()===cnx.configEnums.PlayerTypesEnum.InStream;}),new EzVideoPlayerDeterminer("cnx",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.closest("cnx")!==null&&typeof __ez.cnxPlayer==='undefined';}),new EzVideoPlayerDeterminer("videojs",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.classList.contains("vjs-tech");}),new EzVideoPlayerDeterminer("primis",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.closest("[id^='primis_']")!==null;}),new EzVideoPlayerDeterminer("playwire",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.src.includes("playwire");}),new EzVideoPlayerDeterminer("ex.co",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.closest("[id^='exp_']")!==null;}),new EzVideoPlayerDeterminer("rumble",function(v){if(v instanceof HTMLVideoElement==false){return false;}
return v.closest("[class$='Rumble-cls']")!==null;}),];__ez.vf.findVideo=function(){let vids=document.getElementsByTagName("video");if(vids.length>0){let vidPlayer=__ez.vf.determineVideoPlayer(vids[0]);if(vidPlayer!=''){__ez.vf.sendVideoPlayerPixel(vidPlayer,vids[0].src);}}};setTimeout(__ez.vf.findVideo,3000);}