#include "include/ton/ton_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ton_plugin.h"

void TonPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ton::TonPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
