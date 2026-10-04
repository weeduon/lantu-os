"""Run with Debian's python3 and PyQt6 installed; no desktop session required."""
import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import patch

native_path = Path(__file__).resolve().parents[1] / 'native' / 'lantu-desktop.py'
from importlib.machinery import SourceFileLoader
spec = importlib.util.spec_from_loader('lantu_native', SourceFileLoader('lantu_native',str(native_path)))
native = importlib.util.module_from_spec(spec)
spec.loader.exec_module(native)

class BridgeContract(unittest.TestCase):
    def setUp(self):
        self.bridge = native.Bridge()

    def test_volume_bounds_do_not_spawn(self):
        with patch.object(native, 'run') as run:
            for value in [-1,101,2000000]:
                self.assertFalse(json.loads(self.bridge.setVolume(value))['ok'])
            run.assert_not_called()

    def test_audio_missing_returns_error(self):
        with patch.object(native, 'run', side_effect=OSError()):
            self.assertFalse(json.loads(self.bridge.setVolume(50))['ok'])
            self.assertFalse(json.loads(self.bridge.toggleMute())['ok'])
            state=json.loads(self.bridge.getStatus())
            self.assertIsNone(state['volume'])

    def test_settings_rejects_non_whitelisted_commands(self):
        with patch.object(native.subprocess, 'Popen') as popen:
            for value in ['terminal','network; reboot','../audio','']:
                self.assertFalse(json.loads(self.bridge.openSettings(value))['ok'])
            popen.assert_not_called()

    def test_browser_denies_privileged_schemes(self):
        with patch.object(native.QDesktopServices,'openUrl',return_value=True) as open_url:
            for value in ['file:///etc/passwd','javascript:alert(1)','data:text/html,test','https:///','lantu://desktop/index.html']:
                self.assertFalse(json.loads(self.bridge.openBrowser(value))['ok'])
            open_url.assert_not_called()
            self.assertTrue(json.loads(self.bridge.openBrowser('https://www.debian.org/'))['ok'])
            open_url.assert_called_once()

if __name__=='__main__':
    unittest.main(verbosity=2)
