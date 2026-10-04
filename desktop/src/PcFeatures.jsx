import React, {useEffect,useState} from 'react';
import {Globe,SpeakerHigh,SpeakerSlash,WifiHigh,BatteryFull,ArrowSquareOut,Monitor,Plug,ArrowClockwise} from '@phosphor-icons/react';

const offline={native:false,volume:60,muted:false,network:'浏览器预览无法读取系统连接',battery:null,charging:false};
export function usePcStatus(){
 const [status,setStatus]=useState(offline);
 const refresh=()=>{if(window.desktopBridge)window.desktopBridge.getStatus(raw=>{try{setStatus({...JSON.parse(raw),native:true});}catch{}});};
 useEffect(()=>{refresh();window.addEventListener('desktop-bridge-ready',refresh);const timer=setInterval(refresh,5000);return()=>{clearInterval(timer);window.removeEventListener('desktop-bridge-ready',refresh);};},[]);
 return [status,setStatus,refresh];
}
export function PcFeatures({page,status,setStatus,refresh,notify}){
 const [url,setUrl]=useState('https://www.baidu.com');
 function systemSettings(section){if(window.desktopBridge)window.desktopBridge.openSettings(section,raw=>{const result=JSON.parse(raw);if(!result.ok)notify(result.error);});else notify('浏览器中为界面预览；安装镜像内将打开 KDE 原生设置。');}
 function browse(e){e.preventDefault();let target;try{target=new URL(/^https?:\/\//i.test(url)?url:'https://'+url);if(!['http:','https:'].includes(target.protocol)||!target.hostname)throw Error();}catch{notify('请输入有效的 http 或 https 网址。');return;}if(window.desktopBridge)window.desktopBridge.openBrowser(target.href,raw=>{const r=JSON.parse(raw);if(!r.ok)notify(r.error);});else window.open(target.href,'_blank','noopener,noreferrer');}
 function volume(value){const amount=Math.max(0,Math.min(100,Number(value)));if(window.desktopBridge)window.desktopBridge.setVolume(amount,raw=>{const r=JSON.parse(raw);if(!r.ok)notify(r.error);refresh();});else setStatus(p=>({...p,volume:amount}));}
 function mute(){if(window.desktopBridge)window.desktopBridge.toggleMute(raw=>{const r=JSON.parse(raw);if(!r.ok)notify(r.error);refresh();});else setStatus(p=>({...p,muted:!p.muted}));}
 return <div className="pc-features">
 {page==='browser'?<><div className="pc-hero"><Globe size={40} weight="duotone"/><h3>浏览网页，从这里开始</h3><p>{status.native?'使用已安装的 Firefox 浏览器打开网页。':'使用当前浏览器的新标签页打开网页。'}</p></div><form className="browser-address" onSubmit={browse}><label htmlFor="browser-url">网址</label><div><input id="browser-url" value={url} onChange={e=>setUrl(e.target.value)} autoComplete="url" spellCheck="false"/><button className="primary-button" type="submit">打开网页 <ArrowSquareOut size={17}/></button></div></form><div className="browser-shortcuts">{[['百度','https://www.baidu.com'],['Debian','https://www.debian.org/index.zh-cn.html'],['KDE','https://kde.org/zh-cn/']].map(([name,value])=><button key={name} className="secondary-button" onClick={()=>setUrl(value)}>{name}</button>)}</div></>:<>
 <div className="notice"><Monitor size={18}/>{status.native?'已连接 Linux 系统。状态来自当前设备，设置使用当前登录账户的权限。':'浏览器界面预览。音量数值仅用于演示；实际网络、电源和音量控制在 Linux 镜像中启用。'}</div>
 {page==='audio'&&<><div className="settings-row"><strong>输出音量</strong><span>{status.volume===null?'未检测到音频设备':status.volume+'%'}</span></div><label className="volume-control"><SpeakerHigh size={24}/><input aria-label="输出音量" type="range" min="0" max="100" disabled={status.native&&status.volume===null} value={status.volume??0} onChange={e=>volume(e.target.value)}/><button className="secondary-button" onClick={mute}>{status.muted?<SpeakerSlash size={18}/>:<SpeakerHigh size={18}/>} {status.muted?'取消静音':'静音'}</button></label><p className="small-note">支持调节系统默认输出设备；麦克风、输出切换与应用音量在声音设置中管理。</p><button className="primary-button" onClick={()=>systemSettings('audio')}>打开声音设置</button></>}
 {page==='network'&&<><div className="settings-row"><span><strong>当前网络</strong><small>{status.network}</small></span><WifiHigh size={28}/></div><p>在系统网络设置中连接 Wi-Fi、管理有线连接、配置代理或 VPN。</p><p className="small-note">网络名称与密码由系统的 NetworkManager 管理，本应用不保存 Wi-Fi 密码。</p><button className="primary-button" onClick={()=>systemSettings('network')}>打开网络设置</button></>}
 {page==='power'&&<><div className="pc-hero"><BatteryFull size={48} weight="duotone"/><h3>{status.battery!==null?status.battery+'%':status.native?'此设备未检测到电池':'电池状态不可用'}</h3><p>{status.battery!==null?(status.charging?'正在充电／已接通电源':'正在使用电池'):status.native?'台式机或虚拟机可能没有电池设备。':'浏览器预览不提供虚构的电池电量。'}</p></div><button className="primary-button" onClick={()=>systemSettings('power')}>打开电源与休眠设置</button></>}
 <button className="text-button" onClick={refresh}><ArrowClockwise size={15}/>刷新设备状态</button>
 </>}
 </div>;
}
