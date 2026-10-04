#!/usr/bin/python3
"""A local-only desktop preview with a small, fixed Linux system bridge."""
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from PyQt6.QtCore import QObject,QUrl,QFile,QIODevice,pyqtSlot,QBuffer,QByteArray
from PyQt6.QtGui import QDesktopServices,QIcon
from PyQt6.QtWidgets import QApplication,QMainWindow
from PyQt6.QtWebChannel import QWebChannel
from PyQt6.QtWebEngineCore import QWebEnginePage,QWebEngineScript,QWebEngineUrlScheme,QWebEngineUrlSchemeHandler,QWebEngineUrlRequestJob,QWebEngineSettings
from PyQt6.QtWebEngineWidgets import QWebEngineView
import mimetypes

ASSETS=Path('/usr/share/lantu-desktop/web').resolve()
def run(args):
    return subprocess.run(args,capture_output=True,text=True,timeout=6,check=True).stdout.strip()
def response(ok=True,error=''):
    return json.dumps({'ok':ok,'error':error},ensure_ascii=False)

class Bridge(QObject):
    @pyqtSlot(result=str)
    def getStatus(self):
        state={'volume':None,'muted':False,'network':'未检测到活动连接','battery':None,'charging':False}
        try:
            text=run(['wpctl','get-volume','@DEFAULT_AUDIO_SINK@'])
            found=re.search(r'Volume:\s*([\d.]+)',text)
            if found:state['volume']=round(float(found.group(1))*100)
            state['muted']='MUTED' in text
        except (OSError,subprocess.SubprocessError):pass
        try:
            active=run(['nmcli','-t','-f','NAME,TYPE','connection','show','--active'])
            state['network']=active.replace('\\:',':').replace('\n',' · ') or state['network']
        except (OSError,subprocess.SubprocessError):pass
        for battery in Path('/sys/class/power_supply').glob('*'):
            try:
                if (battery/'type').read_text().strip()!='Battery':continue
                state['battery']=int((battery/'capacity').read_text().strip())
                state['charging']=(battery/'status').read_text().strip() in ('Charging','Full','Not charging')
                break
            except (OSError,ValueError):continue
        return json.dumps(state,ensure_ascii=False)
    @pyqtSlot(int,result=str)
    def setVolume(self,value):
        if not 0<=value<=100:return response(False,'音量范围为 0—100。')
        try:run(['wpctl','set-volume','@DEFAULT_AUDIO_SINK@',str(value)+'%']);return response()
        except (OSError,subprocess.SubprocessError):return response(False,'无法设置音量，请检查输出设备。')
    @pyqtSlot(result=str)
    def toggleMute(self):
        try:run(['wpctl','set-mute','@DEFAULT_AUDIO_SINK@','toggle']);return response()
        except (OSError,subprocess.SubprocessError):return response(False,'无法切换静音，请检查输出设备。')
    @pyqtSlot(str,result=str)
    def openSettings(self,section):
        modules={'audio':'kcm_pulseaudio','network':'kcm_networkmanagement','power':'kcm_powerdevilprofilesconfig'}
        if section not in modules:return response(False,'未知设置项。')
        try:subprocess.Popen(['systemsettings',modules[section]],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL);return response()
        except OSError:return response(False,'无法打开系统设置。')
    @pyqtSlot(str,result=str)
    def openBrowser(self,url):
        parsed=QUrl(url)
        if parsed.scheme() not in ('http','https') or not parsed.host():return response(False,'只允许打开 HTTP 或 HTTPS 网页。')
        return response(QDesktopServices.openUrl(parsed),'浏览器启动失败。')

class Assets(QWebEngineUrlSchemeHandler):
    def requestStarted(self,request):
        if request.requestUrl().host()!='desktop':request.fail(QWebEngineUrlRequestJob.Error.UrlNotFound);return
        target=(ASSETS/request.requestUrl().path().lstrip('/')).resolve()
        if not target.is_relative_to(ASSETS) or not target.is_file():request.fail(QWebEngineUrlRequestJob.Error.UrlNotFound);return
        file=QFile(str(target),request)
        if not file.open(QIODevice.OpenModeFlag.ReadOnly):request.fail(QWebEngineUrlRequestJob.Error.RequestFailed);return
        mime=mimetypes.guess_type(str(target))[0] or 'application/octet-stream'
        request.reply(mime.encode(),file)

class LocalPage(QWebEnginePage):
    def acceptNavigationRequest(self,url,kind,main):
        return url.scheme()=='lantu' and url.host()=='desktop'

def main():
    scheme=QWebEngineUrlScheme(b'lantu')
    scheme.setSyntax(QWebEngineUrlScheme.Syntax.HostAndPort)
    scheme.setDefaultPort(443)
    scheme.setFlags(QWebEngineUrlScheme.Flag.SecureScheme|QWebEngineUrlScheme.Flag.CorsEnabled|QWebEngineUrlScheme.Flag.LocalScheme)
    QWebEngineUrlScheme.registerScheme(scheme)
    app=QApplication(sys.argv);app.setApplicationName('澜图 OS')
    app.setDesktopFileName('lantu-desktop')
    app.setWindowIcon(QIcon('/usr/share/pixmaps/lantu-os.png'))
    window=QMainWindow();window.setWindowTitle('澜图 OS · 中文 AI 工作台')
    view=QWebEngineView(window);page=LocalPage(view);view.setPage(page)
    handler=Assets(page);page.profile().installUrlSchemeHandler(b'lantu',handler)
    page.settings().setAttribute(QWebEngineSettings.WebAttribute.LocalContentCanAccessRemoteUrls,False)
    channel=QWebChannel(page);bridge=Bridge(channel);channel.registerObject('desktop',bridge);page.setWebChannel(channel)
    library=QFile(':/qtwebchannel/qwebchannel.js');library.open(QIODevice.OpenModeFlag.ReadOnly)
    script=QWebEngineScript();script.setName('desktop-bridge');script.setInjectionPoint(QWebEngineScript.InjectionPoint.DocumentReady);script.setWorldId(QWebEngineScript.ScriptWorldId.MainWorld);script.setRunsOnSubFrames(False)
    script.setSourceCode(bytes(library.readAll()).decode()+"\nnew QWebChannel(qt.webChannelTransport,function(c){window.desktopBridge=c.objects.desktop;window.dispatchEvent(new Event('desktop-bridge-ready'));});")
    page.scripts().insert(script);window.setCentralWidget(view);window.resize(1440,960)
    view.setUrl(QUrl('lantu://desktop/index.html'));window.showMaximized();sys.exit(app.exec())
if __name__=='__main__':main()
